# Testing Guide

## Current Test Strategy

This iteration uses manual testing for UI and flow verification.

## Manual Test Checklist

### Home

- Date title appears in large navigation style
- Title collapses to inline while scrolling
- Archive button opens archived sheet
- Calendar button opens date sheet

### Add Task

- Plus button opens native add sheet
- Empty title cannot be saved
- Valid task appears in active list after save

### Task Detail

- Tapping a task opens detail page
- `+` increments count
- `-` decrements count and never goes below zero
- Edit properties updates list/detail values
- Archive moves task out of active list
- Delete removes task and returns to list

### Archived

- Archived tasks are visible in archived sheet
- Unarchive returns task to active list
- Delete removes archived task permanently

## Build Verification

Run:

```bash
xcodebuild -project "Counts.xcodeproj" -scheme Counts -configuration Debug -destination "platform=iOS Simulator,name=iPhone 17" build
```
