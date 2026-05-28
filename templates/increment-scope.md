# Increment scope template

This single file is the working brief for an increment. It contains the objective, the capabilities being exercised, the implementation plan, and the sequencing list — what v1.0 split between `increment-scope.md` and per-item `backlog/<NNN>-<slug>.md` files now lives here.

```markdown
# Increment scope: <inc-slug>

Grounded in:
  - docs/transient/phases/<phase-slug>/phase-plan.md (row for this increment)

## Objective

<From phase plan, restated.>

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

## Implementation plan

(Authored by `technical-design` in mode: increment. Prose overview, ≤500 words, of the implementation approach across the increment. Covers data-model implications, integration points, security boundaries, performance considerations, error-handling approach.)

<prose>

## Sequencing

(The atomic-but-meaningful list. Each entry is a unit of work in delivery order. These are sequencing notes, not separate agent invocations — `increment-execute` runs develop / test / review on the whole increment, not per entry.)

### 001-<slug>

- objective: <one-line>
- scenarios: [<feature-slug>:<scenario name>, ...]
- design-spec-ids: [DS-<feature-slug>-<id>, ...]
- files: [<paths to create or modify>]
- approach: <prose, ≤200 words>
- cross-references: [<ADR slugs>]
- cross-cutting: [<auth / validation / error / logging / persistence concerns>]
- depends: [<other sequencing slugs in this increment>]
- size: S | M | L

### 002-<slug>

...

## Approval at Gate 2

(Filled in at Gate 2.)

- Approved by: <human>
- Approved at: <timestamp>
- Modifications during gate review: <list, or "none">
```
