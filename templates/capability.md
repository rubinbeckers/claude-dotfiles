# Capability template

```markdown
---
id: cap-NNN-<slug> | TBD-<slug>
name: <human-readable name>
summary: <one-line, ≤120 chars; what this capability enables, for whom>
status: proposed | accepted | superseded | deprecated | withdrawn
data_classification: public | internal | confidential | restricted
introduced_in: <phase-slug>
accepted_at_gate: null | gate-1@<phase-slug>
superseded_by: null | cap-NNN-<slug>
supersedes: null | cap-NNN-<slug>
---

# Capability: <name>

Grounded in:
  - <raw-input section, prior capability if superseding, related DRs>

## Description

<One paragraph describing what this capability enables, for whom.>

## Acceptance criteria

- AC-<id>-01: <testable criterion>
- AC-<id>-02: <testable criterion>
- ...

Each AC is referenced by ≥1 BDD scenario via `# AC: <id>` comment in feature files.

## Aggregates involved

- <agg-NNN-<slug>>: <role in this capability>

## Cross-context invariants involved

(Optional — list cross-context invariants from `docs/permanent/domain/domain-model.md` that this capability must respect.)

- <invariant id or description>

## Flows that realize this capability

(Optional — list `docs/permanent/flows/<flow-slug>.md` entries that traverse this capability's UI.)

- <flow-slug>: <one-line>

## Out of scope

- <explicit exclusions>

## Non-functional requirements

### Security
<auth, authz, data handling, audit needs>

### Performance
<targets where applicable>

### Accessibility
<requirements where applicable>

### Other NFRs
<as relevant>

## Threat considerations

(Required if `data_classification > public` OR capability crosses a trust boundary. The agent surfaces the questions; the human supplies the answers.)

- Trust boundaries crossed: <human answer>
- Data flows in / out: <human answer>
- Worst-case abuse scenario: <human answer>
- Threat actor profile: <human answer>

## Authentication required

(Required if `data_classification ≥ internal`.)

- Required: yes | no
- Type: <session, JWT, OAuth flow, etc.>

## Authorization model

- Who can invoke: <role / permission model>
- Conditions: <if conditional>
```
