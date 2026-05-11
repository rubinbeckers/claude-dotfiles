# increment-close

- **Name:** increment-close
- **Version:** 1.0.0
- **Purpose:** Close the increment: invoke `doc-integrity` (utility sub-skill carve-out), assign final numbers to increment-level decision records, write corrective back-references where applicable, finalize indices, consolidate changelog, push branch, prepare PR with mechanical-vs-human-separated checklist.
- **Triggers from:** `technical-reviewer` (on approval).
- **Inputs:**
  - `/docs/increments/NNN-<slug>/` (full folder).
  - All doc diffs since branch creation.
  - All increment-level decision records with TBD placeholders.
  - `/docs/increments/INDEX.md` plus all other indices that may need status updates.
  - Plus meta-skill §1 always-allowed.
- **Outputs:**
  - Invokes `doc-integrity` (utility sub-skill, meta-skill §10) with scope = current increment.
  - **Final-numbered increment-level decision records** (registering-skill rule, meta-skill §7) — TBD-NNNN-* renamed to actual sequential numbers, with INDEX rows added.
  - **Corrective back-references:** if `scope.md` declares `@corrects:inc-NNN`, the corrected artifacts (capabilities, components, aggregates, etc., as named in the corrective ADR/CDR) have their status fields updated to `superseded-by-increment: inc-MMM`, where inc-MMM is the current corrective increment. Forward link on this increment's changelog references inc-NNN; back link on the corrected artifacts references inc-MMM. `doc-integrity` validates bidirectionality.
  - `/docs/increments/NNN-<slug>/changelog.md` (from `templates/increment-changelog.md`).
  - INDEX updates: `capabilities/INDEX.md`, `architecture/INDEX.md` (proposed → accepted; superseded marked), `components/INDEX.md`, `tech-stack.md`, `increments/INDEX.md`.
  - Pushed branch.
  - PR opened against `main` with generated summary and explicit checklist (mechanically-verified vs. needs-human-confirmation sections).
- **Hands off to:** Human at Gate 5 (PR merge). After merge → next session's `session-resume` routes to next step.
- **Inherits:** Meta-skill.
- **Utility sub-skill:** no.

## Skill-specific halt triggers

- T-IC-1: `doc-integrity` reports unresolvable issues.
- T-IC-2: Decision record with TBD number cannot be assigned a unique final number (collision in INDEX).
- T-IC-3: Push to remote fails (auth, branch protection, network).
- T-IC-4: PR creation fails.
- T-IC-5: Corrective increment declared but corrected artifact lookup fails (the CDR/ADR identifying defect points to an artifact that doesn't match any current capability/component/aggregate).

## Process

1. **Invoke `doc-integrity` (utility sub-skill).** Scope = this increment's changed docs. Cite meta-skill §10 carve-out in the invocation. Auto-fix what's trivially fixable; surface what isn't (halt T-IC-1 on unresolvable).

2. **Assign final decision-record numbers.** For each `*-TBD-*.md` in this increment (TBD-numbered drafts produced by `business-analyst`, `functional-specifier`, `implementation-planner`, `developer`):
   - Scan target INDEX for highest existing number.
   - Increment, rename file (e.g., `ADR-TBD-redis-cache.md` → `ADR-0014-redis-cache.md`).
   - Update all references to TBD form throughout codebase and docs.
   - Add row to corresponding INDEX with status (`accepted` for proposed→accepted-pending-review path; `withdrawn` retained as terminal; `superseded` if applicable with bidirectional links).

3. **Corrective back-references.** If `scope.md` declares `@corrects:inc-NNN`:
   - Read the corrective CDR/ADR for the list of corrected artifacts.
   - For each, update its status field to include `superseded-by-increment: inc-MMM` (where inc-MMM is this increment).
   - The corrected artifact's spec file is preserved (append-only at the artifact level); only its status/INDEX row updates.
   - Halt T-IC-5 if any named artifact can't be located.

4. **Update INDEX files:**
   - `capabilities/INDEX.md` — in-scope capabilities → `delivered`, or `superseded-by-increment` for corrective scenarios.
   - `architecture/INDEX.md` — ADRs `accepted-pending-review` → `accepted`; `withdrawn` retained as terminal; supersession bidirectional.
   - `components/INDEX.md` — proposed → active; modified rows updated.
   - `tech-stack.md` — new entries for stack changes, linked to their ADR.
   - `increments/INDEX.md` — this increment → `delivered`.

5. **Generate `changelog.md`** from `templates/increment-changelog.md`. Sections:
   - Capabilities delivered.
   - Scenarios added.
   - Decision records introduced (with final numbers).
   - Decision records superseded / withdrawn.
   - Components added / modified / deprecated.
   - Tech stack changes.
   - Files touched (high-level summary).
   - Quality metrics (coverage, regression, security checklist status, AC coverage).
   - If corrective: explicit "Corrects inc-NNN" section linking the defects addressed.

6. **Commit doc updates** with message: `chore(close): finalize increment NNN-<slug>`.

7. **Push to remote.** `git push -u origin increment/NNN-<slug>` (halt T-IC-3 on failure).

8. **Open PR** against `main` (halt T-IC-4 on failure). Title: `Increment NNN: <slug>`. Body:
   - `changelog.md` content.
   - Link to `review.md`.
   - The mechanical-vs-human-separated checklist (below).

9. **Surface human checklist** (Gate 5):

   ```
   ## 🔔 Gate 5 — Increment Close
   
   ### Verified mechanically (review.md confirms)
   - ✅ Coding standards
   - ✅ Coverage targets (baseline + security-critical)
   - ✅ Plan alignment, no scope creep
   - ✅ Regression clean
   - ✅ Doc-integrity clean
   - ✅ Cross-references resolved
   - ✅ AC coverage complete (every AC has a scenario; every reference resolves)
   - ✅ Dependency trace (declared deps cover what was used)
   - ✅ Secrets grep, logging-hygiene grep
   - ✅ SCA results, secret-scanner results
   - ✅ All decision records numbered, indices updated
   - ✅ Bidirectional supersession links written (if corrective)
   
   ### Needs your confirmation
   - [ ] Threat-considerations answers reviewed for adequacy
   - [ ] Authn/Authz declaration confirmed correct
   - [ ] Security-critical classification correct
   - [ ] Scope-vs-intent alignment (does the work deliver the capability's intent?)
   - [ ] CI status green on the open PR (tests + SCA + secret scan)
   - [ ] Merge PR into main via VCS
   - [ ] Confirm remote branch deletion (auto-configured in VCS, typically)
   ```

10. **Step summary** with grounded sources and the checklist.

11. **Status** = `awaiting approval` (Gate 5). The next session's `session-resume` detects the merge and routes to next step (next increment, or phase-close).

## Notes

- This skill is the boundary where the agent's reach ends. The merge is human (workflow.md §10). Everything after is detected on next `session-resume`.
- The mechanical-vs-human checklist split is critical — without it, the human skims a long review.md and trusts the agent did all of it. The split forces explicit human attention on the items that needed it.
- Number assignment here is the registering-skill action for all increment-level decisions. Phase-level decisions are already numbered (by `phase-intake`).
- Corrective back-reference writing is the bidirectional-supersession discipline at the increment level. `doc-integrity` validates the bidirectionality is intact.
