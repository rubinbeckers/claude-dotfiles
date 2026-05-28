# Naming conventions (placeholder)

Scaffolded by `project-init`. Populated by `technical-design` in the first phase. Always-allowed read per `_meta` §1.

## Code identifiers

- Variables: <convention>
- Functions: <convention>
- Classes: <convention>
- Modules / files: <convention>
- Constants: <convention>

## Test identifiers

- Test file names: <convention>
- Test case names: <convention — typically "describes the behaviour being tested, not the implementation">

## Artifact IDs

- Capabilities: `cap-NNN-<slug>` where NNN is zero-padded sequential, slug is kebab-case ≤30 chars.
- Aggregates: `agg-NNN-<slug>`.
- Features: `feature-<slug>`.
- Flows: `flow-<slug>`.
- Decision records: `DR-NNN-<slug>` and `ADR-NNN-<slug>` (each in its own numbering namespace).
- Increments: `inc-NNN-<slug>`.
- Phases: `NN-<descriptor>` (two-digit phase number).
- Acceptance criteria: `AC-<cap-id>-NN` (cap-id is the parent capability's `cap-NNN-<slug>`).
- Design-spec items: `DS-<feature-slug>-NN`.

## Branch names

- Increment: `inc-<NNN>-<slug>`
- Post-merge fix: `fix/<inc-slug>/<short-slug>`

## Commit messages

<Project convention — Conventional Commits, custom, etc.>

## Tag vocabulary (BDD scenarios)

Tags applied to BDD scenarios in feature files:

- `@<capability-id>` — names the parent capability (one per scenario, minimum).
- `@high` | `@medium` | `@low` — criticality (one per scenario).
- `@security-critical` — scenarios touching paths whose capability has `data_classification ≥ confidential`, or covering security-relevant behaviour (auth, authz, input validation, sensitive-data handling).
- `@error-path` — scenarios verifying error handling at boundaries.
- `@smoke` — scenarios in the smoke set (see `testing-standards.md` for criteria).

Multiple tags may apply. The reviewer (`increment-review`) validates tag application against these rules.

## Glossary terms

Glossary terms are written in their canonical form in `docs/permanent/domain/glossary.md`. When a term appears in any spec-bearing artifact, it uses the canonical form (case, hyphenation, spacing). Renames or refinements happen by glossary supersession plus updates to artifacts.

## File paths in transient

- `docs/transient/phases/<NN-slug>/...` — active phase only.
- `docs/transient/phases/<NN-slug>/increments/<inc-NNN-slug>/...`
- `docs/transient/phases/<NN-slug>/carry-forward/...` — content moving to next phase.
- `docs/transient/archive/<NN-slug>/...` — closed phases.
- `docs/transient/pauses/<ISO>.md` — pause records.
- `docs/transient/pending-skill-diffs/<id>.diff` — staged skill diffs awaiting next session-resume.
