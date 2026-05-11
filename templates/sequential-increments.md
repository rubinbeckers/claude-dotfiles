# Sequential Increments — Policy Decision

> This document records the project-wide default that increments run strictly sequentially, and what would change if that policy were ever revisited. Referenced from `/docs/process/workflow.md` §10.

- **Status:** accepted (project default)
- **Date:** [set at project-init]
- **Tags:** @process

## Context

Increments are the unit of delivery in this workflow. There are two plausible default modes:

1. **Sequential** — no new increment opens until the prior one is merged.
2. **Parallel** — multiple increments may be in flight simultaneously, each on its own branch.

Sequential is simpler. Parallel offers throughput at the cost of coordination overhead.

## Decision

**Increments are strictly sequential.** Specifically:

- `increment-start` refuses to open a new increment until the prior one has status `delivered` (merged to main).
- Increment dependencies declared in the roadmap are enforced — an increment cannot open if any declared dependency is not yet `delivered`.
- This is enforced in the `increment-start` skill, not by external tooling.

## Rationale

- **Single primary operator.** The agentic workflow assumes one human at the gates. Parallel increments would multiply gate decisions and increase context-switching cost.
- **Doc consistency.** Multiple increments mutating product-level docs simultaneously would create merge conflicts at the doc layer, not just the code layer. The selective-loading model assumes docs reflect current truth; parallel changes destabilize that.
- **Decision record numbering.** TBD numbers are finalized at `increment-close`. Concurrent close events would collide.
- **Simplicity.** Parallel coordination is a substantial added concern that does not pay off until throughput demand justifies it.

## Consequences

### Easier

- Linear reasoning about doc state, branch state, and decision records.
- No coordination between in-flight increments needed.
- INDEX updates are deterministic.

### Harder / accepted trade-offs

- Throughput is bounded by single-increment cycle time.
- A long-running increment blocks all other work.
- Independent slices that *could* be done in parallel must be sequenced.

## Impact analysis: what would change if this policy were revisited

If a future decision moved to parallel increments, the following would need to be reworked:

### Skills affected

- **`increment-start`** — would need to handle multiple in-flight increments; dependency check would still apply but would not refuse on basis of "any prior increment open."
- **`increment-close`** — TBD number assignment would need a coordinator or a number-reservation pattern at draft time.
- **`developer`** — branch handling would need explicit base-branch awareness (rebase or merge conflicts on doc files).
- **`technical-reviewer`** — the retry budget would need to account for cross-increment regressions.
- **`doc-integrity`** — would need to handle states where multiple increments have proposed but not yet accepted decision records.

### Doc structure affected

- **`/docs/increments/INDEX.md`** — would have multiple `in-progress` rows.
- **`/docs/process/learnings/`** — concurrent appends would need conflict handling.

### Workflow doc affected

- **§6 Phase Sequencing** — would explicitly describe parallel mode.
- **§10 Sequential Increments** — this doc — would be superseded by a new decision.

### New skills / capabilities needed

- A "merge orchestrator" or coordination skill that watches when an increment's PR merges and re-bases sibling increments.
- A doc-merge skill (or built into `doc-integrity`) for resolving conflicts in INDEX files.

### Estimated rework

Substantial. A move to parallel increments is not a tweak — it's a workflow redesign. This decision is one to revisit only if throughput becomes the binding constraint and the human gate cadence has been re-thought to support it.

## Alternatives considered

- **Parallel from day one.** Rejected: complexity not justified for single-operator scale.
- **Sequential by default, parallel opt-in for independent slices.** Considered. Could be reintroduced later as a controlled extension — would require explicit declaration in scope.md that the increment is "parallel-safe" and a coordinator skill. Deferred.

## Cross-references

- Workflow doc: `/docs/process/workflow.md` §10
- Skill enforcing this: `/skills/increment-start/SKILL.md` (halt trigger T-IS-3)
