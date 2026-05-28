---
name: increment-close
description: Closes an increment. Runs full regression, doc-integrity sweep, Gate 3 for consolidation, commits to the increment branch, opens PR to develop, and then continues running while the increment is in `awaiting-merge` to handle post-merge fix requests inline. Invoked by increment-execute on PASS.
---

# increment-close

Two phases in one skill: the pre-PR close (regression, integrity, consolidation, PR open) and the post-PR continuation (handling fix requests inline until the increment advances to `closed`).

## Inputs

- INDEX (active increment, all cycles complete)
- All transient docs for the increment
- Accepted permanent docs (read-only at the close phase)
- Always-allowed set

## Outputs

- Regression run results in `progress.md`
- `consolidation-proposed.md` and `integrity-report.md`
- Approved doc deltas applied to permanent artifacts
- Commits to the increment branch
- PR opened to `develop`
- Post-merge: fix branches created and merged as needed
- INDEX updates per state transition (closing → awaiting-merge → closed)

## Steps (pre-PR)

### 1. Verify preconditions

`increment-execute` returned PASS. No backlog/sequencing entry left incomplete. No unresolved halt in `progress.md`. All `feedback-inbox.md` entries have a recorded disposition.

### 2. Full regression

Per `workflow.md` §7, run the project's full test suite. Classify failures per §8:
- **All pass** → step 3.
- **Spec divergence** in just-delivered work → open a corrective backlog entry within this increment if the failure is local and the increment is still pre-merge (still within scope-of-close); otherwise append to `phase-debt.md`.
- **Regression** → append to `phase-debt.md` or open corrective increment if severity warrants.
- **Discovered defect** → append to `phase-debt.md`.
- **Structural** → halt (`test-infra-broken`); resolve before close can proceed.

Record results in `progress.md`.

### 3. Doc-integrity (scoped)

Invoke utility sub-skill `doc-integrity` (scope: this increment). Cites the utility carve-out per `_meta` §7.

Checks: references in the increment's outputs resolve; no `TBD-*` IDs survive in accepted artifacts; supersession bidirectional for any records this increment superseded; no accepted record references a withdrawn or deprecated one.

Output: `integrity-report.md`.

### 4. Consolidation candidates

