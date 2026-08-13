# Meeting with Carlos Naranjo - 2026-08-13

**Time:** 4:05 PM to 4:50 PM ET
**Subject:** Ellie / Carlos - CRE related topics
**Role:** Senior Customer Reliability Engineer

## Goals

- Learn how Carlos narrows a technical investigation before escalating.
- Identify one real investigation or customer activity I can shadow.
- Leave with a practical technical exercise or artifact to study.

## Focus questions

### Technical triage

- When a customer reports a broad symptom such as slowness or intermittent failures, what are your first three technical pivots?
- How do you distinguish a GitHub platform defect, customer configuration issue, and customer operational problem early in an investigation?
- Which recurring GitHub Enterprise Server and GitHub Enterprise Cloud failure patterns should I learn first?
- What evidence most effectively changes an engineering escalation from "needs more information" to actionable?

### Building an evidence chain

- Can you walk me through a case from symptom, to hypothesis, to query or log evidence, to conclusion?
- How do you validate that a correlation in Kusto, Splunk, or a support bundle is causal rather than coincidental?
- What row counts, samples, baselines, or cross-checks do you expect before trusting a result?
- Which investigation mistake creates the most rework for newer CREs?

### Health Checks and account risk

- Which Health Check findings most reliably predict future customer impact?
- How do you convert telemetry into a recommendation with a clear owner and next action?
- What makes a Health Check concise without omitting the evidence needed for review?
- Your Intel Health Checks received cleaner reviews than some later reports. Which preparation step made the difference, and could it become a reusable pre-review checklist?

### Practical learning and shadowing

- Could I shadow a live bundle investigation, account Health Check, or engineering escalation?
- Is there a sanitized support bundle or past investigation I could analyze independently and compare with your approach?
- Which saved query, runbook, or dashboard should I become fluent with first?
- Who has a technical specialty that would complement what I can learn from you?

## Notes

### Escalation judgment

- Carlos described the decision to keep investigating or involve engineering as situational rather than a strict rule.
- A useful general heuristic from his onboarding is to escalate when an investigation is likely to require more than a couple of hours.
- For an urgent or high-priority ticket, if about 30 minutes of investigation plus consultation with colleagues produces no direction, involve engineering rather than continuing without a clear path.
- Non-blocking escalations may move more slowly. Set expectations based on customer impact and urgency.

### Evidence and investigation workflow

- Evidence requirements depend on the product and environment. GitHub Enterprise Server and GitHub Enterprise Cloud investigations need different evidence, so a universal checklist is unlikely to be sufficient.
- Capture detailed investigation notes throughout the case, including what was observed, what was tried, and what changed.
- Gather customer activity evidence from Splunk when possible before escalating.
- Treat the request ID as a primary troubleshooting pivot. It can trace a transaction across services and components.
- Search relevant Support Knowledge Base articles for proven queries and troubleshooting steps.
- Search historical Zendesk tickets using the exact error message in quotation marks.

### Caution from a recent case

- Carlos described a case where a repository appeared read-only in an internal interface, initially suggesting an infrastructure issue.
- Engineering clarified that the interface did not reliably represent the actual state. The issue was ultimately routed to the pull requests team.
- Key lesson: validate UI indicators with another source before using them to assign ownership or conclude root cause.

## Key findings and best practices

- Use escalation thresholds as heuristics, not rigid policy.
- Escalate sooner when urgency is high, progress has stalled, and peers cannot identify a next step.
- Build an evidence chain around impact, timestamps, request IDs, exact errors, customer activity, and actions already attempted.
- Validate interface-derived conclusions against logs, telemetry, or another authoritative source.
- Keep chronological notes detailed enough for another investigator or engineering team to continue without repeating work.
- Use existing knowledge and precedent before starting from scratch: Support Knowledge Base guidance, saved queries, colleagues, and exact-error Zendesk searches.


- Consult on-shift peers after the initial investigation when the next step is unclear; peer consultation can either unblock the work or strengthen the case for escalation.
- Structure an escalation with the customer's evidence first, followed by Support's research, request IDs, findings, and a clear question or requested action for engineering.

## Decisions

- No new team decision or formal policy was established. Carlos shared practical heuristics and examples from his experience.

## Action items

- [ ] Use the urgent-ticket heuristic in future triage: investigate, consult available colleagues, then escalate if there is still no direction after about 30 minutes.
- [ ] Capture request ID, exact error text, impact, timestamp, customer actions, and attempted troubleshooting before escalation when available.
- [ ] Add chronological investigation notes as evidence is gathered, not only at case closure.
- [ ] Validate UI or staff-tool state against another data source before assigning root cause or ownership.
- [ ] Review Carlos's evidence-gathering documentation if he publishes it.

## Related

- [[Investigation and Escalation Judgment]]
- [[1-1 Prep - Learning and Growth Areas]]
- [[Splunk Cheatsheet]]
