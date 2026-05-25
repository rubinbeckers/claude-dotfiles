---
name: session-resume
description: Canonical session entry point. Use whenever a working session begins on this project, regardless of whether work is fresh, mid-phase, mid-increment, or post-merge. Trigger phrases include 'continue', 'resume', 'where were we', 'pick up', or any unspecified opening on an existing project.
---

# session-resume

This is the only canonical session-entry skill. The human invokes it (or it runs automatically at session start) before any other workflow action. Its job is to read the workflow's current state and route to the next correct skill.

The skill operates in the orchestrator's chat (main chat). It does not delegate to a subagent.

## Inputs (read in order)

1. `workflow.md` — the workflow contract. Read first, always, every session.
2. `agentic-sdlc-principles.md` — the principles this workflow instantiates.
3. `INDEX.md` — current project state (active phase, active increment, status, last-recorded action).
4. `skill-versions.lock` — pinned skill versions.
5. Git state (via `git log`, `git status`, `git branch --show-current`).
6. The active phase's transient directory, if a phase is active: `docs/transient/phases/<phase-slug>/`.

The skill inherits the always-allowed read set from `_meta/SKILL.md` §1.

## Outputs

- Updates `INDEX.md` to reflect any state changes detected (e.g., a merged PR since last session).
- Emits a status summary to the human chat: where the project is, what skill is next, what action is being taken.
- Invokes the next skill in the workflow, or halts if state is inconsistent.

## Steps

### Step 1 — Load the workflow

Read `workflow.md` end to end. Internalize §1 (levels), §4 (skill inventory), §5 (gates), §6 (phase flow), §7 (increment flow), §8 (halt matrix), §13 (session lifecycle), §15 (status protocol).

This step is non-negotiable and runs even if the chat session has just read `workflow.md`. The workflow is the contract; rules drift if it isn't reloaded.

Emit: `Workflow loaded.`

### Step 2 — Validate pinned skill versions

Per `_meta` §11: read `skill-versions.lock`, verify each pinned skill exists and matches in the skills repo. On mismatch, halt with:

```
HALT
  Skill: session-resume
  At-step: pin-validation
  Reason: pinned skill version not reachable
  Missing/Conflicting: <skill-name>@<pinned-version>
  Route-to: human
  Re-pass: none
```

On success, emit: `Pin validation: <N> skills, <M> templates pinned and reachable.`

### Step 3 — Read project state

Read `INDEX.md`. Extract:
- Active phase (slug, status: planning | in-progress | closing | retrospective | improvement-review | closed)
- Active increment (slug, status: planning | in-progress | closing | awaiting-merge | closed)
- Last halt (if any): source skill, reason, route-to destination
- Pending gates (if any)

If `INDEX.md` is missing or malformed, halt routing to `project-init`.

### Step 4 — Scan git for state drift

Run `git log` to enumerate commits since the last recorded action in `INDEX.md`. For each commit:
- If on a known increment branch and the branch has been merged to `develop` since last session → mark that increment as `closed` in INDEX, advance state. (The workflow does not observe `main`; promotion from `develop` to `main` is out-of-workflow per workflow.md §17.)
- If on `develop` but not associated with any known increment branch → halt with undocumented-develop-commits per `workflow.md` §13 step 4. The workflow never scans `main` (§17).
- If on the current active increment branch and not merged → no state change, increment still in progress.

Run `git status` to detect uncommitted local changes. Surface to human but do not halt (they may be intentional working changes).

### Step 4.5 — Apply staged skill diffs (M6)

Per `_meta` §11 staging rule: if pending skill diffs were staged at the prior `improvement-review` and target critical-path skills (`_meta`, `improvement-review`, `workflow-curator`, `session-resume`, `backlog-loop`), apply them now — before the routing decisions in step 5 — so the new session reads the updated skills.

Diff application uses `workflow-curator` apply-mode (cited under utility-sub-skill carve-out, `_meta` §6). For each pending diff:
- Read the staged diff file from `docs/transient/pending-skill-diffs/`
- Apply to the target skill file
- Validate the resulting file is well-formed (frontmatter parses, markdown sections balanced)
- If well-formed: remove from staging
- If malformed: revert, halt with T-SR-7

