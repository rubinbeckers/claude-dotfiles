---
name: session-resume
description: The canonical entry point for any session that isn't a fresh project init. Reads INDEX, validates skill pins, scans git on the operating branch, and routes to the correct next skill. Invoked by the human saying "resume" or any unspecified opening.
---

# session-resume

The orchestrator's router. Every session that isn't `project-init` starts here.

## Inputs

- `docs/INDEX.md`
- `docs/skill-versions.lock`
- Git state on `develop` and on the active increment branch (if any)
- The human's opening message (which may be empty, "resume", or substantive input)

## Outputs

- Routing decision (which skill to invoke next, or which question to surface to the human)
- INDEX updates if state has advanced since the last session (e.g., a PR merged externally)

## Steps

### 1. Validate pins and surface TBD aging

Read `docs/skill-versions.lock`. Check that every referenced skill and template version is reachable. Mismatch halts with two options for the human (override → log as a DR; rollback → restore pinned versions or roll back the project's pin).

Then scan the active phase's proposed artifacts (under `docs/permanent/...` with `status: proposed`) for `TBD-*` IDs that pre-date the most recent `gate_status:` entry in INDEX. A `TBD-*` ID surviving past its gate is a `doc-integrity` failure waiting to happen — surface them now so they don't blindside the next close gate:

```
⚠ Aging TBD-* IDs detected (older than the most recent gate):
  - <artifact path>: <TBD-slug>  (introduced <ISO>, gate-N decided <ISO>)
  ...

These should have been numbered at their gate. Possible causes: gate walked away mid-approval, or an artifact authored after the gate slipped past the numbering step. Recommend resolving before next close.
```

Don't halt — just surface. The routing decision in step 5 proceeds normally; the aging warning is informational so the human can clean up at the next gate.

### 2. Apply staged skill diffs

Per the staging rule in `phase-close`: if any diffs were staged at the end of the prior session (because they targeted critical-path skills like `_meta`, `session-resume`, or `increment-execute`), apply them now before any routing decision. The session then continues with the updated skills loaded.

### 3. Scan git

Fetch the operating branch (typically `develop`). Compare the current state to what INDEX expects:

- Active increment branch present? Merged?
- Any fix branches on the increment? Their status?
- Undocumented commits on `develop` since the last recorded state? (If yes, halt — those need to be backfilled into the audit trail before routing proceeds.)

### 4. Read INDEX state and parse the human's input

Read the active phase, the active increment (if any), and the most recent `gate_status:` entries. Note the human's opening message:

- Empty, or generic ("resume", "continue") → no new directive.
- Substantive content (a fix request, an approval, a rejection, a new question) → carry it into routing.

### 5. Route

| INDEX state | Human input | Action |
|---|---|---|
| No active phase | Any | Wait for raw input; if provided, invoke `phase-design`; otherwise prompt. |
| Phase `design`, Gate 1 pending | Any | Resume `phase-design` at its gate step. |
| Phase `in-progress`, no active increment | Any | Invoke `increment-design` for next increment in plan. |
| Increment `design`, Gate 2 pending | Any | Resume `increment-design` at its gate step. |
| Increment `in-progress` | Any | Resume `increment-execute` at the last recorded position. |
| Increment `closing` | Any | Resume `increment-close` at the last step. |
| Increment `awaiting-merge` | No new input directed at the increment | Assume approval; flip status to `closed`; advance to next `increment-design` (or to `phase-close` if this was the last increment in the phase). |
| Increment `awaiting-merge` | Fix request | Re-invoke `increment-close` at step 9 (the listen step), passing the human's input as if it had just arrived in chat. The skill handles the fix per its step 10–11. |
| Increment `awaiting-merge` | Explicit approval | Re-invoke `increment-close` at step 9 with the approval input; the skill advances to step 12. |
| Increment `awaiting-merge` | CI failure report on a fix branch | Re-invoke `increment-close` at step 9 with the CI log as part of the input; the skill re-invokes `increment-develop` in `mode: fix` with the CI log in the manifest, on the existing fix branch. |
| Increment `awaiting-merge` | Input describes a new increment or scope (raw input for the next thing, a feature request, a substantive direction change) | **Halt — no implicit approval.** Surface the routing ambiguity to the human and ask them to explicitly resolve the current increment first: (a) "approved" / "ship it" → flip to `closed`, then advance with the new input; (b) "reject: <reason>" → route per the rejection's destination; (c) "fix: <description>" → handle as a fix request and re-prompt for the new direction after. Also list any open fix branches on the increment so the human can clean them up before pivoting. |
| Phase `closing` | Any | Resume `phase-close` at the last step. |

### 6. Surface routing

Emit a status line stating the routing decision:

```
Routing: <skill or action>
Active phase: <slug>
Active increment: <slug or "none">
Reason: <one-line>
```

## Edges

- Pin mismatch → halt with override/rollback options.
- Undocumented `develop` commits → halt; route to corrective-increment backfill or ask the human to clarify.
- INDEX corruption (parse failure, contradictory state) → halt to human.
- Git unavailable or repo state unreadable → halt to human (environment issue).

## Observations to surface

INDEX drift detected and corrected (signal: a prior session crashed or was interrupted before recording a state change); recurring pin mismatches (signal: the dotfiles repo and project are versioning out of sync).
