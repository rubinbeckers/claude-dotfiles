# Aggregate template

```markdown
---
id: agg-NNN-<slug> | TBD-<slug>
name: <name>
status: proposed | accepted | superseded | deprecated
introduced_in: <phase-slug>
accepted_at_gate: null | gate-1@<phase-slug>
superseded_by: null
supersedes: null
data_classification: public | internal | confidential | restricted
---

# Aggregate: <name>

Grounded in:
  - <capabilities that introduced this aggregate>
  - <prior aggregate if superseding>

## Aggregate root

<Entity name> — <one-line description>

## Entities

- <Entity name>: <description, role>
- ...

## Value objects

- <Type name>: <description>
- ...

## Invariants

- <invariant 1: a business rule that must always hold within this aggregate>
- <invariant 2>
- ...

## Capabilities exercising this aggregate

- <cap-NNN-<slug>>: <how>

## Cross-aggregate references

- <agg-NNN-<slug>>: <reference type — by-id, snapshot, etc.>
```
