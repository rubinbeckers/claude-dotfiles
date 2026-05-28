# Phase plan template

```markdown
# Phase plan: <phase-slug>

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
- Architecture decisions exercised: <list of ADR-NNN with links>
- Prototype coverage: <list of paths>
- Depends on: <list or "none">
- Estimated size: S | M | L
- Notes: <optional>

### inc-002-<slug>

...

### inc-<NNN>-<solidifying-descriptor>

- type: solidifying
- Objective: absorb accumulated tech debt from this phase. Concrete scope determined at increment-design from `phase-debt.md`. Skipped at increment-design if `phase-debt.md` is empty.
- Capabilities delivered: none
- Architecture decisions: none
- Depends on: all prior increments in this phase
- Estimated size: variable (TBD at increment-design)

## Plan integrity (at planning time)

- All capabilities referenced exist in domain-design outputs: ✓
- All ADRs referenced exist in technical-design outputs or prior accepted ADRs: ✓
- All prototype paths exist: ✓
- All `depends:` references resolve to earlier increments in this plan or closed prior increments: ✓
- No capability is "delivered" by more than one increment: ✓

## Approval at Gate 1

(Filled in at Gate 1.)

- Approved by: <human>
- Approved at: <timestamp>
- Modifications during gate review: <list, or "none">
```
