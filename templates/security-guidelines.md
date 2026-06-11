# Project Security Guidelines

> **Status:** project-/team-owned security layer — **mandatory** reading for every skill
> and agent (`_meta` §18). Always-allowed read (`_meta` §1).
>
> **Relationship to `owasp-guidelines.md`.** `owasp-guidelines.md` is the fixed,
> verbatim OWASP baseline (do not edit it). *This* file is where your project records its
> own security principles: rules OWASP doesn't cover, project-specific elaborations, and
> any conscious **overrides** of the baseline for this project's context.
>
> **Precedence (`_meta` §18).** Where this file is silent, the OWASP baseline governs.
> Where this file makes a stricter rule, the stricter rule governs. Where this file
> explicitly overrides a baseline item, it must (a) name the OWASP section/item it
> overrides, (b) state the rationale, and (c) be recorded as an ADR. Agents never assume
> an override — only an entry in the "Overrides" section below counts as one.
>
> **Ownership.** Human-owned, like `design.md`. Agents read it and work against it; they
> never edit it except to surface a proposed addition as an observation. `project-init`
> ships this file as an empty scaffold — populate it before the first phase touches
> security-relevant code.
>
> **How to use this scaffold.** Fill in the sections below. Delete the `_(none yet …)_`
> placeholders as you add real content. Keep each rule atomic and testable so the review
> agent can verdict against it. Empty sections are fine on day one; the first phase that
> needs a rule adds it here.

---

## 1. Scope and threat context

_What this application is, who its users are, what data classifications it handles, and
the threat model the team is designing against. This frames every rule below._

_(none yet — describe the system's trust boundaries, data classifications, and primary
threat agents.)_

## 2. Secrets and credential management

_Where secrets live, how they're injected, what's forbidden in source control, rotation
policy, approved secret stores._

_(none yet.)_

## 3. Authentication and authorization

_Project-specific auth requirements beyond the OWASP baseline: identity provider, MFA
policy, session/token lifetimes, role/permission model, service-account rules._

_(none yet.)_

## 4. Data protection and privacy

_PII/PHI/financial-data handling, encryption-at-rest requirements, retention and deletion,
regulatory obligations (GDPR, HIPAA, etc.), logging-of-sensitive-data prohibitions._

_(none yet.)_

## 5. Input handling and output encoding

_Project conventions for validation libraries, canonical encoding, sanitization helpers,
and the contexts (HTML, SQL, shell, LDAP, etc.) that must use them._

_(none yet.)_

## 6. Dependencies and supply chain

_Approved-dependency policy, vulnerability-scanning gates, lockfile discipline,
license constraints, how new third-party code is vetted (ties to the ADR "Supply chain
notes" section)._

_(none yet.)_

## 7. Infrastructure, configuration, and transport

_TLS requirements, security headers, environment separation, least-privilege service
accounts, and any deployment-specific hardening this project mandates._

_(none yet.)_

## 8. Logging, monitoring, and incident response

_What security events must be logged, where, with what fields; alerting expectations; and
the path for handling a suspected incident._

_(none yet.)_

## 9. Project-specific rules (beyond OWASP)

_Anything the OWASP baseline doesn't address that is binding for this project. One atomic,
testable rule per entry._

_(none yet.)_

## 10. Overrides of the OWASP baseline

_The ONLY place a baseline item may be relaxed or replaced. Each entry must name the
overridden item, give a rationale, and reference the approving ADR. Absent an entry here,
the baseline stands._

| Overrides (OWASP section / item) | Project rule | Rationale | ADR |
| -------------------------------- | ------------ | --------- | --- |
| _(none yet)_                     |              |           |     |
