# Udo Execution Queue

This is the working queue for turning Udo into a real production wedding operating system. Use the queue IDs in chat, commits, PRs, and bug reports, for example `UDO-Q04`.

## Execution Rules

- Work one queue item at a time.
- Do not start the next queue item until the current item meets its acceptance gates.
- Every feature must include backend persistence when the data matters.
- Every feature must connect across the correct surfaces: Laravel API, Flutter admin app, and Next.js guest/admin web where relevant.
- No dead controls: every button, card, filter, and CTA must navigate, save, open a panel, trigger an action, or visibly update state.
- Completion means: implemented, typed, wired into UI, covered by focused tests where tooling allows, and documented in this queue.
- If local tooling is blocked, record the blocker clearly and continue only when the code has passed every available check.

## Reference Status

| Status | Meaning |
|---|---|
| `done` | Implemented and verified as far as the local toolchain allows. |
| `active` | The current item being completed. |
| `queued` | Not started yet. |
| `blocked` | Requires missing credentials, services, tooling, or a product decision. |

## Completed Foundation

| ID | Status | Feature | Notes |
|---|---:|---|---|
| UDO-D01 | done | Guest RSVP correctness | RSVP yes/no counts, decline flow, and guest invite URL fixes. |
| UDO-D02 | done | Guest portal uploads | Guest photo upload path and portal data fixes. |
| UDO-D03 | done | Messaging delivery foundation | Email/SMS/WhatsApp delivery services, jobs, retry paths, webhooks, opt-outs, and analytics endpoints. |
| UDO-D04 | done | Role and team access | Wedding roles, team management endpoints, wedding switching, and module permission enforcement. |
| UDO-D05 | done | Subscription entitlements | Billing entitlement payloads and guest/team limit enforcement. |
| UDO-D06 | done | Audit trail | Audit log persistence, endpoints, and key wedding/team/guest actions. |
| UDO-D07 | done | Account operations UI | Web and mobile More screens show real account, billing, team, audit, workspace, wedding settings, and profile controls. |
| UDO-D08 | done | Account preferences persistence | User notification and support preferences persist through API, web, and mobile. |

## Production Queue

