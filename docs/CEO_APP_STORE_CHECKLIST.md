# Udo → Apple App Store: Your Checklist

Companion to `APP_STORE_SUBMISSION.md` (the full technical runbook). This is just
**your** part. The developer handles everything else remotely.

Roughly: ~45 min of account setup you do alone, ~30 min on a call with the
developer at your Mac, then ~15 min to submit once everything's staged.

---

## Part 1 — App Store Connect setup (you, alone, ~30 min)

Sign in at **appstoreconnect.apple.com**.

- [ ] **Agreements, Tax, and Banking**
  - Paid Applications Agreement shows **Active** (accept it if there's a banner)
  - Bank account added
  - Tax forms completed
  - *Why it matters: the $45 in-app purchase gets rejected in review until this is done.*
- [ ] **Users and Access → Users** → invite the developer's email as **Admin**
  - *After this the developer can do the App ID, app record, and in-app purchase for you.*
- [ ] **Create the in-app purchase** (or let the developer): non-consumable,
  product ID exactly `udo_lifetime_access`, price $45
- [ ] **App Information → App-Specific Shared Secret → Generate** → send the value
  to the developer (it goes in the server config)
- [ ] **Apple Developer portal → Membership** → copy the **Team ID** → send to the developer

## Part 2 — Google sign-in (you, ~5 min)

- [ ] Google Cloud Console → project **766006747222** → **APIs & Services →
  OAuth consent screen** → if status is "Testing", click **Publish app** →
  "In production"
  - *Non-sensitive scopes, so it takes effect immediately. If left in "Testing",
    real users and the Apple reviewer can't sign in with Google.*
  - The brand-verification review you already submitted can stay pending — that's fine.

## Part 3 — On a call with the developer, at your Mac (~30 min)

- [ ] **Xcode → Settings → Accounts** → sign in with the Apple ID on the developer account
- [ ] **System Settings → General → Sharing** → turn on **Screen Sharing** and
  **Remote Login**; create a **standard user account** for the developer
- [ ] Developer installs tools, clones the repo, sets the signing team in Xcode,
  runs the build, uploads it — you mostly just watch and approve prompts

## Part 4 — Store listing (you or the developer, ~1 hr)

- [ ] **Screenshots**: iPhone 6.7" (1290×2796) and 6.5" (1242×2688).
  The screenshots we have are Google Play sizes and won't be accepted.
- [ ] Description, keywords, support URL
- [ ] **Privacy Policy URL** (the udowedding.com privacy page)
- [ ] **App Privacy** questionnaire — what data Udo collects (name, email, photos,
  purchase history)
- [ ] **Age Rating** questionnaire
- [ ] **App Review notes**: a working demo account (email + password with a
  wedding already set up) and a note that the $45 unlock is testable with a
  sandbox Apple ID
  - *The app requires login — no demo account = automatic rejection.*

## Part 5 — Submit (you, ~10 min)

- [ ] Attach the build **and** the in-app purchase to the version
- [ ] **Add for Review → Submit**
- [ ] First review usually takes 24–48 hours. Expect at least one round of
  back-and-forth — that's normal.

---

## What's already done (developer side)

- The app's iOS build is fully prepared and pushed to GitHub — icons, name
  ("Udo"), permissions text, Google sign-in wiring, in-app purchase code, a
  one-command build script.
- The server already knows how to verify Apple sign-ins and Apple purchases —
  it just needs the two values from Part 1 (shared secret, Team ID) deployed.

## The one hard dependency

Parts 1 and 2 unblock everything. The developer can't finish the build upload
until you've added them as Admin (Part 1) and created the app record, and the
app can't pass review until the server has the shared secret + Team ID and the
Google consent screen is published.
