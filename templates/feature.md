# Feature template

```markdown
---
slug: feature-<slug>
name: <human-readable name>
summary: <one-line, ≤120 chars; what user-visible behavior this feature delivers>
status: proposed | accepted | superseded | deprecated | withdrawn
introduced_in: <phase-slug>/inc-<NNN>-<slug>
accepted_at_gate: null | gate-2@<phase-slug>/inc-<NNN>-<slug>
capabilities_covered:
  - cap-NNN-<slug>
superseded_by: null
supersedes: null
---

# Feature: <name>

Grounded in:
  - docs/permanent/domain/capabilities/<cap>.md
  - docs/permanent/design/prototype/<paths>

## Description

<One paragraph: what user-visible behavior this feature delivers.>

## Scenarios

<!-- BDD scenarios in Gherkin style. Tag at scenario level. -->
<!-- @<capability-id> @<criticality:high|medium|low> @<security-critical?> @<error-path?> @<smoke?> -->

### Scenario: <name>

# AC: AC-cap-NNN-01, AC-cap-NNN-02
@cap-NNN @high

Given <preconditions>
And <preconditions>
When <user action>
Then <expected outcome>
And <expected outcome>

### Scenario: <name (error path)>

# AC: AC-cap-NNN-03
@cap-NNN @high @error-path

Given ...
When ...
Then ...

### Scenario: <name>

# AC: AC-cap-NNN-04
@cap-NNN @medium @security-critical @smoke

Given ...
When ...
Then ...
```

## Tag conventions

- Every scenario tags `@<capability-id>` and a criticality `@high|medium|low`.
- Every scenario references at least one `# AC: <id>` (the ACs from the source capability it covers).
- `@security-critical` is applied when the scenario touches a path whose capability has `data_classification ≥ confidential`, or covers a security-relevant behavior (auth, authz, input validation, sensitive data handling).
- `@error-path` is applied to scenarios verifying error handling at boundaries.
- `@smoke` is applied per `testing-standards.md` smoke criteria (typically: security-critical paths, capabilities at `data_classification ≥ confidential`, and critical user flows enumerated in `testing-standards.md`).
- Scenarios are *behavioral*: they describe outcomes, not implementation. Implementation details belong in the design spec.
