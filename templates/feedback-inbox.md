# feedback-inbox.md template

The active increment's feedback channel. The human appends entries any time during the increment; the orchestrator triages between backlog items via the `feedback-triage` skill.

```markdown
# Feedback inbox: <inc-slug>

feeds-into:
  - (none — feedback content is reflected via the disposition; the disposition links to whatever artifact resulted, then this transient doc is pruned at increment-close)

## How to use (for the human)

Append a new entry below at any time during the increment. The orchestrator reads new entries (entries with empty `disposition:`) at every backlog-item seam. Each entry gets triaged to one of:
- BACKLOG_TWEAK — handled in-scope (current or next item)
- QUEUE_NEXT_INCREMENT — deferred to next increment, additive
- FUNCTIONAL_LOOPBACK — halts; routes to increment-functional-analysis
- DOMAIN_LOOPBACK — halts; opens corrective increment
- ARCHITECTURE_LOOPBACK — halts; opens corrective increment
- WORKFLOW_OBSERVATION — logged in workflow-observations.md
- HUMAN_CLASSIFY — halts; you classify

Provide reference(s) when possible (artifact paths the feedback relates to); reduces HUMAN_CLASSIFY rate.

## Entries

- id: 001
  added_at: <ISO timestamp>
  by: <human>
  text: |
    <freeform feedback>
  references:
    - <path or "none">
  disposition: <empty until triage>
  disposition_at: <empty>
  action: <empty>
  link: <empty>

- id: 002
  added_at: <ISO timestamp>
  by: <human>
  text: |
    <freeform feedback>
  references:
    - <path>
  disposition: BACKLOG_TWEAK
  disposition_at: <ISO timestamp>
  action: amended backlog/<NNN>-<slug>.md with new scenario "<name>"
  link: backlog/<NNN>-<slug>.md
```
