---
name: _meta
description: Cross-cutting rules every skill in this workflow inherits. Not invoked directly; referenced by other skills.
---

# _meta

The contract every skill and agent operates under. If a skill's text contradicts `_meta`, `_meta` wins.

## 1. Always-allowed reads

Every skill and agent may always read, without listing them in its manifest:

- `docs/workflow.md`, `docs/agentic-sdlc-principles.md`, `docs/doc-structure.md`
- `.claude/skills/_meta/SKILL.md` and the skill's or agent's own definition file
- `docs/permanent/architecture/coding-standards.md`, `testing-standards.md`, `naming-conventions.md`
- `docs/permanent/domain/glossary.md`
- `docs/permanent/domain/domain-model.md` (cross-context invariants — must be readable by any agent that produces or validates spec-bearing artifacts so invariants aren't silently violated)

Everything the workflow manages lives under `docs/`. Project code lives elsewhere (e.g., `src/`) and is not workflow scope unless explicitly listed in a manifest. Anything outside the always-allowed set must appear in the agent's manifest or the skill's `Inputs` section; the agent halts and surfaces the gap rather than reading outside scope.

`project-init` is exempt — its job is to create this set.

## 2. No silent substitution

A skill or agent never fills in for a missing or contradictory input. If a required input is absent or two sources disagree, halt with a structured entry naming the missing or conflicting artifact, the upstream that should have produced it, and the proposed route.

Specifically forbidden: writing a glossary entry, capability, feature, decision record, or design spec without a named source; resolving a contradiction by silently picking one.

## 3. Grounded-in declarations

Every spec-bearing artifact (capability, aggregate, feature, design spec, decision record, increment scope, phase plan) declares a `Grounded in:` header listing the documents whose content supports it. `doc-integrity` validates that listed sources exist and are current (accepted, not withdrawn).

Code and test files do not carry per-file `Grounded in:` headers. Their grounding is the increment scope they implement. The reviewer resolves code-to-spec traceability via the increment's manifest, not via per-file headers.

## 4. Subagent manifest and return contracts

Every subagent invocation opens with a fenced manifest block:

```
<<<MANIFEST>>>
agent: <name>
mode: <agent-specific, e.g. phase | increment | stabilization>
scope: <phase-or-increment slug>
inputs:
  - <path>
allowed_writes:
  - <path or directory>
gate_state: <current gate or "in-loop">
parent_commit: <git hash or "n/a">
<<<END>>>
```

The agent's first step reads the block, asserts it matches its declared inputs, and halts if not. Every return is also fenced:

```
<<<RETURN>>>
status: success | halt | scope-expansion
files_written: [<paths>]
key_findings: <prose, <=200 words>
grounded_in: [<sources>]
observations: [<entries per §6>]
halt: { at_step: <id>, reason: <one-line>, route_to: <destination> }
<<<END>>>
```

Malformed returns halt to the human.

## 5. Subagents do not traverse the filesystem

Subagents read only paths in their manifest plus the always-allowed set. No globbing, no grep across the tree, no directory listing outside manifest scope. The orchestrator traverses; agents don't.

The **discovery scope** exception: agents may read type and interface declarations within the same module tree as listed code paths without halting. "Declaration" means `.d.ts`, type-only sections of `.ts`/`.tsx`, Python `.pyi`, Go interface declarations, equivalents in other languages — per the project's `coding-standards.md`. Behavioral code outside the manifest still requires expansion.

## 6. Observations

Agents and skills surface observations to `docs/transient/phases/<phase-slug>/observations.md`. Each entry:

```
- timestamp: <ISO>
  source: <skill or agent>
  category: workflow-defect | standards-coding | standards-testing | standards-naming | other
  severity: routine | critical
  pattern: <one-line>
  context: <where it occurred>
  proposed_action: <what to do about it>
```

`critical` halts inline for review at the next gate. `routine` accumulates and is synthesized at `phase-close`. The agent picks the best category; the synthesis step at phase-close re-routes if needed.

## 7. Skills don't invoke skills

A skill operates within its declared scope and does not invoke other skills. Handoffs run through the orchestrator. The exceptions are the three declared utilities — `doc-integrity`, `workflow-curator`, `feedback-triage` — which may be invoked by any skill that cites the carve-out in its step.

## 8. Append-only with supersession for accepted artifacts

Once an artifact's `status:` is `accepted`, it changes only by supersession:
- A new entry is created with a successor ID and `supersedes: <original>`.
- The original flips to `superseded_by: <successor>`, or to `deprecated` (with reason), or to `withdrawn` (only valid from `proposed`).

Editorial changes (typos, formatting, link fixes, capitalization, whitespace) happen in place and are logged in a sibling `editorial-log.md`. The boundary: anything touching status, IDs, supersession links, accepted decision values, or AC bodies is supersession. Boundary cases default to supersession; the human may override inline.

Code is exempt from append-only.

## 9. Artifact lifecycle and status

Spec-bearing artifacts are born under `docs/permanent/...` with `status: proposed`. At the gate that approves them, status flips to `accepted` in place — no file move. Subsequent changes follow §8.

Status state machine:

```
proposed -> accepted -> superseded -> (terminal)
                     -> deprecated -> (terminal)
proposed -> withdrawn -> (terminal, may be re-proposed under new ID with prior_withdrawn:)
```

`doc-integrity` validates transitions.

## 10. Decision-record numbering

Two record types: **DR** (domain, capability-scope, feature design) and **ADR** (architecture, technology, system-impact). Each has its own numbering namespace.

Numbers are assigned at gate approval as part of the status flip from `proposed` to `accepted`:
- Phase-level records at Gate 1.
- Increment-level records at Gate 2.

Records sit with `TBD-<slug>` placeholders between authoring and gate approval (minutes, not hours). `doc-integrity` halts if any `TBD-*` ID survives a passed gate.

## 11. Pin validation

`session-resume` validates `skill-versions.lock` against the dotfiles tag at the start of every session. A mismatch halts with two human options:
- **Override** (recorded as a DR): proceed with the available version.
- **Rollback**: restore the pinned version or roll back the project's pin.

Pin failures don't get silently absorbed.

## 12. Expected-duration bands

Each skill declares a typical duration. Exceeding the upper bound is itself a workflow-defect signal — surface as an observation. Bands:

- `session-resume`: 5–60 seconds.
- `project-init`: 1–5 minutes (one-time).
- `phase-design` (includes domain-design + technical-design agents): 5–20 minutes.
- `phase-close` (consolidation + retrospective + skill diffs): 3–15 minutes.
- `increment-design` (includes domain-design + technical-design agents): 4–15 minutes.
- `increment-execute` (one develop + one test + one review pass, plus cycle retries): 10–60 minutes typical, longer on cycle-3 retries.
- `increment-close` (full regression + integrity + PR): 3–25 minutes depending on suite size.
- Post-merge fix cycles (handled inline by the orchestrator while increment status is `awaiting-merge`): per fix, 2–10 minutes plus CI wait and human validation.
- `feedback-triage`: 30 seconds – 2 minutes per entry.
- Utilities (`doc-integrity`, `workflow-curator`): 30 seconds – 5 minutes scoped; up to 10 minutes for full sweep.

## 13. Gate-approval prompt contract

The human never edits INDEX directly to signal a gate decision. At every gate, the orchestrator emits:

```
═══════════════════════════════════════════════
APPROVAL REQUIRED — Gate <N> (<name>)
Active scope: <slug>

Summary: <2–3 sentences>

Files for review:
  - <path> — <one-line>
  ...

To approve: reply "approve" (optionally "approve with modifications: <notes>").
To reject: reply "reject: <reason>".
To request changes: reply "changes: <list>".
═══════════════════════════════════════════════
```

The orchestrator parses the reply, writes the `gate_status:` entry in INDEX, and routes per the response. For "changes", the orchestrator applies targeted edits to proposed artifacts in place and re-emits the gate prompt; substantive changes re-invoke the relevant upstream skill. For "reject", the workflow routes per the gate's defined rejection path.

## 14. Gate-state schema in INDEX

```yaml
gate_status:
  - gate_id: gate-1@<phase-slug>
    decision: approve | reject | changes
    decided_at: <ISO>
    decided_by: <human>
    modifications: <text or "none">
  - gate_id: gate-2@<phase-slug>/<inc-slug>
    decision: approve
    ...
```

`session-resume` reads this for routing.

## 15. Visibility lines

Every skill and agent emits structured status lines so the human can follow progress. Subagents return their lines as part of the fenced return block; the orchestrator surfaces them to chat.

## 16. The principles document is referenced, not duplicated

`agentic-sdlc-principles.md` is the workflow-agnostic statement of why these rules exist. Skills reference principles by section when explaining a behavior; they don't restate them.
