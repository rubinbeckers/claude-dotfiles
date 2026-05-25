# Decision-record templates (CDR / DDR / FDR / ADR)

All four decision-record types share a common structure. The differences are in which kind of decision they document and which role authors them.

## Common header

```markdown
---
id: <type>-NNN-<slug> | TBD-<slug>
type: CDR | DDR | FDR | ADR
title: <decision-stating title>
status: proposed | accepted | superseded | deprecated | withdrawn
authored_by: <role>
introduced_in: <phase-slug>/inc-<NNN>-<slug> | <phase-slug> (if phase-level)
accepted_at_gate: null | gate-N@<location>
superseded_by: null | <type>-NNN-<slug>
supersedes: null | <type>-NNN-<slug>
prior_withdrawn: null | <type>-NNN-<slug>   # only for proposals re-introduced after a prior withdrawal
withdrawn_at: null | <ISO timestamp>
withdrawn_reason: null | <one-line>
deprecated_at: null | <ISO timestamp>
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

## CDR — Capability Decision Record

Authored by: Business Analyst.

Documents decisions about capability scope, boundaries, or interpretation:
- Choosing one interpretation of an ambiguous requirement over another
- Setting capability boundaries (what's in, what's out)
- Acceptance criteria interpretation choices

## DDR — Domain Decision Record

Authored by: Business Analyst.

Documents decisions about the domain model:
- Aggregate boundary choices
- Entity-vs-value-object decisions
- Invariant definitions and their rationale
- Glossary term refinements (when a term shifts meaning)

## FDR — Functional Decision Record

Authored by: Functional Analyst.

Documents decisions about feature design or scenario coverage:
- Choosing one UX pattern over alternatives
- Deciding which scenarios cover an edge case (vs. leaving it implicit)
- Design-spec interpretations of capability ACs

## ADR — Architecture Decision Record

Authored by: Technical Architect.

Documents architectural and technical decisions:
- Technology selection
- Pattern choice (e.g., event sourcing vs CRUD)
- Library/framework introduction
- Database schema choices that have system-level impact

Additional ADR-specific section:

```markdown
## Supply chain notes

(Required when ADR introduces a new external dependency.)

- License: <SPDX identifier or full license name>
- Maintenance status: <active | maintained | dormant | abandoned>
- Known vulnerabilities check: <result of dependency-scanner check at decision time>
- Alternatives considered: <see above section; security/license differences highlighted>
```

## Status state machine reminder

```
proposed → accepted → superseded → (terminal)
                   → deprecated → (terminal)
proposed → withdrawn → (terminal, may be re-proposed under new ID with prior_withdrawn:)
```

Per `_meta` §9. `doc-integrity` validates state transitions are legal.
