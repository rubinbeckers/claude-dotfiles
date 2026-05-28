# Observations template

A single per-phase log. Skills and agents append entries during work. `workflow-curator` synthesizes them at `phase-close` into proposed diffs.

```markdown
# Observations: <phase-slug>

(Append entries. `critical` severity halts inline for the next gate; `routine` accumulates.)

## Entries

### obs-001

- timestamp: <ISO>
- source: <skill or agent>
- category: workflow-defect | standards-coding | standards-testing | standards-naming | other
- severity: routine | critical
- pattern: <one-line description of the pattern>
- context: <where it occurred — increment, scenario, file>
- proposed_action: <what to do about it; may be empty if surfacing only>
- human_confirmed: false | true   # set true when the human has read and validated the pattern
- references:
  - <artifact paths if any>

### obs-002

...
```

Severity rules:
- `critical` — workflow-breaking or quality-critical. Halts inline for review at the next gate regardless of category.
- `routine` — batched; synthesized at `phase-close` by `workflow-curator`.

Category guides synthesis routing at `phase-close`:
- `workflow-defect` → proposed skill / agent / `_meta` diff.
- `standards-coding` / `standards-testing` / `standards-naming` → proposed standards-doc diff.
- `other` → surfaced as an open question for the human at Gate 4.
