---
name: project-pause
description: Cleanly pause a project at a defined point. Commits in-flight transient state, surfaces the project's current position, and writes a hand-off note so a future session (or a different human) can resume cleanly.
---

# project-pause

For when a project is paused for an extended period and the human wants a clean handoff point.

## Inputs

- INDEX (current state)
- All in-flight transient docs (current phase's workspace)
- Optional: a hand-off note from the human ("paused because X; pick up by doing Y")

## Outputs

- A pause record at `docs/transient/pauses/<ISO-timestamp>.md` summarising state
- Any uncommitted transient state committed to the current branch with a `chore: project-pause` message
- INDEX updated with `paused_at:` and `paused_state:`

## Steps

### 1. Capture current state

Read INDEX. Note the active phase, active increment (if any), and where in each skill's lifecycle the work paused.

### 2. Write the pause record

Author `docs/transient/pauses/<ISO>.md`:

```
# Pause: <ISO>

Active phase: <slug or "none">
Active increment: <slug or "none">
Last completed skill: <name>
Next expected skill: <name>

Outstanding items:
  - <halt or unresolved gate>
  ...

Hand-off note:
  <human's note, or "none">

Resume by: running session-resume (or "resume").
```

### 3. Commit transient state

If there are uncommitted changes in `docs/transient/` or in the current increment branch, commit them with `chore: project-pause <ISO>`. The commit message includes the pause-record path.

### 4. Update INDEX

```
paused_at: <ISO>
paused_state: <active phase / increment / position>
```

### 5. Surface

```
Project paused.
Pause record: docs/transient/pauses/<ISO>.md
Resume by running session-resume.
```

## Edges

- Halt entries unresolved at pause time → record them in the pause note; resume handles them.
- Branch not in a committable state (merge conflicts, etc.) → halt to human to resolve before pause.

## Observations to surface

Frequent pauses at the same lifecycle position (signal: that skill may be a friction point).
