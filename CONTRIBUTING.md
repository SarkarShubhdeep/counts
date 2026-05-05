# Contributing

Thanks for contributing to Counts.

## Development Workflow

- Keep changes focused and small.
- Prefer one logical concern per commit.
- Use clear commit messages describing intent and user impact.

## Branching

- `main` for stable history
- feature branches named like:
  - `feature/task-edit-sheet`
  - `feature/archive-flow`
  - `chore/readme-docs`

## Code Style

- Prefer native SwiftUI components and platform conventions.
- Keep view files readable by extracting sections/helpers when they grow.
- Keep business logic in `TaskStore` rather than inline in views.
- Use descriptive symbol names (`isAddTaskPresented` over ambiguous names).

## Pull Request Checklist

- [ ] App builds for simulator
- [ ] New behavior manually verified
- [ ] No debug-only placeholders left unintentionally
- [ ] Docs updated when behavior or workflow changed

## Manual QA Focus Areas

- Home list and navigation behavior
- Add/edit/archive/delete task actions
- Date sheet and toolbar actions
- Counter increment/decrement behavior
