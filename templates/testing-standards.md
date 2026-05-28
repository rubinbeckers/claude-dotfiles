# Testing standards (placeholder)

Scaffolded by `project-init`. Populated by `technical-design` in the first phase. Always-allowed read per `_meta` §1.

## Test types

- **Unit tests** — written by `increment-develop` alongside code. Test internal logic. Located <where>.
- **Integration tests** — written by `increment-test` from spec. Test cross-component behaviour. Located <where>.
- **UI tests** — written by `increment-test` from design specs. Test rendered behaviour. Located <where>.

## Frameworks

- Unit: <framework>
- Integration: <framework>
- UI: <framework>

## Coverage targets

- Default: ≥80% line coverage on new code per increment.
- Security-critical paths (`@security-critical` tag, derived from capability `data_classification ≥ confidential`): 100% line + branch coverage on input-validation and error paths.

## Hermeticity

Every test must:
- Create its own fixtures (in setup or inline).
- Verify clean state before proceeding (assertion or programmatic reset).
- Tear down fixtures at the end.
- Not depend on order of execution or side effects of other tests.

The mechanism is project-defined — inline `beforeEach`/`afterEach`, project-wide hooks, or both. The property (per-test cleanliness) is non-negotiable.

For external dependencies that genuinely can't be hermetic (e.g., real OAuth provider, paid third-party API), this document names the project's provision: <mocked auth provider | signed test JWTs | recorded fixtures | etc.>.

## Smoke set

Tests tagged `@smoke` are run by `increment-test` and as part of the parent-commit classification at increment-close. The `@smoke` tag is applied to tests covering:

- Capabilities at `data_classification ≥ confidential`.
- Paths tagged `@security-critical` in the source feature file.
- Critical user flows: <list of flow slugs from `docs/permanent/flows/` that the project considers critical>.
- Known regression hotspots: tests that have previously failed on develop (recorded in `phase-debt.md` or in prior `observations.md`).

## Categories of test failure

Per `workflow.md` §8:
- **Spec divergence (Category A)** — test exercises item-scope; assertion fails. Reviewer disposition.
- **Regression (Category B)** — test passed on parent commit, fails now. Develop agent's problem. Detected by orchestrator's parent-commit check.
- **Discovered defect (Category C)** — test fails on adjacent code; pre-existing or transitively triggered. Logged to `phase-debt.md`.
- **Structural (Category D)** — test won't compile, fixtures missing, runner crashes. Test agent halts to technical-design.

## Flaky-test handling

A test showing intermittent pass/fail across 3+ identical runs is logged to `phase-debt.md` for the solidifying increment. The current outcome is what's used for the increment's verdict.

## CI

CI runs the full test suite (unit + integration + UI + smoke) on every PR to `develop`. The workflow doesn't manage CI configuration directly — the project's CI config is the source of truth — but the test agent's hermeticity rules and smoke tagging must remain consistent with CI's runner so local + CI agree.