| ID | Status | Feature | Outcome |
|---|---:|---|---|
| UDO-Q01 | done | Runtime and migration readiness | Added `docs/LOCAL_VERIFICATION.md`, captured setup commands, migration requirements, and current PHP/Flutter blockers. |
| UDO-Q02 | done | Guest Experience Builder | Added publish state, layout order, access rules, theme/content settings, config-driven guest portal payloads, web builder wiring, guest rendering, and regression tests. |
| UDO-Q03 | done | Invitation Campaigns | Added campaign metadata, invitation campaign API, audience previews, scheduled/send-now delivery, guest-token template rendering, web/mobile campaign composers, recent results, and regression tests. |
| UDO-Q04 | done | Logistics Hub | Added logistics summary, accommodation assignment, transport assignment/count integrity, capacity/cross-wedding safeguards, guest-facing logistics payloads, web/mobile summary wiring, and regression tests. |
| UDO-Q05 | done | Seating Planner | Added seating summary, table/seat creation, assignment integrity, capacity safeguards, guest-facing seating payloads, web seating board wiring, mobile seating summary/table controls, and regression tests. |
| UDO-Q06 | done | Live Mode Operations | Added operational live-update fields, incident severity/status, resolve action, Today command-center status, arrival readiness, VIP attention signals, real web/mobile live cards, guest feed compatibility, and regression tests. |
| UDO-Q07 | done | Home Command Center | Added real dashboard command-center aggregation for planning health, RSVP health, budget status, guest issues, upcoming actions, and live readiness, plus web/mobile command-center cards and regression tests. |
| UDO-Q08 | done | Registry and Thank-you Tracking | Added registry summary, contribution creation, guest portal contributions, cash-fund/item total tracking, pending/completed thank-you records, web/mobile thank-you controls, and regression tests. |
| UDO-Q09 | done | Gallery Moderation and Memories | Added gallery summary, enriched guest uploader attribution, approve/reject/feature/archive actions, real guest upload moderation, saved/featured/archive collections, web/mobile curation controls, and regression tests. |
| UDO-Q10 | done | Vendor CRM | Added vendor CRM summary, persistent contact logs, vendor-linked tasks, day-of contact sheet, web/mobile CRM dashboards, real add-vendor save, and regression tests. |
| UDO-Q11 | done | Budget and Payments Depth | Added payment schedule persistence, enriched budget summary/category analytics, due and overdue payment reminders, mark-paid rollups, real web add-expense save, mobile payment schedule visibility, and regression tests. |
| UDO-Q12 | done | Smart Alerts and Automations | Added persistent smart alerts, generated event-driven alert refresh for RSVP deadlines, logistics gaps, vendor payments, guest readiness, and post-wedding thank-yous, dashboard/API exposure, web/mobile alert panels, resolve action, and regression tests. |
| UDO-Q13 | done | Search, Filtering, and Bulk Actions | Added saved filters, server-side guest/vendor/task search and filtering, guarded bulk updates, CSV exports, web guest/task/vendor search and bulk controls, mobile guest/task/vendor filtering and bulk actions, and regression coverage. |
| UDO-Q14 | done | Reliability and Scale | Added replay-safe idempotency keys for mutating API requests, guest portal throttles, default guest-token expiry, cached operational health snapshots, dashboard/API health exposure, web/mobile platform-health cards, and regression coverage. |
| UDO-Q15 | done | Internal Ops Panel | Added admin-only internal ops API, account/wedding lookup, health and delivery diagnostics, guarded entitlement overrides with support notes, admin auth payload flags, web More-page ops panel, and regression coverage. |
| UDO-Q16 | done | Mobile Polish and Offline Resilience | Added shared cached API reads, last-good-data fallback, explicit offline/stale banners with retry actions, and preserved critical Home, Guests, Live, and Plan views when network refresh fails; Dart/Flutter tooling remains blocked by local command timeouts. |
| UDO-Q17 | done | Web UX Completion Pass | Completed Gallery and Registry production UX pass: added loading/error/notice states, wired copy/share/external-link actions, replaced fake upload/contribution flows with honest actionable states, removed placeholder archive/saved grids, and verified targeted web type/lint gates. |
| UDO-Q18 | done | Security and Privacy Pass | Added account privacy export, all-session token revocation, password/OAuth-aware account deletion with profile anonymization, regression tests for export/revoke/delete, and redacted geocoding/social-auth failure logging; PHP test execution remains blocked locally because `php` is not on PATH. |
| UDO-Q19 | done | CI/CD and Release Readiness | Added repo-level GitHub Actions for Laravel, Next.js, and Flutter gates; documented CI commands in local verification; added release environment, deployment, smoke-test, rollback, and release-record checklist. Web typecheck/lint/build and diff checks pass locally; PHP and Flutter remain blocked by local toolchain issues. |
| UDO-Q20 | done | Monetization and Plan Packaging | Added plan catalog definitions with prices, feature copy, limits, recommended/current markers, optional Stripe price IDs, owner-only local upgrade/downgrade endpoint with usage-fit checks, regression coverage, and web subscription plan cards wired to real billing APIs. |

## Current Acceptance Gates

### UDO-Q01 Runtime and migration readiness

- Add a clear local setup and verification guide for Laravel, Flutter, and Next.js.
- Capture exact commands for migrations, tests, linting, formatting, and dev servers.
- Document current blockers: PHP missing from PATH and Flutter analysis timeout.
- Ensure newly added migrations and tests are referenced by the verification guide.
- Run available checks and record results in the final handoff.

### Standard Gates for Every Queue Item

- Backend data model and API routes exist where persistence is required.
- Frontend/mobile UI uses real API data or a clearly documented fallback.
- Permission and entitlement rules are enforced where relevant.
- Error/loading/empty states exist for user-facing flows.
- Focused tests or typed checks are added/run where tooling allows.
- This queue is updated before moving to the next ID.
