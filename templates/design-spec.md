# Design-spec template

```markdown
---
slug: <feature-slug>          # same slug as the feature this design-spec describes
name: <human-readable name>
summary: <one-line, ≤120 chars; what UI/UX this design spec covers>
status: proposed | accepted | superseded | deprecated | withdrawn
introduced_in: <phase-slug>/inc-<NNN>-<slug>
accepted_at_gate: null | gate-2@<phase-slug>/inc-<NNN>-<slug>
feature: feature-<slug>
prototype_paths:
  - docs/permanent/design/prototype/<path>
superseded_by: null
supersedes: null
---

# Design spec: <feature name>

Grounded in:
  - docs/permanent/features/<feature-slug>.md
  - docs/permanent/design/prototype/<paths>
  - <related DRs (UX pattern choices, etc.)>

## Description

<One paragraph: what UI/UX this spec covers, anchored to the feature.>

## Requirements

(Each requirement gets a stable ID `DS-<feature-slug>-NN`. BDD scenarios in the feature file reference these IDs via `# DS:` comments or by being tagged with the requirement. UI tests written by `increment-test` produce at least one test per requirement.)

### DS-<feature-slug>-01 — <one-line>

- **What:** <description of the visual element, layout rule, component behaviour, accessibility requirement>
- **Where:** <which prototype path or page this applies to>
- **Acceptance:** <how a test would verify this — observable property the UI should have>

### DS-<feature-slug>-02 — <one-line>

...

## Component composition

<If the feature uses a component hierarchy: describe it. Naming follows naming-conventions.md. References to existing components must point to accepted artifacts.>

## States

<If the UI has multiple states (loading, empty, error, populated, disabled): describe each, with conditions for entry/exit.>

## Accessibility

<Specific accessibility requirements beyond what's already in the parent capability's NFR.>

## Responsive / cross-device considerations

<Breakpoints, mobile-vs-desktop differences, etc.>

## Out of scope

<Explicit exclusions — e.g., "animations are out of scope for this feature; will be added in a follow-up.">
```
