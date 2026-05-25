# Increment scope template

```markdown
# Increment scope: <inc-slug>

feeds-into:
  - (none — increment-scope content is reflected in INDEX upon delivery; this transient doc is pruned at increment-close)

Grounded in:
  - docs/transient/phases/<phase-slug>/phase-plan.md (row for this increment)

## Objective

<From phase plan row.>

## Capabilities delivered

- <cap-NNN-<slug>>: <how this increment delivers it>

## Capabilities partially exercised

- <cap-NNN-<slug>>: <what's covered, what's deferred>

## Architecture decisions exercised

- <ADR-NNN-<slug>>: <which aspect>

## Design coverage

- <prototype path>: <which features this covers>

## Dependencies

- <inc-NNN-<slug>>: <delivered status>

## Out of scope (explicit)

- <items the human or planner explicitly excluded>

## Corrects (if corrective increment)

corrects: <inc-NNN-<slug>>
defect_summary: <what was wrong with the original>
sources:
  - <link to failing review verdict, observation, feedback entry, etc.>

## Approval at Gate 2

(Filled in at Gate 2.)

- Approved by: <human>
- Approved at: <timestamp>
- Modifications during gate review: <list>
```
