# Feedback-inbox template

The rolling inbox for feedback that arrives during execution — from the human, from CI, from staging review during post-merge fix cycles. `feedback-triage` runs at increment-execute cycle boundaries and at phase-close to disposition entries.

```markdown
# Feedback inbox

(Append entries here. Empty `disposition:` means untriaged.)

## Entries

### feedback-001

- timestamp: <ISO>
- source: human | ci | staging-review
- content: |
  <Free-text content of the feedback.>
- tags: [<optional tags, e.g. ui, performance>]
- references: [<artifact paths if any>]
- disposition: ""           # filled by feedback-triage
- decided_at: ""
- reasoning: ""
- proposed_action: ""

### feedback-002

...
```

Dispositions (per `feedback-triage`):
- `BACKLOG_TWEAK` — amend a sequencing entry in the active increment.
- `QUEUE_NEXT_INCREMENT` — out of scope for current increment; carry forward.
- `SOLIDIFYING_DEBT` — append to `phase-debt.md`.
- `DOMAIN_LOOPBACK` / `FUNCTIONAL_LOOPBACK` / `ARCHITECTURE_LOOPBACK` — re-pass relevant gate.
- `WORKFLOW_OBSERVATION` — surface as observation (severity per content).
- `HUMAN_CLASSIFY` — ambiguous; human decides.
