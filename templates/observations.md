# observations.md template

Unified per-phase observations log. Replaces the prior two-log model (`workflow-observations.md` + `standards-observations.md`). Skills append entries with a `category:` field; `workflow-curator` routes by category at `phase-retrospective`.

```markdown
# Observations: <phase-slug>

feeds-into:
  - (workflow-defect observations → proposed skill diffs at phase-retrospective)
  - (standards-* observations → proposed standards-doc diffs at phase-retrospective)
  - This transient log itself is archived at improvement-review

## Entries

- timestamp: <ISO>
  skill: <skill-name>
  category: workflow-defect | standards-coding | standards-testing | standards-naming | other
  severity: routine | critical
  pattern: <one-line description of friction or defect>
  context: <where this occurred: phase / increment / item slug>
  proposed_action: <free text — optional>
  human_confirmed: false | true
  references:
    - <path to artifact related to this observation>

- timestamp: <ISO>
  skill: backlog-review
  category: standards-coding
  severity: routine
  pattern: "naming inconsistency: PascalCase vs camelCase in component files"
  context: "occurred in inc-005, backlog item 'add-invoice-form'"
  proposed_action: "specify component naming in naming-conventions.md"
  human_confirmed: false
  references:
    - <code path>

- timestamp: <ISO>
  skill: backlog-test
  category: workflow-defect
  severity: critical
  pattern: "halt destination undefined for spec-untestable case in capability without ACs"
  context: "phase-3, attempting to write tests for feature-onboarding"
  proposed_action: "add halt-trigger for missing-AC scenario in backlog-test step 2"
  human_confirmed: true
  references:
    - .claude/agents/backlog-test.md
```

## Categories

- `workflow-defect` — gate skipped, halt mechanism missing, observation pattern routing fails, skill coverage gap. Routes to skill or workflow.md diff at synthesis.
- `standards-coding` — code style, error handling, secrets, logging pattern. Routes to `coding-standards.md` diff.
- `standards-testing` — hermeticity gap, framework concern, smoke-tag criteria refinement, coverage rule edge case. Routes to `testing-standards.md` diff.
- `standards-naming` — file/identifier/branch convention. Routes to `naming-conventions.md` diff.
- `other` — catch-all; surfaces as an open question at retrospective.

## Severity criteria

- `critical`: workflow-breaking; halts inline for `improvement-review` regardless of category.
- `routine`: batched until `phase-retrospective`.

## Synthesis at phase-retrospective

`workflow-curator` (per T5 thresholds):
- Promote a pattern to a proposed diff when ≥2 occurrences in this phase, OR ≥3 across last 3 phases, OR ≥1 critical, OR ≥1 human-confirmed.
- Single-occurrence routine observations are logged for posterity but do not produce proposals.
- Check `rejection-log.md` first — don't re-propose patterns the human has explicitly rejected, unless new evidence accompanies them.

## Rejection log reference

If a synthesized proposal was rejected in a prior phase, that pattern's re-proposal requires fresh evidence. See the dotfiles repo's `rejection-log.md`.
