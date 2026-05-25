---
name: backlog-loop
description: Owns the per-item iteration after Gate 2 approval. Sequences develop → test → review delegations, handles verdicts, injects discovered-defect items, runs feedback-triage at seams, writes phase-debt, and advances. Invoked by increment-start (or by session-resume when resuming mid-loop).
---

# backlog-loop

The central execution loop. After Gate 2 approves an increment's backlog, this skill drives every backlog item through develop → test → review → handle verdict. It also runs the feedback-triage seam between items, injects discovered-defect items per `workflow.md` §7.1, writes `phase-debt.md` entries from review findings, and emits the visibility lines that constitute the human's primary view of progress.

Runs as an orchestration skill in the main chat. Delegates to subagents via the Task tool. Cited under the utility-sub-skill carve-out in `_meta` §6 as the canonical executor of the backlog loop.

## Inputs

- INDEX (active increment, current backlog position)
- `increment-plan.md` (sequence of backlog items)
- `backlog/<NNN>-<slug>.md` per item (the spec)
- `feedback-inbox.md` (rolling; checked at every seam)
- `phase-debt.md` (rolling; appended to from review findings)
- Always-allowed set (`_meta` §1)

## Outputs

- Per-item lifecycle status updated in INDEX as items progress
- Backlog items injected for discovered defects per §7.1
- `phase-debt.md` entries from `backlog-review` findings
- `progress.md` (per increment) accumulating the loop's running log
- Status lines emitted to the human chat

## Steps

### Step 1 — Initialise loop state

Read INDEX. Determine starting position:

- Fresh start after Gate 2: position 1.
- Resume mid-loop after `session-resume`: position from `INDEX.active_increment.current_item_position`.
- Resume after a halt resolution: position from the halt's recorded location (typically the item that halted).

Read `increment-plan.md` to enumerate items. Validate that all referenced backlog item files exist.

### Step 2 — Process current item

For each item, in order:

#### 2.1 — Status line: starting

```
Status: Backlog item N/M (<slug>): starting. Manifest will be constructed for backlog-develop.
```

Update INDEX: `current_item_position: N`, `current_item_status: starting`.

#### 2.2 — Delegate to backlog-develop

Construct the manifest per the item spec's "Context manifest (for backlog-develop)" section. Build the prompt with the fenced manifest block per `_meta` §13 (M2 contract). Invoke via Task.

Status line on delegation: `Delegating to backlog-develop: <one-line task>. Manifest: <N> docs.`

Parse return:

- **status: success** → 2.3.
- **status: halt** → route per the halt entry per `workflow.md` §8 halt matrix. The orchestrator (this skill) holds — does not advance to 2.3 until halt resolves. Halt-resolution may invalidate remaining backlog (Gate 2 re-pass) — in that case the loop terminates and `increment-planning` re-runs.

Status line on return: `backlog-develop returned. Wrote: <files>. Key findings: <summary>.`

#### 2.3 — Run parent-commit check (M1)

For any failing tests reported by `backlog-develop`'s unit-test run that are *outside the item's intended scope*, the orchestrator runs the same test against the increment branch's parent commit. Result classified per `workflow.md` §7.1:

- Pass on parent, fail now → regression (route per T-D-2 — typically halt to dev to investigate).
- Fail on parent → pre-existing defect; append to `phase-debt.md` for the solidifying increment.

This step happens here, in the orchestrator, *not* in any subagent. `backlog-test` and `backlog-review` never check out the parent commit themselves — manifest isolation preserved.

#### 2.4 — Delegate to backlog-test

Construct the manifest per the item spec's "Context manifest (for backlog-test)" section (no implementation, no unit tests, no impl plan). Build the prompt with fenced manifest block. Invoke via Task.

`backlog-test` writes its tests and runs them (item-scope + smoke per `workflow.md` §7.2). For any failures it surfaces, it classifies per Category A/B/C/D — but for the parent-commit check, it asks the orchestrator (this skill) to perform the check on its behalf, since the orchestrator already has the result from 2.3 plus any newly-discovered failures from backlog-test's own tests.

Status lines: same pattern as 2.2.

Parse return:
- **status: success** with no failures → 2.5.
- **status: success** with Category A failures → these are spec-divergence findings; pass to `backlog-review` to disposition.
- **status: success** with Category C findings → `phase-debt.md` is appended; loop continues to 2.5.
- **status: halt** → route per matrix.

