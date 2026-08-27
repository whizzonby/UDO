# In-App Purchases Setup (Lifetime Wedding Pass)

The mobile paywall (`apps/mobile/lib/features/billing`) sells one product: a
one-time **$45 lifetime unlock**, product id **`udo_lifetime_access`**
(`AppConstants.lifetimeProductId`). It uses the `in_app_purchase` plugin —
Google Play Billing on Android, StoreKit on iOS — and every purchase is
verified server-side by `PurchaseVerificationService` before anything is
granted.

There are **two independent halves** and both must be done for a user to
pay successfully:

1. **Store side** — the product must exist in Play Console / App Store
   Connect and the app must be distributed through the store.
2. **Server side** — the API must be able to call Google's / Apple's
   verification APIs (`/billing/verify-purchase`).

Until both are done the app shows *"Payments coming soon"* and the
**Unlock Udo** button stays disabled. Check status any time with
`GET /api/billing/config` (auth required):

```json
{ "data": { "ios_configured": false, "android_configured": false,
  "lifetime_product_id": { "ios": null, "android": null } } }
```

---

## A. Symptom → cause

| What the paywall shows | Cause |
| --- | --- |
| "Payments coming soon" + *"Lifetime access isn't available in the store yet."* | Store side not done — product missing/inactive, or app not installed **from** the store (sideloaded / `flutter run`). |
| "Payments coming soon" + *"Payments are being set up — check back soon."* | `/billing/config` says the server half isn't configured for this platform. |
| "Store unavailable" | Device has no Play Store / is offline / Billing unsupported. |
| Pays, then *"Purchases aren't enabled on the server yet."* | Server env vars missing — see section C. |

---

## B. Android — Play Console

### B1. Create the product
Play Console → your app → **Monetize → Products → In-app products → Create product**

- **Product ID:** `udo_lifetime_access` (exactly — cannot be changed later)
- **Name / description:** e.g. "Udo Lifetime Wedding Pass"
- **Price:** set for every country you sell in
- **Status:** **Active** (Save *and* Activate — a draft product is not returned to the app)

### B2. Ship the app to a track
IAP products are **only** returned to an app that Play recognises:

- Upload a **release-signed** build (`flutter build appbundle`, signed with
  the upload key) to at least **Internal testing**.
- `applicationId` must be `com.udowedding.udo_mobile` and the version code
  ≥ the code you're testing locally.
- A build that only ever ran via `flutter run` / a directly-shared APK will
  **always** get an empty product list.

### B3. Add testers
- **Setup → License testing** → add the CEO's Google account (this also
  lets them "buy" without being charged).
- Add the same account to the **Internal testing** track's testers list.
- The tester opens the **Play Store internal-testing opt-in link**, installs
  Udo from there, then opens the paywall.
- New product / new build: allow **up to a few hours** (sometimes 24h) for
  Play to start returning the product.

### B4. Service account for server verification
1. Google Cloud Console → the project **linked to this Play account** →
   **IAM & Admin → Service Accounts → Create**. No roles needed at the GCP
   level.
2. Create a **JSON key** for it and download it.
3. Play Console → **Users and permissions → Invite new users** → paste the
   service-account email → grant **View financial data** and **Manage
   orders and subscriptions** (app-level is fine), or use **Setup → API
   access** to link it.
4. Put the JSON file on the API server, readable by the app user, **outside
   the web root and outside git**.

### B5. Server env (`apps/api/.env`)
```
GOOGLE_PLAY_PACKAGE_NAME=com.udowedding.udo_mobile
ANDROID_LIFETIME_PRODUCT_ID=udo_lifetime_access
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON=/absolute/path/to/service-account.json
```
Then `php artisan config:clear` (and restart PHP-FPM / queue workers).
Confirm with `GET /api/billing/config` → `"android_configured": true`.

---

## C. iOS — App Store Connect (do when the iOS app is ready)

1. App Store Connect → your app → **In-App Purchases → Manage → +** →
   **Non-Consumable**.
   - **Product ID:** `udo_lifetime_access`
   - **Reference name / price / localization / review screenshot**
   - Submit it (a non-consumable can be reviewed alongside the first build).
2. **App Store Connect → Users and Access → Integrations → In-App Purchase**
   → generate the **app-specific shared secret**.
3. Distribute the app via **TestFlight** for testing; add the tester's Apple
   ID as an internal tester.
4. Server env:
```
APPLE_IAP_SHARED_SECRET=<shared secret>
IOS_LIFETIME_PRODUCT_ID=udo_lifetime_access
```
`php artisan config:clear`, then `GET /api/billing/config` →
`"ios_configured": true`.

`PurchaseVerificationService::verifyApple()` already hits the production
endpoint and falls back to sandbox on status `21007`, so TestFlight/sandbox
receipts verify without extra config.

---

## D. End-to-end test

1. `GET /api/billing/config` → the platform under test shows `true`.
2. Open the app **installed from the store track**, go to the paywall
   (More → upgrade, or hit a free-plan limit).
3. Panel reads **"Ready to purchase"**, price shows (e.g. "$45.00"),
   **Unlock Udo** is enabled.
4. Buy with the test account → purchase sheet → success.
5. App calls `/billing/verify-purchase`; `SubscriptionEntitlementService::grantLifetime()`
   flips the subscription to `lifetime` and emails a receipt.
6. Paywall stops appearing; the account shows the Lifetime plan in
   `/admin` → Subscriptions.
7. **Restore purchases** on a reinstall re-grants without charging.

---

## E. Notes / gotchas

- **Product id is the contract.** `udo_lifetime_access` must be identical in
  `AppConstants.lifetimeProductId`, both stores, and both server env vars.
  `verifyGoogle()` rejects a mismatched `product_id` outright.
- **Google requires** digital goods in an Android app to be sold through
  Play Billing. Do not add a link to the website's Stripe checkout from
  inside the app — it risks removal.
- The **website** path (Stripe, `/checkout`) is separate and unaffected by
  any of this; it grants the same `lifetime` plan via the Stripe webhook.
- The free plan is fully usable without any of this — `/paywall` is never a
  forced gate, only a prompt when a free-tier limit is hit.
