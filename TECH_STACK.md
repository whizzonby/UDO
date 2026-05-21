# Udo — Final Tech Stack & Architecture

## The Architecture in One Sentence
One Laravel API serves three frontends: the Flutter admin app (couple/planner), the Next.js guest web experience, and the Filament internal ops panel — all backed by PostgreSQL and Redis.

---

## Frontend Layer

| Layer | Technology | Why |
|---|---|---|
| Admin App (iOS + Android) | **Flutter 3** | Single codebase, best Figma-to-code parity, polished UI, App Store + Play Store |
| Guest Web Experience | **Next.js 14** (App Router) | SSR/ISR for fast, SEO-friendly guest pages opened from email/SMS/WhatsApp |
| Internal Ops Panel | **Filament 3** | Rapid CRUD for Udo's ops team — user management, wedding debugging, support |

- **Flutter state management:** Riverpod + Repository pattern
- **Guest web styling:** Tailwind CSS + shadcn/ui

---

## Backend Layer

| Concern | Technology | Why |
|---|---|---|
| API Framework | **Laravel 11** (PHP 8.3) | Mature, full-featured, Eloquent ORM maps perfectly to Udo's relational schema |
| API Auth (Admin) | **Laravel Sanctum** | Token-based, lightweight, perfect for mobile API auth |
| Guest Tokens | **HMAC-signed URL tokens** | No login required, revocable, wedding-scoped, no internal IDs exposed |
| Social Auth | **Laravel Socialite** | Google + Apple login for admin users |
| Background Jobs | **Laravel Horizon** + Redis | Invitation sends, reminders, thank-you nudges, gallery moderation triggers |
| Scheduled Jobs | **Laravel Scheduler** | Daily reminder checks, post-wedding follow-ups, registry nudges |
| Real-time / WebSockets | **Pusher** (or **Laravel Reverb** if self-hosting) | Live page updates, guest experience live popups, wedding-day broadcasts |
| Role & Permissions | **Spatie Laravel Permission** | Domain-based permissions (`manage_guests`, `manage_plan`, etc.) maps exactly to spec |
| Search | **Laravel Scout + Meilisearch** | Fast guest search (name, email, phone, tags) — self-hosted or Meilisearch Cloud |
| Performance | **Laravel Octane** (FrankenPHP) | Optional: 10x throughput improvement for high-traffic wedding-day load |
| API Responses | **Laravel API Resources** | Clean, versioned, consistent response transformation |
| Testing | **Pest PHP** | Clean, expressive test syntax |
| Static Analysis | **PHPStan** (level 8) | Catches type errors at dev time |
| Code Style | **Laravel Pint** | PSR-12 enforced automatically |

---

## Data Layer

| Concern | Technology | Why |
|---|---|---|
| Primary Database | **PostgreSQL 16** | JSONB for `_json` fields (8+ in schema), superior full-text search, better concurrency |
| Managed Postgres | **Neon** (serverless) | Autoscaling, branching for dev/staging, generous free tier, scales on wedding-day spikes |
| Cache | **Redis** (Upstash) | Session cache, queue backend, ephemeral state, rate limiting |
| ORM | **Eloquent** | Relationships across 15+ tables, query scopes for guest filtering |
| Migrations | **Laravel Migrations** | Version-controlled schema changes |

---

## Infrastructure & Services

| Concern | Technology | Why |
|---|---|---|
| File/Image Storage | **Cloudflare R2** | S3-compatible, zero egress fees (critical for gallery/uploads at scale) |
| CDN | **Cloudflare** | Global edge, DDoS protection, image optimization |
| Email | **Resend** | Modern API, excellent deliverability, 3k emails/day free |
| SMS + WhatsApp | **Twilio** | Invitation delivery, live updates, reminders |
| Push Notifications | **Firebase Cloud Messaging** | Android + iOS push for admin app users |
| Payments (Registry) | **Stripe** | Checkout, Payment Links for cash fund contributions |
| Maps + Directions | **Google Maps Platform** | Venue maps, hotel proximity, guest travel guidance |
| Pinterest | **Pinterest API** | Inspiration board ingestion into Gallery |
| Calendar Export | **ICS generation** (native PHP) | Guest schedule downloads from guest web |

---

## DevOps & Monitoring

| Concern | Technology | Why |
|---|---|---|
| Backend Hosting | **Railway** or **Render** | Simple deploys, managed infra, scales easily — move to AWS when needed |
| Guest Web Hosting | **Vercel** | Next.js first-class support, edge SSR, instant deploys |
| CI/CD | **GitHub Actions** | Automated tests, linting, deploy pipelines |
| Mobile Deployment | **Fastlane** | Automated App Store + Play Store releases |
| Error Tracking | **Sentry** | Both Laravel (backend) and Flutter (app) |
| Dev Debugging | **Laravel Telescope** | Local request/query/job inspection |
| Prod Monitoring | **Laravel Pulse** | Real-time server health, queue depth, slow queries |
| Secrets Management | `.env` + Railway/Render secrets | No credentials in code |

