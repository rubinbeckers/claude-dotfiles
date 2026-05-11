# Component: [Name]

- **Status:** proposed | active | deprecated
- **Tags:** @area-tag @other-tag
- **Justifying ADR(s):** [link]

## Responsibility

One-paragraph statement of what this component is responsible for. Should be possible to state without reference to implementation details.

## Public contracts

The interfaces this component exposes — methods, endpoints, events, whatever's appropriate. Stable surface that other components depend on.

- Contract 1: [signature / description]
- Contract 2: ...

## Dependencies

- **Incoming (who calls this):** [list of components]
- **Outgoing (what this calls):** [list of components and external systems]

## Owned domain artifacts

- **Aggregates persisted / managed:** [link]
- **Invariants enforced:** [list — typically reference aggregate invariants]

## Internal invariants

Rules this component must maintain that are specific to it (not aggregate-level).

## Cross-references

- **Capabilities served:** [link]
- **ADRs constraining design:** [link]
- **Related components:** [link]
