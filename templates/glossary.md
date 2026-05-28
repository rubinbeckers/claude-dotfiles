# Glossary (placeholder)

Scaffolded by `project-init`. Populated by `domain-design` in the first phase. Always-allowed read per `_meta` §1.

The single source of truth for the project's domain vocabulary. Every term used in a spec-bearing artifact appears here with a definition and the source that introduced it.

## Terms

### <Term>

**Definition:** <one or two sentences>

**Source:** <which artifact introduced this term — a capability, a DR, raw input, etc.>

**Use context:** <where this term applies — e.g., "in the billing context"; "across the project">

**Aliases:** <alternative spellings or short forms that map to this term, if any>

**Related:** <other glossary terms with related meaning>

---

### <Term>

...

---

## Glossary discipline

- Adding a term: only via `domain-design` authoring with a named source. Other skills and agents that need a term halt and route to `domain-design`.
- Refining a term (meaning shifts): supersession via a DR. The old definition stays in place with `status: superseded` and `superseded_by:` pointing to the new entry; the new entry has `supersedes:` pointing back.
- Deprecating a term (no longer used): mark `status: deprecated` with reason. Existing references should be migrated; `doc-integrity` flags lingering references.
