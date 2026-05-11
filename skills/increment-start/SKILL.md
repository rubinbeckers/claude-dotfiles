# increment-start

- **Name:** increment-start
- **Version:** 1.0.0
- **Purpose:** Open a new increment: refresh local repo, verify dependencies and main-branch hygiene, create branch, draft scope (including code-changes flag and corrective-increment field).
- **Triggers from:** `session-resume` detecting a phase active and no in-progress increment.
- **Inputs:**
  - `/docs/phases/NN-<slug>/roadmap.md` (current phase).
  - `/docs/business/capabilities/INDEX.md`.
  - `/docs/increments/INDEX.md`.
  - Plus meta-skill §1 always-allowed.
- **Outputs:**
  - Refreshed local repo (pulled from origin; merged local branches pruned).
  - New increment branch `increment/NNN-<slug>` from `main`.
  - `/docs/increments/NNN-<slug>/scope.md` (from `templates/increment-scope.md`) with `code-changes`, optional `@corrects`, declared deps.
  - Initialized `step-log.md`.
  - Row added to `/docs/increments/INDEX.md` with status `in-progress`.
- **Hands off to:** Human at Gate 2, then → `business-analyst` (or `technical-reviewer` directly in doc-only mode).
- **Inherits:** Meta-skill.
- **Utility sub-skill:** no.

## Skill-specific halt triggers

- T-IS-1: Local repo has uncommitted changes.
- T-IS-2: Pull from origin fails.
- T-IS-3: Declared dependency on prior increment not in `delivered` status.
- T-IS-4: Increment number collision.
- T-IS-5: Roadmap entry references capabilities not in index or in `deprecated` / `withdrawn` status.
- T-IS-6 (backstop): **Undocumented commits on main since last `delivered` increment.** Normally caught by `session-resume`; this halt fires if `increment-start` is invoked directly. Requires corrective-increment backfill per workflow.md §10 before this skill can advance.
- T-IS-7: `@corrects:inc-NNN` declared but the named increment is not in `delivered` status, or no CDR/ADR identifying the defect is present.

## Process

1. **Refresh local repo.**
   - Verify clean working tree (halt T-IS-1).
   - `git checkout main && git pull origin main` (halt T-IS-2).
   - **Main-commit hygiene check** (T-IS-6 backstop): scan commits on main since last `delivered` increment's merge commit. Any commit not originating from an increment-branch merge is undocumented — halt and require corrective-increment backfill.
   - Prune local branches merged on origin; report unmerged locals for awareness.

2. **Identify next increment.** From `roadmap.md`, find next `planned` entry. Resolve capability references against `capabilities/INDEX.md` (halt T-IS-5 on bad ref).

3. **Dependency check.** For each `@depends:inc-NNN` declared in roadmap entry, verify `delivered` in `increments/INDEX.md` (halt T-IS-3 otherwise).

4. **Assign increment number.** Scan `/docs/increments/`, increment highest. Halt T-IS-4 on collision.

5. **Create branch.** `git checkout -b increment/NNN-<slug>` from `main`.

6. **Draft `scope.md`** from `templates/increment-scope.md`. Required fields:
   - In-scope capabilities (with slices).
   - In-scope scenarios.
   - Out-of-scope explicit.
   - Acceptance criteria.
   - **`code-changes: yes | none`** — `none` triggers doc-only routing (developer + ui-test-engineer skipped per workflow.md §10).
   - **`@corrects:inc-NNN`** if this is a corrective increment (T-IS-7 validates).
   - Declared dependencies.

7. **Initialize `step-log.md`** with metadata header and this skill's step summary.

8. **Update `/docs/increments/INDEX.md`** — row added, status `in-progress`.

9. **Step summary + halt for Gate 2.**

## Notes

- T-IS-6 is the backstop for the hotfix-discipline enforcement, in case `session-resume` was skipped. The two checks are layered intentionally.
- Doc-only increments (`code-changes: none`) follow the same skill chain through scope.md → review.md → close.md but skip `developer` and `ui-test-engineer`. The orchestrator handles this routing.
- Corrective increments (`@corrects:inc-NNN`) require explicit defect identification before they can open. The CDR/ADR documenting the defect can be drafted as part of this skill's outputs (TBD-numbered, finalized at increment-close per registering-skill rule).
