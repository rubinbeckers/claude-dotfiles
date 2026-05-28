# Aggregate template

```markdown
---
id: agg-NNN-<slug> | TBD-<slug>
name: <human-readable name>
summary: <one-line, ≤120 chars; what this aggregate represents and its primary responsibility>
status: proposed | accepted | superseded | deprecated | withdrawn
introduced_in: <phase-slug>
accepted_at_gate: null | gate-1@<phase-slug>
superseded_by: null | agg-NNN-<slug>
supersedes: null | agg-NNN-<slug>
---

# Aggregate: <name>

Grounded in:
  - <capability references that involve this aggregate>
  - <prior aggregate if superseding>
  - <related DRs>

## Description

<One paragraph describing the aggregate's responsibility — what state it owns, what operations change that state.>

## Root entity

<Name of the root entity and its key attributes.>

## Entities

- <entity name>: <role within the aggregate>
- ...

## Value objects

- <value-object name>: <what it represents>
- ...

## Invariants

The aggregate enforces these invariants whenever its state changes:

- <invariant 1>
- <invariant 2>

Cross-context invariants live in `docs/permanent/domain/domain-model.md`, not here.

## Operations

State-changing operations supported by the aggregate root:

- <operation name>: <one-line description; preconditions; postconditions>
- ...

## Capabilities involved

- <cap-NNN-<slug>>: <how this aggregate participates>
```
