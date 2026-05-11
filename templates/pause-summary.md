# Project Pause Summary

**Paused at:** <ISO timestamp>
**Paused by:** <human / orchestrator>

## Context

- **Active phase:** <NN-slug> [<status>]
- **Active increment:** <NNN-slug | none>
- **Last skill invoked:** <skill-name> @ <timestamp>
- **Last gate hit:** <Gate N | none>
- **Last halt (if any):** <trigger-id | none> — <description>

## Open items

*(Anything in `awaiting approval`, unresolved halts, TBD-numbered decision records, etc.)*

- <item> at <path>
- ...

## Working tree state

- **Branch:** <current branch>
- **Clean:** yes | no
- **Uncommitted changes:** <list of files | none>

## Next planned step on resume

*(Determined by simulating `session-resume`'s routing.)*

- Route: → <skill-name | human action>
- Reason: <one-line>

## Notes

*(Free-form. Human may add context for future-self.)*

---

To resume:
1. Run `session-resume` at next session start.
2. It will detect this summary and surface it.
3. Confirm whether to clear the pause (proceed to the next planned step) or stay paused.
4. To clear: delete or rename this file. Next `session-resume` will route normally.
