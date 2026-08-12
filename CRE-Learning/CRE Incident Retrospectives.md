# CRE Incident Retrospectives

A CRE retrospective is a structured, blameless review of a customer-impacting incident or difficult support engagement. The goal is to improve future detection, investigation, communication, escalation, and prevention.

## When to run one

- Major or prolonged customer impact
- Confusing ownership or delayed escalation
- Failed GitHub Enterprise Server (GHES) upgrade or change
- Repeated incidents with the same pattern
- Near miss that exposed a process gap
- Support case where communication, tooling, or documentation failed

Routine incidents usually need only brief notes and action items.

## Incident retro versus ticket retro

**Incident retrospective:** Reviews the complete event, including impact, detection, technical response, coordination, communication, recovery, and prevention.

**Ticket retrospective:** Reviews how a specific support case was handled, why it followed that path, and what Support or CRE should reuse or change.

## Core questions

1. What happened?
2. What was the customer impact?
3. Which technical and process factors contributed?
4. What worked well during the response?
5. Where did we lose time or context?
6. What should change before the next incident?

## Suggested 45-minute agenda

### Set the tone, 3 minutes

> This is a blameless review. We are examining the conditions, information, and systems that shaped the response, not judging individuals.

### Confirm impact, 5 minutes

- What could the customer not do?
- When did impact begin and end?
- How was recovery confirmed?
- Is any residual risk present?

### Review the timeline, 10 minutes

Record:

- First symptom
- Detection
- Customer report
- Initial hypotheses
- Important evidence
- Escalation points
- Mitigation
- Recovery
- Final verification

Keep facts separate from assumptions made during the incident.

### Discuss contributing factors, 10 minutes

- What made diagnosis harder?
- What information was missing?
- Which signals were misleading?
- Were ownership and escalation boundaries clear?
- Did documentation or tooling help?
- Which customer-side and GitHub-side hypotheses were considered?

### Review the response, 7 minutes

- What worked well and should be repeated?
- Where did we lose time?
- Was the customer updated at the right cadence?
- Did handoffs preserve context?
- Did the customer understand the status and next step?

### Assign actions, 10 minutes

Each action needs:

- One owner
- A specific outcome
- A due date
- A way to verify completion

**Good:** Add the authentication failure signature and validation query to the GHES upgrade runbook by August 21.

**Weak:** Improve documentation.

## CRE-specific review areas

- **Customer trust:** Did communication reduce uncertainty?
- **Account context:** Did we understand the architecture and business impact?
- **Escalation judgment:** Did the right teams engage at the right time?
- **Investigation quality:** Did evidence drive conclusions?
- **Knowledge reuse:** Should this produce a saved query, runbook update, health signal, or support guidance?
- **Prevention:** Could monitoring or an earlier customer conversation have exposed the risk?

## Anti-patterns

- Turning the meeting into a status recap
- Blaming the person who made the final change
- Writing a timeline without examining decisions
- Selecting a convenient cause without considering alternatives
- Creating many vague actions with no owner
- Sharing internal speculation as confirmed customer-facing fact
- Treating human error as a root cause instead of asking why the system allowed it

## Reusable template

### Summary

- 

### Customer impact

- 

### Timeline

| Time | Event | Evidence or decision |
| ---- | ----- | -------------------- |
|      |       |                      |

### What worked well

- 

### Contributing factors

- 

### Alternative hypotheses considered

- 

### Response and communication gaps

- 

### Lessons to reuse

- 

### Action items

- [ ] Action, owner, due date, verification method
