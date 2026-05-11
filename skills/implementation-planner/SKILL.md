# implementation-planner

- **Name:** implementation-planner
- **Version:** 1.0.0
- **Purpose:** Produce a detailed implementation plan for the increment including the explicit Developer Context Manifest. Enforce plan-size cap. Require supply-chain notes on dep-introducing ADRs.
- **Triggers from:** `functional-specifier` (after Gate 3).
- **Inputs:**
  - `/docs/increments/NNN-<slug>/scope.md`.
  - In-scope `.feature` files (tagged `@inc-NNN`).
  - `/docs/technical/architecture/INDEX.md`, `overview.md`, `tech-stack.md`.
  - `/docs/technical/architecture/components/INDEX.md`.
  - Specific component docs and ADRs — pulled only with justification.
  - Plus meta-skill §1 always-allowed.
- **Outputs:**
  - `/docs/increments/NNN-<slug>/plan.md` (from `templates/increment-plan.md`).
  - Proposed ADRs (TBD-numbered). **Dep-introducing ADRs must include a `Supply chain notes` section referencing SCA output (license, maintenance status, known-vulnerabilities check).**
  - Step summary.
- **Hands off to:** Human at Gate 4, then → `developer`.
- **Inherits:** Meta-skill.
- **Utility sub-skill:** no.

## Skill-specific halt triggers

- T-IP-1: Scenario requires functionality from a component that doesn't exist and the plan doesn't propose one.
- T-IP-2: A proposed technical choice has no justifying ADR (must propose one).
- T-IP-3: A scenario can't be implemented within current architectural constraints without ADR revision.
- T-IP-4: A component's documented invariants would be violated by the plan.
- T-IP-5: Plan's coverage strategy can't reach targets (80% baseline, 100% line+branch on `@security-critical`) without unjustified exemption.
- T-IP-6: **Plan-size cap exceeded.** Soft cap: 8 tasks (or equivalent work scope). Beyond it, halt and require splitting into separate increments.
- T-IP-7: Dep-introducing ADR proposed without `Supply chain notes`.

## Process

1. **Load scoped context.** Read `scope.md`, in-scope `.feature` files, and the always-loaded technical artifacts (`overview.md`, `tech-stack.md`, `architecture/INDEX.md`).

2. **Determine architectural touch.** For each scenario:
   - Identify existing components touched (name match against `components/INDEX.md` + scenario-vs-responsibility reading).
   - Identify constraining ADRs (tag match).
   - **Pull only** justified component docs and ADRs. Each pull cited in plan's `Grounded in:` with justification.

3. **Identify new architectural decisions.** For each implementation choice not covered by an accepted ADR:
   - Propose new ADR (TBD-numbered, status `proposed`).
   - Plain-language one-paragraph summary in `plan.md`.
   - **If the ADR introduces a new dependency:** populate `Supply chain notes` section (license, maintenance status, known vulnerabilities from SCA). Halt T-IP-7 if missing.

4. **Identify new components.** If scenario needs functionality outside existing components: propose new component (name, responsibility, contracts, deps). Draft component doc from `templates/component.md` (status `proposed`). Add to `components/INDEX.md`.

5. **Plan-size check.** Count tasks. If > 8, halt T-IP-6 with proposed split into multiple increments.

6. **Draft `plan.md`** from `templates/increment-plan.md`. Required sections:
   - Summary.
   - Components affected.
   - ADRs to honor (links).
   - ADRs proposed (with plain-language summary and Supply chain notes where applicable).
   - Task list (≤ 8 tasks).
   - Test plan (incl. security-critical path coverage strategy).
   - Coverage strategy (incl. exemption taxonomy per `testing-standards.md`).
   - **Developer Context Manifest.**

7. **Validate manifest.** Manifest contains every doc the plan references, no doc unreferenced.

8. **Update INDEX files** (architecture, components — status changes on proposed only).

9. **Step summary** with grounded sources.

10. **Halt for Gate 4** with plain-language ADR digest in the summary.

## Notes

- The plan is the context manifest for `developer`. Every pull upstream must be justified; downstream, no pull beyond the manifest.
- Plan-size cap protects context engineering — a 30-task plan implies the developer loads too much context, defeating the workflow.
- Proposed ADRs are not yet accepted. Approved at Gate 4 as direction; finalized at `increment-close` (numbered, status `accepted`) per registering-skill rule.
- Supply chain notes are a minimum standard — they don't replace project-level SCA in CI, but ensure dep introductions are deliberate decisions with vulnerability awareness.
