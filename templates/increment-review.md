# Review — Increment NNN: <slug>

**Reviewer:** technical-reviewer v<version>
**Date:** YYYY-MM-DD
**Cycle:** 1 of 3 *(increment if rejected; max 3 then abandon|revise-scope)*
**Mode:** code-changes | doc-only
**Verdict:** approve | changes requested | retry-exhausted (abandon|revise-scope required)

## Verified mechanically

These items the agent checked deterministically. Each is a pass/fail with evidence.

### Code (skipped in doc-only mode)

- [ ] Coding standards: pass | <list of issues>
- [ ] Test coverage baseline ≥80% on changed code paths: <pct> | exempted per plan §X
- [ ] `@security-critical` paths: 100% line + branch coverage on input-validation and error paths: pass | <list>
- [ ] No secrets in code (grep + secret-scanner CI): pass | <findings>
- [ ] Logging hygiene grep (PII patterns, authz tokens): pass | <findings>
- [ ] Input validation present at trust boundaries (per Threat considerations): pass | <gaps>
- [ ] SCA (dependency scan) results: clean | <CVEs found + disposition>

### Plan alignment

- [ ] Every plan task → corresponding code change
- [ ] No code outside plan scope (no scope creep)
- [ ] Every proposed ADR exercised | withdrawn | superseded
- [ ] No proposed ADR contradicts an accepted ADR
- [ ] Withdrawn ADRs not referenced elsewhere

### Cross-references and indices

- [ ] All doc artifacts referenced exist and are current (not `deprecated`, `superseded-by-increment`, `withdrawn`)
- [ ] Tag vocabulary clean (no unknown tags)
- [ ] Glossary entries present for new domain terms (authored by upstream skills, not this increment's developer)

### AC coverage

- [ ] Every in-scope AC ID has at least one referencing scenario (via `# AC: AC-N`)
- [ ] Every `# AC:` reference resolves to an existing AC

### Dependency trace

- [ ] Every doc cited in `Grounded in:` chains traces to either always-allowed, the increment's plan-manifest, or an `@depends:`-declared prior increment
- [ ] No implicit cross-increment dependencies

### Regression (skipped in doc-only mode)

- [ ] UI regression by tag: pass / pass count / fail count
- [ ] Any regression failures: <list with disposition>

### Standards observations appended

- [ ] One-liners added to `/docs/phases/NN-<slug>/standards-observations.md` for any standards-related issues surfaced (whether blocking or not).

## Needs human confirmation

These items require human judgment. They are surfaced here for visibility and carried into the Gate 5 PR checklist.

- [ ] Threat-considerations answers (on each in-scope capability classified > public): reviewed for adequacy
- [ ] Authn required / Authz model declaration on each in-scope capability: confirmed correct
- [ ] `@security-critical` classification: correctly applied to components/scenarios touching data ≥ confidential
- [ ] Scope-vs-intent alignment: does the work actually deliver the in-scope capabilities' intent?
- [ ] (Doc-only mode) The doc changes adequately reflect the decision/correction this increment exists to capture

## Findings (if changes requested)

Each finding tied to file/line where possible, with proposed action.

- **<finding>** at `<path>:<line>` — proposed: <action>
- ...

## Retry history

- Cycle 1: <verdict> — <one-line summary>
- Cycle 2: <verdict> — <one-line summary>
- Cycle 3: <verdict> — <one-line summary>

*(On 3rd rejection, this skill halts and surfaces the two paths: abandon or revise-scope per workflow.md §10.)*
