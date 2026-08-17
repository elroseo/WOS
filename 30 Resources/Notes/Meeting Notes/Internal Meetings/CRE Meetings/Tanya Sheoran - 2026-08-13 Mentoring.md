# Tanya Sheoran - Mentoring - 2026-08-13

**Date:** August 13, 2026
**Time:** 2:00 PM to 3:00 PM ET
**Subject:** Ellie/Tanya
**Role:** Customer Reliability Engineer III

## Goals

- Learn how an experienced CRE makes judgment calls that are not documented.
- Leave with practical examples or artifacts I can reuse during ramp-up.

## Questions

### Escalation judgment

- How do you decide when to continue investigating versus involving engineering?
- Can you walk me through a case where the correct escalation point was not obvious?
- What evidence do you gather before escalating?

### Account risk detection

- Which signals tell you an account is drifting before it appears in tickets or escalations?
- How do you separate a meaningful risk signal from normal noise?
- What do you monitor or review consistently across your accounts?

### Technical pattern recognition

- Can you walk me through an investigation that initially led you in the wrong direction?
- What changed your conclusion?
- Which troubleshooting patterns or failure modes should a new CRE learn first?

### Health Checks and technical evidence

- When you review a Health Check, which findings deserve narrative explanation rather than only a metric or status?
- Can you show me how you trace one concerning Health Check signal back to the underlying tickets, telemetry, or configuration?
- What makes a recommendation specific enough for the account team to act on?
- Which sections tend to attract avoidable review feedback, and what evidence is usually missing?

- Your Databricks Health Check had a cleaner initial review than the earlier Southern California Edison report. What changed in your final quality-assurance process between those two?

### Workflow changes and retrospectives

- When ticket ownership or routing changes, how should CRE comments, investigation context, and retrospectives be preserved?
- Which incidents deserve a full retrospective versus a brief learning note?
- Can I shadow the next retrospective, ticket review, or Health Check you conduct?

### Technical practice

- Could we choose one sanitized past investigation and have me build the timeline and hypotheses before you show me the conclusion?
- Which GHES support-bundle logs or GHEC telemetry sources should I learn first, and why?
- What is one technical signal you initially trusted too much, or not enough, when you were newer to the role?

### Organization, note-taking, and resource finding

Melanie recommended learning from Tanya's organization and note-taking practices.

- Could you show me how you organize account context, investigation notes, meeting notes, and follow-up tasks?
- What information do you capture during an investigation, and what do you deliberately leave out?
- How do you make notes reusable without spending too much time maintaining them?
- How do you connect notes back to tickets, accounts, queries, and action items so context is easy to recover later?
- When you encounter an unfamiliar product, symptom, or system, where do you look first?
- What sequence do you usually follow across documentation, internal search, Slack, repository history, telemetry, and asking another person?
- How do you decide that you have searched enough and should ask for help?
- Could you share one example where finding the right owner or resource changed the direction of an investigation?

## Practical follow-ups

- [ ] Ask for one checklist, saved query, or example investigation to study.
- [ ] Identify an investigation or customer meeting I can shadow.
- [ ] Choose one skill to practice before the next mentoring session.

## Notes
### Source

