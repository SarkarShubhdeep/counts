# First TestFlight Release — Counts

Plan to install **Counts** on your iPhone via TestFlight (internal testing, solo developer).

Use this for the **first upload**. After that, repeat from [Phase 4](#phase-4-upload-a-build-from-xcode) whenever you need a fresh build (every ~90 days, or when you ship changes).

---

## Project reference

| Item | Value |
|------|-------|
| App name | Counts |
| Bundle ID | `sarkar.shubhdeep.Counts` |
| Team ID | `Z62938YSA8` |
| Marketing version | `1.0` |
| Build number | `1` (increment for each upload) |
| Min iOS | 26.2 |
| Xcode project | `Counts.xcodeproj` |
| Scheme | `Counts` |
| GitHub | https://github.com/SarkarShubhdeep/counts |

---

## What you are setting up

```text
Mac (Xcode)  →  Archive + Upload  →  App Store Connect  →  TestFlight app on iPhone
GitHub       →  source backup only (not connected to Apple unless you add CI later)
```

- **GitHub** stores code. Pushing does not update TestFlight.
- **TestFlight** distributes a signed Release build. No USB cable after the first install.
- **Internal testing** = only you (and up to 99 other App Store Connect users on your team). No Beta App Review required.

Each TestFlight build lasts **90 days** from upload. Upload a new build before expiry and tap **Update** in the TestFlight app.

---

## Phase 0 — Prerequisites

- [x] **Apple Developer Program** enrolled ($99/yr)
- [ ] **Apple ID** used for enrollment matches the one signed into Xcode (**Settings → Apple Accounts**)
- [ ] **iPhone** on a compatible iOS version (26.2+ for this project’s deployment target)
- [ ] **TestFlight** app installed on iPhone ([App Store link](https://apps.apple.com/app/testflight/id899247664))
- [x] On **`main`** branch with a clean working tree before archiving

```bash
cd Counts
git checkout main
git pull
git status   # should be clean
```

> **Verified 2026-05-23:** On `main`, up to date with `origin/main` at `a58285b`. No modified or staged tracked files. Only untracked: `docs/TESTFLIGHT_RELEASE.md` (this guide — commit it before archive if you want a fully clean `git status`).

---

## Phase 1 — One-time App Store Connect setup

- [x] **1.1** Accept agreements
- [x] **1.2** Register bundle ID `sarkar.shubhdeep.Counts`
- [x] **1.3** Create app record in App Store Connect
- [x] **1.4** Confirm your Apple ID in Users and Access (Internal Testing group comes in Phase 5)

### 1.1 Accept agreements

1. Open [App Store Connect](https://appstoreconnect.apple.com)
2. If prompted, accept **Apple Developer Program License Agreement**
3. Go to **Agreements, Tax, and Banking** — accept **Paid Applications Agreement** (required even for free apps before first upload)

### 1.2 Register the bundle ID (if not already)

1. [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) → **Identifiers** → **+**
2. Type: **App IDs** → **App**
3. Description: `Counts`
4. Bundle ID: **Explicit** → `sarkar.shubhdeep.Counts`
5. Enable only capabilities you actually use (Counts needs none extra for v1 — no Push, iCloud, etc.)
6. **Register**

If Xcode already created this automatically when you built with your paid team, it may already exist.

### 1.3 Create the app record

1. App Store Connect → **Apps** → **+** → **New App**
2. **Platforms:** iOS
3. **Name:** Counts (App Store display name; can differ slightly from home screen name)
4. **Primary language:** English (U.S.) or your preference
5. **Bundle ID:** `sarkar.shubhdeep.Counts`
6. **SKU:** any unique string you never change (e.g. `counts-ios-001`)
7. **User access:** Full access
8. **Create**

You do **not** need a complete App Store listing for internal TestFlight. You **do** need a valid app record and uploaded build.

### 1.4 Add yourself as an internal tester

1. App Store Connect → **Users and Access**
2. Confirm your Apple ID is listed with a role that can test (Admin, App Manager, Developer, or Marketing)
3. Later, in the app’s **TestFlight** tab, you’ll add yourself to an **Internal Testing** group (Phase 5)

---

## Phase 2 — Xcode signing check

1. Open `Counts.xcodeproj`
2. Select **Counts** target → **Signing & Capabilities**
3. Confirm:
   - [ ] **Automatically manage signing** is on
   - [ ] **Team** is your paid team (not “Personal Team”)
   - [ ] **Bundle Identifier** = `sarkar.shubhdeep.Counts`
4. **General** tab:
   - [ ] **Version** = `1.0`
   - [ ] **Build** = `1` (bump build for every TestFlight upload: `2`, `3`, …)

---

## Phase 3 — Pre-upload checklist (Counts-specific)

Run through `docs/TESTING.md` on a **real device** (not Simulator only):

- [ ] Create, edit, archive, and delete tasks
- [ ] Counter +/- works; count never goes below zero
- [ ] SwiftData persists tasks after force-quit and relaunch
- [ ] Activity grid on task detail loads without crash
- [ ] Settings (theme, accent, reset) work
- [ ] App icon appears on home screen
- [ ] No debug-only crashes or placeholder UI

**Release configuration:**

- [ ] Scheme **Counts** → **Edit Scheme** → **Run** / **Archive** use **Release** for Archive (default)
- [ ] Archive destination: **Any iOS Device (arm64)** — not a simulator

**Optional but recommended before upload:**

```bash
git add -A && git status
git commit -m "Prepare TestFlight build 1.0 (1)"
git push origin main
```

Tag builds in git if you want traceability:

```bash
git tag testflight/1.0-1
git push origin testflight/1.0-1
```

---

## Phase 4 — Upload a build from Xcode

### Archive vs Xcode Cloud (important)

| | **Product → Archive** (use this) | **Xcode Cloud “Start Build”** |
|--|----------------------------------|--------------------------------|
| Builds on | Your Mac | Apple’s servers |
| Needs GitHub scheme in repo | No | **Yes** — shared `Counts.xcscheme` committed |
| Best for first TestFlight | **Recommended** | Optional; more setup |

If you see **“Counts is now configured for Xcode Cloud”** with a **Start Build** button, that is **not** the same as Archive. For this guide:

1. Click **Close** on that dialog (you can use Xcode Cloud later).
2. Use **Product → Archive** below.

Xcode Cloud often appears to “do nothing” when the **Counts** scheme was only on your Mac (`xcuserdata/`, gitignored) and not in GitHub. A shared scheme is now at `Counts.xcodeproj/xcshareddata/xcschemes/Counts.xcscheme` if you want Cloud later.

### 4.1 Archive

1. Connect iPhone or select **Any iOS Device (arm64)** in the device menu
2. **Product → Archive** (not **Integrate → Xcode Cloud → Start Build**)
3. Wait for **Organizer** to open with the new archive

If Archive is greyed out, select a real device or “Any iOS Device”, not a simulator.

### 4.2 Validate (recommended)

1. In **Organizer**, select the archive → **Validate App**
2. Fix any errors before distributing

### 4.3 Upload

1. **Distribute App**
2. **App Store Connect** → **Upload**
3. Defaults are usually fine:
   - Include bitcode: N/A on modern Xcode
   - Upload symbols: **Yes** (helps crash reports)
   - Manage version and build number: **Yes** (Xcode can auto-increment build)
4. **Export compliance — encryption**

   Counts uses standard Apple APIs and local SwiftData only. Typical answer:

   - **Does your app use encryption?** → **Yes** (HTTPS/OS APIs count)
   - **Is it exempt / only standard encryption?** → **Yes** — uses only standard encryption

   You can add to `Info.plist` later to skip the prompt every upload:

   ```xml
   <key>ITSAppUsesNonExemptEncryption</key>
   <false/>
   ```

5. Complete upload; wait for “Upload Successful”

### 4.4 Wait for processing

1. App Store Connect → **Apps** → **Counts** → **TestFlight** tab
2. Build appears under **iOS** with status **Processing** (often 5–30 minutes; sometimes longer)
3. When status is **Ready to Submit** / available for testing, continue

If the build is **Missing Compliance**, open the build in TestFlight and answer the export compliance question there.

---

## Phase 5 — Enable internal TestFlight

1. **TestFlight** tab → **Internal Testing** (left sidebar)
2. **+** to create a group (e.g. `Internal`)
3. **Add Builds** → select build `1.0 (1)`
4. **What to Test** (shown to testers):

   ```text
   First internal build. Please verify task creation, daily counters,
   activity grid, archive flow, and settings. Data is stored locally on device.
   ```

5. Add yourself as an internal tester if not auto-included
6. Enable **Automatic Distribution** on the group if you want future uploads to go to testers without manual steps

Internal builds are available to testers **immediately** after processing — no Beta App Review.

---

## Phase 6 — Install on your iPhone

1. Check email for **TestFlight invitation** (or open TestFlight — internal apps often appear automatically)
2. Open **TestFlight** on iPhone
3. Tap **Counts** → **Install** or **Accept**
4. Open Counts from home screen (TestFlight may show “Open”)

**First launch:** iOS may ask you to trust the developer — normal for TestFlight.

**Data note:** If you previously installed via Xcode with the same bundle ID, SwiftData may carry over. If behavior is odd after switching install methods, delete the old app once and reinstall from TestFlight.

---

## Phase 7 — Ongoing maintenance

### When to upload a new build

| Reason | Action |
|--------|--------|
| Bug fixes or new features | Bump **build** number → Archive → Upload |
| Approaching 90-day expiry | Upload any fresh build (can be same code, new build number) |
| TestFlight shows “Expired” | Upload new build; tap **Update** in TestFlight |

### Version vs build

- **Version** (`1.0`, `1.1`): user-visible; change when you ship meaningful releases
- **Build** (`1`, `2`, `3`): must **increase every upload**; users usually don’t see it

Example next upload: Version `1.0`, Build `2`.

### Suggested rhythm (solo dev)

```text
1. Develop on main (or feature branch → merge to main)
2. git push
3. Bump CURRENT_PROJECT_VERSION in Xcode (or let Xcode auto-increment on upload)
4. Archive → Upload
5. TestFlight → Update on phone
```

Set a calendar reminder ~**80 days** after each upload to refresh before expiry.

---

## Phase 8 — Troubleshooting

| Problem | Likely fix |
|---------|------------|
| “Personal Team” / 7-day expiry still happening | Select paid **Team** in Signing; reinstall from TestFlight, not USB |
| Archive greyed out | Select **Any iOS Device**, not Simulator |
| Bundle ID mismatch | App Store Connect app must use exact `sarkar.shubhdeep.Counts` |
| Build stuck “Processing” | Wait up to 24h; check email for Apple issues |
| Missing Compliance | Answer encryption questionnaire on the build in TestFlight |
| “No builds available” for internal group | Add build to internal group manually; confirm processing finished |
| Install fails in TestFlight | Same Apple ID on phone as App Store Connect user; reinstall TestFlight app |
| App crashes on launch (Release only) | Test **Product → Scheme → Edit → Run → Release** on device; check crash logs in Xcode Organizer |

---

## What you are NOT doing yet

These are for **App Store public release**, not required for internal TestFlight on your phone:

- App Store screenshots and full product page copy
- Public App Review submission
- Privacy policy URL (required for **App Store**; good to add before public release)
- App Privacy nutrition label (required for **App Store** submission)

You can fill those in later when you’re ready to ship publicly.

---

## Quick checklist (printable)

**One-time**

- [x] Agreements signed in App Store Connect
- [x] App record created for `sarkar.shubhdeep.Counts`
- [ ] Paid team selected in Xcode signing
- [ ] TestFlight app on iPhone

**Every upload**

- [ ] Code tested on device
- [ ] `git push` to `main`
- [ ] Build number incremented
- [ ] Product → Archive → Upload
- [ ] Build processed in App Store Connect
- [ ] Build added to Internal Testing group
- [ ] Update installed via TestFlight on iPhone

---

## Official Apple docs

- [TestFlight overview](https://developer.apple.com/testflight/)
- [Distribute an app using TestFlight (Xcode)](https://help.apple.com/xcode/mac/current/en.lproj/dev2539d985f.html)
- [Add internal testers](https://developer.apple.com/help/app-store-connect/test-a-beta-version/add-internal-testers)
- [Submitting to the App Store](https://developer.apple.com/app-store/submitting/) (when you go public)

---

## After first successful install

1. Delete the USB-installed dev copy if you still have one (optional; avoids confusion)
2. Use TestFlight as your daily driver until you publish to the App Store
3. Note the upload date; set a reminder for day ~80 to upload build `(2)`
