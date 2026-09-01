# Apple App Store Submission Runbook

How Udo gets from "live on Google Play" to "live on the App Store". Written for
a team where **the developer is on Windows** and **the CEO has the only Mac and
owns the Apple Developer account**.

Split of work:

- **CEO** — anything gated behind the Account Holder role, plus turning her Mac
  into the build machine. ~30 min on a Zoom call, then ~5 min later to submit.
- **Developer** — everything else, remotely, from Windows via App Store Connect
  plus a screen-shared / SSH session into the Mac for the one build step.

---

## 0. What is already done (no action needed)

| Item | Evidence |
| --- | --- |
| Apple Developer account exists | (confirmed by team) |
| Sign in with Apple wired in the app | `apps/mobile/ios/Runner/Runner.entitlements` → `com.apple.developer.applesignin`; `sign_in_with_apple` in `pubspec.yaml` |
| Backend verifies Apple identity tokens | `apps/api/app/Http/Controllers/Auth/MobileSocialAuthController.php::apple()` |
| Backend verifies Apple IAP receipts | `apps/api/app/Services/PurchaseVerificationService.php::verifyApple()` |
| Production API URL baked into the app | `apps/mobile/lib/core/constants/app_constants.dart` → `https://admin.udowedding.com/api` |
| iOS deployment target | 13.0 (`ios/Runner.xcodeproj/project.pbxproj`) |
| Info.plist camera/photo strings, encryption key, name = `Udo`, iPhone-only | done — see section 3a |
| `ios/Podfile` committed; unused `permission_handler` removed | done — see section 3b |
| `Info.plist` prepped for Google Sign-In (client id placeholder) | see section 3c |
| `scripts/ios_release.sh` one-shot build script | committed |

Key identifiers:

| | Value |
| --- | --- |
| iOS bundle ID | `com.udowedding.udoMobile` |
| Android applicationId (for reference — differs) | `com.udowedding.udo_mobile` |
| App display name | `Udo` (`CFBundleDisplayName`) |
| Marketing version / build | `1.0.0` / `7` (`pubspec.yaml` `version: 1.0.0+7`) — fine for a first submission |
| IAP product ID | `udo_lifetime_access` — non-consumable, $45 lifetime unlock |

---

## 0.5. Mac quick start (once the repo is pulled)

The developer has done all the repo-side work and pushed to `master`. On the Mac:

1. **Environment** — section 5b (Xcode license, Homebrew, `brew install --cask flutter`, `brew install cocoapods`).
2. `git clone` / `git pull`, then `cd apps/mobile` and section 5c.
3. **Xcode signing** — section 5d (one time, pick the team).
4. `./scripts/ios_release.sh` → produces the `.ipa` (section 5e).
5. **Upload** — Xcode Organizer or Transporter (section 5f).
6. **TestFlight test + submit** — sections 5g and 6.

What still needs a human decision / account access before submitting is tracked
in section 7 of the chat summary and sections 2–4 here — most importantly the
Google iOS OAuth client (3c) and the App Store Connect app record + IAP (2c/2d).

---

## 1. CEO tasks — on the Zoom call

### 1a. Verify money is set up (App Store Connect → **Agreements, Tax, and Banking**)

The $45 IAP will be **rejected in review** if this is not finished.

- [ ] **Paid Applications Agreement** status = **Active** (not "Pending Agreement", no yellow banner).
- [ ] **Bank Account** added and verified.
- [ ] **Tax Forms** complete (for a non‑US company: W‑8BEN‑E plus any local questionnaire).

If any of these is missing, she completes it now. Only the Account Holder can.

### 1b. Add the developer to the account

- **App Store Connect → Users and Access → Users →** invite the developer's
  email with role **Admin** (or **App Manager** + **Developer** if she wants
  tighter scoping).
- **Apple Developer portal (developer.apple.com) → People →** confirm the same
  account shows there with access to **Certificates, Identifiers & Profiles**.

After this, the developer can do sections 2, 3, 5, 6 remotely.

### 1c. Turn the Mac into the build machine

