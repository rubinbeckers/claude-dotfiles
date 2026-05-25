---
name: improvement-review
description: Gate 3. Human reviews proposed skill diffs and standards updates produced by phase-retrospective + workflow-curator. Approved diffs are applied mechanically to the skills repo. Invoked by session-resume when a phase has status improvement-review.
---

# improvement-review

Gate 3. Presents the human with proposed skill and standards diffs synthesized during `phase-retrospective`. Approves, modifies, defers, or rejects each. Applied diffs are committed to the skills repo (dotfiles or project-local).

Runs as an orchestration skill in the main chat. Invokes `workflow-curator` to apply approved diffs.

## Inputs

- `docs/transient/phases/<phase-slug>/phase-retrospective.md`
- `docs/transient/phases/<phase-slug>/skill-diff-proposals/*.diff`
- `docs/transient/phases/<phase-slug>/standards-diff-proposals/*.diff`
- INDEX
- Skills repo (`.claude/skills/`, `.claude/agents/` — possibly symlinked)
- `skill-versions.lock`
- Always-allowed set (`_meta` §1)

## Outputs

- Annotated proposals: each proposal file gets a `decision: approve | modify | defer | reject` header
- Applied diffs in the skills repo (committed to dotfiles repo if symlinked)
- Updated `skill-versions.lock` reflecting new pinned versions
- INDEX updated: phase status flips to `closed` after approval, `transient_pruning_eligible` confirmed
- The phase's transient docs pruned per consolidation outcome from phase-close

## Steps

### Step 1 — Surface proposals to human

Status line:

```
═══════════════════════════════════════════════
Gate 3: Improvement review.
Phase: <phase-slug>
Skill diff proposals: <count>
Standards diff proposals: <count>

Each proposal:
  - <id>: <one-line summary>
    Source observations: <count>
    Risk: <low|medium|high>
    File: docs/transient/phases/<phase-slug>/skill-diff-proposals/<id>.diff

Awaiting decisions.
═══════════════════════════════════════════════
```

The human reads each diff and annotates it with one of:
- `decision: approve` — apply as-is
- `decision: modify` — apply with edits (human edits the diff first, then approves)
- `decision: defer` — postpone; no action this gate, no log of further deferrals
- `decision: reject` — reject; logged so the same observation doesn't re-propose without new context

### Step 2 — Apply approved diffs (M6 staging rule)

For each `approve` (after human modifications, if any):

**Critical-path skills (staged for next session):** if the diff targets `_meta`, `improvement-review`, `workflow-curator`, `session-resume`, or `backlog-loop`, do NOT apply in-session. Stage the diff at `docs/transient/pending-skill-diffs/<diff-id>.diff` and record in INDEX. The next `session-resume` step 4.5 applies it before any routing decisions, so the new session reads the updated skill.

**All other skills:** apply in-session.
- Invoke `workflow-curator` apply-mode (cited under utility-sub-skill carve-out per `_meta` §6).
- Verify the resulting file is well-formed (skill SKILL.md parses, standards doc parses).
- If the change is in a dotfiles-symlinked skills repo, commit the change to that repo with a structured message:
  ```
  feat(<skill-name>): <one-line summary> [phase <phase-slug>]
  
  Grounded in: <observation count> observations
  Risk: <level>
  ```
- Tag the dotfiles commit with a version identifier if the change is non-trivial.

The staging rule prevents the workflow from breaking its own infrastructure mid-session.

### Step 3 — Update skill-versions.lock

For each applied diff:
- If the changed file is a skill or template that other projects might pin to, the dotfiles repo's new version (commit hash or tag) is the new canonical.
- Update this project's `skill-versions.lock` to pin to the new version.
- Commit `skill-versions.lock` change to the project's `develop` branch (in the project repo, not dotfiles).

### Step 4 — Log rejections and deferrals

For each `reject`: append to a per-skill or per-standards-doc `rejection-log.md` (kept in the dotfiles repo, not the project) with:
```
- proposal_id: <id>
  rejected_at: <timestamp>
  phase: <phase-slug>
  reason: <human's reason>
  source_observations: <list>
```

The rejection log informs future `workflow-curator` runs: a pattern that's been rejected in the same form is *not* re-proposed without new occurrences flagged as `human-confirmed`.

For each `defer`: append to `docs/transient/<phase-slug>/carry-forward/deferred-proposals.md` (not the dotfiles repo — deferrals are project-specific). Per the carry-forward mechanism (workflow.md §15.6), this content relocates to the next phase's workspace at phase transition; the next `phase-retrospective` re-considers deferred proposals alongside new observations.

### Step 5 — Apply consolidation outcomes from phase-close

Per `phase-close` step 6: transient docs were marked `transient_pruning_eligible`. Now that improvement-review is complete and standards/skill changes are applied, prune those transient docs:

- Move `docs/transient/phases/<phase-slug>/` to `docs/transient/archive/<phase-slug>/` (preserve for audit).
- The `feeds-into` content has been absorbed; the originals are no longer needed in the active tree.

This is the final pruning step. After this, the active tree contains only permanent docs and any active phase/increment.

### Step 6 — Close the phase

Update INDEX:
- Phase status flips to `closed`.
- Phase's increment list and outputs preserved in INDEX as historical record.
- `active_phase` flips to `null` (next phase, if any, requires explicit phase-start invocation).

Status line:

```
═══════════════════════════════════════════════
Phase <phase-slug> closed.
Skill diffs applied: <count>
Standards diffs applied: <count>
Transient docs archived: <list>

Next action: provide raw input for next phase (if any), then run session-resume.
═══════════════════════════════════════════════
```

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-IR-1 | Approved diff fails to apply cleanly (target file changed since proposal) | re-synthesize, re-run improvement-review |
| T-IR-2 | Applied diff produces malformed SKILL.md or standards doc | revert, halt to human |
| T-IR-3 | Dotfiles repo not writable | human (resolve git access) |
| T-IR-4 | All proposals rejected (no improvements adopted) | continue (warn that the phase's signal was discarded) |
| T-IR-5 | Human attempts to apply a diff that's structurally invalid (e.g., breaks halt-trigger numbering) | reject with explanation |

## Observations

Surface as `routine`:
- Skills frequently being modified across many phases (signal: skill is unstable, may need a rewrite rather than patches).
- Proposals frequently rejected for the same reason (signal: synthesis heuristic in workflow-curator could be tuned).
- High deferral rate (signal: human is not engaging with improvements, or proposals lack actionability).

Surface as `critical`:
- Approved diff applied but a subsequent skill invocation fails to parse the modified file — apply must be reverted immediately.
