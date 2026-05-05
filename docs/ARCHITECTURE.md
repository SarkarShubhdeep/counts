# Architecture

## Overview

Counts uses a lightweight single-target SwiftUI architecture suitable for early-stage product iteration.

Core parts:

- **Model**: `CountsTask`
- **State layer**: `TaskStore` (`ObservableObject`)
- **Screens/Views**: `ContentView`, `TaskDetailView`, sheet views

## Data Flow

1. `ContentView` owns `TaskStore` with `@StateObject`.
2. Child views receive the same store as `@ObservedObject`.
3. User actions trigger store mutation methods.
4. `@Published` task changes refresh all dependent views automatically.

## Navigation

- Root uses `NavigationStack`.
- Task detail routing is value-based with task UUID:
  - `NavigationLink(value:)`
  - `.navigationDestination(for: UUID.self)`

## Task Lifecycle

- Create via `AddTaskSheet`
- Read from active list in home
- Update in `EditTaskSheet`
- Archive/unarchive through detail and archived list actions
- Delete with explicit destructive confirmation

## Current Constraints

- Storage is in-memory only
- State resets on app restart

## Next Evolution

- Introduce persistence layer abstraction in `TaskStore`
- Add date-aware counting/reset behavior
- Add tests around store mutation rules