For each transient artifact in the increment (technical-analysis.md, review.md from each cycle, defects-discovered/*), determine whether it produced content that should update permanent docs. Most increments don't produce new permanent-doc deltas — the proposed artifacts were already promoted at Gate 2. The exception is when post-implementation findings should update a standards doc, a glossary entry, or an architecture doc.

Produce `consolidation-proposed.md` listing any such deltas with their target permanent doc and the proposed change.

### 5. Gate 3 — Close approval

Emit the gate-3 approval prompt per `_meta` §13:

```
═══════════════════════════════════════════════
APPROVAL REQUIRED — Gate 3 (Increment close)
Active scope: <phase-slug>/<inc-slug>

Summary:
  Regression: <pass/fail summary>
  doc-integrity: <clean | findings count>
  Consolidation deltas: <count>
  Files for review:
    - progress.md
    - integrity-report.md
    - consolidation-proposed.md (if non-empty)

PR will open to develop on approval.

To approve: reply "approve" (or "approve with modifications: <notes>").
To request changes: reply "changes: <list>".
To reject: reply "reject: <reason>".
═══════════════════════════════════════════════
```

Parse reply:
- **approve** → step 6.
- **changes** → apply (typically targeted edits to consolidation deltas or to the increment branch); re-emit.
- **reject** → resolve the rejection (usually re-running regression or fixing integrity findings); re-emit.

### 6. Apply consolidation deltas

For each approved delta in `consolidation-proposed.md`: apply to the target permanent doc. Track in INDEX: `delta_applied: <id>`. Rejected deltas log with reason; their source transient content survives for further disposition.

### 6.5. Solidifying-increment debt truncation

If this is the solidifying increment (per the phase-plan row's `type: solidifying`): truncate `phase-debt.md` to empty after the increment's `included` entries have been delivered. The log was already drained at `increment-design` step 2 (each entry dispositioned to `included` / `deferred` / `accepted`); included entries are now delivered as part of this increment's diff, so the log file is rewritten with a `# Phase debt: <phase-slug>` header and an empty entries section.

Any new debt entries that arose during this increment's execution (uncommon, but possible from the increment's own regression findings) go to `docs/transient/phases/<phase>/carry-forward/deferred-debt.md` instead of back into the truncated log.

For non-solidifying increments, this step is a no-op.

### 7. Commit to the increment branch

Commit all changes — implementation, tests, applied deltas, transient artifacts — with a structured message:

```
feat(<inc-slug>): <one-line summary>

Delivered:
  - <feature/scenario summaries>
Files: <count> created, <count> modified
Tests: <unit count> + <integration/UI count>; coverage <X>%
Decisions: <DR IDs> | <ADR IDs>
```

### 8. Open PR

Open a PR from the increment branch to `develop`. Title and description summarise the increment.

Status line:

```
═══════════════════════════════════════════════
PR opened: <url>
Target: develop
Files changed: <count>; +<additions> / -<deletions>
Tests added: <count>

Awaiting CI + human review on staging after merge.
Reply with fix requests as needed; reply "approved" or signal acceptance to close the increment.
═══════════════════════════════════════════════
```

Update INDEX: `status: awaiting-merge`. The skill continues running (steps 9+) within the same session; if the session ends, `session-resume` picks up here next time.

## Steps (post-PR — handling fixes inline)

### 9. Listen for human input

While `status: awaiting-merge`, the skill watches the chat for the human's next message. Parse intent:

- **Approval** (any message indicating the work is accepted: "good", "approved", "ship it", "all set", "lgtm", etc.) → step 12.
- **Fix request** (the human describes a change to make) → step 10.
- **CI failure report** (the human pastes a CI log or describes a failing build) → step 10 with the CI log added to the next fix's manifest.
- **Scope-expansion question** (the human raises a substantive issue beyond a fix) → surface the corrective-increment vs next-increment options per `workflow.md` §9; route per decision.
- **Session ends without input** → next `session-resume` assumes approval (per `session-resume` §5).

The skill does not act on ambiguous input — if the message doesn't clearly fit one of these, ask the human to clarify in one short question.

### 10. Handle a fix request

Per `workflow.md` §10:

1. Determine the short slug for the fix (from the human's description, or generate one and confirm).
2. `git checkout -b fix/<inc-slug>/<short-slug>` from `develop`.
3. Construct the manifest for `increment-develop` with `mode: fix`:
   - The human's fix description
   - The affected code paths (best-effort identification from the description; ask the human to confirm if unclear)
   - Existing tests touching those paths
   - The increment-scope (for context only)
   - CI logs if relevant
4. Invoke via Task tool.
5. Parse return:
   - **success** → step 11.
   - **scope-expansion** → surface options to the human (absorb into next increment, open corrective increment, override and log as a DR); route per decision.
   - **halt** → route per entry.

### 11. Push and open fix PR

Push the fix branch. Open a PR to `develop`. Surface:

```
Fix PR opened: <url>
Branch: fix/<inc-slug>/<short-slug>
Changes: <one-line>

Awaiting CI + human validation.
```

Return to step 9 (listening). If CI fails, the human reports back; the orchestrator re-invokes `increment-develop` in `mode: fix` with the CI log in the manifest, on the same fix branch (commits stack).

### 12. Close the increment

When the human approves (explicitly, or implicitly via session-end + resume without input):
- INDEX: `status: closed`, `closed_at: <ISO>`.
- If there's a phase-debt entry for this increment that was deferred during execution and the close approval includes it, ensure it's recorded.

Advance: if this is the last increment in the phase plan, invoke `phase-close`. Otherwise, invoke `increment-design` for the next increment.

## Edges

- Regression structural error → halt; resolve test infrastructure (may need technical-design loopback).
- Critical regression at full-suite run → halt; human decides to abandon, open immediate corrective, or accept-and-rollback.
- doc-integrity critical finding → corrective increment or in-place fix.
- Fix branch CI fails repeatedly with no clear root cause → after 3 attempts, halt to human for diagnostic.
- Human input that's neither approval nor fix nor recognizable → ask one clarifying question.

## Observations to surface

Increments with no consolidation deltas (signal: nothing learned that should update permanent docs — may be fine, but check); high volume of post-merge fixes per increment (signal: increment-execute review is missing patterns); CI failures of the same type recurring (signal: local test rules diverge from CI rules); ambiguous human input recurring at step 9 (signal: status line at step 8 may need clearer prompting).
