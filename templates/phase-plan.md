# Phase plan template

```markdown
# Phase plan: <phase-slug>

feeds-into:
  - (none — phase-plan content is absorbed only via increment delivery; this transient doc is pruned at improvement-review)

Grounded in:
  - docs/transient/phases/<phase-slug>/phase-scope.md
  - <BA outputs from this phase>
  - <TA outputs from this phase>

## Objective

<From phase-scope.md, restated.>

## Increments

### inc-001-<slug>
- Objective: <one-line>
- Capabilities delivered: <list of cap-NNN with links>
- Capabilities partially exercised: <list with notes>
- Architecture decisions: <list of ADR-NNN with links>
- Prototype coverage: <list of paths>
- Depends on: <list or "none">
- Estimated size: S | M | L
- Notes: <optional>

### inc-002-<slug>
...

## Plan integrity (at planning time)

- All capabilities referenced exist in BA outputs: ✓
- All ADRs referenced exist in TA outputs or prior accepted ADRs: ✓
- All prototype paths exist: ✓
- All `depends:` references resolve to earlier increments in this plan or closed increments: ✓
- No capability is "delivered" by more than one increment: ✓

## Approval at Gate 1

(Filled in at Gate 1 — see workflow.md §5.)

- Approved by: <human>
- Approved at: <timestamp>
- Modifications during gate review: <list, or "none">
```
