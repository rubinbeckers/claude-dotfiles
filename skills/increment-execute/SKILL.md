---
name: increment-execute
description: Runs the develop → test → review loop at increment scope. One pass per agent per cycle. Cycle budget 3; exhaustion triggers human decision. On PASS, advances to increment-close. Invoked by increment-design on Gate 2 approval, or by session-resume when resuming mid-loop.
---

# increment-execute

The central execution skill. Drives the increment through develop → test → review and handles verdicts.

## Inputs

- INDEX (active increment, current cycle)
- `increment-scope.md` (with sequencing)
- `technical-analysis.md`
- Proposed and accepted features, design specs, ADRs the increment touches
- `feedback-inbox.md` (checked at start and at each cycle boundary)
- Always-allowed set

## Outputs

- Implementation diff on the increment branch
- Unit tests (from develop), integration/UI tests (from test)
- `review.md` (per cycle, from review)
- `phase-debt.md` entries from review findings
- `progress.md` accumulating cycle outcomes
- INDEX updates per state transition

## Steps

### 1. Initialise

Read INDEX. Determine current cycle (fresh after Gate 2: cycle 1; resume after halt: from recorded position). Read `increment-scope.md`, `technical-analysis.md`, and any prior cycle's `review.md`.

### 2. Status line

```
Status: increment-execute cycle <K>/3 starting. Delegating to increment-develop.
```

Update INDEX: `current_cycle: K`, `current_step: develop`.

### 3. Delegate to increment-develop

Construct the manifest per `_meta` §4 with `mode: increment`. The manifest includes:
- `increment-scope.md`
- Proposed/accepted features and design specs for the increment
- `technical-analysis.md`
- Referenced ADRs
- Prior-increment code paths the implementation will integrate with (listed explicitly per the depends section of increment-scope)
- Prototype paths (UI-relevant only)

Invoke via Task tool.

Parse return:
- **success** → step 4.
- **halt** → route per the halt entry. Domain or technical loopbacks may invalidate the increment plan; in that case re-pass Gate 2 with the updated proposals.

### 4. Run parent-commit classification

For any failing tests the develop agent reported outside the increment's intended scope: the orchestrator runs the same tests against the increment branch's parent commit.

- Pass on parent, fail now → regression. Halt to develop (T-D-2 equivalent — dev investigates).
- Fail on parent → discovered defect. Append to `phase-debt.md`. Continue.

This step happens here, in the orchestrator. The agents don't check out the parent commit themselves.

### 5. Delegate to increment-test

Manifest:
- `increment-scope.md`
- Feature files and design specs the increment touches
- Prototype paths
- The existing tests directory path (for structure reference)

Explicitly **NOT** in the manifest: implementation diff, unit tests, technical-analysis.

Invoke. Parse return:
- **success** with no failures → step 6.
- **success** with spec-divergence failures → record findings; pass to review.
- **success** with discovered-defect findings → append to `phase-debt.md`; continue to step 6. (Test agent didn't run the parent-commit check; orchestrator did in step 4 or runs it now for any new findings.)
- **halt** → route per entry.

### 6. Delegate to increment-review

Manifest:
- `increment-scope.md`
- Feature files and design specs (accepted)
- Implementation diff (from develop)
- Unit tests (from develop)
- Integration/UI tests (from test)
- Test run results
- Referenced ADRs
- Parent-commit classification results (from step 4 and any from step 5)

Invoke. Parse return:
- **PASS** → step 7.
- **PASS_WITH_DISCOVERED_DEFECTS** → append defect specs to `defects-discovered/<slug>.md` per defect; phase-debt.md already updated; step 7.
- **FAIL** on cycle K<3 → status line indicates retry; back to step 2 with K+1; the dev agent receives the review attached to its next invocation.
- **FAIL** on cycle 3 → step 8 (budget extension prompt).
- **halt** → route per entry.

For any phase-debt entries flagged in the review, append now if not already done.

### 7. Advance to increment-close

Status line: `increment-execute complete. Advancing to increment-close.`

Update INDEX: `status: closing`. Invoke `increment-close`.

### 8. Cycle-budget extension (cycle 3 fail)

Emit the budget-extension prompt:

```
═══════════════════════════════════════════════
Cycle 3 review failed. Options:
  1. Extend budget by N cycles (logged as a DR; specify N).
  2. Abandon this increment (route to phase-design for re-scoping).
  3. Open a corrective increment to address the failures separately.

Reply with: 1 N | 2 | 3
═══════════════════════════════════════════════
```

On 1: log DR, increment K, back to step 2.
On 2: increment status → `abandoned`; route to phase-design for re-scoping.
On 3: open corrective increment per `workflow.md` §9; this increment closes as `superseded-by` the corrective one.

### 9. Feedback-triage at cycle boundaries

Between cycles, if `feedback-inbox.md` has new entries (`disposition:` empty), invoke `feedback-triage` (utility carve-out per `_meta` §7). Process dispositions:
- **BACKLOG_TWEAK** → sequencing entry amended or added in `increment-scope.md`.
- **QUEUE_NEXT_INCREMENT** → entry queued in `carry-forward/`.
- **SOLIDIFYING_DEBT** → entry appended to `phase-debt.md`.
- **FUNCTIONAL_LOOPBACK / DOMAIN_LOOPBACK / ARCHITECTURE_LOOPBACK** → halt; re-pass relevant gate.
- **WORKFLOW_OBSERVATION** → logged; continue unless critical (inline review at phase-close).
- **HUMAN_CLASSIFY** → pause loop; resume when classified.

## Edges

- INDEX state out of sync with files → human reconciliation.
- Subagent halt routed to a destination this skill can't reach → terminate the loop; route per the halt; record state.
- Feedback-triage requires human classification → pause loop.
- Cycle-3 fail without human input within reasonable window → log state; defer to next session-resume.

## Observations to surface

Recurring high cycle counts (signal: spec quality below threshold); many discovered defects (signal: adjacent code fragile); feedback-triage running long at every boundary (signal: feedback rate suggests shorter increments).
