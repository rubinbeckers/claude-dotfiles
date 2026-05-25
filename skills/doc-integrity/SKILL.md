---
name: doc-integrity
description: Utility sub-skill. Validates documentation integrity: references resolve, supersession is bidirectional, statuses are consistent, TBD-* IDs are resolved, withdrawn/deprecated records are not referenced. May only be invoked by close skills (phase-close, increment-close) per _meta §6 utility-sub-skill carve-out.
---

# doc-integrity

Utility sub-skill. Performs structural checks on the documentation corpus. Invoked by `phase-close` (full sweep) and `increment-close` (scoped sweep). Cited explicitly under the utility-sub-skill carve-out in `_meta` §6.

Does not modify documents (with one narrow exception in §6 below). Produces a report; the calling skill decides what to do with findings.

## Inputs

Determined by `scope` argument from the invoking skill:
- `scope: full` — all permanent docs, all transient docs, all decision-record INDEXes
- `scope: increment <inc-slug>` — only the increment's outputs and the permanent docs they reference

Plus always-allowed set (`_meta` §1).

## Outputs

- An integrity-report markdown file at the appropriate transient location
- A structured findings list returned to the caller per `_meta` §13

## Checks (in order)

### Check 1 — Reference existence

For every `Grounded in:` declaration in scope:
- Each listed source must exist at the declared path.
- Each must be readable (not 0 bytes).

For every cross-reference (markdown links to other docs, by-ID references):
- The target document must exist.
- If the reference is by ID (`CDR-007`, `ADR-014`), the ID must be present in the target's index.

Findings: `MISSING_REFERENCE`

### Check 2 — Reference scope

For each `Grounded in:` source:
- The source must be either in the always-allowed set OR within the invoking skill's manifest as declared in its SKILL.md.
- A skill that grounded in a doc outside its declared manifest is a workflow defect.

Findings: `OUT_OF_SCOPE_REFERENCE`

### Check 3 — Reference currency

For each reference target:
- Status must not be `deprecated` or `withdrawn`.
- A `superseded` record is referenceable only when the referencing record explicitly notes `supersedes-chain: <list>` for historical context.

Findings: `STALE_REFERENCE`

### Check 4 — Supersession bidirectionality

For every record with `superseded-by: <id>`:
- The target record must exist.
- The target record must declare `supersedes: <this-id>` (bidirectional).

For every record with `supersedes: <id>`:
- The target record must exist.
- The target record must declare `superseded-by: <this-id>`.

Findings: `BROKEN_SUPERSESSION`

### Check 5 — Status state machine

For every decision record:
- Status must be one of: `proposed`, `accepted`, `superseded`, `deprecated`, `withdrawn`.
- If `proposed`: the record must have been created within an active phase or increment (not stranded from a closed phase).
- If `accepted`: must have a `accepted_at: <timestamp>` and a `approved_at_gate: <gate-id>`.
- If `superseded`: must have `superseded-by:` and `superseded_at:`.
- If `deprecated`: must have `deprecated_reason:` and `deprecated_at:`.
- If `withdrawn`: must have `withdrawn_reason:` and `withdrawn_at:`; status is terminal.

Findings: `INVALID_STATUS`, `ORPHAN_PROPOSED`

### Check 6 — TBD-ID resolution

