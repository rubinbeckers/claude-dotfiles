# Aggregate: <name>

**Bounded context:** <name>
**Status:** active | deprecated | superseded-by-increment: inc-NNN
**Tags:** `@<area>` `<other tags>`
**Last-modified-by:** inc-NNN

## Purpose

One-paragraph description of what this aggregate represents in the domain.

## Data classification

`public` | `internal` | `confidential` | `restricted`

This classification applies to instances of this aggregate when persisted or transmitted. Capabilities touching this aggregate inherit a classification of at least this level.

## Entities

- **<EntityName>** — <one-line role>
  - Fields: <list>
  - Identity: <how identified>

## Value Objects

- **<VOName>** — <description>
  - Fields: <list>
  - Equality: <by-value semantics>

## Invariants

- <constraint that must always hold>
- <constraint>

## Behaviors (commands)

- **<behavior name>** — <what it does>
  - Pre: <pre-conditions>
  - Post: <post-conditions>
  - Events emitted: <list>

## Relationships

- **References:** <other aggregates referenced by ID, e.g., "holds a CustomerId reference to Customer aggregate">
- **Referenced by:** <other aggregates that reference this one>

## References

- Capabilities using this: <list>
- DDRs: <list>
- Components: <list>
