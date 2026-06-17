# Project INDEX template

Lives at `docs/INDEX.md` in each project. The canonical state record. Updated by the orchestrator at every state transition. The human does not edit this directly.

```yaml
---
project_slug: <slug>
operating_branch: develop
skill_versions_lock: docs/skill-versions.lock
created_at: <ISO>
---

# Project: <name>

## Active state

active_phase: <slug or null>
active_increment: <slug or null>
paused_at: null

## Phases

- slug: 01-<descriptor>
  status: closed | in-progress | retrospective | closed
  created_at: <ISO>
  closed_at: <ISO or null>
  gate_status:
    - gate_id: gate-1@01-<descriptor>
      decision: approve | reject | changes
      decided_at: <ISO>
      decided_by: <human>
      modifications: <text or "none">
    - gate_id: gate-4@01-<descriptor>
      decision: approve
      decided_at: <ISO>
      decided_by: <human>
  increments:
    - slug: inc-001-<descriptor>
      status: closed | in-progress | abandoned | skipped
      created_at: <ISO>
      closed_at: <ISO or null>
      gate_status:
        - gate_id: gate-2@01-<descriptor>/inc-001-<descriptor>
          decision: approve
          decided_at: <ISO>
        - gate_id: gate-3@01-<descriptor>/inc-001-<descriptor>
          decision: approve
          decided_at: <ISO>
      current_cycle: <K or null>
      cycle_extensions_granted: 0
      capabilities_delivered: [<cap-id>, ...]
      adrs_exercised: [<adr-id>, ...]
      fix_branches_merged: [<branch>, ...]
    - slug: inc-002-<descriptor>
      ...
  notes: <free text>

## Pending

transient_pruning_eligible: []
pending_skill_diffs: []      # diffs staged at last phase-close for next-session apply
delta_rejected: []

## Pin

dotfiles_tag: workflow-v1.3
```
