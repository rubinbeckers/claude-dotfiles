---
name: workflow-curator
description: Utility sub-skill. Synthesizes observation patterns into proposed skill diffs; applies approved diffs to the skills repo. Two modes - synthesis (invoked by phase-retrospective) and apply (invoked by improvement-review). May only be invoked by these skills per _meta §6 utility-sub-skill carve-out.
---

# workflow-curator

Utility sub-skill with two modes:

- **synthesis mode** — invoked by `phase-retrospective`: reads observation patterns, constructs concrete skill-diff proposals.
- **apply mode** — invoked by `improvement-review`: applies approved diffs to the skills repo (potentially the dotfiles symlinked repo).

Cited explicitly under the utility-sub-skill carve-out in `_meta` §6.

Does not modify skill files in synthesis mode; only in apply mode after human approval.

## Inputs (synthesis mode)

- `workflow-observations.md` (current phase)
- `standards-observations.md` (current phase)
- All halt entries this phase
- All skill SKILL.md files (read-only, for diff construction)
- `.claude/skills/_meta/SKILL.md` (read-only)
- Past `rejection-log.md` entries (to avoid re-proposing patterns already rejected)
- Always-allowed set (`_meta` §1)

## Inputs (apply mode)

- Approved diff files (annotated with `decision: approve`)
- The target skill or standards files (read-write)
- Skills repo location (`.claude/skills/`, `.claude/agents/` — possibly symlinked to dotfiles)
- `skill-versions.lock` (read-write)

## Outputs (synthesis mode)

- Diff files at `docs/transient/phases/<phase-slug>/skill-diff-proposals/<id>.diff`
- Diff files at `docs/transient/phases/<phase-slug>/standards-diff-proposals/<id>.diff`
- A summary at the same location

## Outputs (apply mode)

- Modified skill / agent / standards files
- Updated `skill-versions.lock`
- Commits to the dotfiles repo (if symlinked) or project repo (if local)
- Updated `rejection-log.md` (for rejected diffs)

## Synthesis mode steps

### S1 — Read all observations and halts

Collate. Each observation has a `pattern:` field. Each halt has a `reason:` field and a `route_to:` field.

### S2 — Group by pattern

Identify clusters. The rules (per `agentic-sdlc-principles.md` §7.7, with T5 thresholds tuned for solo-mode realism):
- Synthesize a proposal when pattern has ≥2 occurrences in this phase, OR ≥3 occurrences across the last 3 phases (cross-phase counting per T5), OR ≥1 occurrence flagged `critical`, OR ≥1 occurrence flagged `human-confirmed`.
- Check `rejection-log.md`: if this pattern was rejected in a prior phase with the same proposed fix, do not re-propose unless new evidence accompanies it (e.g., severity escalated, new occurrence type, additional occurrences since last rejection).

### S3 — Identify target file(s) per cluster

For each cluster, decide:
- Which file should change (`workflow.md`, `_meta/SKILL.md`, a specific skill's SKILL.md, an agent definition, a standards doc).
- What kind of change (add a halt trigger, refine a manifest, add a step, add an observation type, add a standard).

If the cluster's pattern doesn't map cleanly to a single target, the proposal is flagged as `open-question` (no concrete diff; surfaces for human discussion).

### S4 — Construct the diff

For each cluster with a clear target:
- Construct a unified diff against the target file.
- The diff must be minimal: the smallest change that addresses the pattern.
- The diff includes a rationale comment in the diff header.
- The diff includes the source-observation IDs.

Example diff structure:
```
--- a/.claude/skills/increment-functional-analysis/SKILL.md
+++ b/.claude/skills/increment-functional-analysis/SKILL.md
@@ -45,6 +45,12 @@ Halt with T-FA-3 if a referenced design-spec doesn't exist.
 
+## Halt trigger: glossary-term not in scope
+
+T-FA-7: A capability's spec introduces a domain term not present in glossary.md.
+Per _meta §2 (non-assumption), do not author the term silently.
+Route to: phase-business-analysis loopback (Gate 1 re-pass).
+
 ## Inputs
```

Synthesized from observations: obs-2026-05-20-001, obs-2026-05-22-014, obs-2026-05-23-007 (3 occurrences, pattern: "FA halted attempting to use undefined term")

### S5 — Risk classification per proposal

Each proposal carries a risk level:
- **low**: adding a halt trigger or observation type that doesn't affect existing behavior
- **medium**: modifying an existing step or manifest in ways that could affect halts or outputs
- **high**: changing meta-rules (`_meta`, `workflow.md`), restructuring multi-skill interactions

### S6 — Write proposals

Each proposal is a separate file. Plus a summary index listing all proposals with their risk and source observations.

## Apply mode steps

### A1 — Read approved diffs

Filter to those annotated `decision: approve` (or `decision: modify` — human has already edited the diff to its final form).

### A2 — Apply each diff

For each diff:
- Re-read the target file (it may have changed since synthesis).
- Apply the diff using `patch` (or equivalent reliable mechanism).
- If the diff doesn't apply cleanly, halt with `T-WC-A1` (re-synthesis required).
- Validate the resulting file is well-formed: SKILL.md frontmatter parses, no syntax errors, markdown sections balanced.

### A3 — Commit

For each applied diff:
- If the target is in the dotfiles repo: commit there with structured message.
- If the target is project-local: commit on the project's `develop` branch.

```
feat(<scope>): <one-line> [phase <phase-slug>, proposal <id>]
```

### A4 — Update skill-versions.lock

After all diffs apply, if the skills repo is the dotfiles repo:
- Determine the new commit hash or tag for each modified skill/template.
- Update `skill-versions.lock` to pin to the new versions.
- Commit `skill-versions.lock` to the project's `develop` branch.

### A5 — Log rejections

For each `decision: reject`, write to `rejection-log.md` in the skills repo (or in a project-local rejection store if dotfiles repo isn't writable for some reason). Append entry per `improvement-review` §4.

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-WC-S1 (synthesis) | A cluster of patterns has no clear target file | caller (surface as open-question in retrospective) |
| T-WC-S2 (synthesis) | Diff would conflict with another pending diff | merge or surface for human disposition |
| T-WC-A1 (apply) | Diff doesn't apply cleanly | caller (re-synthesize) |
| T-WC-A2 (apply) | Resulting file is malformed | caller (revert, re-synthesize) |
| T-WC-A3 (apply) | Skills repo not writable | human |
| T-WC-A4 (apply) | Diff modifies a file pinned to a version other than the current dotfiles head | resolve pin first |

## Observations

Surface as `routine`:
- Patterns rejected ≥3 phases in a row with substantially the same proposal (signal: the proposal generator should learn to deprioritize this pattern).
- Diffs frequently failing to apply cleanly (signal: synthesis isn't reading current file state).
- Heavy skewing of changes toward one skill (signal: that skill may need a structural rewrite rather than incremental patches).

Surface as `critical`:
- Apply-mode failure produces a non-parseable skill file that breaks subsequent session-resume (workflow integrity violation).
