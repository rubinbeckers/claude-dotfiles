# Meta-Skill (shared behavior inherited by all skills)

> Every skill in this workflow inherits the behavior defined here. A skill that does not honor these rules is broken. Skill-specific SKILL.md files may extend this but never weaken it.

## 1. Always-allowed inputs (the single authoritative definition)

These docs are always loadable by any skill, regardless of plan, manifest, or scope. They define project-wide constants the workflow depends on:

- `/docs/process/workflow.md`
- `/docs/process/tag-vocabulary.md`
- `/docs/process/sequential-increments.md`
- `/docs/business/domain/glossary.md`
- `/docs/business/domain/cross-context-invariants.md`
- `/docs/technical/guidelines/coding-standards.md`
- `/docs/technical/guidelines/testing-standards.md`
- `/docs/technical/guidelines/naming-conventions.md`
- The skill's own SKILL.md and this meta-skill.

This is the single authoritative list. **Workflow.md, SKILL.md files, and templates reference this section by link, never restate.** A skill needing anything else must justify it via its declared `Inputs:`, the increment plan's Developer Context Manifest, or an explicit halt-and-surface.

## 2. Identity contract

Every skill must declare, at the top of its SKILL.md:

- **Name** (matches folder name).
- **Version** (semver).
- **Purpose** (one sentence).
- **Triggers from** (which skill or event invokes it).
- **Inputs** (specific docs and indices, in addition to §1 always-allowed).
- **Outputs** (specific docs it creates or modifies).
- **Hands off to** (which skill comes next, or "human" if it ends at a gate).
- **Halt triggers** (the shared set in workflow.md §7, plus any skill-specific additions).
- **Utility sub-skill: yes | no** (default: no; see §10).

The orchestrator uses these to verify the loop closes.

## 3. Non-assumption principle

Skills never proceed by assumption. When ambiguity, gap, or conflict arises, the skill:

1. Halts.
2. Appends a halt entry to `step-log.md` (or the appropriate phase-level doc if pre-increment) using the step summary template (§5).
3. Surfaces: trigger fired, affected docs (by path), why it blocks, defensible suggested resolution if available.
4. Returns control with status `awaiting approval`.

## 4. Shared halt triggers

The authoritative list is **workflow.md §7**. Skills inherit it. Skill-specific halt triggers extend the list and are declared in the individual SKILL.md.

## 5. Step summary template

Every step ends with an append to `step-log.md`:

```
## Step Summary — [Phase] / [Skill v<version>] — [ISO timestamp]
- Did: one-line description
- Outputs: file paths
- Decisions logged: decision record paths (TBD-numbered unless this is the registering skill)
- Grounded in: source docs each claim derives from
- Open items surfaced: gaps, conflicts, halts (with proposed resolutions)
- Next: handover target and what it'll do
- Mode: auto-handover | awaiting approval
```

### The `Grounded in:` field (structural enforcement)

For every non-trivial claim or output, list the source doc(s) it derives from.

- `doc-integrity` lints `Grounded in:` entries for **existence** (the doc exists), **scope** (the doc was loadable by this skill — in §1 always-allowed, or in the skill's declared inputs, or in the increment's Developer Context Manifest), and **currency** (not `deprecated`, `superseded`, `withdrawn`, or `superseded-by-increment`). Semantic grounding ("does this doc actually support this claim?") is a Gate-3 / Gate-4 spot-check responsibility for the human.

If a claim cannot be traced to a source, it is an assumption. Move it to `Open items surfaced:` and halt.

## 6. INDEX update discipline

Every doc created or modified requires the corresponding INDEX to be updated in the same step. If the INDEX is not updated, the step is incomplete and may not hand off. Specific responsibilities:

- New capability spec → `capabilities/INDEX.md` row added.
- New ADR → `architecture/INDEX.md` row added.
- New component doc → `components/INDEX.md` row added.
- Status change on existing artifact → row updated.
- New `.feature` file → `features/INDEX.md` row added.
- New prototype → `design/INDEX.md` row added.
- Increment status transitions (`in-progress` → `delivered` / `abandoned` / `superseded-by-increment`) → `increments/INDEX.md`.

## 7. Decision-record number assignment (registering-skill rule)

Final numbers are assigned by the skill that **registers** the decision into its INDEX. Currently:

- **Phase-level decisions** proposed by `phase-intake` are numbered by `phase-intake` at Gate 1 approval.
- **Increment-level decisions** proposed during an increment (by `business-analyst`, `functional-specifier`, `implementation-planner`, `developer`, or any other increment-scoped skill) are numbered by `increment-close`.

Drafts use the placeholder `<TYPE>-TBD-<slug>.md` until the registering skill assigns the final number. Any non-registering skill needing a final number halts (workflow.md §7 trigger 9).

This rule supersedes any earlier wording that said "only increment-close assigns final numbers" — that wording is obsolete.

## 8. Tag validation

Every doc write validates any tags against `/docs/process/tag-vocabulary.md`. Unknown tags trigger halt trigger 8.

