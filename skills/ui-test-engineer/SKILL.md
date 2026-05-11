# ui-test-engineer

- **Name:** ui-test-engineer
- **Version:** 1.0.0
- **Purpose:** Author automated UI tests for new scenarios in this increment; run full UI regression by tag. Ensure security-critical scenarios include negative cases.
- **Triggers from:** `developer` (after local unit tests pass).
- **Inputs:**
  - `.feature` files tagged `@inc-NNN`.
  - Plus meta-skill §1 always-allowed (which includes `testing-standards.md`).
- **Outputs:**
  - New automated UI tests under `/tests/ui/` covering `@inc-NNN`-tagged scenarios.
  - Regression run results (pass/fail by scenario).
  - Commits to the increment branch.
- **Hands off to:** `technical-reviewer`.
- **Inherits:** Meta-skill.
- **Utility sub-skill:** no.

## Skill-specific halt triggers

- T-UT-1: A scenario tagged `@inc-NNN` cannot be automated as written (back to `functional-specifier`).
- T-UT-2: A test fails in a way that suggests the scenario's expected outcome is wrong (halt; do not modify scenario).
- T-UT-3: A regression scenario starts failing — surface as regression. Halt for human direction.
- T-UT-4: Test environment cannot be brought up.
- T-UT-5: **A scenario tagged `@security-critical` lacks corresponding negative-case scenarios** (input validation failures, authz failures). Surface to `functional-specifier` to add.

## Process

1. **Identify new scenarios.** Filter `/features/` by `@inc-NNN` tag. These are the scenarios to automate. Load only these into reasoning context.

2. **Security-critical check.** For each scenario tagged `@security-critical`, verify the feature file has companion negative-case scenarios (failed input validation, failed authz). Halt T-UT-5 if missing.

3. **Author UI tests.** For each new scenario:
   - Write the test under `/tests/ui/`.
   - Follow `testing-standards.md` conventions.
   - Comment header: scenario name and tags.
   - For `@security-critical` scenarios: include both happy path and the corresponding negative cases.

4. **Run new tests.** Execute new tests locally; all must pass before regression.

5. **Run full regression by tag.** Run all UI tests including prior increments'. Filter via tag; the runner reads files from disk, reasoning context stays on tagged new subset.

6. **Triage results.**
   - All pass: proceed.
   - New tests fail: investigate. T-UT-2 halts. Otherwise iterate on test code (not scenario, not application code).
   - Regression failures: halt T-UT-3.

7. **Commit tests** to increment branch: `test(ui): <scenario summary> [inc-NNN]`.

8. **Step summary:**
   - Scenarios automated (file paths).
   - Negative-case coverage for security-critical scenarios.
   - Regression: pass count / fail count.
   - Every `@inc-NNN` scenario has corresponding automated test.

9. **Handover** to `technical-reviewer`.

## Notes

- "Load only `@inc-NNN` scenarios into reasoning" is the context-engineering discipline. Regression runs operate on disk.
- This skill writes test code only — never application code. Application defects surfaced by tests loop back through `developer` via the orchestrator.
- Security-critical negative coverage is the practical implementation of the testing-standards rule. The skill enforces presence; quality of the negative cases is a Gate-3 spot-check.