After all pending diffs apply, proceed to step 5 with the updated skill content (which the orchestrator will re-load).

### Step 5 — Route

Based on the combined state from steps 3, 4, and 4.5, read the latest `gate_status:` entries in INDEX (per `_meta` §16) and route to the next skill per the routing table below.

```
State                                          → Action
─────────────────────────────────────────────────────────────────────────────
No INDEX.md exists                             → invoke project-init
INDEX exists, no active phase, raw-input present → invoke phase-start
INDEX exists, no active phase, no raw input    → halt to human, await phase initiation
Active phase, status=planning, no gate-1 entry → resume in phase-planning (re-enter at step it halted on)
Active phase, status=planning, gate-1 approved → invoke increment-start (first increment)
Active phase, gate-1 changes/reject            → re-pass relevant phase-* skill per the changes
Active phase, no active increment, increments remain in plan → invoke increment-start (next increment)
Active phase, no active increment, all increments delivered → invoke phase-close
Active phase, status=closing                   → resume in phase-close
Active phase, status=retrospective             → resume in phase-retrospective
Active phase, status=improvement-review        → invoke improvement-review (Gate 3)
Active phase, status=closed (and next-phase trigger present) → invoke phase-start (new phase; reads carry-forward per workflow.md §15.6)
Active increment, status=planning, no gate-2 entry → resume in increment-planning
Active increment, status=planning, gate-2 approved → invoke backlog-loop
Active increment, gate-2 changes/reject        → re-pass relevant increment-* skill per the changes
Active increment, status=in-progress           → invoke backlog-loop (resumes mid-loop)
Active increment, status=closing               → resume in increment-close
Active increment, status=awaiting-merge        → halt to human, surface "merge PR before resuming"
Last halt recorded, not yet resolved           → resume at halt's route-to destination
Undocumented develop commits exist             → halt, require corrective-increment backfill
```

### Step 6 — Emit status summary and invoke

Before invoking the next skill, emit a status summary in this format:

```
═══════════════════════════════════════════════
Session resumed.
Project: <project-name>
Active phase: <slug> (status: <status>)
Active increment: <slug or "none"> (status: <status>)
Last recorded action: <action> at <timestamp>
Detected since last session: <list of git changes or "none">
Next: <skill-name>
═══════════════════════════════════════════════
```

Then invoke the next skill (orchestration skills are invoked by loading their SKILL.md and proceeding through their steps; subagent skills are invoked via the Task tool with the manifest constructed per the subagent's definition).

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-SR-1 | Pinned skill version not reachable | human |
| T-SR-2 | `INDEX.md` missing or malformed | `project-init` (if missing) or human (if malformed) |
| T-SR-3 | Undocumented `develop` commits detected (commits not traceable to an increment branch) | human (require corrective-increment backfill) |
| T-SR-4 | Last halt unresolved AND its route-to skill cannot be invoked | human |
| T-SR-5 | Git state and INDEX state diverge in ways step 4's rules can't reconcile | human |
| T-SR-6 | Two active increments detected (workflow invariant violation) | human |
| T-SR-7 | Staged skill diff application produced malformed file at step 4.5 | revert; halt to human; requires re-synthesis at next phase-retrospective |

## Observations to surface

Surface as `routine` per `_meta` §10 whenever:
- Pin re-validation took notably long or required network retries.
- Git scan found commits that fit a pattern not in the routing table (a new pattern the workflow should learn).
- An increment was closed at the same time `phase-close` should have triggered, but routing went to `phase-close` cleanly only because of step ordering — surface as a robustness observation.

Surface as `critical` per `_meta` §10 whenever:
- Two active increments are detected (T-SR-6) — workflow integrity violation.
- A halt entry references a skill that no longer exists in the skills repo.

## Step summary template

```
Skill: session-resume
Status: success | halt
Files written: INDEX.md (updated)
Grounded in: workflow.md, INDEX.md, skill-versions.lock, git state
Next: <skill-name>
Observations: <list>
```

End of `session-resume/SKILL.md`.
