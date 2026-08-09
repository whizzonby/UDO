# Udo Admin Operations Runbook

This is the operational reference for the Filament admin panel built out in
`docs/ADMIN_OPERATIONS_BUILD_QUEUE.md` (ADM-01 through ADM-23). It covers how
to bootstrap staff access, what each role can actually do, how to use the
operational consoles, what to do when something breaks, and what to check
before and after a release touches the admin panel.

For general product release steps (CI gates, environment variables,
deployment order, rollback), see `docs/RELEASE_READINESS.md`. This document
only covers what is specific to `/admin`.

## 1. Admin Bootstrap

The admin panel lives at `/admin` on the API host and uses Filament's
built-in session login (`->login()` in `AdminPanelProvider`) — there is no
separate admin app to deploy.

**Creating the first admin user** (or promoting an existing one):

```bash
php artisan admin:ensure ops@example.com \
  --name="Ops Admin" \
  --role=super_admin
```

This command:

- Seeds `RolesSeeder` first (safe to run repeatedly — it uses
  `firstOrCreate`/`syncPermissions`, not raw inserts), so the six staff
  roles and their `admin.*` permissions always exist before it assigns one.
- Creates the user if the email doesn't exist yet, or promotes an existing
  user by assigning the role.
- Marks the user's email as verified and onboarding-complete (required for
  `canAccessPanel()` — see below — and to avoid the app's onboarding
  redirect intercepting a staff login).
- Prints a temporary password if you didn't pass `--password`. Rotate it on
  first login.

Available options: `--name=`, `--password=`, `--role=` (defaults to
`super_admin`), `--force-password` (rotate the password on an existing
user).

**Panel access gate.** `App\Models\User::canAccessPanel()` only lets in
users holding one of the six staff roles below — a normal wedding-owner
account can never reach `/admin`, regardless of permissions.

## 2. Roles and Permissions

Two layers of authorization apply, both introduced across ADM-02 and
ADM-23:

1. **Door gate** — `canAccessPanel()`: any of the six roles below gets past
   login. Everyone else gets a 403 on `/admin`.
2. **Room gate** — `App\Filament\Concerns\HasDomainPermission`: every
   resource and the two custom console pages declare a single
   `$requiredPermission` (e.g. `admin.finance`). A staff member who is in
   the panel but lacks that permission gets a 403 on that specific
   resource — the sidebar link simply won't appear for them either.

| Role | Permissions | Practical access |
| --- | --- | --- |
| `super_admin` | all seven (`admin.access`, `.users`, `.weddings`, `.operations`, `.finance`, `.support`, `.content`) | everything |
| `admin` | same as `super_admin` | everything |
| `ops_admin` | `.access`, `.weddings`, `.operations`, `.support` | Platform weddings/guests, all Operations-group resources, Live Command Center, Reliability Console, support tickets — **not** user records, billing, or content |
| `support_admin` | `.access`, `.users`, `.weddings`, `.support` | User 360, weddings, support tickets — **not** operations, finance, or content |
| `finance_admin` | `.access`, `.users`, `.finance`, `.support` | Users, subscriptions, registry contributions, thank-yous, support tickets — **not** operations or content |
| `content_admin` | `.access`, `.content` | Blog, testimonials, FAQs, email templates only — **not** users, weddings, operations, or finance |

**Assigning or changing a role:**

- From the command line: `php artisan admin:ensure <email> --role=<role> --force-password` (safe to rerun; it promotes rather than duplicates).
- From the panel: once a `super_admin` exists, edit the target user in
  User 360 (`/admin/users`) — the "Roles" multi-select on the Account
  section calls the same underlying Spatie role assignment.

**Adding a new resource later:** every new `Resource` or console `Page`
must `use HasDomainPermission;` and declare
`protected static string $requiredPermission = 'admin.xxx';` matching its
nav group, or it will silently inherit Filament's permissive default (no
policy = allowed) and bypass role boundaries entirely. Grep for
`HasDomainPermission` in `app/Filament` to see the existing pattern before
adding a resource.

