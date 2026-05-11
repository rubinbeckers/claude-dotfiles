# Capability: <name>

**Status:** active | deprecated | superseded-by-increment: inc-NNN | withdrawn
**Tags:** `@<area>` `@<criticality>` `<other tags from vocabulary>`
**Last-modified-by:** inc-NNN

## Intent

One-paragraph statement of what this capability enables. Phrased from the user/system perspective. No implementation.

## Actors

- Primary: <who initiates>
- Secondary: <who participates / who is affected>

## Data classification

`public` | `internal` | `confidential` | `restricted`

(See `/docs/business/domain/<context>/<aggregate>.md` for the aggregates touched and their classifications. The capability inherits the strictest classification among its data.)

## Authn required

`yes — <type, e.g., session token, API key, OAuth2>` | `no`

## Authz model

Who can invoke this capability, under what conditions. Be specific:
- Role(s)
- Resource ownership rules (e.g., "user can only access their own orders")
- Other constraints

If `authn required: no`, this section may state "open" with a one-line justification.

## Threat considerations

**Triggered when Data classification > public OR a trust boundary is crossed.**

These are **questions for the human to answer**, not threats the agent identified. The agent surfaces the standard prompts; the human's answers (and any answers' implications for design) become part of this section before Gate 1 / Gate 4 approval.

- What trust boundaries does this capability cross?
- What data flows in and out, and where?
- What's the worst-case scenario if this capability is abused?
- Who is the threat actor (insider, anonymous external, authenticated external)?
- What logging / audit trail is required for security-relevant events here?
- Are there compliance constraints (e.g., GDPR right-to-be-forgotten, audit logging, data residency)?

If classification ≤ internal AND no trust boundary crossing, this section may be marked "Not applicable" — but the data classification justification must be explicit.

## Acceptance criteria

Each criterion has a stable ID for referencing from scenarios and tests.

- **AC-1:** <criterion>
- **AC-2:** <criterion>
- ...

## Non-functional requirements

- **Performance:** <e.g., p95 latency, throughput>
- **Reliability:** <e.g., availability targets>
- **Security:** <additional security NFRs beyond the structured fields above; e.g., encryption at rest, specific compliance requirements>
- **Usability:** <accessibility, error messages, latency to user feedback>
- **Other:** <as needed>

## Out of scope

- <explicit list of related-but-not-included things>

## References

- Aggregates: `/docs/business/domain/<context>/<aggregate>.md`
- Related capabilities: <list>
- Related ADRs: <list, by ID>
- Scenarios: `/features/<this-capability>.feature`
