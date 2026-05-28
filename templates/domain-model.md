# Domain model (placeholder)

Scaffolded by `project-init`. Populated by `domain-design` in the first phase that establishes cross-context invariants. Always-allowed read per `_meta` §1.

This file holds **cross-context invariants** — domain rules that span multiple aggregates and don't naturally belong on any single aggregate's spec. Per `doc-structure.md` §1, individual aggregate specs live in `docs/permanent/domain/aggregates/`; this file is for the rules that connect them.

Because this file is in the always-allowed read set, every spec-bearing artifact's authoring agent has access without manifest expansion — invariants are universally enforceable.

## Bounded contexts

<If the project uses bounded contexts: list them with one-line descriptions of each context's responsibility.>

## Cross-context invariants

Each invariant is identified, statused, and supersession-tracked like other spec-bearing artifacts. Authoring agents declare `Grounded in:` chains on the invariant's source.

### inv-001 — <name>

```yaml
id: inv-001-<slug>
status: proposed | accepted | superseded | deprecated | withdrawn
summary: <one-line, ≤120 chars; the rule in a sentence>
introduced_in: <phase-slug>
accepted_at_gate: gate-1@<phase-slug>
superseded_by: null | inv-NNN-<slug>
supersedes: null | inv-NNN-<slug>
```

**Statement:** <the invariant, stated as an always-true condition>

**Contexts involved:** <list>

**Why:** <rationale>

**Source:** <raw input, DR, capability that introduced this>

**Enforcement:** <which aggregate or operation enforces it; whether the invariant is checked at commit time, at request boundary, etc.>

---

### inv-002 — <name>

...

---

## Context map

<If using context maps: describe the relationships between bounded contexts — shared kernel, customer/supplier, conformist, anticorruption layer, etc.>

## Discipline

- Adding an invariant: via `domain-design` (at phase scope) with grounding to a named source. Numbered at Gate 1 — own numbering namespace `inv-NNN`.
- Modifying an invariant: supersession. The predecessor flips to `superseded`; the successor records `supersedes:`. `doc-integrity` validates bidirectionality and that no accepted capability or aggregate references a `deprecated` or `withdrawn` invariant.
- The invariants in this file are always-readable; authoring agents do NOT need to list it in their manifest. They are expected to consult it before producing capability/aggregate/feature specs.
