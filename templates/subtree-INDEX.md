# Subtree INDEX template

Per workflow.md §15.8, every significant permanent-doc subtree has an `INDEX.md` listing its entries with just enough meta-information for the orchestrator to filter during manifest construction. This template covers `capabilities/INDEX.md`, `aggregates/INDEX.md`, `features/INDEX.md`, `flows/INDEX.md`, `architecture/components/INDEX.md`, and the per-decision-record-type INDEXes.

```markdown
# INDEX: <subtree-name>

Owner: <role per workflow.md §2>
Last updated: <ISO or inc-slug>

## Entries

- id: <slug-or-id>
  title: <human-readable, ≤80 chars>
  status: proposed | accepted | superseded | deprecated | withdrawn
  tags: [<@tag>, ...]
  brief: <one-line description, ≤120 chars>
  refs: [<related entry ids — bidirectional where applicable>]
  last_modified: <inc-slug or ISO>

- id: <next>
  ...
```

## Conventions

- **Append-or-amend.** Adding a new entry: append. Modifying status/refs/etc.: amend the relevant fields. Wholesale rewriting an INDEX is forbidden (would erase ordering and audit trail).
- **Same-step updates.** The skill that writes a permanent doc updates the corresponding INDEX in the same step. INDEX drift from the underlying docs is a workflow defect — `doc-integrity` validates them in sync.
- **Minimal meta.** INDEX entries carry only what's useful for manifest selection. Full content lives in the entry's own file. Don't duplicate large content into INDEX.
- **Ordering.** Numeric records (CDR-007, ADR-014) order by number. Slugged records (capabilities, features, flows) order by status (accepted before superseded/deprecated), then alphabetical within status.
- **Refs are bidirectional.** If entry A's `refs:` lists entry B, entry B's `refs:` should list entry A. `doc-integrity` validates the symmetry.

## Example: capabilities/INDEX.md

```markdown
# INDEX: capabilities

Owner: BA
Last updated: inc-026

## Entries

- id: cap-007-invoicing
  title: Generate and deliver invoices for completed assessments
  status: accepted
  tags: [@billing, @critical]
  brief: Stakeholder-visible invoicing capability; payment integrations are scoped out
  refs: [agg-003-invoice, agg-005-payment-method, ADR-014-currency-handling]
  last_modified: inc-022

- id: cap-008-author-team-report
  title: Assessor authors and saves team assessment reports
  status: accepted
  tags: [@assessment, @crud, @high]
  brief: Core authoring flow for team reports; draft and published states
  refs: [agg-006-team-report, FDR-009-tab-structure, flow-create-report, flow-edit-report]
  last_modified: inc-026
```

## Example: flows/INDEX.md

```markdown
# INDEX: flows

Owner: FA
Last updated: inc-026

## Entries

- id: create-report
  title: Assessor creates a new team assessment report
  status: accepted
  tags: [@crud, @assessment, @important]
  brief: Happy path + 4 error paths; ConfirmDialog and slug-derivation behavior
  capability: cap-008-author-team-report
  surfaces: [teams, report-editor, confirm-dialog, team-detail]
  last_modified: inc-026
```
