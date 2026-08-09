# Local Verification Guide

This guide is the setup and verification contract for Udo. Use it before marking any queue item in `docs/UDO_EXECUTION_QUEUE.md` as complete.

## Required Toolchain

| Area | Required |
|---|---|
| API | PHP 8.2+, Composer, SQLite/PostgreSQL-compatible local database |
| Web | Node.js, npm |
| Mobile | Flutter 3.10+, Dart 3.x, Android Studio or Xcode for device builds |

## CI: GitHub Actions

The repo-level CI workflow lives at `.github/workflows/ci.yml`.

```powershell
# API job
cd apps/api
composer install --no-interaction --prefer-dist --no-progress
php artisan migrate --force
php artisan test

# Web job
cd apps/web
npm ci
npx tsc --noEmit
npx eslint .
npm run build

# Mobile job
cd apps/mobile
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Release promotion checklist and deployment notes are in `docs/RELEASE_READINESS.md`. Admin panel bootstrap, role assignment, operational runbooks, and admin-specific smoke checks are in `docs/ADMIN_OPERATIONS_RUNBOOK.md`.

## API: Laravel

Run commands from `apps/api`.

```powershell
composer install
php artisan key:generate
php artisan migrate
php artisan test
```

Focused queue regression test:

```powershell
php artisan test --filter=WeddingFlowBugFixTest
```

Useful maintenance checks:

```powershell
php artisan route:list
php artisan config:clear
vendor/bin/pint --test
```

Current blocker in this workspace: `php` is not recognized on PATH, so Laravel tests cannot run until PHP is installed or added to PATH.

## Web: Next.js

Run commands from `apps/web`.

```powershell
npm install
npx tsc --noEmit
npm run lint
npm run dev
```

Targeted lint for account operations work:

```powershell
npx eslint components/dashboard/MorePage.tsx contexts/AuthContext.tsx lib/auth.ts
```

Targeted lint for guest experience, logistics, invitation, and seating work:

```powershell
npx eslint components/guest/GuestPortal.tsx components/dashboard/PlanPage.tsx components/dashboard/guests/GuestExperience.tsx components/dashboard/GuestsPage.tsx
```

Targeted lint for live operations work:

```powershell
npx eslint components/dashboard/LivePage.tsx components/guest/GuestPortal.tsx
```

Targeted lint for home command-center work:

```powershell
npx eslint components/dashboard/HomePage.tsx contexts/WeddingContext.tsx
```

Targeted lint for registry and thank-you work:

```powershell
npx eslint components/dashboard/RegistryPage.tsx components/guest/GuestPortal.tsx
```

Targeted lint for gallery moderation and memories work:

```powershell
npx eslint components/dashboard/GalleryPage.tsx components/guest/GuestPortal.tsx
```

Targeted lint for vendor CRM work:

```powershell
npx eslint components/dashboard/PlanPage.tsx
```

Targeted lint for budget and payments work:

```powershell
npx eslint components/dashboard/PlanPage.tsx
```

Targeted lint for smart alerts and automations work:

```powershell
npx eslint components/dashboard/HomePage.tsx contexts/WeddingContext.tsx
```

Targeted lint for reliability and scale work:

```powershell
npx eslint components/dashboard/HomePage.tsx contexts/WeddingContext.tsx lib/api.ts
```

Targeted lint for internal ops work:

```powershell
npx eslint components/dashboard/MorePage.tsx lib/auth.ts
```

Targeted lint for search, filtering, and bulk-action work:

```powershell
npx eslint components/dashboard/GuestsPage.tsx components/dashboard/guests/GuestListSection.tsx components/dashboard/PlanPage.tsx lib/api.ts
```

Default local URL:

```text
http://localhost:3000
```

## Mobile: Flutter

Run commands from `apps/mobile`.

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Targeted analysis for More/auth work:

```powershell
flutter analyze lib/features/auth/data/auth_models.dart lib/core/network/auth_service.dart lib/features/auth/presentation/providers/auth_provider.dart lib/features/more/presentation/screens/more_screen.dart
```

Targeted analysis for guest, logistics, invitation, and seating work:

```powershell
flutter analyze lib/features/guests/presentation/providers/invitation_provider.dart lib/features/guests/presentation/providers/logistics_provider.dart lib/features/guests/presentation/screens/guests_screen.dart lib/features/plan/presentation/providers/seating_provider.dart lib/features/plan/presentation/screens/plan_screen.dart
```

Targeted analysis for live operations work:

```powershell
flutter analyze lib/features/live/presentation/providers/live_provider.dart lib/features/live/presentation/screens/live_screen.dart
```

Targeted analysis for home command-center work:

```powershell
flutter analyze lib/features/home/presentation/providers/home_provider.dart lib/features/home/presentation/screens/home_screen.dart
```

Targeted analysis for registry and thank-you work:

```powershell
flutter analyze lib/features/registry/presentation/providers/registry_provider.dart lib/features/registry/presentation/screens/registry_screen.dart
```

Targeted analysis for gallery moderation and memories work:

```powershell
flutter analyze lib/features/gallery/presentation/providers/gallery_provider.dart lib/features/gallery/presentation/screens/gallery_screen.dart
```

Targeted analysis for vendor CRM work:

```powershell
flutter analyze lib/features/plan/presentation/providers/plan_provider.dart lib/features/plan/presentation/screens/plan_screen.dart
```

Targeted analysis for budget and payments work:

```powershell
flutter analyze lib/features/plan/presentation/providers/plan_provider.dart lib/features/plan/presentation/screens/plan_screen.dart
```

Targeted analysis for smart alerts and automations work:

```powershell
flutter analyze lib/features/home/presentation/providers/home_provider.dart lib/features/home/presentation/screens/home_screen.dart
```

Targeted analysis for reliability and scale work:

```powershell
flutter analyze lib/features/home/presentation/providers/home_provider.dart lib/features/home/presentation/screens/home_screen.dart
```

Targeted analysis for mobile offline resilience work:

```powershell
flutter analyze lib/core/network/api_client.dart lib/features/home/presentation/providers/home_provider.dart lib/features/home/presentation/screens/home_screen.dart lib/features/guests/presentation/providers/guests_provider.dart lib/features/guests/presentation/screens/guests_screen.dart lib/features/live/presentation/providers/live_provider.dart lib/features/live/presentation/screens/live_screen.dart lib/features/plan/presentation/providers/plan_provider.dart lib/features/plan/presentation/screens/plan_screen.dart
```

Targeted checks for web UX completion work:

```powershell
cd apps/web
npx tsc --noEmit
npx eslint components/dashboard/GalleryPage.tsx components/dashboard/RegistryPage.tsx
```

Targeted backend tests for security and privacy work:

```powershell
cd apps/api
php artisan test --filter=WeddingFlowBugFixTest
```

Targeted analysis for search, filtering, and bulk-action work:

```powershell
flutter analyze lib/features/guests/presentation/providers/guests_provider.dart lib/features/guests/presentation/screens/guests_screen.dart lib/features/plan/presentation/providers/plan_provider.dart lib/features/plan/presentation/screens/plan_screen.dart
```

Current blocker in this workspace: targeted Flutter analysis and `dart format` time out before diagnostics/formatting complete. Treat Flutter verification as incomplete until `flutter analyze` and `dart format` finish locally.

## Migration Checklist

Before testing backend changes:

```powershell
php artisan migrate
```

Recent migrations that must be applied for the current queue:

- `2026_07_16_080418_add_is_saved_to_gallery_assets_table.php`
- `2026_07_16_090000_add_communication_preferences_to_guests_table.php`
- `2026_07_16_100000_create_audit_logs_table.php`
- `2026_07_16_110000_add_preferences_to_users_table.php`
- `2026_07_16_120000_add_builder_fields_to_guest_experience_configs_table.php`
- `2026_07_16_130000_add_campaign_fields_to_messages_table.php`
- `2026_07_16_140000_add_show_seating_to_guest_experience_configs_table.php`
- `2026_07_16_150000_add_operations_fields_to_live_updates_table.php`
- `2026_07_16_160000_add_vendor_id_to_tasks_table.php`
- `2026_07_16_160100_create_vendor_contact_logs_table.php`
- `2026_07_16_170000_create_budget_payment_schedules_table.php`
- `2026_07_16_180000_create_smart_alerts_table.php`
- `2026_07_16_190000_create_saved_filters_table.php`
- `2026_07_16_200000_create_idempotency_keys_table.php`

## Completion Record Format

When completing a queue item, record:

- Queue ID and feature name.
- Files changed.
- Commands run.
- Commands blocked and exact reason.
- Any known follow-up risk.

Example:

```text
UDO-Q01 Runtime and migration readiness
Passed: npx tsc --noEmit
Passed: npx eslint ...
Blocked: php artisan test --filter=WeddingFlowBugFixTest because PHP is not on PATH.
Blocked: flutter analyze ... because the command timed out before diagnostics.
```
