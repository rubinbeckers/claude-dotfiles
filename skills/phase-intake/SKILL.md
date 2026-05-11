# phase-intake

- **Name:** phase-intake
- **Version:** 1.0.0
- **Purpose:** Convert raw unstructured input for a phase into quality-checked structured outputs (capabilities, domain updates, architectural direction, design direction, increment roadmap). Number phase-level decisions on registration.
- **Triggers from:** `session-resume` detecting raw input + no active phase; or `phase-close` of prior phase.
- **Inputs:**
  - All files in `/docs/phases/NN-<slug>/intake/raw/`.
  - Product-level indices: `capabilities/INDEX.md`, `domain/INDEX.md`, `architecture/INDEX.md`, `components/INDEX.md`.
  - Existing decision records filtered by status `accepted`.
  - Plus meta-skill §1 always-allowed.
- **Outputs (Pass 1 — before Gate 0):**
  - `/docs/phases/NN-<slug>/intake-review.md` — itemized gaps, conflicts, suggested defaults, **proposed initial area tags** (alongside other approvals).
- **Outputs (Pass 2 — after Gate 0, before Gate 1):**
  - Capability index updates and new/revised `<capability>.md` specs (with all required fields incl. Data classification, Authn/Authz, Threat considerations elaborated for classified capabilities).
  - New/revised aggregate files (from `templates/aggregate.md`) with Data classification.
  - **Glossary entries** authored in the same step as the aggregate/capability that introduces them (meta-skill §9 carve-out). Definitions cite the introducing artifact.
  - DDRs for domain model changes; CDRs for scope decisions; FDRs for design direction; ADRs for architectural direction. All from `templates/decision-record.md`.
  - **Phase-level decision records numbered by this skill** at Gate 1 approval (registering-skill rule, meta-skill §7).
  - `/docs/phases/NN-<slug>/scope.md`, `direction.md`, `roadmap.md`.
- **Amendment mode outputs:** `/docs/phases/NN-<slug>/intake-amendment-NN.md`.
- **Hands off to:** Human at Gate 0, then Gate 1, then → `session-resume` → `increment-start`.
- **Inherits:** Meta-skill.
- **Utility sub-skill:** no.

## Skill-specific halt triggers

- T-PI-1: Raw input folder is empty.
- T-PI-2: Raw input is unreadable (no silent skipping — surface the unreadable file).
- T-PI-3: An approved default would contradict an existing accepted ADR or DDR (supersession decision required first).
- T-PI-4: A capability classified > public has Threat Considerations questions the human did not answer.
- T-PI-5: Amendment mode invoked but no active phase exists, or phase-close has already run for the named phase (use corrective increment instead).

## Process

### Pass 1 — Intake review (before Gate 0)

1. **Inventory raw input.** List each file in `intake/raw/`. Halt T-PI-2 on unreadable.

2. **Extract themes and implied capabilities.** Map to existing capabilities or flag as "new candidate."

3. **Identify gaps and conflicts.**
   - Capabilities underspecified (no actor, no AC, no NFRs, no data classification).
   - Domain terms used not in glossary.
   - Statements conflicting with existing accepted decisions.
   - References to non-existent artifacts.
   - Missing prioritization signals.

4. **Propose initial area tags.** For each major domain area implied by the input, propose an area tag (`@billing`, `@auth`, etc.) with a one-line definition. These ride alongside the gap items for individual approval, so the first phase doesn't constantly halt on the first tag write.

5. **Draft `intake-review.md`** from `templates/phase-intake-review.md`. Itemize every gap, conflict, proposed default, and proposed area tag for individual approval.

6. **Step summary + halt for Gate 0.**

### Pass 2 — Phase outputs (after Gate 0)

7. **Apply approved defaults.** Approved area tags are added to `tag-vocabulary.md`. Approved direction defaults become decision records (CDR/FDR/ADR/DDR per type).

8. **Update capability index and specs.** Use `templates/capability.md`. Required fields:
   - Intent, actors, AC with IDs (`AC-1`, `AC-2`, …).
   - NFR section.
   - **Data classification** (public / internal / confidential / restricted).
   - **Authn required** (yes/no — type).
   - **Authz model** (who can invoke, under what conditions).
   - **Threat considerations** — **questions** to be answered when classification > public or trust boundary crossed. Standard prompts: trust boundaries crossed; data in/out; worst-case abuse; threat actor profile. The agent does not author threat analysis; the agent surfaces the questions. The human answers at Gate 1. Halt T-PI-4 if approval is attempted before answers exist.

9. **Update domain.** Aggregate files include Data classification. New glossary entries authored alongside (carve-out). DDRs for model changes.

10. **Number phase-level decision records.** Per registering-skill rule: at this moment (entering Gate 1 approval), this skill assigns final numbers to its own proposed decision records by scanning each target INDEX and incrementing. TBD placeholders are resolved here. Rows added to INDEX with status `accepted` post Gate 1.

11. **Draft phase docs.**
    - `scope.md` (`templates/phase-scope.md`)
    - `direction.md` (`templates/phase-direction.md`)
    - `roadmap.md` (`templates/phase-roadmap.md`)

12. **Step summary + halt for Gate 1.**

### Amendment mode

13. **Triggered when:** during an active phase, new or corrected raw input arrives. Skill is invoked explicitly in amendment mode by the human.

14. **Halts if:** phase-close has already run for this phase (use corrective increment) or no active phase exists.

15. **Produces:** `intake-amendment-NN.md` (NN sequential) listing what changed in the input, what's affected in existing outputs, proposed delta actions.

16. **Gate 0' approval:** the human approves the amendment items. Approved deltas are applied as patches to capability specs, domain, etc., with their own new decision records (numbered now per registering rule). Existing decision records are not edited — they are superseded if necessary.

17. **No new Gate 1:** if the amendment only adjusts existing outputs, no second Gate 1 is required. If it materially shifts direction, a follow-on `phase-intake` pass may be triggered explicitly.

## Notes

- Threat Considerations are *prompts*, not answers. The agent doesn't have security expertise; it ensures the questions are asked.
- "Area tag proposal in Pass 1" prevents the first-phase tag-halt-loop the red team flagged.
- Glossary authoring is bounded to this skill and `business-analyst`; downstream skills halt on missing terms.
- Decision-record numbering at Gate 1 makes phase-level proposals durable. Subsequent agents reference them by final number.
