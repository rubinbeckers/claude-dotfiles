---
name: phase-start
description: Initiate a new phase. Reads raw input, handles prototype classification (overwrite/additive/none), delegates business analysis and technical architecture to subagents, then hands off to phase-planning. Invoked by session-resume when a new phase is starting.
---

# phase-start

Initiates a phase. Reads raw input from the human, handles the prototype that may have arrived with it, delegates parallel-ish analysis work to the BA and TA subagents, then advances to `phase-planning`. The big human-facing skill at the top of every phase.

Runs as an orchestration skill in the main chat. Delegates to subagents.

## Inputs

- Raw input file(s) at `docs/transient/phases/<next-phase-slug>/raw-input/` (provided by the human before invocation)
- Existing permanent docs (read-only at this step; the subagents will reference them)
- Any prototype files newly delivered (typically dropped into `docs/transient/phases/<next-phase-slug>/prototype-candidate/`)
- INDEX
- Always-allowed set (`_meta` §1)

## Outputs

- The next phase's transient workspace created: `docs/transient/phases/NN-<slug>/`
- Prototype handling decision recorded
- BA and TA subagent outputs (written by the subagents themselves to their owned permanent docs as proposed entries)
- `phase-scope.md` (transient) capturing the agreed scope before planning
- INDEX updated: new active phase, status `planning`

## Steps

### Step 1 — Determine phase slug, create workspace, relocate carry-forward

Read INDEX. The next phase number is `(highest phase number) + 1`. Ask the human for a slug for the phase if not already provided in raw input. Create:

```
docs/transient/phases/<NN>-<slug>/
  raw-input/                          (move from where human placed it)
  prototype-candidate/                (if prototype delivered)
  observations.md                     (empty stub, single unified log per _meta §10)
  carry-forward-from-<prior-slug>/    (relocated from prior phase; see below)
  proposed/                           (subagent-authored proposals; promoted to permanent at gates per workflow.md §5.2)
    capabilities/
    aggregates/
    features/
    design-specs/
    decision-records/
      CDR/
      DDR/
      FDR/
      ADR/
```

**Carry-forward relocation (M10):** If the prior phase's transient tree contains a `carry-forward/` directory, *move* its contents into this new phase's `carry-forward-from-<prior-slug>/`. The original location in the prior phase is then removed (the carry-forward content has moved homes; the prior phase is now fully archived-eligible). The new phase reads carry-forward content as part of its raw input — `phase-business-analysis` and `phase-technical-architecture` manifests include it.

Update INDEX: `active_phase: <slug>`, `status: planning`.

### Step 2 — Prototype classification

Per `workflow.md` §6.1, classify the prototype situation:

```
A) New prototype provided, overwrites existing.
   Detect: prototype-candidate/ contains files that match (by name or path) existing files in docs/permanent/design/prototype/.
B) New prototype provided, additive.
   Detect: prototype-candidate/ contains files with no name collision in docs/permanent/design/prototype/.
C) No new prototype provided.
   Detect: prototype-candidate/ is absent or empty.
```

For each detected case, emit a classification proposal to the human:

```
Prototype classification proposal:
  Case: <A|B|C>
  Affected files: <list>
  Recommended action: <describe>

Confirm? (yes / change to <other case> / provide modifications)
```

Wait for human confirmation. Then:

- **Case A**: Archive existing `docs/permanent/design/prototype/` to `docs/permanent/design/archive/<timestamp>/`; move prototype-candidate contents to `docs/permanent/design/prototype/`. Record an FDR documenting the prototype replacement with rationale.
- **Case B**: Merge prototype-candidate contents into `docs/permanent/design/prototype/`. No archive. Record an FDR documenting the additions.
- **Case C**: Run capability-coverage analysis: read planned capabilities from raw input, list capabilities for which no prototype file exists. Surface gaps to human:

  ```
  No new prototype provided. Capability-coverage analysis:
    Covered by existing prototype: <list>
    Uncovered: <list>

  Choose:
    1) Accept risk: FA proceeds without high-fidelity prototype for uncovered capabilities.
    2) Provide a prototype before phase proceeds. (Halt.)
  ```

  On option 1: record a CDR (one per uncovered capability) noting acceptance of the design-coverage gap. On option 2: halt with `T-PS-1`.

### Step 3 — Draft phase-scope.md

Read raw input. Produce a transient `phase-scope.md` that captures:
- High-level objective(s) of the phase
- Capabilities expected to be added or modified (by name, sourced from raw input)
- Out-of-scope items the human explicitly noted
- Prototype handling outcome (from step 2)

This is *not* the phase plan (that's the next skill). It's a scope assertion used to ground the BA and TA subagents.

Surface to human for confirmation. The human modifies `phase-scope.md` if needed; once confirmed, proceed.

### Step 4 — Delegate to phase-business-analysis subagent

Status line:
```
Delegating to phase-business-analysis: domain modeling for <phase-slug>.
Manifest: phase-scope.md, raw-input/, docs/permanent/domain/**, existing CDRs/DDRs.
```

Construct subagent prompt per `_meta` §3 and `phase-business-analysis.md`. Invoke via Task tool.

Parse return (per `_meta` §13):
- On success: BA produced proposed capability and aggregate entries (still in `proposed` status), glossary additions, possibly CDRs/DDRs. Update INDEX with reference to outputs.
- On halt: route per the halt entry's `route_to`. Typically these halts are at this level (raw input ambiguity → human) — escalation does not exist above phase-start. Halt to human.

### Step 5 — Delegate to phase-technical-architecture subagent

Status line:
```
Delegating to phase-technical-architecture: architecture decisions for <phase-slug>.
Manifest: phase-scope.md, BA outputs (capabilities, aggregates from step 4), docs/permanent/architecture/**, existing ADRs.
```

Construct subagent prompt per `phase-technical-architecture.md`. Invoke via Task tool.

Parse return:
- On success: TA produced proposed architecture entries, possibly ADRs, possibly standards updates. Update INDEX.
- On halt: route per halt entry. Typical halts: BA outputs surface a domain need the architecture can't accommodate (loops back to BA — re-run step 4 with the surfaced gap as input).

### Step 6 — Advance to phase-planning

Status line:
```
Phase start complete. BA wrote: <N> capabilities, <M> aggregates. TA wrote: <P> architecture updates, <Q> ADRs.
Advancing to phase-planning.
```

Invoke `phase-planning` (next orchestration skill).

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-PS-1 | Human chose "provide prototype" for case C | human (await prototype) |
| T-PS-2 | Raw input absent | human |
| T-PS-3 | Raw input contradicts existing permanent docs in non-trivial ways | human (clarification before BA runs) |
| T-PS-4 | BA subagent returned halt that escalates above phase level | human |
| T-PS-5 | TA subagent returned halt that escalates above phase level | human |
| T-PS-6 | Step 2 prototype classification proposal rejected without alternative | human |

## Observations

Surface as `routine`:
- Raw input that consistently lacks structure helpful for BA grounding (signal: a raw-input template would reduce friction).
- Prototype coverage gaps that recur across phases (signal: design pipeline could integrate earlier).
- BA halts that surface terms not in the glossary at a rate that exceeds the baseline (signal: glossary-authoring carve-out per `_meta` may need adjustment).
