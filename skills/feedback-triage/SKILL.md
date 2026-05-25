---
name: feedback-triage
description: Classify and route feedback inbox entries. Runs between backlog items during an increment. Decides whether feedback handles in-scope, defers to next increment, or escalates upstream as a halt.
---

# feedback-triage

Reads the feedback inbox and classifies each unprocessed entry to the right level. Runs between backlog items (never mid-item). The skill is mechanical when classification is reference-based; halts to human when ambiguous.

Runs as an orchestration skill in the main chat. Does not delegate.

## Inputs

- `docs/transient/phases/<phase-slug>/increments/<inc-slug>/feedback-inbox.md`
- Current increment scope: `increment-scope.md`
- Current backlog: `backlog/` directory
- Permanent docs referenced by classifications (capabilities, features, ADRs)
- Always-allowed set (`_meta` §1)

## Outputs

- Updated `feedback-inbox.md` with each entry annotated with its disposition
- New or modified backlog items (for in-scope tweaks)
- Halt entries (for upstream escalations)
- Queue entries in `docs/transient/phases/<phase-slug>/next-increment-queue.md` (for out-of-scope additive items)

## Steps

### Step 1 — Read inbox

Parse `feedback-inbox.md`. Each entry has:
```
- id: <auto>
  added_at: <timestamp>
  by: <human>
  text: <freeform>
  references: <optional: artifact paths the human pointed to>
  disposition: <empty until triage>
```

Process only entries with empty `disposition`.

### Step 2 — Classify each entry

For each new entry, determine the lowest artifact level the feedback touches. The classification rules:

```
Rule 1 — Backlog-item-only
If feedback references only:
  - the current or pending backlog items
  - implementation details (code, files modifiable within an item's scope)
  - UI tweaks (copy, color, spacing) on screens covered by pending items
→ Disposition: BACKLOG_TWEAK
Sub-cases:
  a) Backlog item not yet started → amend the item's spec in place
  b) Item in flight (develop in progress) → queue as immediate next backlog item
     (do NOT modify the in-flight item's spec mid-flight)
  c) Item already in review or done → queue as a new backlog item

Rule 2 — Out-of-scope additive
If feedback references:
  - a capability or feature not in this increment but compatible with phase plan
  - a new behavior that doesn't conflict with anything delivered
→ Disposition: QUEUE_NEXT_INCREMENT
Add to docs/transient/phases/<phase-slug>/carry-forward/queued-for-next-increment.md
The carry-forward mechanism (workflow.md §15.6) ensures phase-planning sees this when assembling
the next phase's increments. Items not picked up by the immediate next increment in the same phase
relocate to the next phase's workspace at phase transition.

Rule 3 — Functional gap
If feedback challenges:
  - a feature definition in scope
  - a BDD scenario in scope
  - a design-spec requirement in scope
→ Disposition: FUNCTIONAL_LOOPBACK
Halt the workflow. Route to: increment-functional-analysis loopback (re-passes Gate 2).
Note: this invalidates remaining backlog items in the increment until FA re-runs.

Rule 4 — Domain gap
If feedback challenges:
  - a capability (any in this phase or prior)
  - an aggregate
  - a glossary term
→ Disposition: DOMAIN_LOOPBACK
Halt the workflow. Route to: corrective-increment per workflow.md §9.
The current increment cannot resolve this; a corrective increment is opened after current increment closes (or current increment is abandoned if early enough).

Rule 5 — Architecture gap
If feedback challenges:
  - an ADR (any in this phase or prior)
  - architecture, database model, tech-stack decision
→ Disposition: ARCHITECTURE_LOOPBACK
Halt the workflow. Route to: corrective-increment per workflow.md §9.

Rule 6 — Workflow defect
If feedback describes a workflow issue (gate skipped, halt mechanism missing, observation pattern):
→ Disposition: WORKFLOW_OBSERVATION
Append to workflow-observations.md with severity flag per the human's description.
If severity=critical, halt for inline improvement-review.

Rule 6.5 — Solidifying-scope cleanup
If feedback describes cleanup, refactoring, dead-code removal, or test-suite hygiene
that is not tied to a specific in-scope behavior:
→ Disposition: SOLIDIFYING_DEBT
Append entry to docs/transient/phases/<phase-slug>/phase-debt.md per the template.
The solidifying increment (§7.3) absorbs this at the end of the phase.

Rule 7 — Ambiguous
If the entry can't be classified mechanically (insufficient references, mixed concerns, unclear scope):
→ Disposition: HUMAN_CLASSIFY
Halt for human clarification before proceeding.
```