- [ ] Install **Xcode** from the Mac App Store (~10 GB — start this first, it is slow). Then launch it once and let it install "additional required components".
- [ ] **Xcode → Settings → Accounts →** sign in with the Apple ID that owns the developer account. Confirm the **Udo** team appears.
- [ ] **System Settings → General → Sharing →** enable **Screen Sharing** (and/or **Remote Login** for SSH). Note the Mac's local IP / hostname.
- [ ] Create a **standard user account** on the Mac for the developer, or agree to leave a screen-share session open. The developer will install Flutter + CocoaPods and clone the repo under that account.
- [ ] Optional: install [Homebrew](https://brew.sh) then `brew install --cask flutter` and `brew install cocoapods` together on the call to save time.

### 1d. Later (after the developer preps everything) — ~5 min

- [ ] **Submit for Review** on the first version (Account‑Holder gated on the first release only).
- [ ] Sanity-check the **App Privacy** answers the developer filled in are truthful.

---

## 2. Developer tasks — Apple Developer portal + App Store Connect

Do these from Windows in the browser.

### 2a. Register the App ID

**developer.apple.com → Certificates, Identifiers & Profiles → Identifiers → +**

- Type: **App IDs → App**
- Bundle ID: **Explicit**, `com.udowedding.udoMobile`
- Capabilities: enable **Sign in with Apple** and **In‑App Purchase**. (Do *not*
  add Push Notifications — the app uses Pusher Channels, not APNs.)

### 2b. Signing

Two options:

1. **Xcode automatic signing** (simplest for one release) — in Xcode on the Mac,
   open `ios/Runner.xcworkspace`, select the Runner target → Signing &
   Capabilities → check "Automatically manage signing", pick the **Udo** team.
   Xcode creates the distribution cert + provisioning profile itself.
2. **Manual / CI** — create an **Apple Distribution** certificate and an
   **App Store** provisioning profile in the portal, download both. Needed if
   you later move to Codemagic / GitHub Actions.

### 2c. Create the app record

**App Store Connect → Apps → + → New App**

- Platform: **iOS**
- Name: **Udo** (must be unique across the App Store — check availability)
- Primary language, bundle ID `com.udowedding.udoMobile`, SKU (any string, e.g. `udo-ios-001`)
- User access: Full Access

### 2d. Create the In‑App Purchase

**App Store Connect → your app → Monetization → In‑App Purchases → +**

- Type: **Non‑Consumable**
- Reference Name: `Udo Lifetime Wedding Pass`
- Product ID: **`udo_lifetime_access`** (must match `AppConstants.lifetimeProductId` exactly — cannot be changed later)
- Price: **$45** tier, set for every territory you sell in
- Localization: display name + description
- Review screenshot (1284×2778 or similar) showing the paywall
- **Submit the IAP with the first app version** — a non‑consumable that has never
  shipped will not be reviewed on its own, and shipping the app without it means
  the paywall is dead.

### 2e. App‑Specific Shared Secret (for backend receipt verification)

**App Store Connect → your app → App Information → App‑Specific Shared Secret →
Generate.** Give this value to whoever manages the API env — it becomes
`APPLE_IAP_SHARED_SECRET` (section 4).

### 2f. Store listing metadata

- **Screenshots** — 6.7" iPhone (1290×2796) and 6.5" iPhone (1242×2688) are
  required; iPad 12.9" required **because the app currently declares iPad
  support** (`UISupportedInterfaceOrientations~ipad` in Info.plist). Either
  produce iPad screenshots or drop iPad support (section 3d).
  The existing `store-listing/` PNGs are Play Store sizes — they will be
  rejected; regenerate at Apple dimensions.
- Description, keywords, support URL, marketing URL — adapt from
  `store-listing/play-store-descriptions.md`.
- **Privacy Policy URL** — required. Use the marketing site's policy page.
- **App Privacy** questionnaire — declare what Udo collects: name, email,
  photos/user content, identifiers, purchase history, coarse diagnostics.
  Match what the API actually stores.
- Age rating questionnaire.
- **App Review Information** — see section 6.

---

## 3. Repo / build config

### 3a. Info.plist + Xcode project — DONE

`apps/mobile/ios/Runner/Info.plist`:

- `NSCameraUsageDescription` — `image_picker` camera capture is used in `plan_screen.dart`
- `NSPhotoLibraryUsageDescription` — gallery/memories/invitations/vision-board image picking
- `ITSAppUsesNonExemptEncryption` = `false` — skips the export-compliance prompt on every upload
- `CFBundleDisplayName` = `Udo` (was "Udo Mobile") — home-screen name, matches the store
- `UISupportedInterfaceOrientations~ipad` removed — see 3d

`ios/Runner.xcodeproj/project.pbxproj`:

- `TARGETED_DEVICE_FAMILY` = `1` (iPhone only) in all three build configs — see 3d

No location string is added because the app has no `Geolocator` / device-location
use — `flutter_map` only renders tiles. If device location is added later, add
`NSLocationWhenInUseUsageDescription` at the same time or review will flag it.

### 3b. `permission_handler` — REMOVED

`permission_handler` was in `pubspec.yaml` but imported nowhere in `lib/`. On iOS
it compiles in permission stubs for capabilities the app never uses, which App
Review rejects. It has been removed from `pubspec.yaml` entirely (`flutter pub
get` confirmed nothing else depends on it) — no Podfile preprocessor hack needed.

`ios/Podfile` is now committed (standard Flutter template, `platform :ios,
'13.0'`), so `pod install` on the Mac is deterministic. If Flutter's template
changes in a future SDK, delete the file and let `flutter build` regenerate it.

### 3c. Google Sign-In on iOS — wired, ONE thing left to verify

The app talks to Google directly (no Firebase SDK). On iOS `google_sign_in` reads
`GIDClientID` from `Info.plist`, so `auth_provider.dart`'s bare
`GoogleSignIn().signIn()` needs **no Dart change**.

**Done in the repo:**

| Where | Value |
| --- | --- |
| `ios/Runner/Info.plist` → `GIDClientID` | `766006747222-iqa0ji0fgdj8snujti0jqr4565t7vgmi.apps.googleusercontent.com` |
| `ios/Runner/Info.plist` → `CFBundleURLSchemes` | `com.googleusercontent.apps.766006747222-iqa0ji0fgdj8snujti0jqr4565t7vgmi` |
| `production .env` → `GOOGLE_IOS_CLIENT_ID` | same client id (deploy this to the live API) |

`config/services.php` already reads `GOOGLE_IOS_CLIENT_ID`, and
`MobileSocialAuthController::verifyGoogleToken()` already accepts it as a valid
token audience alongside the web client id — no API code change, just ship the
env var.

**⚠️ Left to do — the OAuth consent screen.** This iOS client was created in
Google Cloud project **766006747222**, which is **not** the project Android uses
(`udoapp-64663` / `563593264357`). Sign-in still works cross-project (the API
accepts both audiences; Google's `sub` is stable per account), **but the OAuth
consent screen is per-project**. Pick one:

- **Fast:** Google Cloud Console → project **766006747222** → **APIs & Services
  → OAuth consent screen** → if *Publishing status* is "Testing", click
  **Publish app** → "In production". Scopes here are only `email` / `profile` /
  `openid` (non-sensitive), so this takes effect immediately — no Google
  verification review. Also set an app name, support email, and (nice-to-have) a
  logo + the udowedding.com homepage/privacy links, since this screen is shown to
  users and to the App Reviewer.
- **Tidier:** delete this client, recreate the iOS OAuth client **inside
  `udoapp-64663`** (which already has a working published consent screen from
  Android), and swap the three values above for the new id.

If *Testing* is left in place, real users and the App Reviewer get
`Error 403: access_denied` and the app is rejected.

**Verify** on the TestFlight build: tap *Continue with Google* → Google sheet
appears → sign in → land authenticated. `missing-config` = `GIDClientID` wrong;
`invalid_client` / redirect error = URL scheme wrong or bundle id mismatch;
`access_denied` = consent screen still in Testing.

**Fallback if blocked:** gate the Google button behind `!Platform.isIOS` in the
auth screen and ship Apple + email only — Apple only requires *Sign in with
Apple* when a third-party login is offered, so dropping Google on iOS is
compliant. Add it back later.

### 3d. iPad support — DROPPED

`TARGETED_DEVICE_FAMILY` is now `1` (iPhone only) and the iPad orientation key is
removed. No iPad screenshots needed. Xcode's Runner target will show "iPhone"
only under Deployment Info — leave it. Add iPad support in a later release if
wanted (set family back to `1,2`, test the layout, add iPad screenshots).

### 3e. Version / build number

Staying at `1.0.0+7` — fine for a first App Store submission (Play and App Store
build numbers are independent). `flutter build ipa` maps `1.0.0` →
`CFBundleShortVersionString` and `7` → `CFBundleVersion`. Every **subsequent**
upload just needs a strictly higher build number: `1.0.0+8`, `1.0.0+9`, …

### 3f. App icon

`flutter_launcher_icons` is configured. Confirm
`ios/Runner/Assets.xcassets/AppIcon.appiconset/` has a non-transparent
1024×1024 marketing icon (Apple rejects icons with alpha / transparency).

---

## 4. Backend env vars (production API)

Set these on the API host. Until they are present, `GET /api/billing/config`
reports `ios_configured: false` and the paywall shows "Payments coming soon".

| Var | Value | Purpose |
| --- | --- | --- |
| `APPLE_IAP_SHARED_SECRET` | App-Specific Shared Secret from 2e | Receipt verification (`verifyApple`) |
| `IOS_LIFETIME_PRODUCT_ID` | `udo_lifetime_access` | Which product the receipt must contain |
| `APPLE_CLIENT_ID` | `com.udowedding.udoMobile` | Audience check for Sign in with Apple **native** flow (the `aud` claim is the bundle ID, not a Services ID) |
| `APPLE_TEAM_ID` | Apple Developer Team ID | Apple token verification |
| `APPLE_KEY_ID` / `APPLE_CLIENT_SECRET` | from an Apple **Sign in with Apple** key | Only needed if the web/OAuth Apple flow is used; native mobile flow needs just `APPLE_CLIENT_ID` |
| `GOOGLE_IOS_CLIENT_ID` | the iOS OAuth client id from section 3c | Accepted as a valid audience for Google ID tokens minted on iOS |

See `docs/IN_APP_PURCHASES_SETUP.md` for the full IAP server picture (it is
written Android-first but section C applies to Apple too).

> Note: `verifyApple()` uses the legacy `verifyReceipt` endpoint. Apple has
> deprecated it but it still works for now. Migrating to the App Store Server API
> is a separate follow-up, not a launch blocker.

---

## 5. Build & upload — the Mac

Xcode is installed. Everything below happens on the CEO's Mac. The developer
drives it remotely; see 5a.

### 5a. Give the developer a way to work on the Mac

Pick one:

- **Screen share on a call** — CEO shares screen in Zoom, developer dictates,
  CEO types. Slowest, but zero setup. Fine for a one-off.
- **Remote access (recommended)** — on the Mac: **System Settings → General →
  Sharing** → turn on **Screen Sharing** *and* **Remote Login** (SSH). Create a
  separate **standard user account** for the developer (Users & Groups → Add
  Account) so the CEO's desktop/keychain stays private. Developer connects over
  SSH for the CLI work and screen-shares only for the Xcode signing screen.
  Both machines must be on, and for off-network access you need Tailscale / a
  VPN or to keep the Zoom screen-share as the fallback.

> The Apple ID that owns the developer account should be signed into **Xcode →
> Settings → Accounts** (in whichever macOS user account does the build). If the
> developer works in their own macOS account, sign Xcode in there too — an
> Xcode account login is per-macOS-user.

### 5b. One-time environment setup

Run in the Mac Terminal (developer's account). Apple Silicon assumed.

```bash
# 1. Xcode license + components (needs admin password)
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
xcodebuild -version                      # confirm it prints a version

# 2. Rosetta (some build tooling still needs it on Apple Silicon)
sudo softwareupdate --install-rosetta --agree-to-license

# 3. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# then follow the "Next steps" it prints to add brew to your PATH

# 4. Tooling — CocoaPods from brew; Flutter PINNED to 3.38.7 (NOT brew's latest)
brew install cocoapods git

# brew installs whatever Flutter is newest, and Dart >= 3.13 crashes this
# project's code generation. Install the exact version instead:
git clone https://github.com/flutter/flutter.git -b 3.38.7 --depth 1 ~/flutter-udo
echo 'export PATH="$HOME/flutter-udo/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 5. Verify — MUST say 3.38.7 / Dart 3.10.x
flutter --version
flutter doctor
```

`flutter doctor` must show **Xcode** and **CocoaPods** with green checks. Ignore
the Android / Chrome lines — not needed for an iOS build.

> **Flutter version is pinned to 3.38.7 (Dart 3.10.7).** `apps/mobile/.fvmrc`
> records it, and `pubspec.yaml` caps `sdk: <3.13.0` so a wrong Dart fails
> `flutter pub get` with a clear message instead of a cryptic
> `visitDotShorthandPropertyAccess` crash mid-codegen. If `brew install --cask
> flutter` was already run, remove it (`brew uninstall --cask flutter`) or make
> sure `~/flutter-udo/bin` comes first on `PATH`. FVM alternative:
> `brew tap leoafarias/fvm && brew install fvm && fvm use` from `apps/mobile`.
>
> `apps/mobile/pubspec.lock` is committed — `flutter pub get` uses exactly the
> verified versions (`retrofit` 4.5.0; newer breaks codegen). Don't
> `flutter pub upgrade`. The root CI's "Flutter 3.24" line is stale — ignore it.

### 5c. Get the project building

```bash
git clone <REPO_URL> udo
cd udo/apps/mobile

flutter pub get
flutter precache --ios
flutter build ios --config-only   # writes Flutter/Generated.xcconfig so pods can resolve

cd ios && pod install && cd ..
```

`ios/Podfile` is committed, so `pod install` just works — no editing needed
(`permission_handler` was removed; see 3b).

### 5d. Signing (Xcode, one time)

```bash
open ios/Runner.xcworkspace
```

In Xcode:

1. Left sidebar → **Runner** (blue icon) → **TARGETS → Runner** → **Signing &
   Capabilities**.
2. **Automatically manage signing** — checked.
3. **Team** → select the **Udo** team (the developer account). If it's not
   listed, the Apple ID in Xcode → Settings → Accounts isn't on that team, or
   the developer hasn't been added (section 1b).
4. **Bundle Identifier** must read `com.udowedding.udoMobile`. If Xcode shows a
   provisioning error, click **Try Again** — with automatic signing it creates
   the distribution certificate and App Store profile itself.
5. Confirm **Signing & Capabilities** lists **Sign in with Apple** (it should,
   from `Runner.entitlements`). If not, **+ Capability → Sign in with Apple**.
6. Repeat Team selection for the **RunnerTests** target (or it can block the
   archive) — or just set it once at the **PROJECT → Runner** level.

### 5e. Build the IPA

After signing is set once (5d) and the Google client id is filled in (3c), the
whole build is one script:

```bash
./scripts/ios_release.sh
```

It runs `flutter pub get` → codegen → `pod install` → `flutter clean` →
`flutter build ipa --release`, and warns if the `REPLACE_WITH_IOS_CLIENT_ID`
placeholder is still in `Info.plist`.

Output: `build/ios/ipa/*.ipa` and an archive under `build/ios/archive/`.

> The app already defaults its API base URL to production
> (`app_constants.dart`), so no `--dart-define` is required.

### 5f. Upload to App Store Connect

Prerequisite: the **app record exists** (section 2c) and the **App ID is
registered** (section 2a). You cannot upload a build for an app that doesn't
exist in App Store Connect yet.

**Option A — Xcode Organizer (easiest with a person at the Mac):**
`flutter build ipa` prints a line pointing at the archive. Open Xcode →
**Window → Organizer → Archives**, select the build → **Distribute App → App
Store Connect → Upload** → accept the defaults → **Upload**.

**Option B — Transporter app** (free, Mac App Store): sign in with the Apple ID,
drag `build/ios/ipa/udo_mobile.ipa` in, **Deliver**.

**Option C — command line** (good once you want CI):

```bash
# one-time: App Store Connect → Users and Access → Integrations → App Store Connect API
#           → generate a key with "App Manager" access. Note the Key ID + Issuer ID,
#           download the .p8 once, put it at ~/.appstoreconnect/private_keys/AuthKey_XXXX.p8
xcrun altool --upload-app -f build/ios/ipa/udo_mobile.ipa -t ios \
  --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>
```

### 5g. After upload

- Processing takes ~5–30 min. The build then appears under **TestFlight** and
  can be attached to the App Store version under **Distribution → Build**.
- If Apple emails an **ITMS-90xxx** rejection at this stage it's a metadata /
  binary problem (missing icon, bad Info.plist key, private API) — fix and
  re-upload with a higher build number (`version: 1.0.0+8`, etc.).
- Test the build via **TestFlight** on a real iPhone (install the TestFlight
  app, accept the internal-tester invite) — check login (Apple + Google + email)
  and the paywall before submitting for review.

---

## 6. App Review submission checklist

- [ ] Build attached to the version.
- [ ] IAP `udo_lifetime_access` attached to the **same** version ("In-App
      Purchases" section of the version page → select it).
- [ ] **Sign-in demo account** in *App Review Information* — a real Udo account
      with a wedding set up (couple role), email + password. The whole app is
      login-gated; without this it is an automatic rejection.
- [ ] **Review notes** explaining:
  - The app is a wedding-planning companion to the existing Play Store app.
  - The single IAP is a one-time $45 lifetime unlock; to test it, use a sandbox
    Apple ID (create one under Users and Access → Sandbox Testers) — sandbox
    purchases are free.
  - Which features are behind the paywall vs. free.
- [ ] **Export compliance** — `ITSAppUsesNonExemptEncryption=false` is set, so no
      questionnaire should appear. If it does, answer that the app only uses
      standard HTTPS.
- [ ] **App Privacy** answers saved and truthful.
- [ ] Screenshots at required sizes uploaded.
- [ ] Privacy Policy URL + Support URL filled.
- [ ] Age rating completed.
- [ ] CEO clicks **Add for Review → Submit** (first release).

First review is typically 24–48h. Expect at least one round of rejection —
common reasons for this app are in section 7.

---

## 7. Likely rejection reasons for Udo (pre-empt these)

| Guideline | Risk | Mitigation |
| --- | --- | --- |
| 2.1 App Completeness | Reviewer can't log in | Demo account in review notes (section 6) |
| 2.1 | IAP not testable | Sandbox tester + notes; IAP submitted with the build |
| 4.8 Sign in with Apple | Required because Google login is offered; must be visually equal | Already implemented — just confirm the button is present and works on the review build |
| 1.5 / 5.1.1 | Camera/photo prompts with no/weak purpose string | Strings added in section 3a — keep them specific |
| 5.1.1(v) | Permission code for unused capabilities (`permission_handler`) | Podfile exclusions, section 3b |
| 2.3.1 | Hidden/broken features (Google button that crashes) | Fix section 3c or hide the button on iOS |
| 3.1.1 | Selling the lifetime pass through anything other than IAP on iOS | The app already uses StoreKit via `in_app_purchase`; make sure no "pay on our website" link is shown to iOS users |
| 5.1.2 | App Privacy label doesn't match behavior | Fill it from what the API actually stores |
| 2.3.8 | App name/metadata mismatch | Use "Udo" consistently |

---

## 8. After approval

- Release manually or automatically (version page → "Manually release this
  version" is safer for a first launch).
- Update `docs/RELEASE_READINESS.md` "Mobile release configuration" section with
  the iOS specifics.
- For future releases, consider moving the build to **Codemagic** or a
  **GitHub Actions `macos-14`** workflow so the developer never needs the Mac
  again — the manual Xcode path in section 5 is fine for v1 but doesn't scale.
