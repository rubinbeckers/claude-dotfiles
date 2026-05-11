# Phase Intake Review — Phase NN-<slug>

> Produced by `phase-intake` before any analysis output is generated. The human reviews this and approves each itemized default individually. Approved defaults are logged as CDRs/FDRs/ADRs for traceability.

## Raw input inventory

List of files processed:

- `/intake/raw/<file>` — type, apparent purpose
- ...

Unreadable files (if any — these are halts, not items): listed separately.

## Themes identified

What is this input asking for, at a high level?

- Theme 1: ...
- Theme 2: ...

## Implied capabilities

| Implied capability | Maps to existing? | Notes |
|--------------------|-------------------|-------|
| Capability A | Yes — links to CAP-NNNN | refinement only |
| Capability B | No — new candidate | needs new spec |

## Gaps surfaced

Each numbered for individual approval.

### Gap 1: [short label]

- **What's missing:** specific description.
- **Why it blocks:** what downstream is impacted.
- **Suggested default:** proposed resolution.
- **Logged as if approved:** [CDR | FDR | ADR | none].
- **[ ] Approve  [ ] Modify  [ ] Reject**

### Gap 2: [short label]

...

## Conflicts surfaced

### Conflict 1: [short label]

- **Statement in new input:** ...
- **Conflicting existing doc:** [link] — ...
- **Suggested resolution:** ...
- **Approved supersession?:** [ ] Yes  [ ] No

## Underspecified items

Items needing clarification before analysis can proceed (these are not approve/reject — they need an actual answer from the human).

- Question 1: ...
- Question 2: ...

## Required human input

Before pass 2 can run, the following must be settled:

- [ ] All gaps reviewed
- [ ] All conflicts resolved
- [ ] All questions answered
