# Codex Workflow Rules

## Core instruction

Codex may inspect and read files in the workspace when needed.

Codex should only inspect files, propose changes, and edit files when asked.

## Command rule

Codex is allowed to inspect files, read files, list folders, search the workspace, and run safe verification commands.

Allowed commands:

- flutter analyze
- flutter test
- flutter pub get
- file listing commands
- file reading commands
- workspace search commands

Codex must not run install or dependency-changing commands without approval.

Forbidden unless explicitly approved:

- flutter pub add
- flutter pub upgrade
- flutter upgrade
- pod install
- pod update
- npm install
- yarn install
- git commands
- build commands
- deployment commands
- deleting files through terminal commands
- starting the app with flutter run

If a forbidden command is needed, Codex must write:

Run this command manually:
<command>

## Before making changes

Codex must always:

1. Inspect the current files first.
2. Confirm the affected files.
3. Explain the intended change briefly.
4. Make the smallest safe change possible.
5. Avoid rewriting unrelated files.

## After making changes

Codex must provide:

- files changed
- what changed
- why it changed
- any manual command the developer should run
- any follow-up task

## Project safety rules

- Do not delete existing screens unless explicitly instructed.
- Do not remove the existing design system.
- Do not replace the folder structure with a completely different one.
- Do not introduce mock data as the final data strategy.
- Do not hardcode products, users, carts, or orders into UI screens.
- Do not create random UI that is not based on the old or new design references.
- Do not change app branding unless instructed.
- Do not add packages without explaining why they are needed first.

## Design reference rule

The folders `docs/old/` and `docs/new/` are design references.

The new design folder is the main reference.

The old design folder is a secondary reference.

Codex should compare both when working on UI, but the final app should follow the new flow.

## Communication style

Codex should be direct and practical. No long theory. No vague summaries. Every response should move the project forward.

## Progress Tracking Rule

After every completed task:

- update progress-tracker.md
- update current phase
- update current feature
- update completed work
- update next task
- suggest commit message based on work done use feat | chore | update etc

Do not skip progress tracking.

## Dependency Rule

Before adding a package:

- explain why it is needed
- explain alternatives
- wait for approval

Do not add packages automatically.