#### 2.5 — Delegate to backlog-review

Construct the manifest per the item spec's "Context manifest (for backlog-review)" section. Build the prompt with fenced manifest block. Invoke via Task.

Parse return:

- **PASS** → mark item done, advance to 2.7 (feedback seam).
- **PASS_WITH_DISCOVERED_DEFECTS** → mark item done; for each defect in the return, construct a new backlog item spec per §7.1; insert at position N+1 (references between items use slug only per M7, so no renumbering of `depends:` needed); advance to 2.7.
- **FAIL (cycle K/3)** → loop back to 2.2 (re-delegate to backlog-develop with the review attached). Increment K.
- **FAIL on cycle 3** → human gets cycle-budget extension prompt per M5. Options: (a) extend by N cycles (logged as a CDR-equivalent audit), (b) abandon item, (c) open corrective increment per §9. If extension, increment K and resume at 2.2 with an audit note. Track `correction_depth` per M5.
- **status: halt** → route per matrix.

For any phase-debt entries flagged in the review (per `backlog-review.md` step 8), append to `phase-debt.md` now.

#### 2.6 — Update INDEX

Item complete: `current_item_status: done`, `done_at: <timestamp>`, `review_cycles: K`. If item was injected mid-loop, record `injected_from: <source-item-slug>`.

#### 2.7 — Feedback-triage seam

Read `feedback-inbox.md`. If new entries exist (`disposition:` empty), invoke `feedback-triage` per its skill spec. Process its dispositions:

- BACKLOG_TWEAK → item is amended or queued; the loop respects the placement.
- QUEUE_NEXT_INCREMENT → entry is queued (writes to `docs/transient/carry-forward/` per M10) — no immediate loop impact.
- SOLIDIFYING_DEBT → `phase-debt.md` is appended — no immediate loop impact.
- FUNCTIONAL_LOOPBACK / DOMAIN_LOOPBACK / ARCHITECTURE_LOOPBACK → halt. Loop terminates; route per matrix.
- WORKFLOW_OBSERVATION → logged; loop continues unless severity=critical (inline halt for improvement-review per `workflow.md` §11).
- HUMAN_CLASSIFY → halt to human for classification; loop pauses.

#### 2.8 — Status line: advancing

```
Status: Backlog item N/M done (cycles: K, defects injected: D). Advancing to N+1.
```

### Step 3 — Termination

When position exceeds the backlog length (all items done or abandoned), the loop terminates:

```
Status: Backlog loop complete. <D> items delivered, <A> abandoned, <I> injected defect items. Advancing to increment-close.
```

Update INDEX: `current_item_position: null`, `loop_status: complete`. Orchestrator advances to `increment-close`.

If the loop terminated via a Gate 2 re-pass (halt that invalidates the backlog), instead route to `increment-planning` for re-planning.

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-BL-1 | INDEX position out of sync with `increment-plan.md` (item file missing for declared position) | human (manual reconciliation, or re-invoke `increment-planning`) |
| T-BL-2 | A delegated subagent returns a halt routed to a destination this loop can't reach (e.g., halt to `phase-business-analysis` while loop is mid-iteration) | terminate loop; route per matrix; record state so `session-resume` can pick up after loopback closes |
| T-BL-3 | `feedback-triage` returns HUMAN_CLASSIFY for ≥1 entry | pause loop; surface to human; resume when classified |
| T-BL-4 | Backlog injection at N+1 fails (collision, validation error) | human; loop pauses |
| T-BL-5 | Cycle-3 fail and no human input within reasonable window (e.g., session about to close) | log state; defer to next session-resume |

## Observations

Surface as `routine`:
- Recurring high cycle counts per item (signal: spec quality is below threshold).
- Many discovered defects injected from a single item (signal: that item's adjacent code is fragile; flag for solidifying-increment refactor).
- `feedback-triage` running long at every seam (signal: feedback rate is high; may want shorter increments).

Surface as `critical`:
- Halts of type T-BL-1 (workflow integrity broken at the loop level).
- Backlog item references a manifest path that doesn't exist (orchestrator's prompt-construction is broken; pause loop).

## Visibility notes

This skill is the human's primary view of progress. Every step emits a status line. If the human sees no status line for longer than the expected-duration band for the current subagent (T1), the loop is likely stuck — recommend Ctrl-C and `session-resume`.

End of `backlog-loop/SKILL.md`.
