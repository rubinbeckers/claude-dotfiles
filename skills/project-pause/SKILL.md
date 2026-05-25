---
name: project-pause
description: Pause the project cleanly mid-flow. Records a paused state in INDEX with a one-page summary so a future session can resume without confusion. Use when work needs to stop for an extended period without abandoning the project.
---

# project-pause

Clean pause. Records the current state in INDEX so that a later `session-resume` can pick up exactly where things left off, even months later. Does not abandon work; does not modify in-flight artifacts.

Runs in the main chat. Does not delegate.

## Inputs

- `INDEX.md`
- All active transient docs in the current phase / increment workspace
- Always-allowed set (`_meta` §1)

## Outputs

- `INDEX.md` updated with `status: paused` on the active phase/increment
- `docs/transient/phases/<phase-slug>/pause-summary.md` — one-page snapshot
- Any in-flight subagent work is *not* paused mid-flight; the skill waits for the current subagent to return, or halts if a subagent is active

## Steps

### Step 1 — Verify no active subagent

If the orchestrator has an in-flight Task call, halt with `T-PP-1`. Pausing during a subagent run leaves the subagent's return unhandled. The human must wait for subagent return, or interrupt manually before invoking pause.

### Step 2 — Snapshot active state

Read INDEX for active phase and active increment. Read the active transient workspace (phase or increment level).

Produce `pause-summary.md`:

```
# Pause summary
Paused: <ISO timestamp>
Active phase: <slug> (status: <status>)
Active increment: <slug or "none"> (status: <status>)

## Where we are
<2-3 sentences: what was just completed, what was about to happen>

## Outstanding halts
<list of unresolved halts in workflow-observations.md, or "none">

## Backlog state (if active increment)
- Items delivered: <list>
- Item in progress: <slug or "none">
- Items pending: <list>

## Pending feedback inbox entries
<list of entries not yet triaged, or "none">

## To resume
Run session-resume. It will route to: <expected next skill>
```

### Step 3 — Update INDEX

Append a `status: paused` flag to the active phase and active increment entries in INDEX. Add a `paused_at: <timestamp>` field. Add `pause_summary: <path>` reference.

### Step 4 — Commit

`git commit` on `develop` (or the active increment branch if work is on a branch):

```
chore: project-pause at <phase>/<increment>
```

### Step 5 — Status summary

Emit to human:

```
═══════════════════════════════════════════════
Project paused.
Active phase: <slug>
Active increment: <slug or "none">
Pause summary: docs/transient/phases/<phase-slug>/pause-summary.md
To resume: invoke session-resume at any later session.
═══════════════════════════════════════════════
```

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-PP-1 | Subagent currently in flight | human (wait for return) |
| T-PP-2 | No active phase to pause (project already idle) | human (no-op) |
| T-PP-3 | INDEX malformed | human |

## Resuming

`session-resume` recognises `status: paused` in INDEX and routes the same way it would for the recorded `last_action`. The pause-summary.md is read by the human (not the skill) to refresh context. The workflow itself reads from INDEX and proceeds.
