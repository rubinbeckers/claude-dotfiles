---
name: doc-consolidator
description: Utility sub-skill. Walks transient docs' feeds-into headers and produces proposed deltas to permanent docs. Does not apply edits; the calling skill applies after human approval. May only be invoked by close skills (increment-close, phase-close) per _meta §6 utility-sub-skill carve-out.
---

# doc-consolidator

Utility sub-skill. Reads transient docs, finds their `feeds-into:` declarations, synthesizes proposed deltas to the named permanent docs. Outputs proposals; never modifies permanent docs. The calling skill (`increment-close` or `phase-close`) applies after human approval.

Cited explicitly under the utility-sub-skill carve-out in `_meta` §6.

## Inputs

Determined by `scope` argument:
- `scope: increment <inc-slug>` — only transient docs within the increment's workspace
- `scope: phase <phase-slug>` — all transient docs in the phase's workspace, including all closed increments

Plus always-allowed set (`_meta` §1).

## Outputs

- `consolidation-proposed.md` at the appropriate transient location
- Structured return per `_meta` §13

## Steps

### Step 1 — Enumerate transient docs in scope

List every `.md` file under the scoped transient path. For each:
- Read the `feeds-into:` header (or note its absence).
- Read the doc's body content.

A transient doc with no `feeds-into:` is scaffolding (per `doc-integrity` Check 8) and is pruned wholesale at close without absorption — `doc-consolidator` does not process it.

### Step 2 — Group by target permanent doc

For every `feeds-into: <path>` declaration, group transient docs by their target. Each target permanent doc may have content contributions from multiple transient docs.

### Step 3 — Synthesize proposed delta per target

For each target permanent doc:
- Read the current content.
- For each contributing transient doc, identify the lasting content (the part the doc author intended to absorb — typically the doc's body minus headers, status fields, and ephemeral metadata).
- Construct a proposed addition or modification to the target doc.

Synthesis rules:
- **Append-only by default.** Proposed deltas add new content rather than modifying existing content. Modifications are flagged for explicit human review.
- **Preserve grounding.** Every proposed addition declares `Grounded in:` linking back to the transient source.
- **Format conformance.** Proposed content matches the target doc's structural conventions (headings, sections, formatting).
- **No paraphrasing without need.** If the transient doc's text is already clear and structurally compatible, lift it directly with attribution. Only paraphrase when the target's format demands restructuring.

### Step 4 — Detect conflicts

For each proposed delta:
- If multiple contributing transients propose overlapping content to the same section, flag as `MULTI_SOURCE_CONFLICT` — human disposes.
- If a proposed addition contradicts existing content in the target doc, flag as `CONTRADICTS_EXISTING` — human disposes.
- If a proposed addition references a permanent doc that doesn't exist, flag as `BROKEN_TARGET_REFERENCE` — human resolves before applying.

### Step 5 — Write consolidation-proposed.md

```
# Consolidation proposal
Scope: <full | increment <slug>>
Generated: <timestamp>

## Summary
- Transient docs scanned: <count>
- Eligible (feeds-into declared): <count>
- Skipped (no feeds-into): <count>
- Proposed deltas: <count>
- Conflicts: <count>

## Proposed deltas

### Delta 1
Target: docs/permanent/domain/capabilities/cap-007-invoicing.md
Source transients:
  - docs/transient/.../increments/<inc-slug>/observations/billing-edge-cases.md

Action: APPEND new section "Acceptance criteria refinements"

Proposed content:
  ```
  ## Acceptance criteria refinements (from inc-005)
  
  Grounded in: docs/transient/.../observations/billing-edge-cases.md
  
  - AC-007.3 was found ambiguous regarding fractional cents. Refined as: ...
  ```

Decision: [pending: approve | modify | reject]

### Delta 2
Target: docs/permanent/architecture/coding-standards.md
Source transients:
  - docs/transient/.../standards-observations.md (entries 4, 7, 11)

Action: APPEND new section "Async/await usage in API handlers"

Proposed content:
  ```
  ## Async/await in API handlers (from phase-2 observations)
  ...
  ```

Decision: [pending]

## Conflicts

### Conflict 1
Type: MULTI_SOURCE_CONFLICT
Target: docs/permanent/architecture/coding-standards.md (section "Error handling")
Contributing transients:
  - <transient1>: proposes <one approach>
  - <transient2>: proposes <different approach>
Resolution required: human selects between approaches or merges
```

### Step 6 — Surface to caller

Return per `_meta` §13:
```yaml
status: success
files_written:
  - <path>/consolidation-proposed.md
key_findings: |
  Synthesized <N> proposed deltas across <M> target permanent docs.
  Flagged <K> conflicts requiring human disposition.
grounded_in:
  - <transient docs scanned>
observations:
  - <list>
```

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-DC-1 | Invalid scope argument | caller |
| T-DC-2 | Target permanent doc declared in feeds-into doesn't exist | caller (resolve target first) |
| T-DC-3 | Conflicts so severe synthesis can't proceed (>50% of deltas conflict) | caller (rework transient docs' feeds-into declarations) |

## Observations

Surface as `routine`:
- Frequent MULTI_SOURCE_CONFLICT (signal: transient docs should target finer-grained sections of permanent docs).
- Frequent paraphrase-required cases (signal: transient template structure should align more with target permanent template).
- Targets that consistently receive 0 deltas across phases (signal: the target is over-stable; consider if transient content is really meant to feed elsewhere).