Proposing a new tag: halt with proposed tag, definition, why no existing tag fits. The human approves (which updates `tag-vocabulary.md`) before the skill resumes.

## 9. Glossary authoring carve-out

The default rule is halt-on-missing-term (workflow.md §7 trigger 3). The carve-out:

**Any skill that creates an aggregate or capability spec may author the corresponding glossary entry in the same step.** Currently this is `phase-intake` and `business-analyst`. Authored entries cite the aggregate or capability spec as the source ("definition introduced via `<path>`") and are reviewed at the gate that approves the originating artifact. The gate approves the entry implicitly by approving the artifact.

All other skills halt on missing terms. Surfacing missing terms downstream is a signal that the upstream layer missed something.

## 10. Skill boundaries and the utility sub-skill carve-out

A skill operates only within its declared scope:

- Reads only its declared `Inputs:` plus §1 always-allowed.
- Writes only its declared `Outputs:`.
- Does not modify docs owned by other skills.

**Utility sub-skill exception:** a skill that declares `Utility sub-skill: yes` in its identity contract may be invoked from other skills (rather than only by the orchestrator). The currently-declared utility sub-skill is **`doc-integrity`**, invocable from `increment-close` and `phase-close`. No other skill currently holds this status. The exception is opt-in: a skill must explicitly declare itself a utility sub-skill, and the invoking skills must explicitly cite this carve-out when invoking it.

A skill needing to do something outside its boundary (and not authorized via utility sub-skill carve-out) halts (workflow.md §7 trigger 11) and surfaces.

## 11. Mechanical vs. human-judgment outputs

When a skill produces verifications or attestations (typically `technical-reviewer` and `increment-close`), it explicitly separates two categories in its output:

- **Verified mechanically:** items checked by the agent against deterministic rules (coverage thresholds, lint results, scan results, cross-reference resolution, INDEX consistency).
- **Needs human confirmation:** items that require human judgment (threat-considerations answers, authn/authz declarations, security-critical classification correctness, scope-vs-intent alignment).

This separation is reflected in `review.md` and in the Gate 5 PR checklist. The intent is to prevent the human skimming a long mechanical-pass-summary and implicitly trusting items that actually needed their attention.

## 12. Standards-observations append

Skills that surface standards-related issues (typically `technical-reviewer`, occasionally `developer` when self-flagging) append a one-line observation to `/docs/phases/NN-<slug>/standards-observations.md`:

```
[timestamp] [skill] [inc-NNN] [category] one-line description
```

Categories: `coding`, `testing`, `naming`, `security`, `other`. Appending happens whether or not the observation blocks the current step.

`phase-close` synthesizes this file into the retrospective's standards-adequacy section.

## 13. Learnings logging

Every skill, at end of step, evaluates: did anything happen future runs should know about? If yes, append to `/docs/process/learnings/<skill-name>.md`:

```
## [ISO timestamp] — [increment id]
- Observation: what happened
- Trigger: what caused it
- Resolution: how it was resolved (or who decided)
- Generalizable?: yes / no / unclear (curator's call)
```

`skill-curator` reads these at phase close.

## 14. Pin re-validation and the override path

At session start (via `session-resume`), the meta-skill bootstrap check validates that every pinned skill version in workflow.md §15 is reachable in dotfiles.

- **Match:** proceed.
- **Mismatch:** halt with a structured surface listing missing or modified versions.

**Override path (exceptional):** if mid-phase rollback isn't workable, the human may authorize a forward-pin override:

- An ADR is created recording: the missing/modified version, the substitute version chosen (nearest available newer version), the rationale, and an explicit "exceptional mid-phase override" acknowledgement.
- The pin in workflow.md §15 is updated to the substitute.
- The override is logged for `skill-curator` review at phase end — repeated overrides may signal dotfiles repo hygiene issues.

Phase-rollback-and-restart is reserved for cases where forward-pin substitution isn't workable (e.g., breaking change in the substitute).

## 15. Handover toggle handling

Each skill reads its effective handover mode (skill override → project default in workflow.md §15).

- `auto`: write step summary, advance to handover target without surfacing.
- `gated`: write step summary, surface for confirmation, await `proceed`.

Required gates (workflow.md §8) and halt-trigger surfaces always surface regardless of mode.

## 16. Failure modes

For failures not covered by halt triggers (tool failure, environment issue):

- Log the failure in `step-log.md` with full context.
- Status `failed`.
- Surface: nature, partial outputs (if any), suggested recovery.

The orchestrator (or human) decides retry / escalate / abandon.

## 17. Inheritance summary

Individual SKILL.md files are permitted to:

- Add skill-specific halt triggers.
- Add skill-specific input/output requirements.
- Specify domain-specific behavior.

Individual SKILL.md files are **not** permitted to:

- Disable or weaken any rule in this meta-skill.
- Bypass tag validation, INDEX updates, step summaries, `Grounded in:` discipline, or mechanical-vs-human-judgment separation.
- Self-modify on the basis of project-level learnings (only the curator + human can change a skill).
