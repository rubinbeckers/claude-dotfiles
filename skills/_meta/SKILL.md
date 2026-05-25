---
name: _meta
description: Cross-cutting rules every skill in this workflow inherits. Not invoked directly; referenced by other skills.
---

# _meta

This file defines the rules every skill in this workflow operates under. Skills do not restate these rules — they inherit them. If a skill specifies behavior contradicting `_meta`, `_meta` wins.

## 1. The always-allowed read set

Every skill (orchestration or subagent) may always read, without listing them in its manifest:

- `workflow.md`
- `agentic-sdlc-principles.md`
- `doc-structure.md`
- `.claude/skills/_meta/SKILL.md`
- The skill's own `SKILL.md` (or, for subagents, the agent definition file)
- `docs/permanent/architecture/coding-standards.md`
- `docs/permanent/architecture/testing-standards.md`
- `docs/permanent/architecture/naming-conventions.md`
- `docs/permanent/domain/glossary.md`
- `docs/permanent/process/tag-vocabulary.md` (the canonical tag definitions per workflow.md §15.9)

This set is the single source of truth for "always allowed." Any skill that needs a doc not in this set and not in its manifest halts and surfaces the gap.

**Bootstrap exception (T8).** `project-init` runs *before* the always-allowed set exists — its job is to create the set. It is the only skill exempt from the always-allowed-set dependency. All other skills assume the set exists (project-init's completion is a precondition for any of them).

## 2. Non-assumption

A skill never silently substitutes its own judgement for missing or contradictory input. If a required input is absent, the skill halts with a structured halt entry naming:
- the missing input
- the upstream artifact or skill that should have produced it
- the proposed loopback destination

Specifically forbidden: writing a glossary entry, capability spec, design spec, or decision record without grounding in a named source; resolving a contradiction between two source documents by silently picking one; "filling in the obvious."

## 3. Context manifest

Every subagent receives a context manifest in its invocation prompt. The manifest lists the documents the subagent may read. The subagent reads only those documents (plus the always-allowed set in §1). If the subagent needs a document outside its manifest, it halts and surfaces the need.

Orchestration skills run in the main chat and inherit the chat's accumulated context, but they still apply the manifest discipline conceptually: they only act on documents listed in their skill's `Inputs` section, plus the always-allowed set.

## 4. Halt protocol

A skill halts by writing a halt entry to the active workflow log and returning to its caller (the orchestrator or, for nested calls, the invoking skill). The halt entry must include:

```
HALT
  Skill: <skill-name>
  At-step: <step-id or step-name from this skill's SKILL.md>
  Reason: <one-line>
  Missing/Conflicting: <artifacts>
  Route-to: <skill or human>
  Re-pass: <gate to re-pass, or "none">
```

The orchestrator routes per the halt entry. The skill that resolves the halt produces an output linked back to the halt entry.

## 5. Grounded-in declarations

Every *artifact* a skill produces declares its `Grounded in:` sources — the specific documents whose content supports the artifact's claims. The declaration is structural, not narrative; it goes in a header field on the artifact.

```
Grounded in:
  - docs/permanent/capabilities/cap-007-invoicing.md
  - docs/permanent/decision-records/ADR/ADR-014-currency-handling.md
```

`doc-integrity` validates structurally that every listed source exists, is in scope for the producing skill, and is current (not deprecated or withdrawn). Semantic grounding ("does this source actually support this claim?") is a human-review responsibility at gates.

**Granularity (T6).** `Grounded in:` declarations live at the *artifact* level: decision records, capability specs, features, design specs, FDRs/ADRs/CDRs/DDRs, backlog-item specs. Code files and test files do *not* carry individual `Grounded in:` headers — their grounding is the backlog item's spec they implement (which already declares `Grounded in:`). This prevents hundreds of brittle per-file path strings that would go stale on every supersession. `backlog-review`'s dependency-trace checklist resolves code-to-spec grounding via the backlog item's manifest, not via per-file headers.

## 6. Skills don't invoke skills

A skill operates only within its declared scope. Skills do not invoke other skills directly. Handovers are managed by the orchestrator.

**Exception — utility sub-skills.** `doc-integrity`, `doc-consolidator`, `workflow-curator`, and `backlog-loop` are declared utility sub-skills. They may be invoked by other skills (typically `phase-close`, `increment-close`, `phase-retrospective`, `increment-start`) within those skills' steps. Any skill invoking a utility sub-skill must cite the carve-out explicitly in its step description. No other sub-skill invocation is permitted.

## 7. Append-only with supersession

Artifacts under `docs/permanent/` are append-only once approved at a gate. Modification is via supersession:
- A new entry is created with a successor identifier
- The original's status flips to `superseded-by: <successor-id>` or `deprecated` (with reason)
- The successor declares `supersedes: <original-id>`

`doc-integrity` validates both directions of the link at every close event.

Code is exempt from append-only (it's a different kind of artifact); decisions, specs, and interpretations are not.

### 7.1 Editorial-change carve-out

Typos, formatting, link fixes, capitalization, and whitespace changes do not require supersession. They are made in-place on the accepted artifact and logged as a single line in a per-document `editorial-log.md` sibling file:

```
- timestamp: <ISO>
  by: <human or skill>
  scope: typo | formatting | link | capitalization | whitespace
  description: <one-line description of the change>
```

`doc-integrity` validates that editorial changes do not touch decision-relevant content — specifically: status fields, IDs, supersession links, accepted decision values, AC text bodies (formatting of AC text is editorial; semantic change is supersession). Boundary-case changes ("is this clarifying or supersession?") default to supersession when ambiguous; the human can override via inline approval (§13).

## 8. Decision-record numbering

Each decision-record type (CDR, DDR, FDR, ADR) has its own numbering namespace. Numbers are assigned by the **gate-approval step** that promotes the record to `accepted`:

- **Phase-level records** (typically domain-wide CDRs, DDRs, architecture-wide ADRs) are numbered at Gate 1 approval, as part of the promotion step in `phase-planning` step 7 (or its equivalent).
- **Increment-level records** (typically FDRs, capability-scoped CDRs, scoped ADRs) are numbered at Gate 2 approval, as part of the promotion step in `increment-planning` step 9.

Records sit with `TBD-<short-slug>` placeholders only between the authoring subagent's run and the gate's approval — typically minutes. Once accepted, IDs are stable through the rest of the workflow. `doc-integrity` validates that no `TBD-*` IDs appear in any accepted record at any point after the gate that produced them.

Concurrent gate approvals are not a concern in this single-human workflow (gates are sequential by construction), but the numbering routine should still record `assigned_at` timestamps for audit.

## 9. Status transitions

Decision-record statuses follow this state machine:

```
       ┌─────────┐
       │proposed │
       └────┬────┘
            │ (at gate approval)
            ▼
       ┌─────────┐         ┌──────────┐
       │accepted │────────▶│superseded│
       └────┬────┘         └──────────┘
            │
            ▼
       ┌──────────┐
       │deprecated│
       └──────────┘

(from proposed only:)
proposed ───▶ withdrawn (decision never made; rationale required)
```

`withdrawn` is terminal. A withdrawn decision may be re-proposed under a new identifier, with `prior-withdrawn: <id>` declared on the new proposal. `doc-integrity` validates that `withdrawn` and `deprecated` records are not referenced by accepted records or by code.

## 10. Observation surfacing

Skills surface observations to a single per-phase log: `docs/transient/phases/<phase-slug>/observations.md`. Entries declare a `category` field; `workflow-curator` routes by category at synthesis time.

Format:

```
- timestamp: 2026-05-24T14:00Z
  skill: backlog-review
  category: workflow-defect | standards-coding | standards-testing | standards-naming | other
  severity: routine | critical
  pattern: "naming inconsistency: PascalCase vs camelCase in component files"
  context: "occurred in inc-005, backlog item 'add-invoice-form'"
  proposed-action: "specify component naming in naming-conventions.md"
  human_confirmed: false | true
  references:
    - <path>
```

Severity rules:
- `critical`: workflow-breaking; halts inline for `improvement-review` regardless of category.
- `routine`: batched until `phase-retrospective`.

Category guides synthesis routing at retrospective:
- `workflow-defect` → proposed skill or workflow.md diff.
- `standards-coding` / `standards-testing` / `standards-naming` → proposed standards doc diff.
- `other` → surfaced as an open question.

A skill author chooses the category that fits; boundary cases pick one and trust synthesis to route correctly. The two-log model is consolidated into this single log — `workflow-observations.md` and `standards-observations.md` are no longer separate.

## 11. Pin validation

At every `session-resume`, the orchestrator validates that the pinned skill and template versions (in `skill-versions.lock`) are reachable. Mismatch halts with one of two responses required from human:

- **Override** (recorded as a CDR): proceed with the available version, accept the deviation
- **Rollback**: restore the pinned version or roll back the project's pin to a known-reachable version

Pin failures cannot be silently absorbed. Mid-phase pin failures generally route to override (rolling back mid-phase is heavier than accepting the deviation).

## 12. Visibility lines

Every skill, including subagents, emits structured status lines per `workflow.md` §15. Subagents emit lines that are returned to the orchestrator as part of their structured return; the orchestrator surfaces them to the human chat.

**Expected-duration bands (T1).** Each skill declares an expected-duration band — typical run-time range under normal conditions. The orchestrator considers a skill "running long" only when it exceeds the upper bound of its band. Bands per current skill:

- `session-resume`: 5–60 seconds.
- `project-init`: 1–5 minutes (one-time).
- `phase-start` (includes BA + TA subagents): 3–15 minutes.
- `phase-planning`: 1–5 minutes.
- `phase-close`, `phase-retrospective`: 1–5 minutes each.
- `improvement-review`: 2–10 minutes (depends on diff count).
- `increment-start` (includes FA + TL subagents): 3–10 minutes.
- `increment-planning`: 1–5 minutes.
- `increment-close` (includes full regression): 2–20 minutes depending on suite size.
- `backlog-loop`: cumulative; expected per-item: 2–15 minutes for develop, 1–10 for test, 1–5 for review.
- `feedback-triage`: 30 seconds – 2 minutes per entry.
- Utility sub-skills (`doc-integrity`, `doc-consolidator`, `workflow-curator`): 30 seconds – 3 minutes scoped; up to 10 minutes for full sweep.

A skill exceeding its upper bound is a workflow-defect signal: either the task is too large (split it), the subagent is stuck (escalate), or the band needs revision (workflow observation, `category: workflow-defect`).

## 13. Subagent invocation and return contracts

### 13.1 Invocation contract (orchestrator → subagent)

Every subagent invocation includes a fenced manifest block at the top of the prompt:

```
<<<MANIFEST>>>
subagent: <agent-name>
scope-id: <phase-or-increment-or-item-slug>
inputs:
  - <path>
  - <path>
allowed-writes:
  - <path-or-directory>
gate-state: <current-gate-or-"in-loop">
parent-commit: <git-hash or "n/a">
<<<END>>>
```

The orchestrator constructs this block from the subagent's declared manifest in its definition file. Step 1 of every subagent reads this block, enumerates it, and asserts it matches the inputs declared in its own definition. Mismatch halts with `T-<agent>-MANIFEST` (specific halt-trigger per subagent).

The fenced block is the architectural enforcement of context engineering — the subagent's discipline is no longer policy-based.

### 13.2 Return contract (subagent → orchestrator)

Every subagent return is fenced and structured:

```
<<<RETURN>>>
status: success | halt
files_written:
  - <path>
  - <path>
key_findings: <prose, <=200 words>
grounded_in:
  - <source>
  - <source>
observations:
  - timestamp: <ISO>
    category: workflow-defect | standards-coding | standards-testing | standards-naming | other
    severity: routine | critical
    pattern: <description>
halt:
  at_step: <step>
  reason: <one-line>
  route_to: <destination>
<<<END>>>
```

The orchestrator parses the fenced block deterministically — unfenced YAML in chat would be ambiguous and breaks silently on formatting drift. Malformed returns halt with `T-<agent>-RETURN` and route to human.

### 13.3 Approval-prompt contract (human ↔ orchestrator at gates)

The human never edits INDEX directly to signal gate approval. At every gate halt, the orchestrator emits a structured approval prompt:

```
═══════════════════════════════════════════════
APPROVAL REQUIRED — Gate <N> (<gate-name>)
Active scope: <phase-or-increment-slug>

Summary of artifacts produced:
  <2–3 sentence summary>

Files for review (read at your discretion):
  - <path 1> — <one-line summary>
  - <path 2> — <one-line summary>
  ...

To approve: reply "approve" (or "approve with modifications: <notes>").
To reject: reply "reject: <reason>".
To request changes: reply "changes: <list>".
═══════════════════════════════════════════════
```

The orchestrator parses the human's reply, writes the corresponding `gate_status:` entry to INDEX (see §14), and routes per the response. The human's role is to read (or skim) and decide; the orchestrator handles all file modifications.

## 14. No filesystem traversal in subagents

Subagents must not glob, grep, or list-directory beyond their manifest. They may only read paths that appear in their manifest or in the always-allowed set. Path validation happens at read time: the subagent's first action on a non-manifest path is to halt.

The orchestrator may traverse (it is the bookkeeper); subagents may not.

## 15. The principles document is referenced, not duplicated

`agentic-sdlc-principles.md` is the workflow-agnostic statement of why these rules exist. Skills do not restate principles in their SKILL.md; they reference the relevant principle by section when explaining a halt or a behavior. This keeps skills readable and the principles document the canonical reference.

## 16. Gate-state schema in INDEX

Every gate decision is recorded in INDEX under a `gate_status:` block:

```yaml
gate_status:
  - gate_id: gate-1@<phase-slug>
    decision: approve | reject | changes
    decided_at: <ISO>
    decided_by: <human-identifier>
    modifications: <free text or "none">
    notes: <free text or "none">
  - gate_id: gate-2@<phase-slug>/<inc-slug>
    decision: approve
    ...
```

`session-resume` reads this to determine routing per `workflow.md` §13. The orchestrator writes entries based on the human's response to approval prompts (§13.3). The human never edits this directly; the orchestrator does.

For "changes" decisions, the orchestrator routes back to the relevant upstream skill with the change list as input. For "reject", the orchestrator routes per the gate's defined rejection destination (typically the producing skill, re-passing).

End of `_meta/SKILL.md`.
