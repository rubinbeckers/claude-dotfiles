# <TYPE>-NNNN: <slug>

> **Decision record types:**
> - **ADR** (Architectural Decision Record) — `/docs/technical/architecture/ADR-NNNN-*.md`
> - **CDR** (Capability Decision Record) — `/docs/business/capabilities/decisions/CDR-NNNN-*.md`
> - **DDR** (Domain Decision Record) — `/docs/business/domain/decisions/DDR-NNNN-*.md`
> - **FDR** (Functional Decision Record) — `/docs/functional/decisions/FDR-NNNN-*.md`

**Status:** proposed | accepted | superseded by <TYPE>-NNNN | withdrawn | rejected
**Date:** YYYY-MM-DD
**Originating increment:** inc-NNN  *(or "phase-intake" for phase-level decisions)*
**Tags:** `@<area>` `@nfr` *(if cross-cutting NFR)* `<others>`

*(For fresh re-proposals of a decision a previously-withdrawn record covered:)*
**Previously considered:** <TYPE>-NNNN  *(link to the prior withdrawn record; optional)*

## Context

What's the situation that requires a decision? Pull from refined business / functional / architectural state. Reference source docs.

## Decision

The decision itself. Specific, actionable. Avoid weasel words.

## Consequences

- **Positive:** <what's better>
- **Negative:** <what's harder, what we're committing to>
- **Neutral:** <observed but not pro or con>

## Alternatives considered

- **<Alternative 1>** — Why not chosen
- **<Alternative 2>** — Why not chosen

## Supply chain notes

*(Required when this decision introduces a new dependency. Otherwise omit or mark "N/A.")*

- **Dependency:** <name + version>
- **License:** <SPDX identifier; check compatibility>
- **Maintenance status:** <active / dormant / unmaintained; commits in last 12 months; primary maintainer>
- **Known vulnerabilities:** <reference SCA tool output for this branch; e.g., "no high/critical per SCA on branch X" or "1 medium CVE-YYYY-NNNN, accepted because <reason>">
- **Alternatives evaluated:** <briefly list 1-2 alternatives and why this was chosen on supply-chain grounds>

## References

- Source docs: <paths grounding the context>
- Superseded by: <ID, if applicable>
- Supersedes: <ID, if applicable>

---

## Status semantics

- **proposed** — drafted by the originating skill (TBD-numbered until registered).
- **accepted** — approved at the appropriate gate; numbered by the registering skill (`phase-intake` for phase-level decisions; `increment-close` for increment-level decisions). Once accepted, the file is append-only.
- **superseded by <X>** — replaced by a later decision. Bidirectional: this record gets the forward link; X gets a "supersedes <this>" back link.
- **withdrawn** — **terminal status.** A proposed decision the work didn't actually require. A withdrawn record is never revived. If the decision needs to be made later in a different context, a *new* record is created with a new number, optionally referencing this one via `Previously considered: <this-ID>`.
- **rejected** — considered at the time and explicitly not chosen. Like withdrawn, terminal; a later fresh proposal gets a new number.