### Step 3 — Apply dispositions

For each classified entry:

- **BACKLOG_TWEAK (a)**: Edit the pending backlog item spec. Record edit in the item's history and in the inbox entry.
- **BACKLOG_TWEAK (b/c)**: Create a new backlog item file (`backlog/<NNN+1>-<slug>.md`). Sequence appropriately (typically appended). Update increment-plan.md to reflect.
- **QUEUE_NEXT_INCREMENT**: Append to `next-increment-queue.md` with full feedback reference and proposed handling.
- **FUNCTIONAL_LOOPBACK / DOMAIN_LOOPBACK / ARCHITECTURE_LOOPBACK / WORKFLOW_OBSERVATION (critical)**: Write a halt entry per `_meta` §4 to `workflow-observations.md`. The orchestrator stops the backlog loop; the human routes the halt.

### Step 4 — Update inbox

For each processed entry, annotate the inbox:

```
- id: 003
  added_at: 2026-05-24T11:00Z
  by: rubin
  text: "The invoice form should have a 'save draft' button per discussion."
  references: docs/permanent/features/feature-invoicing.md
  disposition: BACKLOG_TWEAK (a)
  disposition_at: 2026-05-24T14:30Z
  action: amended backlog/003-add-invoice-form.md with new scenario "save draft"
  link: backlog/003-add-invoice-form.md#scope
```

### Step 5 — Surface summary

Status line:

```
Feedback triage complete.
Processed entries: <count>
Dispositions:
  - BACKLOG_TWEAK: <count>
  - QUEUE_NEXT_INCREMENT: <count>
  - FUNCTIONAL_LOOPBACK: <count> (HALT)
  - DOMAIN_LOOPBACK: <count> (HALT)
  - ARCHITECTURE_LOOPBACK: <count> (HALT)
  - WORKFLOW_OBSERVATION: <count>
  - SOLIDIFYING_DEBT: <count>
  - HUMAN_CLASSIFY: <count> (HALT)
```

If any halts, the orchestrator does not advance to the next backlog item. The human resolves per the halt's route-to.

If no halts, the orchestrator advances normally.

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-FT-1 | Entry classification yields FUNCTIONAL_LOOPBACK | `increment-functional-analysis` loopback (Gate 2 re-pass) |
| T-FT-2 | Entry classification yields DOMAIN_LOOPBACK | corrective increment per §9 |
| T-FT-3 | Entry classification yields ARCHITECTURE_LOOPBACK | corrective increment per §9 |
| T-FT-4 | Entry classification ambiguous | human |
| T-FT-5 | Entry references artifacts that don't exist | human (typo or stale reference) |
| T-FT-6 | BACKLOG_TWEAK (b) but the in-flight item's review-cycle budget already exhausted | open corrective increment |

## Observations

Surface as `routine`:
- High volume of HUMAN_CLASSIFY (signal: feedback template needs clearer artifact-reference field).
- Recurring DOMAIN_LOOPBACK in same phase (signal: phase BA missed structural domain elements).
- BACKLOG_TWEAK (c) entries that recur after the same item (signal: spec authoring quality).

Surface as `critical`:
- Feedback entries that reveal a halt-classification gap (a real-world feedback type the rules don't cover) — workflow defect.