---

## Key Architectural Rules

These must be enforced from day one — in code review, in PR descriptions, in team onboarding.

**1. One API, three consumers**
Laravel serves Flutter, Next.js, and Filament. No separate backends. All business logic lives in the API layer.

**2. Module ownership is law**
Seating mutations only through `/plan/*`. Guest record mutations only through `/guests/*`. Home is read-only aggregation. No exceptions.

**3. Queue everything with side effects**
Invitation sends, notifications, reminder jobs, gallery processing — nothing blocks the HTTP response. Everything goes through Horizon.

**4. Guest tokens are never raw IDs**
Guest links (`/g/:token`) always resolve through a lookup table. Internal IDs are never exposed in guest-facing URLs.

**5. Events drive Home and Smart Alerts**
`guest.rsvp.updated`, `invitation.sent`, `registry.contribution.received` — Laravel Events fire on every domain action. Listeners update computed summaries. This is what makes Home feel live without polling.

**6. Wedding day is a reliability event**
On `status = live`, the system must handle degraded connectivity. Guest web pages must be cached at CDN edge. Laravel Octane handles spike traffic. Pusher handles realtime with automatic reconnection.

---

## Primary Navigation (Admin App)

```
Home | Plan | Guests | Live | Gallery | Registry | More
```

## Module Ownership Reference

| Data / Feature | Owned By | Read By |
|---|---|---|
| Seating planner | Plan | Guests (status only) |
| Guest records | Guests | Home (summary), Live (count) |
| Event schedule / timeline | Plan | Live, Guest Experience |
| Guest Experience builder | Guests → Experience | Live (live updates) |
| Registry | Registry | Invitations, Guest Experience, Messages |
| Invitation builder | Guests → Invitations | Guest Experience (preview) |
| Live updates | Live / Messages | Guest Experience (popup feed) |
| Gallery | Gallery | Guest Experience (if enabled) |
| Home | Read-only aggregation | — |

---

## User Roles & Permission Domains

### Roles
- **Owner / Primary Couple** — full control
- **Partner / Co-owner** — near-full access
- **Planner** — operational access (configurable)
- **Collaborator** — scoped module access
- **Guest** — personalized link only, no app access

### Permission Domains (Spatie)
```
manage_plan           manage_guests         manage_invitations
manage_guest_experience  manage_messages    manage_live
manage_gallery        manage_registry       manage_logistics
manage_collaborators  view_financials
```

---

## Guest Token Model

```
Token references:  wedding_id + guest_id + role/view_type + expiry
Guest URL format:  /g/:token  (opaque, no internal IDs)
Properties:        revocable by admin, regeneratable, rate-limited
Auth requirement:  none — frictionless for guests
```

---

## Build Order

```
Phase 1   Auth + Wedding shell + onboarding
Phase 2   Home (aggregation + computed summaries)
Phase 3   Plan core (tasks, timeline, vendors, budget)
Phase 4   Guests core (list, detail drawer, filters, bulk actions)
Phase 5   Invitations + Guest token system
Phase 6   Guest Experience builder + preview
Phase 7   Messages + notification channels (email, SMS, WhatsApp)
Phase 8   Seating planner (drag-and-drop, table builder)
Phase 9   Logistics (hotels, transport groups, assignments)
Phase 10  Live page (dual mode — bride view + planner view)
Phase 11  Gallery (uploads, moderation, moments, inspiration/Pinterest)
Phase 12  Registry (cash fund, items, Stripe, thank-you tracking)
Phase 13  Push notifications + real-time polish
Phase 14  Guest web layer (Next.js — all /g/:token routes)
Phase 15  Analytics, smart reminders, background job polish
```

---

## Key Third-Party Accounts Needed

Before development starts, set up accounts for:

- [ ] Neon (PostgreSQL hosting)
- [ ] Upstash (Redis)
- [ ] Cloudflare (CDN + R2 storage)
- [ ] Pusher (real-time)
- [ ] Resend (email)
- [ ] Twilio (SMS + WhatsApp)
- [ ] Firebase (push notifications)
- [ ] Stripe (payments)
- [ ] Google Cloud (Maps Platform)
- [ ] Sentry (error tracking)
- [ ] Vercel (Next.js hosting)
- [ ] Railway or Render (Laravel hosting)
- [ ] Apple Developer Account (App Store)
- [ ] Google Play Developer Account (Play Store)
- [ ] Pinterest Developer Account (API access)

---

*Last updated: May 2026*
*Stack confirmed by team before Figma handoff*
