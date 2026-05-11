# doc-integrity

- **Name:** doc-integrity
- **Version:** 1.0.0
- **Purpose:** Validate doc structure consistency: indices, cross-references, tags, glossary, decision-record supersession (forward + back), `Grounded in:` provenance, withdrawn-reference checks, corrective-increment back-references.
- **Triggers from:** `increment-close` (per-increment scope) and `phase-close` (full sweep) via the utility sub-skill carve-out (meta-skill §10); or manual.
- **Utility sub-skill:** **yes.** This is the currently-only declared utility sub-skill. Invoking skills must cite this carve-out explicitly in their invocation.
- **Inputs:** Determined by scope:
  - Per-increment scope: changed-doc set from current increment.
  - Full sweep: all `/docs/**/*.md`, `/features/**/*.feature`, `/design/**/*.md`.
  - Plus meta-skill §1 always-allowed.
- **Outputs:**
  - Integrity report (returned to invoking skill; or `/docs/process/doc-integrity-report.md` for manual runs).
  - Auto-fixes (exact-match only, see below).
  - Surfaced unresolvable issues (with proposed resolutions).
- **Hands off to:** Invoking skill (per-increment / phase-close), or human (manual run).
- **Inherits:** Meta-skill.

## Skill-specific halt triggers

- T-DI-1: Auto-fix would require non-trivial semantic judgment — surface, don't fix.
- T-DI-2: Cross-reference is broken but multiple plausible fixes exist — surface options, don't pick.
- T-DI-3: Bidirectional link required but only one direction present, and the other end's status is ambiguous — surface.
- T-DI-4: Withdrawn artifact is referenced by an in-scope artifact — surface for human direction (withdrawn artifacts shouldn't be referenced; this may be a stale link or a genuine need for un-withdrawal — see workflow.md §14).

## Checks performed

### 1. INDEX consistency

For every doc in scope, verify an INDEX row exists with current status. Surface mismatches.

### 2. Cross-reference resolution

For every link from one doc to another (markdown link, explicit reference, decision-record citation):
- Target exists.
- Target status is `active` / `accepted` / `delivered` / `in-progress` — not `deprecated` / `superseded` / `withdrawn` / `superseded-by-increment` / `abandoned`.
- Halt T-DI-4 if reference to `withdrawn` artifact found.
- For `deprecated` / `superseded` references: surface as warning (not necessarily an error — historical references in retrospectives are valid).

### 3. Tag vocabulary

Every tag used in `.md` / `.feature` is in `/docs/process/tag-vocabulary.md`. Unknown tags → surface (do not auto-add).

### 4. Glossary completeness

Every domain noun appearing in capability specs, aggregates, scenarios — verifies presence in glossary. Surface missing entries (do not author — glossary authoring is restricted by meta-skill §9 carve-out).

### 5. Decision-record supersession (bidirectional)

For each decision record with status `superseded`:
- Has forward link to superseding record.
- Superseding record has back link to this one.
- Both rows in INDEX reflect supersession.

For each decision record with status `withdrawn`:
- No incoming references from currently-accepted artifacts.
- Optionally has `previously-considered:` link from a later fresh proposal — these are valid.

For each decision record with status `accepted` that has a `previously-considered: <X>` field:
- X exists with status `withdrawn`.

### 6. Increment-level supersession (bidirectional, corrective pattern)

For each increment with `@corrects:inc-NNN` declared in `scope.md`:
- The corrected artifacts (as named in the corrective CDR/ADR) have their status updated to include `superseded-by-increment: inc-MMM`.
- Conversely, every artifact with `superseded-by-increment: inc-MMM` traces to an increment that declares the corresponding `@corrects:` link.
- Halt T-DI-3 if only one direction present.

### 7. `Grounded in:` lint

For each step-summary block in `step-log.md` (or `phase-log.md` for full sweep), validate each entry in the `Grounded in:` list:
- **Existence:** doc path exists.
- **Scope:** the doc was loadable by the citing skill — in meta-skill §1 always-allowed, or in the skill's declared Inputs, or in the citing increment's Developer Context Manifest.
- **Currency:** doc status is not `deprecated` / `superseded` / `withdrawn` / `superseded-by-increment`.

Semantic grounding ("does this doc actually support this claim?") is a Gate-3 / Gate-4 spot-check responsibility — explicitly out of scope here.

### 8. Capability-feature alignment

Every in-scope capability has at least one `.feature` file with scenarios covering its AC IDs. Every `# AC: AC-N` reference in a scenario points to an existing AC. Surface mismatches.

### 9. Component-ADR alignment

Every component referenced in plans/scenarios has a doc. Every ADR's referenced components exist. Surface broken links.

### 10. Rename auto-fix (exact-match only)

When `phase-close` detects a renamed file via git history with **exact-match content** (no other edits since the previous commit), `doc-integrity` may auto-update incoming references. Any non-exact-match (renamed AND edited) requires human direction — halt T-DI-1.

## Process

1. **Determine scope** from invocation: per-increment (with file list) or full sweep.

2. **Run checks 1-9** in order.

3. **For each violation:**
   - Trivially auto-fixable + low-risk (broken markdown link to a clearly renamed file in scope; exact-match rename detected; INDEX row missing for a doc that exists) → auto-fix, record in report.
   - Anything else → surface in report with proposed resolution(s).

4. **For each halt trigger fired:** stop fixing within that domain, surface, continue with other domains.

5. **Return integrity report** to invoking skill. Per-increment: brief summary of fixes + surfacing. Full sweep: comprehensive `doc-integrity-report.md`.

## Report structure

```
## Doc Integrity Report — [scope] — [timestamp]
### Auto-fixed
- <issue> in <path> — fixed: <description>
### Needs attention (surfaced)
- <issue> in <path> — proposed resolution: <option(s)>
### Halts
- <trigger> in <path>
### Stats
- Docs checked: N
- Cross-refs validated: M
- Auto-fixes applied: X
- Surfaced: Y
- Halts: Z
```

## Notes

- Auto-fix conservatism is a deliberate stance — false negatives (missing a fix) are recoverable; false positives (wrong fix applied silently) are not.
- The bidirectional supersession discipline is what makes the audit trail durable. Without back-references, history runs only forward and the past becomes invisible.
- Withdrawn-reference checks (#4) catch the most common drift: a previously-proposed decision was withdrawn, but some downstream artifact still cites it. The skill surfaces these for human direction because the resolution is context-dependent (delete the citation, replace with a different ADR, or revisit whether withdrawal was correct).
- `Grounded in:` lint (#7) is the mechanical layer of grounded-claims discipline. Semantic adequacy is human review territory.
- Utility-sub-skill status means this skill is invokable from other skills (specifically `increment-close` and `phase-close`). No other skill currently holds this status.