## 3. Panel Map

Nav groups, in sidebar order, with the resources/pages in each and their
required permission:

- **Platform** (`admin.users` / `admin.weddings`) — Users, Weddings, Guests, Wedding Collaborators.
- **Operations** (`admin.operations`) — Live Command Center, Invitation Campaigns, Messages, Message Deliveries, Guest Experience, Guest Tokens, Vendors, Tasks, Gallery, Live Updates, Smart Alerts, Budget Items, Budget Payment Schedules, Timeline, Audit Log Center, Saved Filters, Reliability Console, Failed Jobs, Idempotency Keys.
- **Logistics** (`admin.operations`) — Seating, Accommodation, Transport.
- **Finance & Support** (`admin.finance` / `admin.support`) — Subscriptions, Registry Contributions, Thank-Yous, Support Tickets.
- **Content** (`admin.content`) — Blog Posts, Testimonials, FAQs, Email Templates.

Route slugs follow `/admin/<resource>` using the plural-kebab form (e.g.
`/admin/support-tickets`, `/admin/failed-jobs`). Run
`php artisan route:list --path=admin` for the exact current list.

## 4. Operational Consoles

These are the purpose-built pages (as opposed to plain CRUD resources)
built for day-to-day ops work:

**Live Command Center** (`/admin/live-command-center`, `admin.operations`,
ADM-17) — the primary screen during an active wedding weekend:

- *Live, final-week and upcoming weddings* — weddings that are `live`,
  `final_week`, or `planning` with an event date inside 7 days. Guarded
  **Start live** / **Mark final week** row actions call
  `AdminLiveOpsService`, which audits the transition.
- *Unresolved incidents and actions* — open `LiveUpdate` rows of type
  `incident`/`alert` or flagged `requires_action`, across live/final-week
  weddings, sorted by severity. **Resolve** is audited.
- *VIP readiness gaps* — VIP guests at live/final-week weddings missing
  seating or (if travelling) arrival/accommodation/transport info.

**Reliability Console** (`/admin/reliability-console`, `admin.operations`,
ADM-21) — platform health at a glance:

- Stats: platform health score/status, failed job count, pending job
  count, active idempotency keys, token expiry risk, cache driver — all
  sourced from `OperationalHealthService::snapshot()`.
- *Stale sending messages* — messages stuck in `sending` for 15+ minutes.
- *Token expiry risk* — active guest tokens expired or expiring within 7
  days.

**Audit Log Center** (`/admin/audit-logs`, `admin.operations`, ADM-05) —
read-only, searchable log of every audited admin action (who, what,
before/after, IP, metadata). This is the source of truth for "who did
this" questions; every `Admin*OpsService` method writes here.

**Smart Alert Center** (`/admin/smart-alerts`, `admin.operations`, ADM-06)
— generated per-wedding risk alerts (RSVP deadlines, logistics gaps,
vendor payments due, etc.), with a guarded resolve action and a
refresh-all action.

## 5. Incident Playbooks

**A wedding's messages are stuck "sending."**
1. Reliability Console → *Stale sending messages* to confirm and identify
   the wedding/message.
2. Open Message Deliveries (`/admin/guest-message-deliveries`) for
   per-recipient status — the sidebar badge shows the current failed count;
   use the Status filter to narrow the table to `Failed`.
3. Use the **Retry** action on individual failed rows to requeue just that
   delivery (guarded, dispatches the existing delivery job).
4. If the underlying job is in `failed_jobs`, see the next playbook.

**Queue jobs are failing.**
1. Reliability Console → Failed Jobs stat, or go straight to
   `/admin/failed-jobs`.
2. Open the job to read the exception and payload.
3. If the cause is transient (timeout, provider hiccup), use **Retry** —
   this pushes it back onto the queue via Laravel's real `queue:retry` and
   removes the row on success.
4. If the cause is a bad payload or a bug that will just fail again, use
   **Delete** to discard it rather than let it retry forever. Both actions
   are audited (`admin.failed_job_retried` / `admin.failed_job_forgotten`).

