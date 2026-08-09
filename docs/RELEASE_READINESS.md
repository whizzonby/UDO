# Release Readiness

Use this checklist before promoting Udo to staging or production.

## CI Gates

Every pull request must pass the root GitHub Actions workflow in `.github/workflows/ci.yml`.

- Laravel API: Composer install, `.env.example` boot, app key generation, SQLite migration, and `php artisan test`.
- Next.js web: `npm ci`, `npx tsc --noEmit`, `npx eslint .`, and `npm run build`.
- Flutter mobile: `flutter pub get`, `dart format --set-exit-if-changed lib test`, `flutter analyze`, and `flutter test`.

## Environment Checklist

API production variables:

- `APP_ENV=production`
- `APP_DEBUG=false`
- `APP_KEY`
- `APP_URL`
- `FRONTEND_URL`
- `CORS_ALLOWED_ORIGINS`
- `DB_CONNECTION`, `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`
- `QUEUE_CONNECTION`
- `CACHE_STORE`
- `SESSION_DRIVER`
- `FILESYSTEM_DISK` and storage credentials
- `MAIL_MAILER` and sender credentials
- `SENTRY_LARAVEL_DSN` when monitoring is enabled
- `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, sender numbers, and `TWILIO_VALIDATE_WEBHOOKS=true` when messaging is enabled
- `OPENWEATHER_API_KEY` when weather is enabled
- `GUEST_TOKEN_DEFAULT_EXPIRY_DAYS`
- `STRIPE_PRICE_*` plan price IDs before switching from local billing state to hosted checkout

Web production variables:

- `NEXT_PUBLIC_API_URL=https://<api-host>/api`

Mobile release configuration:

- Point API base URL at the production API host.
- Verify iOS and Android signing credentials are configured outside the repo.
- Verify push/social-login provider IDs match the production bundle IDs.

## Deployment Order

1. Confirm CI is green on the release commit.
2. Back up the production database.
3. Deploy the Laravel API.
4. Run `php artisan migrate --force`.
5. Run `php artisan db:seed --class=RolesSeeder --force`. Idempotent — safe on every deploy, not just the first. Skipping this after a migration leaves the `admin.*` permissions missing, which locks every staff role (including `super_admin`) out of every admin panel resource; see `docs/ADMIN_OPERATIONS_RUNBOOK.md`.
6. Restart queue workers.
7. Deploy the Next.js web app with `NEXT_PUBLIC_API_URL` pointed at the API.
8. Smoke test auth, dashboard load, guest portal token load, RSVP save, registry contribution, gallery upload, and logout. If the release touched `app/Filament` or admin roles/permissions, also run the admin smoke checks in `docs/ADMIN_OPERATIONS_RUNBOOK.md`.
9. Promote mobile builds only after the API and web smoke tests pass.

## Rollback Notes

- Keep the previous API and web artifact available for one-click rollback.
- If a migration is not reversible, restore from the pre-release database backup instead of guessing.
- Pause queue workers before rolling back messaging, registry, or guest-token changes.
- After rollback, run guest portal and auth smoke tests again.

## Release Record

For every release, record:

- Release commit SHA.
- CI workflow URL.
- Migration status.
- Smoke-test results.
- Known risks or deferred checks.
- Rollback owner and rollback deadline.
