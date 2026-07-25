# Site Buddy — Flutter app 👷

The native Site Buddy app: a focus timer for tradespeople and freelancers, built with Flutter for **iOS first** (Android and web builds work from the same codebase).

## Features

- **On the Clock timer** — 25/45/60 min focus sessions, tagged by category or linked to a job. The countdown is anchored to wall-clock time (`endsAt`), not counted ticks, so it stays correct when iOS suspends the app; a session that finishes while the app is closed pays out on next launch.
- **Buddy the Apprentice** — custom-painted mascot with idle / working / paused / celebrating moods and animations.
- **Mini buddy guard crew** — six miniature buddies (Nut, Bolt, Rivet, Sprocket, Chip, Washer). Every distracting app you block gets a guard assigned; during a session the guards visibly "sit on" your apps. If you leave the app mid-session, the guard catches you when you come back, calls you out, and the distraction is tallied. Swap guards per app from the Crew tab.
- **Job list** — quotes to send, invoices to chase; sessions log against jobs.
- **Workshop / Garage / Van** — spend materials earned from sessions on 15 unlockable items.
- Persistence via `shared_preferences`; light + dark theme; state restores across launches, including a running session.

## Running

```bash
flutter pub get
flutter run              # device/simulator of your choice
flutter test             # 9 unit + widget tests
flutter analyze
```

### iOS

```bash
cd ios && pod install    # first time, on macOS
flutter run -d <iphone>
flutter build ipa        # release
```

The iOS project uses display name **Site Buddy**, bundle ID **`com.sitebuddy.app`**, deployment target iOS 16.

## Real app blocking on iOS (Screen Time)

App blocking is fully implemented with Apple's Screen Time stack:

- **Native** (`ios/Runner/AppDelegate.swift`): `AuthorizationCenter` authorization, the system `FamilyActivityPicker` for choosing which apps to shield (selections are opaque tokens — the app never learns which apps were picked), and a `ManagedSettingsStore` shield raised for the length of each focus session.
- **Dart** (`lib/services/app_block.dart` + Crew tab): shows "Enable Screen Time access" → "Choose apps to shield" when the build supports blocking, and falls back to guard reminder mode everywhere else (web, tests, Android for now).
- **Entitlement**: `ios/Runner/Runner.entitlements` declares `com.apple.developer.family-controls`, wired into all Runner build configurations.

### Shipping checklist

1. **Register the bundle ID** `com.sitebuddy.app` in [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) (or change `PRODUCT_BUNDLE_IDENTIFIER` in the Xcode project to one you prefer — it appears once per build configuration).
2. **Development builds work immediately**: open `ios/Runner.xcworkspace`, select your team under Signing & Capabilities (Xcode will add the Family Controls *(development)* capability from the entitlements file), and `flutter run` on a device. Screen Time APIs need a physical device — the simulator can't authorize.
3. **Request the distribution entitlement** at [developer.apple.com/contact/request/family-controls-distribution](https://developer.apple.com/contact/request/family-controls-distribution), signed in as the Account Holder, for `com.sitebuddy.app`. Describe the app as a personal digital-wellbeing focus timer where users voluntarily shield their own distracting apps during self-started focus sessions, with no collection of usage data for advertising or profiling. Typical turnaround is days to a few weeks.
4. Once approved, enable Family Controls (distribution) on the App ID, regenerate provisioning profiles, and `flutter build ipa`.

Known edge: if the app is force-quit mid-session, the shield stays up until the next launch reconciles the expired session. Scheduling `DeviceActivityMonitor` (same entitlement family) to auto-lower the shield at the session's end time is the natural follow-up.

## Web build note

`web/index.html` pins `canvasKitBaseUrl` to the locally bundled CanvasKit and the Roboto variable font is bundled as an asset (`assets/fonts`, SIL OFL 1.1 — see `assets/fonts/OFL.txt`), so the web build runs fully offline with no CDN dependency.