**A wedding is going live and something's wrong.**
1. Live Command Center → confirm the wedding shows as `live` (use **Start
   live** if it hasn't transitioned yet).
2. Check *Unresolved incidents and actions* for anything flagged against
   that wedding; resolve what's actually handled.
3. Check *VIP readiness gaps* for last-minute logistics holes.
4. For anything guest-facing, post a `LiveUpdate` (Live Updates resource)
   with the right `type`/`severity`/`audience` so the couple's app reflects
   it.

**A guest token needs revoking** (lost device, wrong recipient, security
concern).
1. Guest Tokens (`/admin/guest-tokens`) → find the token by guest or
   wedding.
2. **Revoke** (guarded, confirmation required). A replacement token can be
   issued directly from this resource's **Create** page if the guest needs
   a new link immediately, rather than waiting on the couple to re-send an
   invite from their own app.

**A user requests account deletion or data export** (privacy/GDPR-style
request).
1. User 360 (`/admin/users`) → open the user.
2. Use **Export privacy data**, **Revoke API tokens**, or **Anonymize
   account** as appropriate. Anonymize requires typing a confirmation
   phrase — this is intentionally hard to trigger by accident. All three
   are audited on the user's Audit Evidence tab.

**Suspicious admin activity, or "who changed this?"**
1. Audit Log Center (`/admin/audit-logs`) → filter by actor, wedding,
   record type, or date range.
2. Every guarded action across the panel writes an entry here with
   before/after state — this is the first place to look, not the raw
   database.

**Support ticket needs escalation or triage.**
1. Support Tickets (`/admin/support-tickets`).
2. **Assign to me** claims it (moves `open` → `in_progress`, sets
   `first_responded_at`). **Resolve** closes it out (sets `resolved_at`).
   Both audited. The ticket's Account Context panel shows the reporter's
   plan, active wedding, and other open tickets without leaving the page.

## 6. Smoke Checks

Run these after any deploy that touches `app/Filament`, the roles/
permissions seeder, or migrations affecting admin-only tables
(`audit_logs`, `smart_alerts`, `saved_filters`, `idempotency_keys`,
`failed_jobs`, `support_tickets.wedding_id`).

1. **Migrations and roles applied.** `php artisan migrate --force` then
   `php artisan db:seed --class=RolesSeeder --force` (idempotent — safe on
   every deploy). Skipping the seeder after a fresh migration means the
   `admin.*` permissions don't exist yet, which locks *every* role
   — including `super_admin` — out of every resource. This is the single
   most important step in this checklist.
2. **Login works.** Log in at `/admin` as a `super_admin`.
3. **Dashboard renders.** Confirm the stat widgets load (Platform health,
   Delivery issues, Guest token risk, Live operations, Support load) and
   the sidebar shows all five nav groups.
4. **Role boundary spot check.** Log in as (or `admin:ensure`-promote) one
   non-`super_admin` role, e.g. `content_admin`, and confirm it can reach
   `/admin/blog-posts` but gets a 403 on `/admin/users`.
5. **Live Command Center and Reliability Console load** without errors —
   these are custom pages, not plain CRUD, so they're the most likely to
   break silently on a Filament version bump.
6. **One guarded action produces an audit entry.** E.g. resolve a Smart
   Alert or a Live Update, then confirm the corresponding row appears in
   Audit Log Center.
7. **Full backend suite.** `php artisan test` from `apps/api` (Herd PHP
   8.3) — the admin-relevant coverage is concentrated in
   `tests/Feature/WeddingFlowBugFixTest.php`.

## 7. Deployment Notes

`docs/RELEASE_READINESS.md`'s deployment order includes
`php artisan db:seed --class=RolesSeeder --force` right after
`migrate --force`, for exactly this reason: before ADM-23, staff roles
without correctly seeded `admin.*` permissions still had full panel access
because nothing checked permissions. Now, a deploy that migrates but never
seeds roles locks every staff member out of every resource until the
seeder runs. The command is idempotent and safe on every deploy, not just
the first one — don't remove it from the deployment order.
