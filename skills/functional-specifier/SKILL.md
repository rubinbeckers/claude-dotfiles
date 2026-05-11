# functional-specifier

- **Name:** functional-specifier
- **Version:** 1.0.0
- **Purpose:** Translate refined business specs into functional artifacts: BDD scenarios with explicit AC references, flows, and UI specs. Handle prototype gaps without inventing design.
- **Triggers from:** `business-analyst`.
- **Inputs:**
  - `/docs/increments/NNN-<slug>/scope.md`.
  - In-scope (refined) capability specs.
  - Existing `/features/<capability>.feature` files.
  - `/docs/functional/flows/INDEX.md` + flow docs referenced.
  - `/docs/functional/ui/INDEX.md` + UI specs for affected screens.
  - `/design/INDEX.md` + prototype manifests.
  - Plus meta-skill §1 always-allowed.
- **Outputs:**
  - New or updated `/features/<capability>.feature` files. Scenarios tagged `@<capability> @inc-NNN @phase-NN @<criticality>` and reference specific AC IDs via `# AC: AC-N` comments on each scenario.
  - New or updated `/docs/functional/flows/<flow>.md` (from `templates/flow.md`).
  - New or updated `/docs/functional/ui/<screen>.md` (from `templates/ui-spec.md`).
  - New FDRs (TBD-numbered).
  - Updated `/features/INDEX.md`, `/docs/functional/flows/INDEX.md`, `/docs/functional/ui/INDEX.md`.
  - Step summary.
- **Hands off to:** Human at Gate 3, then → `implementation-planner`.
- **Inherits:** Meta-skill.
- **Utility sub-skill:** no.

## Skill-specific halt triggers

- T-FS-1: In-scope capability touches UI but has no UI spec AND no prototype to derive from.
- T-FS-2: UI spec references prototype version that no longer exists.
- T-FS-3: Scenario as written would test behavior not stated in the capability spec (scope drift; back to `business-analyst`).
- T-FS-4: Existing `.feature` scenarios contradict refined capability spec.
- T-FS-5: Prototype redirection needed (replacement design for existing UI spec) — requires explicit FDR.
- T-FS-6: An in-scope AC has no scenario covering it (every AC ID must have at least one referencing scenario).
- T-FS-7: A scenario references an AC ID that doesn't exist in the capability spec.

## Process

1. **Load scoped context.** Read `scope.md` and refined capability specs. Identify which capabilities touch UI.

2. **UI sub-step** (for each capability touching UI):
   - UI spec + current prototype manifest → proceed.
   - UI spec but stale/missing prototype → halt T-FS-2.
   - No UI spec but prototype exists → derive UI spec from manifest; FDR if non-obvious.
   - Neither exists → halt T-FS-1; surface three options: (a) human wireframe, (b) propose design direction as FDR, (c) defer slice.

3. **Author or update scenarios.** For each in-scope capability:
   - Open `.feature` file (create from `templates/feature.feature` if absent).
   - Write Gherkin scenarios covering in-scope slice.
   - Tag scenarios `@<capability> @<criticality> @inc-NNN @phase-NN`.
   - **Reference AC IDs:** each scenario carries `# AC: AC-N` (or `# AC: AC-N, AC-M` for compound) immediately above its `Scenario:` line.
   - Halt T-FS-7 if a scenario references a non-existent AC.
   - Pre-existing scenarios that conflict with refined specs (T-FS-4) — surface, don't silently rewrite.

4. **AC coverage check.** For each capability in scope, verify every AC ID has at least one referencing scenario. Halt T-FS-6 on uncovered ACs.

5. **Update flows.** For multi-screen scenarios or those with decision points, ensure flow doc current. Add new flows as needed.

6. **Validate against glossary.** All domain nouns in scenarios/flows/UI specs must be in glossary (meta-skill §9 halt if missing — this skill is not a glossary author).

7. **Update INDEX files** (features, flows, ui).

8. **Step summary** with grounded sources.

9. **Halt for Gate 3.**

## Notes

- AC references make missing-AC coverage visible: `technical-reviewer` checks scenarios → ACs → capability cleanly.
- The skill does not invent UI design. It translates, surfaces, or proposes (with approval).
- The `@inc-NNN` tag is critical for `ui-test-engineer` to filter new scenarios.
- This skill cannot author glossary entries — if a scenario uses a missing term, halt and surface upstream to `business-analyst`.
