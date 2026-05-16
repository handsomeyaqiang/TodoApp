# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is a native iOS app — there is no CLI build command. All development is done through Xcode.

- **Open project**: `open TodoApp.xcodeproj`
- **Build & run**: Use Xcode (⌘R) targeting an iOS 17+ simulator or real device
- **Minimum deployment target**: iOS 17.0
- **Required Xcode version**: 15.0+

There are no external dependencies — the project uses only Apple frameworks (SwiftUI, SwiftData, Swift Charts, UserNotifications).

## Architecture

MVVM with SwiftUI's `@Observable` macro and SwiftData for persistence.

**Data flow:**
1. `SwiftData ModelContainer` is created in `TodoAppApp.swift` and injected into the environment
2. Views fetch data directly via `@Query` (no ViewModel needed for fetching)
3. ViewModels (`@Observable` classes) hold derived/transient state: filtering, sorting, form fields
4. `NotificationService.shared` manages local push reminders — it stores a `notificationID` on each `TodoItem` to cancel/reschedule idempotently

**Key relationships:**
- `TodoItem` ↔ `Tag`: many-to-many with `.nullify` delete rule (deleting either side does not cascade)
- `Tag.name` has a unique constraint enforced case-insensitively in `TagViewModel`

**Tab structure** (`ContentView.swift`):
- Tab 1 (checklist icon): `TodoListView` — main list with filter bar, search, sort
- Tab 2 (calendar icon): `CalendarView` — month grid + per-day item list
- Tab 3 (chart icon): `OverviewView` — statistics, priority distribution, 7-day trend, upcoming items

## Conventions

- **Color storage**: Tags store colors as hex strings (`colorHex`); conversion helpers live in `Utilities/Color+Extensions.swift`
- **Date formatting**: Shared formatters are in `Utilities/DateFormatter+Extensions.swift` — use these rather than creating new `DateFormatter` instances
- **Preview data**: `Preview Content/PreviewData.swift` provides in-memory `ModelContainer` and sample objects for SwiftUI canvas previews; new views should use it
- **Notification scheduling**: Always go through `NotificationService.shared.scheduleNotification(for:)` and `cancelNotification(for:)` — never schedule `UNUserNotificationCenter` requests directly from views
