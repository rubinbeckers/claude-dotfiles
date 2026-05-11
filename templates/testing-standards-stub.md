# Testing Standards

Project-specific testing standards. Filled in by project setup; baseline items below are workflow-mandated.

## Baseline (workflow-mandated)

### Coverage targets

- **Unit tests:** ≥80% line coverage on code paths changed by the increment. Measured by the CI coverage tool.
- **`@security-critical` paths:** 100% line coverage **and** 100% branch coverage on:
  - Input-validation code paths
  - Error-handling paths
  - Authentication and authorization code

  `@security-critical` is derived deterministically from capability/aggregate Data classification ≥ `confidential` (per tag-vocabulary.md). It's not an ad-hoc judgment.

### Coverage exemptions

Exemptions must be pre-declared in the increment's `plan.md` per the exemption taxonomy:

- **Pure boilerplate** — generated code, simple getters/setters, framework scaffolding.
- **Untestable in isolation** — code requiring a real external system to exercise (covered by integration / UI tests instead).
- **Deprecated paths** — code on the way out, scheduled for removal in a near increment.

Any other exemption must be justified case-by-case in `plan.md` and reviewed at Gate 4.

`@security-critical` paths are not exemptible — if coverage can't reach 100% on input-validation/error paths, the design has a problem and the developer halts (T-D-4).

### UI tests

- Every `.feature` scenario tagged `@inc-NNN` has a corresponding automated UI test under `/tests/ui/`.
- `@security-critical` scenarios include companion negative-case scenarios (input-validation failures, authz failures) per workflow.md §6 Phase 7.

### Regression frequency by criticality tag

- `@critical` — full regression run on every increment.
- `@important` — regression run when changes touch the related capability or component.
- `@nice-to-have` — smoke regression only.

### Test isolation and determinism

- Unit tests run without network, filesystem (beyond temp), or external services.
- Tests are deterministic — flaky tests are bugs to fix, not noise to tolerate.
- Test data is scoped per test; no shared mutable state across tests.

## Project-specific (project fills in)

### Tooling

- *(Test framework, coverage tool, mocking library, CI integration)*

### Conventions

- *(Test file naming, structure, fixtures)*

### Mocking / stubbing patterns

- *(When to mock vs. when to use real dependencies)*

### Performance / load testing

- *(If applicable: targets, tooling, frequency)*

## Notes

- This file is refined via doc-only increments from standards-adequacy synthesis at `phase-close`.
- Coverage tooling and threshold enforcement are project-specific; the baseline rules are language-agnostic.
