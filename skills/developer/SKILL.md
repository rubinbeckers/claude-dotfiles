# developer

- **Name:** developer
- **Version:** 1.0.0
- **Purpose:** Implement the plan: code, unit tests at required coverage, local test runs, component doc updates, ADR status transitions (including `withdrawn`). Commit to increment branch.
- **Triggers from:** `implementation-planner` (after Gate 4), or loop-back from `technical-reviewer` on rejection.
- **Inputs:**
  - `/docs/increments/NNN-<slug>/plan.md`.
  - **Only the docs listed in the plan's Developer Context Manifest** (plus meta-skill §1 always-allowed).
- **Outputs:**
  - Source code under `/src/`.
  - Unit tests under `/tests/unit/` — ≥80% coverage on code paths; **100% line + branch coverage on `@security-critical`-tagged paths' input-validation and error paths**.
  - Updated component docs where public contracts changed.
  - ADR status transitions:
    - `proposed` → `accepted-pending-review` if the implementation exercised the decision as planned.
    - `proposed` → `withdrawn` (**terminal**) if the work didn't actually require the decision. Future re-proposals get a *new* number, optionally linked via `previously-considered: ADR-NNNN`.
    - If the implementation diverged from a proposed ADR: supersede with a new proposed ADR.
  - New proposed ADRs (TBD-numbered) for unexpected decisions made during development.
  - Local test run results.
  - Commits to the increment branch.
- **Hands off to:** `ui-test-engineer` (skipped in doc-only mode — but doc-only mode doesn't invoke this skill at all).
- **Inherits:** Meta-skill.
- **Utility sub-skill:** no.

## Skill-specific halt triggers

- T-D-1: Implementation decision arises not covered by plan or in-manifest ADR (propose new ADR, halt for review).
- T-D-2: A component contract documented in a component doc must change in a way the plan didn't anticipate (halt for human direction; do not silently change contract).
- T-D-3: A unit test would require behavior contradicting a scenario's expected outcome (suggests scenario error).
- T-D-4: Coverage cannot reach target (80% baseline, or 100% line+branch on `@security-critical` paths) by writing additional in-scope tests.
- T-D-5: Local test environment broken.
- T-D-6: A doc outside the manifest seems necessary (planner missed something — halt, do not load).
- T-D-7: **New domain term encountered.** Implementation surfaces a term not in glossary. Halt back upstream — developer does NOT author glossary entries (carve-out is bounded to `phase-intake` and `business-analyst` per meta-skill §9).

## Process

1. **Verify branch.** Currently on `increment/NNN-<slug>`. Otherwise halt (out-of-scope, meta-skill §10).

2. **Load manifest.** Read every doc in Developer Context Manifest. No additional loading (except always-allowed).

3. **Execute task list.** For each task:
   - Write/modify code per task description.
   - Write unit tests; for code paths covering security-critical functionality (input validation, authz, error handling on data flagged at confidential or higher), apply 100% line + branch coverage.
   - Run unit tests locally; must pass before next task.
   - Commit: `feat|fix|refactor(<area>): <task summary> [inc-NNN]`.

4. **Coverage check.** After all tasks:
   - Run coverage report.
   - Confirm baseline ≥80% on changed code paths.
   - Confirm `@security-critical` paths reach 100% line+branch on input-validation and error paths.
   - Halt T-D-4 if unachievable; do not silently exempt.

5. **Update component docs.** For each component whose public contract changed.

6. **Update proposed ADR statuses:**
   - Exercised as planned → `accepted-pending-review`.
   - Implementation diverged → supersede with new proposed ADR.
   - Not exercised, decision wasn't actually needed → `withdrawn` (terminal).

7. **Propose new ADRs** for any unanticipated decision made during development. Halt T-D-1 mid-task if needed; do not silently absorb new decisions.

8. **Final local test run.** All unit tests pass; coverage targets met.

9. **Step summary** with:
   - `Grounded in:` listing manifest items actually used.
   - Commits made (hashes).
   - Test run results and coverage report.
   - ADR status transitions explicitly listed (with reason for each, especially withdrawals).

10. **Handover** to `ui-test-engineer`.

## Notes

- The manifest constraint is the central context-engineering mechanism. Violating it defeats the workflow. If a doc seems necessary, halt — the gap is in the plan, not in the runtime.
- Withdrawn is terminal. If a later increment finds the decision is actually needed, it proposes a fresh ADR with a new number. The withdrawn record remains as historical context, linked via `previously-considered:` in the new ADR if useful.
- New domain terms encountered during implementation are an upstream signal — the developer halts and the business-analyst is reinvoked next increment. Authoring at the developer layer would smuggle business decisions into code.
- "Run tests locally" is non-negotiable. CI also runs them on push; the developer verifies locally first.
- This skill does not push to remote; `increment-close` handles that.
