# technical-reviewer

- **Name:** technical-reviewer
- **Version:** 1.0.0
- **Purpose:** Review the increment's code, tests, and proposed decisions against project standards, security checklist, AC coverage, and declared dependencies. Append standards observations. Separate mechanically-verified from human-judgment items. Loop with `developer` up to 3 cycles, then abandon|revise.
- **Triggers from:** `ui-test-engineer` (code-changes increment) or `business-analyst` / other doc-authoring skills (doc-only increment).
- **Inputs:**
  - `/docs/increments/NNN-<slug>/plan.md`.
  - Diff of changed files (since branch creation).
  - Proposed ADRs from this increment.
  - Coverage report (from `developer`).
  - UI regression run results (from `ui-test-engineer`).
  - SCA + secret-scan results from CI for this branch.
  - `scope.md` (for declared dependencies and AC coverage check).
  - In-scope capability specs (for AC IDs and declared classifications).
  - In-scope `.feature` files (for AC coverage).
  - Plus meta-skill §1 always-allowed (which includes coding/testing/naming standards).
- **Outputs:**
  - `/docs/increments/NNN-<slug>/review.md` (from `templates/increment-review.md`) — verdict (approve / changes requested), checklist with **mechanically-verified** and **needs human confirmation** sections explicitly separated.
  - Appends one-liners to `/docs/phases/NN-<slug>/standards-observations.md` (per `templates/standards-observations.md`) for every standards-related issue surfaced (blocking or not).
- **Hands off to:**
  - On approval → `increment-close`.
  - On rejection (cycle <3) → `developer` (or relevant authoring skill in doc-only mode).
  - On 3rd rejection → halt for human; two paths only: `abandon` (status → abandoned) or `revise scope` (open corrective increment per workflow.md §10).
- **Inherits:** Meta-skill.
- **Utility sub-skill:** no.

## Skill-specific halt triggers

- T-TR-1: 3rd rejection — retry budget exhausted.
- T-TR-2: A proposed ADR conflicts with an accepted ADR not flagged superseded.
- T-TR-3: Coverage report unparseable.
- T-TR-4: Test or code references doc artifact that doesn't exist or is `deprecated` / `superseded-by-increment` / `withdrawn`.
- T-TR-5: SCA reports high/critical CVE on a new or upgraded dependency — surface for human direction (route through hotfix or regular increment per CVE rule, workflow.md §10).
- T-TR-6: Secret scanner reports a leaked secret on this branch.

## Process

### Code-changes mode (`scope.md` `code-changes: yes`)

1. **Verify inputs.** Coverage, regression, SCA, secret-scan, diff, plan all retrievable.

2. **Standards review.** Diff vs. `coding-standards.md` (style, module structure, naming, patterns).

3. **Coverage review.**
   - Baseline ≥80% on changed code paths.
   - **`@security-critical` paths: 100% line + branch on input-validation and error paths.**
   - Verify any exemptions are pre-declared in plan and conform to exemption taxonomy.

4. **Plan alignment.**
   - Every task in `plan.md` resulted in corresponding code changes.
   - No code changes beyond the plan (scope creep).
   - Every proposed ADR has been exercised, withdrawn, or superseded by code.

5. **ADR coherence.**
   - No proposed ADR contradicts an accepted ADR not marked superseded.
   - Tech-stack changes flagged for `increment-close` to record.
   - Withdrawn ADRs are not referenced in code or other accepted ADRs.

6. **Regression.** `ui-test-engineer`'s regression clean; otherwise reject.

7. **Doc-artifact existence.** Every artifact referenced in code comments or tests exists and is current (not deprecated/superseded/withdrawn). Halt T-TR-4 otherwise.

8. **Security checklist (mechanical):**
   - Secrets-in-code grep (no API keys, no passwords, no tokens). Halt T-TR-6 if scanner flagged.
   - Logging-hygiene grep (no PII fields per known patterns, no authz tokens).
   - **Input validation present at trust boundaries** (per Threat considerations and `@security-critical` paths).
   - SCA results clean for new/upgraded deps; halt T-TR-5 on high/critical CVE.
   - Dep-introducing ADRs have populated `Supply chain notes`.

9. **AC coverage check.** Every AC ID in scope has at least one referencing `.feature` scenario (via `# AC: AC-N`); every `# AC:` reference points to an existing AC. Surface gaps.

10. **Dependency-trace check (implicit-dep detection):** Walk developer's step-summary `Grounded in:` lists. For each doc cited, trace to its source increment (via decision-record metadata, source-increment tags). Any doc traced to an increment not in `scope.md`'s declared deps is surfaced as an implicit dependency — likely needs `@depends:inc-NNN` declaration.

11. **Standards observations append.** For any standards-related issue surfaced (whether blocking or not), append one-liner to `standards-observations.md`:
    ```
    [timestamp] [technical-reviewer] [inc-NNN] [category] one-line description
    ```

12. **Verdict + structured `review.md`** (per `templates/increment-review.md`):
    
    **Mechanically verified:**
    - Coding standards compliance
    - Coverage (baseline + security-critical)
    - Plan alignment
    - Regression
    - Doc-artifact existence
    - Secrets grep, logging-hygiene grep
    - SCA, secret-scanner results
    - AC coverage (every AC has a scenario; every reference resolves)
    - Dependency trace (declared deps cover what was used)
    
    **Needs human confirmation (carried to Gate 5):**
    - Threat-considerations answers reviewed for adequacy
    - Authn/Authz declaration confirmed correct
    - Security-critical classification correct
    - Scope-vs-intent alignment (did the work actually deliver the capability's intent)

13. **Retry handling.**
    - Approve: hand off to `increment-close`.
    - Reject: items must be specific, actionable, tied to file/line where possible. Loop to `developer`. Increment cycle counter in `review.md`.
    - 3rd rejection: halt T-TR-1 with full history. Surface to human with the two paths: `abandon` or `revise scope` (corrective increment).

### Doc-only mode (`scope.md` `code-changes: none`)

- Skip steps 3, 6, parts of 8 that depend on code (secrets grep on docs is still valid; coverage/SCA/secret-scanner-on-code skipped).
- Standards observations still appended.
- AC coverage check still applies if scope touched capabilities.
- Verdict structure same: mechanically-verified + needs-human-confirmation sections, scoped to what actually changed.

## Notes

- Mechanical-vs-human separation in `review.md` is the meta-skill §11 discipline made concrete. Carried forward into Gate 5 PR checklist by `increment-close`.
- The dependency-trace check is partially mechanical (when decision records have source-increment metadata) and partially human (semantic code reading is out of scope). It catches the common case of using a prior increment's component without declaring `@depends:`.
- Standards observations are a per-increment capture; `phase-close` synthesizes them.
- Three-cycle retry budget is the workflow's commitment to bounded iteration. Beyond it, the increment is structurally wrong and needs scope revision (corrective increment) or abandonment.
