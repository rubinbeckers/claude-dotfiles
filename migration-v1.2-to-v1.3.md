# Migration: workflow v1.2 → v1.3

v1.3 is a **minor, additive** update over v1.2: it introduces the **security baseline guardrail**. Two project-level docs — `docs/owasp-guidelines.md` (a verbatim copy of the OWASP Secure Coding Practices Quick Reference Guide) and `docs/security-guidelines.md` (the project's own custom security layer) — become permanent, always-allowed references that every skill and agent reads and works against at every step. This is the security analogue of the v1.2 design-system guardrail.

Nothing in the lifecycle, gates, INDEX schema, status state machine, or decision-record namespaces changes. The guardrail tightens what already-existing steps must check; it adds no new step, gate, or skill.

## What's new in v1.3

- `docs/owasp-guidelines.md` — verbatim OWASP Secure Coding Practices baseline (a vendored upstream standard; **not project-edited**). Added to the `_meta` §1 always-allowed read set.
- `docs/security-guidelines.md` — the project's custom security layer + a baseline-overrides table (human-owned; ships as an empty scaffold). Also always-allowed.
- `_meta` §18 — the security-baseline rule: mandatory for every skill and agent, with precedence (project layer may be stricter; a baseline item is relaxed only by a recorded, ADR-backed override entry) and per-role obligations.
- `domain-design` and `technical-design` derive security requirements / abuse cases / supply-chain notes from the baseline; `increment-develop` implements against it; `increment-test` derives abuse-case tests from it; `increment-review` runs a **mandatory security pass** where an un-overridden violation blocks the increment.
- `workflow.md` §17 (contract summary) and `agentic-sdlc-principles.md` §11 ("Security is a baseline, not a feature").
- `project-init` scaffolds both files into `docs/` so the always-allowed set resolves on day one.

Note: `increment-review` previously pointed its Security check at a stale `workflow.md §11`; v1.3 repoints it at the new security section.

## Migrating an existing v1.2 project

1. **Finish the current phase under v1.2** — avoid mid-phase migration (same discipline as v1.1→v1.2).
2. At a phase boundary, add the two new files at the `docs/` root:
   - `owasp-guidelines.md` — copy unchanged from `templates/owasp-guidelines.md`. Do not edit it; refresh only by re-importing a newer OWASP release.
   - `security-guidelines.md` — scaffold from `templates/security-guidelines.md` and populate it with your project's security rules and any baseline overrides before the next security-relevant increment.
3. Switch the project's `docs/skill-versions.lock` pin to `workflow-v1.3`.
4. The first v1.3 session runs `session-resume`'s pin check; it detects the migration, halts, and prompts for override or rollback. Choose override; record a DR documenting the migration.
5. Existing artifacts are untouched. No data migration, no re-classification of records. Existing code and specs are held to the baseline lazily — from the next increment forward, `increment-review`'s security pass applies to the changed surface (it does not retroactively re-review merged code).

## Overrides discipline

The OWASP copy is fixed. Any project-specific relaxation of a baseline item lives **only** in the Overrides section of `security-guidelines.md`, naming the overridden item, the rationale, and an approving ADR. Absent a recorded override, the baseline stands — agents never infer one.

## Install

No installer change. v1.3 adds no skills or agents and renames none; it edits existing skills/agents and adds two templates. `git pull` propagates the edits to the symlinked live files; re-running `install-claude.{sh,ps1}` is not required.
