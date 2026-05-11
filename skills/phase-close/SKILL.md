# phase-close

- **Name:** phase-close
- **Version:** 1.0.0
- **Purpose:** Close a phase after its final increment is merged: full doc-integrity sweep (utility carve-out), consolidate increment step-logs into phase log, archive ephemera, write retrospective including workflow-defects and standards-adequacy synthesis, lock the phase, trigger curator.
- **Triggers from:** `session-resume` detecting last increment of phase is `delivered` and no more roadmap entries planned (or manual invocation).
- **Inputs:**
  - Current phase folder `/docs/phases/NN-<slug>/`.
  - All increment folders belonging to this phase (resolved via `@phase-NN` in `increments/INDEX.md`).
  - `/docs/phases/NN-<slug>/standards-observations.md`.
  - `/docs/process/learnings/*.md`.
  - Plus meta-skill §1 always-allowed.
- **Outputs:**
  - Invokes `doc-integrity` (utility sub-skill, meta-skill §10) with scope = full project.
  - `/docs/phases/NN-<slug>/phase-log.md` — consolidated step-log narrative across all increments.
  - Archived (or deleted, per config) increment `step-log.md` files. Default: archive to `/docs/phases/NN-<slug>/archived-step-logs/<inc-id>.md`. Config `cleanup_step_logs: true` deletes instead.
  - `/docs/phases/NN-<slug>/retrospective.md` (from `templates/phase-retrospective.md`) including:
    - Delivered vs. planned scope.
    - Key decisions made.
    - **Workflow-defects synthesis** — patterns from `learnings/*.md` files this phase that suggest skill or workflow issues.
    - **Standards-adequacy synthesis** — synthesizing `standards-observations.md` into proposed standards updates (each is a candidate change to `coding-standards.md`, `testing-standards.md`, or `naming-conventions.md`, surfaced for human approval).
    - Direction for next phase (if known).
  - Updated `/docs/phases/INDEX.md` — this phase → `completed`.
  - Trigger sent to `skill-curator`.
- **Hands off to:** `skill-curator` (asynchronous). Phase is now **locked** — see notes.
- **Inherits:** Meta-skill.
- **Utility sub-skill:** no.

## Skill-specific halt triggers

- T-PC-1: Full `doc-integrity` sweep reports unresolvable issues.
- T-PC-2: An increment in this phase not in `delivered` or `abandoned` status (can't close with open increments).
- T-PC-3: Roadmap has unaddressed `planned` entries (must be explicitly deferred via CDR or moved out of scope).

## Process

1. **Verify phase completion.**
   - Every increment tagged for this phase is `delivered` or `abandoned`. Halt T-PC-2.
   - Every roadmap entry is `delivered`, `deferred-with-CDR`, or `out-of-scope`. Halt T-PC-3.

2. **Invoke `doc-integrity` (utility carve-out, full sweep).** Cite meta-skill §10. Checks broader than per-increment: full cross-reference resolution, INDEX consistency, tag vocabulary, glossary completeness (full sweep), ADR coherence (orphan proposed, bidirectional supersession, withdrawn-reference checks), capability ↔ feature alignment, component ↔ ADR alignment. Surface unresolvable issues (halt T-PC-1).

3. **Consolidate phase log.** Create `phase-log.md` summarizing each increment in narrative form (scope, decisions, capabilities delivered, key challenges from step-log halts, retrospective notes). Goal: someone reading only this can reconstruct the phase without individual step-logs.

4. **Archive (or delete) increment step-logs.** Default: move each `step-log.md` to `/docs/phases/NN-<slug>/archived-step-logs/<inc-id>.md`. The other increment files (`scope.md`, `plan.md`, `changelog.md`, `review.md`) are preserved — they're durable records.

5. **Synthesize workflow-defects.** Read each `/docs/process/learnings/<skill>.md` file. For each entry tagged with this phase, surface in retrospective:
   - Patterns observed (recurring halts, gaps in skills).
   - Skill ambiguities encountered.
   - Process friction.
   This feeds `skill-curator`.

6. **Synthesize standards-adequacy.** Read `/docs/phases/NN-<slug>/standards-observations.md`. Group by category (coding / testing / naming / security / other). For each cluster, propose a candidate standards update (specific text addition / change to `coding-standards.md`, `testing-standards.md`, etc.). Surface for human approval in the retrospective; approved updates become a doc-only increment in the next phase (or current phase if not yet locked at this exact moment — see lock-in note).

7. **Write `retrospective.md`** with required sections (delivered vs. planned, decisions, workflow-defects, standards-adequacy, next-phase direction, metrics).

8. **Update `phases/INDEX.md`** — this phase → `completed` with date.

9. **Trigger `skill-curator`.** Pass project learnings paths, retrospective, phase log. Curator runs asynchronously.

10. **Step summary:**

    ```
    ## ✅ Phase NN-<slug> closed
    - Increments delivered: <count>
    - Doc integrity: clean (full sweep)
    - Phase log written
    - Retrospective written (workflow-defects: <N>, standards-adequacy: <M>)
    - Step-logs archived
    - Skill curator triggered
    
    ## 🔒 Phase locked
    - Subsequent corrections to this phase's outputs route through corrective increments (workflow.md §10).
    - `phase-intake` amendment mode is no longer available for this phase.
    
    ## 🔔 Next
    - To start next phase: place raw input in /docs/phases/<next>/intake/raw/ and run `session-resume`.
    - To pause: no action needed. Run `project-pause` for explicit pause state.
    ```

## Notes

- **Phase lock-in:** once this skill completes, the phase becomes immutable. The amendment mode in `phase-intake` is no longer available for this phase. Corrections to its outputs route through corrective increments in the next phase. This is enforced by `phase-intake` itself (halt T-PI-5 in `phase-intake`).
- Archive-vs-delete for step-logs: default archive (zero risk of losing context); cleanup is opt-in via config.
- Skill version bumps are natural at phase-close. Retrospective's workflow-defects + curator output may motivate updating pinned versions in `workflow.md` §15 before the next phase begins.
- Phase-close runs `doc-integrity` in full-sweep mode — broader than the per-increment scope. Catches cumulative drift the per-increment checks can't see.