- [Teams meeting recap](https://teams.microsoft.com/l/meetingrecap?driveId=b%21d5EqXu7ubEWVzhGN0rA-oizg-oydu3JEht1BSPvwShzNmMMVIyzeSaJgwpmQZAmB&driveItemId=01Q72VVLJW35336SBJZJFYKU52JZJFYKU52JLPGBQWT&threadId=19%3Ameeting_MGZjNGMwM2QtZGIzNy00NTNkLWIyOGQtZGRkMjRiMzAyYTNj%40thread.v2&iCalUid=040000008200E00074C5B7101A82E00800000000D9824BE47A2ADD01000000000000000010000000D1BA0CA84FE8574CACD76374E607D009)
- The meeting was transcribed. These notes use the available transcript excerpt, which may not cover every part of the conversation.

### Distinguishing noise from risk

- Repeated operational notices are not automatically meaningful risk.
- Focus on whether the customer has an execution blocker, active technical failure, unsupported configuration, or material customer impact.
- Upgrade delay alone may be normal noise. Risk increases when the customer encounters blockers, operates outside support, or lacks a credible execution plan.

### Customer and Support boundaries

- Support calls should primarily gather evidence and clarify the problem.
- Do not create an expectation that Support Engineering will conduct extended live debugging for the customer.
- Technical troubleshooting should normally continue offline after the required data is collected.
- Clear boundaries may need to be repeated consistently before expectations change.

### Proactive account monitoring

- Tanya uses saved queries and alerts to prevent recurring incidents rather than relying only on manual review.
- The demonstrated workflow was: run the query, validate the result, save it as an alert, set cadence and thresholds, then deliver actionable results to Slack.
- Useful recurring account signals include primary and secondary API rate limits, rate-limit increase requests, upgrade readiness, and major infrastructure changes.
- Alert thresholds must be based on a validated signal and customer context, not copied blindly from another account.

### Finding unfamiliar information and owners

- Start with the technical evidence, particularly the API route or component surfaced by the query.
- Use that evidence to identify the likely engineering owner or Slack channel.
- Do not assume the first suggested owner is correct. Follow redirects until the responsible team is confirmed.
- Ownership discovery is more reliable when driven by routes and system evidence than by broad product names.

### Technical walkthrough

- Tanya demonstrated a secondary rate-limit investigation using recent 403 responses.
- The route in the query output provided the pivot for identifying engineering ownership.
- She demonstrated turning a validated query into a recurring alert with Slack delivery.
- The example threshold and cadence were specific to the demonstrated use case and are not universal defaults.

### Growth and hands-on learning

- I want to move from passive observation toward active participation in account and ticket work.
- Ticket work provides practical exposure to customer context, investigation flow, ownership boundaries, and escalation decisions.
- The next useful step is to reproduce a known investigation workflow and explain the evidence chain, not only run the query.


### Key findings from transcript review

- Escalation should be evidence-first. Customer urgency alone does not make an engineering escalation actionable.
- Investigate broadly enough to avoid confirmation bias. Check related errors, request IDs, routes, traffic patterns, historical incidents, and alternative explanations before concluding root cause.
- Reusable investigations can become proactive monitoring. Validate a Splunk search first, then consider saving it as an account-specific alert with an owner, cadence, threshold, and response.
- Ownership discovery may require parallel outreach to multiple plausible teams or subject-matter experts until the responsible component is confirmed.
- Request IDs, API routes, traffic patterns, and rate-limit indicators are strong escalation artifacts.
- Use existing resources before escalating: LLM Assist, prior tickets, Support Knowledge Base guidance, Slack discussions, public search, and recognized subject-matter experts.
- Account risk can appear before a ticket through repeated upgrade delays, unsupported versions, execution blockers, major infrastructure changes, and weak operational readiness.
- Support calls are primarily for clarifying impact and gathering evidence. Deeper troubleshooting generally continues offline.

### Transcript-derived follow-up discussed

- Tanya planned to continue investigating the Anthropic merged-batch push failures with broader Splunk searches and historical incidents.
- If the evidence supports an infrastructure problem, document the findings and escalate with the evidence chain.
- Review the investigation results and engineering issue approach together afterward.

## Action items
- [ ] Reproduce the secondary rate-limit investigation workflow with a safe practice example.
- [ ] Learn how to create, validate, and manage a query-based operational alert.
- [ ] Practice identifying an engineering owner from an API route before asking broadly in Slack.
- [ ] Pursue hands-on ticket or account work where I can own part of the evidence gathering.
- [ ] Ask Tanya for a follow-up walkthrough from alert detection through customer action or resolution.