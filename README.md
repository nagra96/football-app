# Site Buddy 👷

A focus timer for tradespeople and freelancers — knock out your admin (quotes, invoices, social posts) in short "On the Clock" sessions, earn materials, and build out Buddy the Apprentice's workshop, garage, and van.

Two implementations live in this repo:

- **`mobile/` — the Flutter app (iOS-first, primary).** Adds the mini buddy guard crew that keeps you away from distracting apps. See [mobile/README.md](mobile/README.md).
- **Repo root — the original React web MVP** (the sections below).

## MVP feature set

- **On the Clock timer** — 25/45/60 min Pomodoro-style focus sessions, tagged by category (invoicing, quoting, social, admin) or linked directly to a job on your list.
- **Buddy the Apprentice mascot** — reacts to idle / working / paused / celebrating states.
- **Job list** — lightweight task tracking for quotes to send, invoices to chase, and other admin, with sessions logged against each task.
- **Workshop / Garage / Van builder** — spend materials earned from completed sessions to unlock decorations across three zones.
- **Focus Mode reminders** — pick the apps that distract you (Instagram, TikTok, etc.); a banner reminds you to keep them closed during a session, with a nudge if you switch away and back. True OS-level app blocking needs a native (iOS/Android) build — see below.
- All state is persisted to `localStorage`, no backend required.

## Getting started

```bash
npm install
npm run dev
```

```bash
npm run build   # production build
npm run lint    # oxlint
```

## Project structure

```
src/
  components/     Timer, Tasks, Workshop, Settings screens + Mascot
  store/           AppStore (context + reducer) and localStorage persistence
  data/catalog.ts  Session durations, task types, workshop item catalog
  types.ts         Shared types
```

## Path to native app blocking

Real distraction blocking (iOS Screen Time API / Android UsageStats + Digital Wellbeing) requires a native shell. The recommended next step is wrapping this same React codebase in Capacitor (or rebuilding the timer/mascot/workshop screens in Swift/SwiftUI + Flutter) and adding a native plugin for app blocking during an active session. The current web MVP ships the full reward loop and UX so that native work can focus purely on the blocking integration.
