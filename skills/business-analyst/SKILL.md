# business-analyst

- **Name:** business-analyst
- **Version:** 1.0.0
- **Purpose:** Refine business-layer documentation (capabilities and domain model) for the in-scope increment. Author glossary entries alongside new terms. Surface threat-question prompts on capabilities classified > public.
- **Triggers from:** `increment-start` (after Gate 2).
- **Inputs:**
  - `/docs/increments/NNN-<slug>/scope.md`.
  - In-scope capability specs.
  - Aggregate files referenced by in-scope capabilities (via cross-references).
  - Decision records (DDRs, CDRs) tagged for in-scope context.
  - Plus meta-skill §1 always-allowed (which includes glossary and cross-context-invariants).
- **Outputs:**
  - Refined `<capability>.md` files (NFRs, Data classification, Authn/Authz, Threat considerations questions where applicable).
  - Updated aggregate files (with Data classification; new ones from `templates/aggregate.md`).
  - **Glossary entries authored alongside new aggregates/capabilities** (meta-skill §9 carve-out; entries cite the introducing artifact).
  - New DDRs (TBD-numbered) for domain changes; new CDRs (TBD-numbered) for scope decisions surfaced. All decision records use `templates/decision-record.md`.
  - Updated INDEX files.
  - Step summary.
- **Hands off to:** `functional-specifier`.
- **Inherits:** Meta-skill.
- **Utility sub-skill:** no.

## Skill-specific halt triggers

- T-BA-1: In-scope capability spec missing required sections (intent, AC with IDs, NFRs, Data classification).
- T-BA-2: Refinement would change a cross-context-invariant (requires explicit human-approved DDR).
- T-BA-3: Contradictory acceptance criteria across in-scope capabilities on the same actor or domain object.
- T-BA-4: In-scope capability requires a domain concept not modelled (no aggregate, no VO).
- T-BA-5: Capability classified > public lacks Authn required, Authz model, or Threat considerations questions surfaced for human answer (questions, not answers; the human supplies answers).

## Process

1. **Load scoped context.** Read `scope.md`. For each in-scope capability, load its spec and the aggregates it cross-references.

2. **Check required fields.** Every in-scope capability spec must have: intent, actors, AC with IDs, NFRs, Data classification, Authn required, Authz model. Halt T-BA-1 on any missing.

3. **Surface threat-considerations questions.** For capabilities classified > public OR crossing a trust boundary, populate the Threat considerations section with standard prompts (per `templates/capability.md`):
   - What trust boundaries does this capability cross?
   - What data flows in and out?
   - What's the worst-case scenario if abused?
   - Who is the threat actor?
   
   This is a refinement of the spec — the agent surfaces the questions; the human answers at the next gate. Halt T-BA-5 if approval is attempted with the questions still unanswered.

4. **Glossary authoring.** For any new domain term introduced in a refined capability or aggregate this skill is creating, author the corresponding glossary entry (meta-skill §9 carve-out) citing the introducing artifact. The entry is reviewed implicitly at the gate that approves the artifact.

5. **Domain alignment.** Verify:
   - Every actor and key noun in in-scope capabilities maps to an aggregate, entity, or VO.
   - Behaviors don't contradict invariants.
   - Cross-context implications recognized (halt T-BA-2 on cross-context-invariant change).

   For gaps, draft DDRs (TBD-numbered) proposing the change. Surface for review.

6. **Refine capability specs.** Sharpen AC, refine NFRs (especially Security: subsection), add cross-references.

7. **Update INDEX files** (capabilities statuses, domain aggregates).

8. **Step summary** with `Grounded in:` listing exact source docs.

9. **Handover** to `functional-specifier`.

## Notes

- Refinement is conservative — change only what the scope reveals. Speculative refinement of out-of-scope capabilities is forbidden (meta-skill §10 / workflow.md §7 trigger 11).
- New CDRs typically capture decisions like "this capability's slice X is in scope, slice Y deferred." Numbered by `increment-close` at increment-close per registering rule.
- Threat Considerations: the agent does not produce expert threat analysis (workflow.md §16). It surfaces the standard questions and ensures the human answers them before the gate.
- Glossary entries authored here cite the aggregate or capability spec that introduced the term ("Definition introduced via [path]"). The curator may later promote stable definitions to first-class glossary entries cited independently.
