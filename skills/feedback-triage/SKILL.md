---
name: feedback-triage
description: Utility skill. Reads feedback-inbox.md entries with no disposition and assigns each a routing decision (backlog-tweak, queue-next-increment, solidifying-debt, loopback to one of the design agents, workflow observation, or human-classify). Invoked by increment-execute at cycle boundaries, by phase-close, and on demand.
---

# feedback-triage

Triages incoming feedback into the workflow's existing channels.

## Inputs

- `docs/transient/phases/<phase>/increments/<inc>/feedback-inbox.md` (or phase-level inbox if invoked at phase scope)
- The current increment-scope (if scoped to an increment)
- The current phase plan
- Always-allowed set

## Outputs

- Updated `feedback-inbox.md` with `disposition:` assigned per entry
- Side effects per disposition (entries appended elsewhere — phase-debt, sequencing list, carry-forward — by the invoking skill, not by triage itself)

## Steps

### 1. Read entries

Load `feedback-inbox.md`. Process only entries with `disposition:` empty or unset.

Each entry should carry:
- `timestamp`
- `source` (human or skill)
- `content` (free text, what the feedback says)
- Optional: `tags`, `references`

### 2. Classify each entry

For each entry, decide:

- **BACKLOG_TWEAK** — the feedback is a small adjustment to a sequencing entry in the active increment (e.g., "the button colour should be primary-500"). Within the increment's scope; doesn't touch accepted artifacts beyond editorial.
- **QUEUE_NEXT_INCREMENT** — the feedback is in scope for the project but not for the current increment. Queue in `docs/transient/carry-forward/`.
- **SOLIDIFYING_DEBT** — the feedback is a code-level cleanup, flaky-test report, or refactor that belongs in the phase's solidifying increment. Append to `phase-debt.md`.
- **DOMAIN_LOOPBACK** — the feedback reveals a gap in domain modeling (a capability missing, an aggregate boundary wrong, a glossary term needed). Routes to `phase-design` if phase-level, `increment-design` if increment-level.
- **FUNCTIONAL_LOOPBACK** — the feedback reveals a gap in feature design (a scenario missing, a UX pattern wrong). Routes to `increment-design`.
- **ARCHITECTURE_LOOPBACK** — the feedback reveals an ADR that's wrong, a missing technical decision, or a standards gap that blocks implementation. Routes to `phase-design` or `increment-design`.
- **WORKFLOW_OBSERVATION** — the feedback is about the workflow itself (a skill being awkward, a template field missing, a step that's confusing). Surface as an observation per `_meta` §6 with appropriate severity.
- **HUMAN_CLASSIFY** — the entry is genuinely ambiguous, references something not in scope, or could plausibly fit two categories. The human picks.

The decision is based on the feedback content, not on hopes. If you don't have enough context to decide, choose HUMAN_CLASSIFY.

### 3. Write dispositions

For each entry, append a disposition block:

```
- disposition: BACKLOG_TWEAK
  decided_at: <ISO>
  reasoning: <one-line>
  proposed_action: <what the invoking skill should do>
```

### 4. Surface critical entries

Any entry with disposition `*_LOOPBACK` or `WORKFLOW_OBSERVATION (severity: critical)` is surfaced immediately to the invoking skill, which halts and re-routes.

### 5. Return

Structured return per `_meta` §4. `key_findings` is a count by disposition.

## Edges

- Entry has no content or is malformed → flag for human; don't try to interpret.
- Entry references an artifact that doesn't exist (e.g., names a feature that was withdrawn) → HUMAN_CLASSIFY with the reference issue noted.
- High volume of WORKFLOW_OBSERVATION at the same seam (signal: severity threshold or template format needs revisiting; flag in own observation).

## Observations to surface

Patterns of HUMAN_CLASSIFY for a specific kind of feedback (signal: classification heuristic needs a rule); BACKLOG_TWEAK clusters touching the same sequencing entry (signal: that entry was under-specified).
