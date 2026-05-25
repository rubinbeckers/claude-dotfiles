---
name: increment-close
description: Close an increment after all backlog items are delivered. Runs scoped doc-consolidation and integrity sweep, assigns final numbers to TBD records, surfaces proposed permanent-doc deltas, halts at implicit gate for human merge.
---

# increment-close

Closes an increment. Consolidates scoped transient content into permanent docs (via `doc-consolidator`), runs a scoped `doc-integrity` sweep, resolves all TBD decision-record numbers, surfaces proposed deltas, then halts at the implicit gate for the human to merge.

Runs as an orchestration skill in the main chat. Invokes utility sub-skills per the carve-out in `_meta` §6.

## Inputs

- INDEX (with current active increment, all backlog items marked done)
- All transient docs under `docs/transient/phases/<phase-slug>/increments/<inc-slug>/`
- Permanent docs (read-only at this step; deltas are proposed)
- Always-allowed set (`_meta` §1)

## Outputs

- `docs/transient/phases/<phase-slug>/increments/<inc-slug>/consolidation-proposed.md`
- `docs/transient/phases/<phase-slug>/increments/<inc-slug>/integrity-report.md`
- TBD decision records assigned final numbers
- INDEX updated: increment status flips to `closing`, then `awaiting-merge`

## Steps

### Step 1 — Verify pre-conditions

- All backlog items in this increment have status `done` in INDEX.
- No backlog item is in `review-fail` or `develop-in-progress` state.
- No unresolved halts in this increment's `progress.md` or in `workflow-observations.md` (scoped to this increment).
- All feedback-inbox entries have a recorded disposition.

If any pre-condition fails, halt with `T-IC-1` (specific condition cited).

### Step 1.5 — Full regression run

Per `workflow.md` §7.2, run the full test suite at increment-close. The per-item loop only ran item-scope + smoke; this is the comprehensive pass.

```
Status line: "Running full regression suite at increment-close."
```

Execute the project's full test suite per `testing-standards.md`. For each failure, classify per §7.1 (spec divergence / regression / discovered defect / structural).

Disposition:

- **All pass:** advance to step 2.
- **Spec divergence on item that was already marked done:** the just-closed work has a defect that escaped per-item review. Two paths: (a) if the failing test reveals a clear gap in an item still inside this increment's recent scope and the increment hasn't yet flipped to `awaiting-merge`, open a corrective backlog item via §7.1; (b) if the failure crosses increment boundaries or challenges an accepted artifact, append to `phase-debt.md` for the solidifying increment, OR open a corrective increment per §9 if severity warrants.
- **Regression:** the increment introduced a regression. Append to `phase-debt.md` for solidifying, or open a corrective increment if severity is high.
- **Discovered defect:** append to `phase-debt.md` for the solidifying increment. Do not open a new backlog item now — the increment is closing.
- **Structural error:** test infrastructure broken. Halt with `T-IC-6` (resolve before close can proceed).

Record the regression-run results in `progress.md`.

### Step 2 — Validate no TBD-* IDs remain

Per `_meta` §8 (updated by M14): increment-level decision records were numbered at Gate 2 acceptance, not here. This step is now a verification rather than an assignment.

Verify no `TBD-*` ID appears in any accepted permanent doc related to this increment. If any do, surface a critical observation — the Gate 2 numbering step failed and this is a workflow defect.

(Historical note: prior workflow versions numbered at this step. The shift to gate-time numbering eliminates the rename-everywhere step that lived here.)

### Step 3 — Invoke doc-consolidator (scoped)

Invocation cited under utility-sub-skill carve-out:

```
Invoking utility sub-skill doc-consolidator (scope: increment <inc-slug>).
```

`doc-consolidator` walks transient docs in this increment's workspace, reads `feeds-into:` headers, produces `consolidation-proposed.md`. Same pattern as `phase-close` step 2 but scoped to the increment.

