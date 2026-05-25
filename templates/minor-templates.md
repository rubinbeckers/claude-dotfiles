# Minor templates

Smaller templates used by orchestration skills. Combined here for compactness.

---

## phase-scope.md

Used by `phase-start`. Captures the phase's intent before BA and TA run.

```markdown
# Phase scope: <phase-slug>

feeds-into:
  - (none — phase-scope is reflected in phase-plan and pruned at improvement-review)

Grounded in:
  - docs/transient/phases/<phase-slug>/raw-input/<files>

## Objective
<paragraph>

## Capabilities expected (high-level, refined by BA)
- <name or description>
- ...

## Architecture concerns expected (high-level, refined by TA)
- <area or concern>
- ...

## Out of scope (explicit)
- <item>

## Prototype handling outcome
- Case: A | B | C
- Files: <list>
- Recorded FDR/CDR: <id or "none">
- Risk acceptances (for case C): <list of capabilities accepted without prototype>
```

---

## phase-retrospective.md

Output of the `phase-retrospective` skill. Format is fully specified in `phase-retrospective/SKILL.md` step 5; that specification is the canonical template.

```markdown
# Phase retrospective: <phase-slug>

feeds-into:
  - (synthesis target — content absorbed via approved skill diffs at improvement-review; this transient doc is archived)

Grounded in:
  - workflow-observations.md
  - standards-observations.md
  - all halt entries this phase

## Delivery summary
<see phase-retrospective/SKILL.md>

## Workflow defects synthesized
<list>

## Standards adequacy
<list>

## Singletons logged
<list>

## Halts surfaced (resolution summary)
<list>

## Open questions
<patterns without clear proposed actions>
```

---

## consolidation-proposed.md

Output of `doc-consolidator`. Format fully specified in `doc-consolidator/SKILL.md` step 5.

```markdown
# Consolidation proposal
Scope: increment <slug> | phase <slug>
Generated: <timestamp>

## Summary
- Transient docs scanned: <N>
- Eligible: <N>
- Proposed deltas: <N>
- Conflicts: <N>

## Proposed deltas
(see doc-consolidator/SKILL.md for per-delta format)

## Conflicts
(see doc-consolidator/SKILL.md for conflict format)
```

---

## integrity-report.md

Output of `doc-integrity`. Format fully specified in `doc-integrity/SKILL.md` (Output format section). The template is the format in that SKILL.md.

---

## pause-summary.md

Used by `project-pause`. Captures enough state for a future human to refresh their context.

**Pruning rule (T9 — canonical).** Pause-summary is created at `project-pause`. Survives session boundaries unconditionally. When the project resumes via `session-resume`, the orchestrator marks the pause-summary for pruning at the next close event (phase-close or increment-close, whichever comes first in the resumed flow). At that close, it's archived alongside other transient docs. This is the single canonical rule; the prior `doc-structure.md` §3.2 wording and `minor-templates.md` wording have been reconciled to this.

```markdown
# Pause summary

feeds-into:
  - (none — read by human on resume; pruned manually or at next phase-close)

Paused: <ISO timestamp>
Active phase: <slug> (status: <status>)
Active increment: <slug or "none"> (status: <status>)

## Where we are
<2-3 sentences>

## Outstanding halts
<list, or "none">

## Backlog state (if active increment)
- Delivered: <list>
- In progress: <slug or "none">
- Pending: <list>

## Pending feedback inbox entries
<list>

## To resume
Run session-resume. Expected next: <skill-name>.
```

---

## skill-versions.lock

Owned by `project-init`; updated by `improvement-review`.

```yaml
# skill-versions.lock
# Pinned versions of skills and templates.
# Updated at improvement-review (Gate 3) between phases.
# See workflow.md §14 and §14.1.

dotfiles_repo: <absolute path to dotfiles repo or "none">
dotfiles_commit: <git hash at last pin sync or "n/a">

skills:
  session-resume: <version-tag or commit-hash>
  project-init: <version>
  project-pause: <version>
  phase-start: <version>
  phase-planning: <version>
  phase-close: <version>
  phase-retrospective: <version>
  increment-start: <version>
  increment-planning: <version>
  increment-close: <version>
  feedback-triage: <version>
  improvement-review: <version>
  doc-integrity: <version>
  doc-consolidator: <version>
  workflow-curator: <version>
  _meta: <version>

agents:
  phase-business-analysis: <version>
  phase-technical-architecture: <version>
  increment-functional-analysis: <version>
  increment-technical-analysis: <version>
  backlog-develop: <version>
  backlog-test: <version>
  backlog-review: <version>

templates:
  capability: <version>
  aggregate: <version>
  feature: <version>
  decision-records: <version>
  phase-plan: <version>
  increment-scope: <version>
  backlog-item: <version>
  feedback-inbox: <version>
  workflow-observations: <version>
  standards-observations: <version>
  INDEX: <version>
  minor-templates: <version>
```
