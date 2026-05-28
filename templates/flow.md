# Flow template

```markdown
---
slug: flow-<slug>
name: <human-readable name>
summary: <one-line, ≤120 chars; the user journey this flow describes>
status: proposed | accepted | superseded | deprecated | withdrawn
introduced_in: <phase-slug>
accepted_at_gate: null | gate-1@<phase-slug>
capabilities_traversed:
  - cap-NNN-<slug>
superseded_by: null
supersedes: null
---

# Flow: <name>

Grounded in:
  - <capabilities the flow traverses>
  - <prototype paths>

## Description

<One paragraph: who travels this flow, what they're trying to accomplish, the high-level path.>

## Steps

1. <Step 1>: <where the user is, what they do, what happens>
2. <Step 2>: ...
3. ...

## Capabilities traversed

For each step, name the capabilities the user interacts with:

- Step 1 → cap-NNN-<slug>
- Step 2 → cap-NNN-<slug>, cap-MMM-<slug>
- ...

## Variations

- **Happy path**: as described above.
- **Error path: <name>**: <where the deviation occurs, what the flow becomes>
- **Variant: <name>**: <alternative path for a specific role or condition>

## NFRs at flow level

<Where flow-level NFRs apply — end-to-end latency targets, accessibility flow requirements, etc.>
```