### Step 4 — Invoke doc-integrity (scoped)

Invocation cited under utility-sub-skill carve-out:

```
Invoking utility sub-skill doc-integrity (scope: increment <inc-slug>).
```

Scoped checks:
- All references in this increment's outputs resolve.
- TBD-* IDs fully resolved (step 2).
- Supersession bidirectional for any records this increment superseded.
- Withdrawn/deprecated reference checks.

### Step 5 — Surface proposed deltas via structured approval prompt

Emit the increment-close approval prompt per `_meta` §13.3:

```
═══════════════════════════════════════════════
APPROVAL REQUIRED — Increment-close consolidation
Active scope: <phase-slug>/<inc-slug>

Summary of changes proposed:
  <2–3 sentence summary: how many doc-deltas across which permanent docs;
   doc-integrity verdict; full-regression result>

Files for review:
  - docs/transient/.../consolidation-proposed.md — <N> proposed deltas
  - docs/transient/.../integrity-report.md — integrity findings (<count critical>, <count routine>)
  - <regression run summary if any failures>

To approve all deltas: reply "approve".
To approve selectively: reply "approve: <list>" (delta IDs).
To reject some: reply "reject: <list with reasons>".
To request changes: reply "changes: <list>".
═══════════════════════════════════════════════
```

### Step 6 — Apply approved deltas

When the human's reply is parsed:

- Approved deltas: apply edits to permanent docs (orchestrator does this; the human never edits files directly).
- Rejected deltas: log in INDEX with rejection reason; the source transient content survives for further disposition (typically routes to `phase-debt.md` or `carry-forward/`).

### Step 7 — Commit to increment branch

Commit all approved deltas to the increment branch (`inc-<NNN>-<slug>`). The commit message references the increment slug:

```
chore(<inc-slug>): increment-close consolidation
- Approved <N> permanent-doc deltas
- Resolved <M> TBD records
- doc-integrity: clean
```

### Step 8 — Halt at implicit gate (merge)

Status line:

```
═══════════════════════════════════════════════
Increment <inc-slug> ready for merge.
PR target: develop
Files changed: <summary>
Doc-integrity: <clean | findings list>

Human action required: review the PR on develop and merge.
The workflow will resume at the next session-resume after merge.
═══════════════════════════════════════════════
```

Update INDEX: increment status flips to `awaiting-merge`. The session ends here (or stays idle).

`session-resume` at the next session detects the merge to `develop` and advances per `workflow.md` §13.

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-IC-1 | Pre-condition failure (backlog incomplete, unresolved halt, etc.) | resolve, re-invoke |
| T-IC-2 | doc-consolidator halt | resolve, re-invoke |
| T-IC-3 | doc-integrity critical finding | open corrective increment or resolve in-place if mechanical fix |
| T-IC-4 | TBD-* ID resolution conflict (e.g., chosen number already in use) | rare; halts to human |
| T-IC-5 | 3-cycle review exhaustion encountered earlier in the increment, but reached close without corrective-increment trigger | workflow defect (critical), open inline improvement-review |
| T-IC-6 | Full regression run at step 1.5 hits structural errors (test infrastructure broken) | resolve scaffolding first; may need to halt to `increment-technical-analysis` if pattern recurs |
| T-IC-7 | Full regression surfaces a critical-severity regression that can't wait for solidifying or corrective increment | inline improvement-review (critical halt); human decides whether to abandon increment, open immediate corrective, or accept-and-rollback |

## Observations

Surface as `routine`:
- Increments where consolidation produced 0 deltas (signal: transient docs not declaring `feeds-into`, or content wasn't worth absorbing).
- Increments where >3 deltas were rejected (signal: consolidator's synthesis is overshooting).
- Increments with no observations at all in workflow-observations (signal: skill discipline may have lapsed).

Surface as `critical`:
- Bidirectional supersession failures.
- TBD-* IDs found in permanent docs from prior closed increments (numbering rule violation).
