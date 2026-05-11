# project-pause

- **Name:** project-pause
- **Version:** 1.0.0
- **Purpose:** Capture a clean paused state for the project so future `session-resume` invocations can pick up unambiguously without inferring intent.
- **Triggers from:** Manual invocation when the human wants to pause work explicitly (long break, switching to another project, end of engagement).
- **Inputs:**
  - All `INDEX.md` files (for current statuses).
  - Last `step-log.md` if mid-increment.
  - `/docs/phases/<active>/roadmap.md` if a phase is active.
  - Plus meta-skill §1 always-allowed.
- **Outputs:**
  - `/docs/process/pause-summary.md` — captures: pause timestamp, what was in progress, what was the next planned step, any open items / surfaced halts, notes for resumption.
  - Statuses left as-is in INDEX files (pause is a project-level annotation, not a status change on artifacts).
- **Hands off to:** Human (project now paused; next session's `session-resume` will detect and surface).
- **Inherits:** Meta-skill.
- **Utility sub-skill:** no.

## Skill-specific halt triggers

- T-PP-1: `pause-summary.md` already exists with a recent timestamp (within the last hour) — likely accidental re-invocation. Surface for confirmation.
- T-PP-2: Working tree is dirty with uncommitted changes — surface, ask whether to commit, stash, or proceed without.

## Process

1. **Snapshot state.**
   - Current phase and status.
   - Current increment (if any) and status.
   - Last skill invoked, last gate hit, last halt (if any) — from most recent step-log.
   - Working tree status (clean / dirty).
   - Branch state.

2. **Identify next planned step** by simulating `session-resume`'s routing logic. Record this in the summary so the human knows what would happen on resume.

3. **Collect open items** — any `awaiting approval` step summaries, any unresolved halts, any decision records in TBD state.

4. **Generate `pause-summary.md`** from `templates/pause-summary.md`. Sections:
   - Pause timestamp.
   - Phase and increment context.
   - Last step.
   - Open items (with paths).
   - Working-tree state.
   - Next planned step (per simulated routing).
   - Notes (free-form, optional human-supplied context).

5. **Commit pause-summary** to current branch (or main if no branch): `chore(pause): record project pause state`.

6. **Step summary.**

   ```
   ## ⏸️ Project paused — [ISO timestamp]
   - Phase: <NN-slug> [<status>]
   - Increment: <NNN-slug | none>
   - Last step: <skill> @ <timestamp>
   - Open items: <count>
   - Working tree: <clean | dirty with note>
   - Next on resume: <route>
   - Summary at: /docs/process/pause-summary.md
   ```

## Notes

- Pause is a soft state. Nothing technical prevents continuing — the artifact just makes the pause visible to future `session-resume`.
- On resume, `session-resume` detects `pause-summary.md`, surfaces it, and asks the human whether to clear it (and proceed with whatever the original next step was) or stay paused.
- Clearing the pause is done by deleting or renaming `pause-summary.md` — there's no separate "unpause" skill. The next session's `session-resume` notices it's gone and routes normally.
- Pause summary captures intent for the future-self / future-orchestrator. It's not auto-generated state that can be reconstructed from git — it's a narrative artifact.
- If the project is going to be paused for a long time, the human may also want to pin all skill versions explicitly in `workflow.md` §15 (rather than relying on dotfiles availability later). That's a separate decision, not enforced here.
