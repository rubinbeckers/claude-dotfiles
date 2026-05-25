# Flow template

Flows describe user journeys that span multiple features and surfaces. They sit above features (testable BDD scenarios of individual screens) and below capabilities (business intent). A flow binds a capability to the concrete UI surfaces the user traverses, including happy paths, error paths, and decision points.

```markdown
---
id: <flow-slug>
title: <human-readable name>
status: proposed | accepted | superseded | deprecated
introduced_in: <phase-slug>/<inc-slug>
accepted_at_gate: null | gate-2@<location>
superseded_by: null
supersedes: null
tags: [<@domain-area>, <@criticality>, ...]   # see docs/permanent/process/tag-vocabulary.md
capability: <cap-NNN-<slug>>
capability_acs_covered: [<AC-id>, ...]
surfaces: [<surface-slug or component path>, ...]
prototype_refs: [<path>, ...]
last_modified_by: <skill | inc-slug>
---

# Flow: <Title>

Grounded in:
  - <docs/permanent/domain/capabilities/cap-NNN-<slug>.md>
  - <surface or design-spec paths>
  - <prototype paths>

## Happy path

<step-by-step traversal — each step on its own line, with → for transitions and ↓ for user actions>

```
<Surface A> (route)
  ↓ <Actor> performs <action>
<Surface B> (route)
  ↓ ...
  → <system outcome>
<final surface or state>
```

## <Error path 1>

```
<setup>
  ↓ ...
  → <error condition>
<error UI state>
  ↓ <recovery action>
```

## <Error path 2>
...

## Cancel / discard / abandonment paths

(if applicable)

## Route guard / permission paths

(if applicable — what happens when an unauthorized actor tries to traverse this flow)

## Decision points

| Decision | Branch |
|----------|--------|
| <decision the system makes during traversal> | <Yes outcome> / <No outcome> |

## Notes

- <free text — design rationale, references to other flows, history>
```

## Conventions

- **One capability per flow.** If a flow naturally spans multiple capabilities, split it. The primary `capability:` field is the one whose ACs the flow's happy path satisfies.
- **Surfaces are referenced, not described.** A surface link points to either a `docs/permanent/architecture/components/<surface>.md` reference doc or a design spec. The flow describes traversal between surfaces; surface internals belong in their own docs.
- **Tags drive manifest selection.** Add tags for the domain area (`@billing`, `@assessment`, `@crud`), criticality, and any cross-cutting concerns. The orchestrator uses tags to construct manifests for subagents working on related items.
- **Status transitions follow `_meta` §9.** Proposed → accepted at gate 2. Supersession produces a new flow with bidirectional links; the old one's status flips.
- **Append-only after acceptance.** Editorial changes (typos, formatting) bypass per `_meta` §7.1; semantic changes produce a successor flow.

## INDEX entry

Update `docs/permanent/flows/INDEX.md` when authoring or modifying:

```yaml
- id: <flow-slug>
  title: <title>
  status: <status>
  tags: [<tags>]
  brief: <one-line description>
  capability: <cap-NNN-<slug>>
  surfaces: [<list>]
  last_modified: <inc-slug or ISO>
```
