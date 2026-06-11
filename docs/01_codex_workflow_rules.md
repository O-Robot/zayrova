# Codex Workflow Rules

## Core instruction

Codex must not execute Flutter, build, git, install, analyse, or test commands.

Codex may inspect and read files in the workspace when needed.

Codex should only inspect files, propose changes, and edit files when asked. Any command that needs to be executed must be written clearly for the developer to run manually.

## Command rule

When a command is needed, Codex must respond with:

```text
Run this command manually:
<command>
```

Codex must not execute the command itself.

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
