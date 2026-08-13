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

- 

## Action items

- [ ] Capture one investigation artifact or exercise to study.
- [ ] Arrange one technical shadowing opportunity.
- [ ] Choose one failure pattern to document in `CRE-Learning/Investigations/`.
