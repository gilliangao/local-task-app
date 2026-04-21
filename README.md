# Task Atelier

Portfolio-ready Flutter task planner focused on clarity, visual polish, and deadline-driven planning.

## At a Glance

- Built with Flutter for macOS, iOS, Android, web, and desktop targets
- Refactored from a basic CRUD task app into a portfolio-style product experience
- Features deadline-aware planning, custom calendar UX, bilingual localization, and a polished visual system

## Overview

Task Atelier is a cross-platform Flutter app that turns a simple local task manager into a more editorial, portfolio-style productivity experience. It combines section-based planning, deadline-aware sorting, a custom calendar surface, bilingual localization, and a refined UI system built to feel intentional rather than template-driven.

## Gallery

Drop screenshots into `docs/screenshots/` using the filenames below and this section is ready to publish.

| Dashboard | Calendar | Task Dialog |
| --- | --- | --- |
| `docs/screenshots/dashboard.png` | `docs/screenshots/calendar.png` | `docs/screenshots/dialog.png` |

| List View | Completed View | Mobile Detail |
| --- | --- | --- |
| `docs/screenshots/list.png` | `docs/screenshots/completed.png` | `docs/screenshots/mobile.png` |

Recommended capture size:
- Mobile portrait: `1290 x 2796`
- Web/desktop showcase: `1600 x 1000`

Suggested README image order:
- `dashboard.png` first for hero impact
- `calendar.png` second to show the custom calendar UX
- `dialog.png` third to demonstrate form polish and deadline picking

## Highlights

- Portfolio-grade visual system with custom color palette, typography via `google_fonts`, layered backgrounds, and premium card styling.
- Deadline-aware task workflow with add/edit date picking, inline deadline display, and automatic deadline sorting.
- Custom calendar experience with monthly overview, selected-day task list, and visual task markers for active vs completed items.
- Adaptive shell behavior that gives Calendar a more immersive layout while keeping list-based tabs more editorial and dashboard-like.
- Architecture cleanup with `Provider`, `TaskController`, and `TaskRepository` separation so state, UI, and persistence stay decoupled.
- Bilingual UX with English and Chinese localization through Flutter `l10n`.
- Local-first persistence using `SharedPreferences`, keeping the experience lightweight and immediately usable.

## What Makes It Portfolio-Worthy

- Strong before/after contrast: this project evolved from a basic Flutter CRUD app into a polished product-style interface.
- Thoughtful system design: data layer, controller layer, reusable widgets, and themed surfaces are separated cleanly.
- Demonstrates product taste, not just implementation: hierarchy, copywriting, motion-ready layout, and component consistency were all considered.
- Shows practical frontend judgment: the UI works across constrained test viewports while still feeling rich on real devices.

## Feature Set

- Organize tasks into `Today`, `Short Term`, `Long Term`, `Calendar`, and `Completed`
- Add, edit, delete, and complete tasks
- Assign optional deadlines with date picker support
- View tasks sorted by deadline
- Browse tasks on a custom calendar page
- Clear completed tasks in bulk
- Switch language between English, Chinese, or system locale

## Tech Stack

- Flutter
- Dart
- Provider
- SharedPreferences
- Flutter l10n
- Google Fonts

## Product Decisions

- Deadlines are optional, but once added they become a primary organizing signal.
- Calendar is treated as a first-class planning surface rather than a secondary filter view.
- The app stays local-first to keep onboarding friction low and make the UX immediately testable.
- UI polish focuses on hierarchy, spacing, and presentation quality so the project reads well in a portfolio.

## Project Structure

```text
app/lib/
├── app.dart
├── main.dart
├── controllers/
│   └── task_controller.dart
├── models/
│   └── task_item.dart
├── pages/
│   ├── calendar_page.dart
│   └── home_page.dart
├── repositories/
│   └── task_repository.dart
├── widgets/
│   ├── task_dialog.dart
│   └── task_list_page.dart
└── l10n/
```

## Run Locally

```bash
cd app
flutter pub get
flutter run
```

## Open In Xcode

```bash
cd app
open ios/Runner.xcworkspace
```

For macOS:

```bash
cd app
open macos/Runner.xcworkspace
```

## Quality Checks

```bash
cd app
flutter analyze
flutter test
```

## Notes For Showcase Publishing

- Use the root README for GitHub presentation.
- Export 4 to 6 clean screenshots with consistent spacing and light background framing.
- Lead with `dashboard.png` and `calendar.png` if you only show two images.
- If you publish this as a case study, emphasize the UI upgrade, deadline workflow, and architecture refactor.

## Future Extensions

- Sync tasks to cloud storage or a backend service
- Add filtering, search, and overdue task views
- Add analytics cards with weekly completion trends
- Package macOS output as a cleaner distributable build for demo sharing

## License

This project is private and not licensed for public use.