For every TBD-* ID in scope:
- In `docs/permanent/...` (any record with `status: accepted`): must be zero (TBD-* must not appear in any accepted record at any time — they're resolved at gate-acceptance per M14, not at close).
- In `docs/transient/<phase>/proposed/...` or other transient locations: TBD-* is permitted (records are proposed; numbering happens at gate-acceptance promotion).

Findings: `UNRESOLVED_TBD` (now a critical finding regardless of when discovered — accepted records should never have TBD-*).

### Check 7 — Withdrawn/deprecated reference checks

For every `withdrawn` or `deprecated` record:
- Scan permanent docs and code for references to its ID.
- A reference from another accepted record or from code is a finding.

Findings: `REFERENCE_TO_WITHDRAWN`, `REFERENCE_TO_DEPRECATED`

### Check 8 — Feeds-into validity

For every transient doc:
- If it has a `feeds-into:` header, each target permanent doc must exist (and be appropriate for the content type).
- If it has no `feeds-into:`, it is marked as scaffolding (eligible for pruning at close without absorption).

Findings: `INVALID_FEEDS_INTO`

### Check 9 — INDEX consistency

For each subtree INDEX (per workflow.md §15.8 — capabilities, aggregates, features, flows, components, each decision-record type):
- Every file in the subtree must appear as an entry in the INDEX.
- Every INDEX entry must correspond to an existing file.
- For decision-record namespaces: number sequence must be gap-free (gaps indicate either deletion, which is forbidden, or numbering errors).
- For slugged subtrees: ordering follows the convention (status descending, then alphabetical) but is not strictly enforced — drift here is a routine finding, not critical.
- Every entry's `status:`, `tags:`, `refs:` match what's in the underlying file's frontmatter.
- Every entry's `refs:` is bidirectional — if entry A lists B in refs, B must list A.

Findings: `INDEX_DRIFT`, `BROKEN_BIDIRECTIONAL_REF`

### Check 10 — Tag vocabulary

For every tag used on any record (in `tags:` fields anywhere — capability specs, feature specs, flow files, ADRs, BDD scenarios, INDEX entries):
- The tag must be defined in `docs/permanent/process/tag-vocabulary.md`.
- Undefined tag usage halts during workflow runs; at integrity-sweep time, undefined tags are surfaced as critical findings.

Findings: `UNDEFINED_TAG`

### Check 10 — Rename-detection auto-fix (narrow)

The one modification authorized in doc-integrity: exact-rename references can be auto-fixed.

Detection: if a file was renamed within the increment (detected via `git diff --name-status`) AND references to the old path resolve to a unique new path:
- Update the references.
- Log the auto-fix in the integrity report under `AUTO_FIXED`.

Heuristic similarity matches are **not** auto-fixed. If a reference is broken and there's no exact-rename evidence, surface as `MISSING_REFERENCE`.

## Severity classification

```
CRITICAL (must resolve before close):
  - BROKEN_SUPERSESSION
  - INVALID_STATUS
  - UNRESOLVED_TBD in permanent docs
  - REFERENCE_TO_WITHDRAWN or REFERENCE_TO_DEPRECATED from accepted records or code
  - INDEX_DRIFT

ROUTINE (surface but do not block close):
  - MISSING_REFERENCE in transient docs (may be expected during draft)
  - STALE_REFERENCE where supersedes-chain note is missing but not strictly required
  - INVALID_FEEDS_INTO (signals consolidation will fail; should fix but not blocker)
  - OUT_OF_SCOPE_REFERENCE in transient (signals manifest discipline gap; routine for now)
```

## Output format

```
# Doc-integrity report
Scope: <full | increment <slug>>
Run at: <timestamp>

## Summary
- Critical findings: <count>
- Routine findings: <count>
- Auto-fixed: <count>

## Findings
### CRITICAL
- type: BROKEN_SUPERSESSION
  record: ADR-014
  detail: declares superseded-by: ADR-022, but ADR-022 does not declare supersedes: ADR-014
  location: docs/permanent/decision-records/ADR/ADR-014-currency-handling.md

### ROUTINE
- type: STALE_REFERENCE
  source: docs/permanent/features/feature-invoicing.md
  reference: CDR-007 (status: superseded)
  detail: reference lacks supersedes-chain note

## Auto-fixed
- type: RENAME
  from: docs/permanent/capabilities/cap-invoicing.md
  to: docs/permanent/capabilities/cap-007-invoicing.md
  updated_references_in: <list of files>
```

## Halt triggers

`doc-integrity` rarely halts on its own — it surfaces findings to its caller, which decides. It halts only when the corpus is so broken that scanning is impossible (e.g., INDEX.md unreadable, scope argument invalid).

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-DI-1 | Invalid scope argument | caller (re-invoke with valid scope) |
| T-DI-2 | INDEX file unreadable | human |
| T-DI-3 | Files appear/disappear during scan (active concurrent modification) | retry once, then halt to human |

## Observations

Surface as `routine`:
- Patterns of findings clustered by skill (signal: that skill's discipline needs reinforcement).
- Findings consistently auto-fixed via rename (signal: rename-detection is doing useful work; track for stats).
- Findings consistently produced by a specific template (signal: template needs revision).

Surface as `critical`:
- A finding type that doesn't fit any defined category (workflow-curator should add a new check type).
- INDEX_DRIFT detected (workflow invariant violation; integrity model is failing somewhere).
