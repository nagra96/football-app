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

The iOS project is set up with display name **Site Buddy** (bundle org `com.sitebuddy`). The Runner builds unmodified from the standard Flutter template except for the app-block platform channel described below.

## Real app blocking on iOS (roadmap)

True app blocking uses Apple's Screen Time stack — `FamilyControls`, `ManagedSettings`, and `DeviceActivity` — which requires the `com.apple.developer.family-controls` entitlement granted by Apple to a real bundle ID.

The plumbing is already in place:

- Dart side: `lib/services/app_block.dart` calls the `sitebuddy/appblock` method channel (`isBlockingAvailable`, `startShield`, `stopShield`) and degrades gracefully.
- Native side: `ios/Runner/AppDelegate.swift` registers the channel and currently reports blocking unavailable.

Until the entitlement is approved, the app runs in **guard reminder mode**: the crew watches the session, and app-switches are detected via the app lifecycle and called out. To ship full blocking, request the entitlement, then replace the stubbed channel handler with a `ManagedSettingsStore` shield + `FamilyActivityPicker` selection.

## Web build note

`web/index.html` pins `canvasKitBaseUrl` to the locally bundled CanvasKit and the Roboto variable font is bundled as an asset (`assets/fonts`, SIL OFL 1.1 — see `assets/fonts/OFL.txt`), so the web build runs fully offline with no CDN dependency.
