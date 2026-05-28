# Decision-record templates (DR / ADR)

Two record types: **DR** (domain, capability-scope, feature-design) and **ADR** (architecture, technology, system-impact). Each has its own numbering namespace. Both share a common structure.

## Common header

```markdown
---
id: <type>-NNN-<slug> | TBD-<slug>
type: DR | ADR
title: <decision-stating title>
summary: <one-line, ≤120 chars; the decision in a sentence>
status: proposed | accepted | superseded | deprecated | withdrawn
authored_by: domain-design | technical-design | human
introduced_in: <phase-slug>/inc-<NNN>-<slug> | <phase-slug> (if phase-level)
accepted_at_gate: null | gate-N@<location>
superseded_by: null | <type>-NNN-<slug>
supersedes: null | <type>-NNN-<slug>
prior_withdrawn: null | <type>-NNN-<slug>   # only for proposals re-introduced after a prior withdrawal
withdrawn_at: null | <ISO>
withdrawn_reason: null | <one-line>
deprecated_at: null | <ISO>
deprecated_reason: null | <one-line>
---

# <Title>

Grounded in:
  - <input artifacts: capability, aggregate, feature, prior decision being superseded, observation that triggered this>

## Context

<What triggered this decision. What problem are we solving? What alternatives existed?>

## Decision

<What we chose. Stated affirmatively.>

## Alternatives considered

- <Alt 1>: <why not chosen>
- <Alt 2>: <why not chosen>

## Consequences

### Positive
- ...

### Negative / trade-offs
- ...
```

## DR — Decision Record

Authored by: `domain-design` agent (mostly) or by the human directly (for cross-cutting decisions during stabilization or correction).

Documents decisions about:
- **Capability scope** — choosing one interpretation of an ambiguous requirement; setting boundaries on what's in and out; acceptance-criteria interpretation choices.
- **Domain model** — aggregate boundary choices; entity-vs-value-object decisions; invariant definitions; glossary refinements.
- **Feature design** — UX pattern choices; scenario coverage decisions; design-spec interpretations of capability ACs.

## ADR — Architecture Decision Record

Authored by: `technical-design` agent.

Documents architectural and technical decisions:
- Technology selection
- Pattern choice (event sourcing vs CRUD, etc.)
- Library/framework introduction
- Database schema choices with system-level impact
- Cross-cutting concerns at architecture level (e.g., logging strategy, auth provider)

### ADR-specific section: Supply chain notes

Required when the ADR introduces a new external dependency:

```markdown
## Supply chain notes

- License: <SPDX identifier or full license name>
- Maintenance status: <active | maintained | dormant | abandoned>
- Known vulnerabilities check: <result of dependency-scanner check at decision time>
- Alternatives considered: <reference the Alternatives section above; security and license differences highlighted>
```

## Status state machine

```
proposed → accepted → superseded → (terminal)
                   → deprecated → (terminal)
proposed → withdrawn → (terminal; may be re-proposed under new ID with prior_withdrawn:)
```

`doc-integrity` validates that transitions are legal and that supersession links are bidirectional.
