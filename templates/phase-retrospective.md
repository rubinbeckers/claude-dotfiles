# Retrospective — Phase NN: <slug>

**Closed:** YYYY-MM-DD
**Increments delivered:** <count>
**Increments abandoned:** <count>

## Delivered vs. planned

- **Roadmap entries delivered:** <list>
- **Roadmap entries deferred (with CDR):** <list with CDR ref>
- **Roadmap entries explicitly out-of-scope:** <list>

## Key decisions

Significant ADRs, CDRs, DDRs, FDRs accepted this phase. One-line each.

- ADR-NNNN: <one-line>
- ...

## Workflow-defects synthesis

*(Synthesized from `/docs/process/learnings/*.md` entries tagged with this phase, plus halt patterns from step-logs.)*

Group recurring patterns:

- **Skill: <skill-name>**
  - Pattern: <recurring observation>
  - Occurrences this phase: <count>
  - Proposed action: <track-only | propose to curator>

- **Workflow / cross-skill**
  - Pattern: <e.g., "halt T-X fired N times across 3 skills">
  - Proposed action: <e.g., "consider clarification in workflow.md §7">

This section feeds `skill-curator`.

## Standards-adequacy synthesis

*(Synthesized from `/docs/phases/NN-<slug>/standards-observations.md`.)*

Group by category:

- **Coding standards**
  - Observations: <count>
  - Patterns: <e.g., "naming convention X surfaced N times; not currently in standards">
  - Proposed update: <specific text to add to `coding-standards.md`>

- **Testing standards**
  - Observations: <count>
  - Patterns: <e.g., "coverage exemption pattern Y not in taxonomy">
  - Proposed update: <text>

- **Naming conventions**
  - <as above>

- **Security**
  - Observations: <count>
  - Patterns: <e.g., "input-validation check failed on N capabilities — same pattern">
  - Proposed update: <text>

Approved updates from this section typically become a doc-only increment in the next phase, updating the relevant standards file.

## Direction for next phase

- <bullets capturing what the next phase should pick up or reconsider>
- <any open items not closed this phase that next-phase intake should address>

## Metrics

- Avg cycles per increment to review approval: <N>
- Halt-trigger frequency by trigger ID: <top 5>
- Coverage avg: <pct>
- Security-critical paths total: <count> | coverage avg: <pct>

## Phase locked

This phase is now locked. Subsequent corrections to its outputs route through corrective increments per workflow.md §10.
