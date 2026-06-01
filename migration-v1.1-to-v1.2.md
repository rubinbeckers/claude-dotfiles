# Migration: workflow v1.1 → v1.2

v1.2 is a **minor, additive** update over v1.1: it introduces the **design-system guardrail**. A project-level `design.md` (the design system — tokens + component inventory) becomes a permanent, always-allowed reference that UI-bearing artifacts must conform to. When a needed component or foundation token has no match in `design.md`, the gap is surfaced to the human for disposition, and every deviation is logged.

Nothing in the lifecycle, gates, INDEX schema, status state machine, or decision-record namespaces changes. A project that never produces UI simply never triggers the guardrail.

## What's new in v1.2

- `docs/permanent/design/design.md` — the design system (human-owned; source of truth for tokens + components). Added to the `_meta` §1 always-allowed read set.
- `docs/permanent/design/design-deviations.md` — append-only, permanent log of every divergence from `design.md`.
- `_meta` §17 — the design-system guardrail rule + the design-decision prompt; `_meta` §4 gains a `design-gap` return status.
- `domain-design` (primary decision point, Gate 2), `increment-develop` (execute-time backstop), and `increment-review` (conformance check) are wired to the guardrail.
- `doc-integrity` validates that every design-spec component/token resolves to `design.md` or to a logged provisional.
- `phase-debt` / `accepted-debt` gain a `design-deviation` category — the fix-vs-accept choice reuses the existing solidifying-increment and accepted-debt machinery.

## Migrating an existing v1.1 project

1. **Finish the current phase under v1.1** — avoid mid-phase migration (same discipline as v1.0→v1.1).
2. At a phase boundary, add the two new files under `docs/permanent/design/`:
   - `design.md` — your project's design system. If you don't have one yet, scaffold the placeholder from `templates/design.md` and populate it before the next UI increment.
   - `design-deviations.md` — empty header from `templates/design-deviations.md`.
3. Switch the project's `docs/skill-versions.lock` pin to `workflow-v1.2`.
4. The first v1.2 session runs `session-resume`'s pin check; it detects the migration, halts, and prompts for override or rollback. Choose override; record a DR documenting the migration.
5. Existing artifacts are untouched. No data migration, no re-classification of records. Existing design-specs are re-validated against `design.md` lazily, at the next close gate's `doc-integrity` sweep — any reference that doesn't resolve is flagged then (and surfaced as a design-gap to disposition).

## Design-system versioning

`design.md` carries a `version:` field. Bump it on every human change; for a significant change (new component family, foundation token change, palette revision) also record an ADR. The doc is human-owned — no supersession machinery is applied to it.

## Install

No installer change. v1.2 adds no skills or agents and renames none; it edits existing skills/agents and adds templates. `git pull` propagates the edits to the symlinked live files; re-running `install-claude.{sh,ps1}` is not required.
