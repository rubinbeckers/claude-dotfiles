# session-resume

- **Name:** session-resume
- **Version:** 1.0.0
- **Purpose:** Entry point at every session start. Reconcile state (git, indices, in-progress artifacts), validate pinned skill versions, enforce hotfix-backfill discipline by halting on undocumented main-branch commits, route to the appropriate next skill or human action.
- **Triggers from:** Every session start, before any other skill action.
- **Inputs:**
  - Git state (current branch, last fetch, recent commits, working tree status).
  - `/docs/increments/INDEX.md` (most recent statuses).
  - `/docs/phases/INDEX.md` (most recent statuses).
  - Last increment's `step-log.md` if `in-progress`.
  - Last phase's roadmap if a phase is active.
  - Dotfiles registry (for pin re-validation).
  - Plus meta-skill §1 always-allowed.
- **Outputs:**
  - Routing decision: which skill to invoke next, or which human action is required.
  - Updated INDEX statuses if reconciliation requires (e.g., last increment merged on remote since last session → mark `delivered`).
  - Step summary appended to wherever appropriate (last increment's step-log if mid-increment; otherwise a top-level session-resume log).
- **Hands off to:** Determined by routing logic (see Process). Possible targets: `project-init`, `phase-intake`, `increment-start`, in-progress skill (resume), `phase-close`, or human (paused).
- **Inherits:** Meta-skill.
- **Utility sub-skill:** no.

## Skill-specific halt triggers

- T-SR-1: **Undocumented commits on main since last `delivered` increment.** These signal an out-of-workflow change (likely a hotfix per workflow.md §10) that has not been back-filled. Halt and surface — corrective-increment backfill is required before any other workflow action.
- T-SR-2: **Pin re-validation failure** — one or more pinned skill versions per workflow.md §15 not reachable in dotfiles. Halt; surface the failing pins with the override path (workflow.md §13 / meta-skill §14).
- T-SR-3: Conflicting state — local branch on `increment/NNN-<slug>` but `/docs/increments/INDEX.md` shows that increment `delivered`, or vice versa. Surface for human reconciliation.
- T-SR-4: `phase-close` triggered (last increment merged) but `roadmap.md` has unaddressed `planned` entries with no explicit deferral. Surface for direction.
- T-SR-5: Git operation fails (fetch, status).

## Process

1. **Bootstrap: pin re-validation.** Per meta-skill §14, validate every pinned version in workflow.md §15 is reachable in dotfiles. Halt T-SR-2 on mismatch with override-path guidance.

2. **Git state read.**
   - Fetch from origin (read-only; no merging or pulling at this stage).
   - Identify current branch, working tree status (clean? dirty?), most recent commits on `main` and on any `increment/*` branch.

3. **Main-branch hygiene check.**
   - Find merge commit of last `delivered` increment.
   - Scan commits on `main` since that point.
   - Every commit must be a merge commit from an `increment/NNN-<slug>` branch matching an increment in `/docs/increments/INDEX.md`.
   - Any commit not matching is undocumented (likely a hotfix). Halt T-SR-1; surface with corrective-increment-backfill instructions:
     - Open a corrective increment (`@corrects:<inferred-prior-inc>` or `@corrects:hotfix-<date>` if no prior inc applies).
     - Draft a CDR/ADR documenting what the hotfix changed and why.
     - Run through normal workflow to close the loop.

4. **Index reconciliation.**
   - Last increment in `INDEX.md` shows `in-progress` but its branch is merged on remote → flip to `delivered`, log reconciliation.
   - Last increment shows `delivered` but its branch still exists unmerged locally → surface T-SR-3.
   - A phase shows `active` but all its roadmap entries are `delivered` → mark phase as candidate for `phase-close`.

5. **Determine state class:**

   | State | Indicators | Route to |
   |-------|-----------|----------|
   | **No project yet** | No `/docs/process/workflow.md` | `project-init` |
   | **Project exists, no active phase, no raw input** | `phases/INDEX.md` empty or all `completed`; no raw input | Wait (paused); surface to human |
   | **Project exists, raw input present, no active phase** | `/docs/phases/<NN>-<slug>/intake/raw/` non-empty for an unopened phase | `phase-intake` |
   | **Phase active, no in-progress increment** | Phase status `active`, no increment in `in-progress` | `increment-start` |
   | **Mid-increment, no halt** | Increment `in-progress`, step-log shows clean handover state | Resume from last skill's handover target |
   | **Mid-increment, awaiting approval** | Increment `in-progress`, step-log status `awaiting approval` | Surface to human (gate pending) |
   | **Increment merged since last session** | Most recent INDEX update behind git state | Reconcile (step 4), then determine next route |
   | **Last increment of phase merged** | All roadmap entries `delivered`/`deferred` | `phase-close` |
   | **Project paused** | `pause-summary.md` present | Surface paused state with summary; await `project-pause`-removal action |

6. **Step summary.**

   ```
   ## Session resumed — [ISO timestamp]
   - Pin re-validation: ✅ (all versions reachable) | ❌ (see surfaced list)
   - Main-branch hygiene: ✅ (no undocumented commits) | ❌ (see T-SR-1)
   - Index reconciliation: <none | description of reconciliations applied>
   - State detected: <state class>
   - Routing to: <next skill or human action>
   ```

7. **Hand off** per routing decision, or surface for human action if state requires.

## Notes

- This is the workflow's "where am I" skill. It's the first thing run every session — even sessions that pick up exactly where the prior one left off.
- The undocumented-main-commit check (T-SR-1) is the enforcement mechanism for the hotfix-backfill discipline (workflow.md §10). Without it, an emergency commit silently breaks the audit trail forever; with it, the next session refuses to proceed until the backfill happens.
- Pin re-validation (T-SR-2) catches dotfiles drift (a pinned version disappearing or being modified) at session start, not partway through an increment.
- Routing is deterministic given the state class. The skill does not improvise — every state class maps to one route.
- If two state classes look applicable (e.g., raw input present AND mid-increment), the workflow says: complete the increment first (mid-increment wins). Routing reflects that.
- This skill never proceeds past its routing decision. The next skill is invoked separately by the orchestrator.
