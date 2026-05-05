# Counts

Counts is a native iOS SwiftUI app for tracking repeatable daily tasks with simple counters.

The app is currently focused on fast local prototyping and portfolio-quality code organization.

## Features

- Create tasks with:
  - Title
  - Frequency per day
  - Description
- Home list with native collapsing large title (`Mon, May 4` style date header)
- Task detail screen with:
  - Increment (`+`) and decrement (`-`) counter controls
  - Progress summary
  - Edit properties
  - Archive / unarchive
  - Delete with confirmation
- Archived tasks list (accessible from home toolbar)
- Native sheets for:
  - Date selection
  - Add task
  - Edit task

## Tech Stack

- Swift
- SwiftUI
- Xcode project target: `Counts`
- Local in-memory store (`TaskStore`) for current prototype iteration

## Project Structure

- `Counts/CountsApp.swift`: app entry point
- `Counts/ContentView.swift`: home screen, navigation, and sheet flow
- `Counts/TaskDetailView.swift`: task detail page with counter actions
- `Counts/AddTaskSheet.swift`: native add-task form sheet
- `Counts/EditTaskSheet.swift`: native edit-task form sheet
- `Counts/ArchivedTasksView.swift`: archived tasks list
- `Counts/TaskStore.swift`: app state and task operations
- `Counts/CountsTask.swift`: task data model

## Local Setup

### Requirements

- macOS with Xcode 16+
- iOS Simulator runtime installed

### Run in Xcode

1. Open `Counts.xcodeproj`.
2. Select the `Counts` scheme.
3. Pick an iPhone simulator (for example, iPhone 17).
4. Press `Cmd + R`.

### Build from Terminal

```bash
xcodebuild -project "Counts.xcodeproj" -scheme Counts -configuration Debug -destination "platform=iOS Simulator,name=iPhone 17" build
```

## Architecture Notes

The app uses a simple view + store approach for fast iteration:

- `TaskStore` is the source of truth for task state.
- Views subscribe to store updates with `@StateObject` / `@ObservedObject`.
- Mutations are centralized in store methods (`addTask`, `adjustCount`, `updateTask`, `archiveTask`, etc.).
- Navigation is value-driven (`NavigationLink` / `navigationDestination`) using task IDs.

For more details, see `docs/ARCHITECTURE.md`.

## Testing Status

The current phase prioritizes UI and interaction flow. Automated test targets are not set up yet.

Manual validation checklist is available in `docs/TESTING.md`.

## Roadmap

- Persist tasks to local storage (SwiftData or file-based persistence)
- Daily reset behavior for counts by date boundary
- Richer progress analytics
- Optional reminders/notifications
- Home screen widgets
- iCloud sync

## Contributing

See `CONTRIBUTING.md` for development workflow and conventions.

## License

This project is licensed under the MIT License. See `LICENSE`.
