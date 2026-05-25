# INDEX.md template

The project's state document. Read on every session entry by `session-resume`. Updated by every orchestration skill that changes state.

```yaml
project: <project-slug>
description: <one-line>
initialized: <ISO timestamp>
workflow_version: <git hash or tag from dotfiles repo>

# Branch configuration (per workflow.md §17)
operating_branch: develop           # configurable; e.g., "staging" if project convention differs
production_branch: main             # configurable; the branch the workflow never touches

# Project-level path overrides (per doc-structure.md)
# These are optional. If absent, defaults apply.
design_root: docs/permanent/design/prototype/      # override if the prototype lives elsewhere

# Current state
active_phase: <slug> | null
active_increment: <slug> | null
last_action: <skill-name>
last_action_at: <ISO timestamp>

# Halt state (if any)
last_halt:
  skill: <skill-name>
  at_step: <step-id>
  reason: <one-line>
  route_to: <destination>
  raised_at: <ISO timestamp>
  resolved_at: null | <ISO timestamp>

# Gate decisions (per _meta §16)
# Written by the orchestrator parsing human approval-prompt replies; never edited by the human directly
gate_status:
  - gate_id: gate-1@02-invoicing
    decision: approve | approve-with-modifications | changes | reject
    decided_at: <ISO>
    decided_by: <human-identifier>
    modifications: <free text or "none">
    notes: <free text or "none">
  - gate_id: gate-2@02-invoicing/inc-001-invoice-crud
    decision: approve
    decided_at: <ISO>
    decided_by: <human-identifier>
    modifications: "none"
    notes: "none"

# Pending skill diffs staged for next session-resume (M6)
pending_skill_diffs:
  - diff_id: <id>
    target: <skill path>
    staged_at: <ISO>
    source_phase: <phase-slug>

# Phases delivered, in order
phases:
  - slug: 01-initial-setup
    status: closed
    started_at: <timestamp>
    closed_at: <timestamp>
    increments:
      - slug: 01-initial-setup/inc-001-domain-bootstrap
        status: closed
        delivered_at: <timestamp>
        type: value-adding | solidifying
        # capabilities, ADRs, FDRs delivered are stored in the permanent doc indexes,
        # not duplicated here. INDEX is state, not content.
  - slug: 02-invoicing
    status: in-progress | planning | closing | retrospective | improvement-review
    started_at: <timestamp>
    closed_at: null | <timestamp>
    increments:
      - slug: 02-invoicing/inc-001-invoice-crud
        status: in-progress
        type: value-adding
        current_item_position: 3
        current_item_status: develop-in-progress
        # ... etc.
      - slug: 02-invoicing/inc-007-solidifying
        status: planned
        type: solidifying
```

## State transitions

```
Phase status:
  planning → in-progress → closing → retrospective → improvement-review → closed
  (status: paused may be applied at any non-terminal state via project-pause)

Increment status:
  planning → in-progress → closing → awaiting-merge → closed
  (status: abandoned terminal; status: paused via project-pause)
```

## Conventions

- One file. Never split.
- Append-only with edits — historical state preserved in `phases:` and per-increment entries.
- All timestamps ISO-8601 UTC.
- A halt entry under `last_halt:` is cleared (set `resolved_at:`) when its routing destination produces its output. Never deleted; the historical halts are preserved by leaving them with `resolved_at:` populated.
- The INDEX is read by every skill at session-entry; treat it as the source of truth for "where are we" questions.
