# Investigation and Escalation Judgment

Reusable lessons from the August 14, 2026 mentoring session with Carlos Naranjo.

## Treat escalation thresholds as heuristics

Escalation decisions depend on urgency, customer impact, available evidence, and whether the investigation has a credible next step.

- If an investigation is likely to require more than a couple of hours, consider involving engineering.
- For urgent or high-priority cases, investigate for roughly 30 minutes and consult available colleagues. If there is still no direction, escalate rather than continuing without a clear path.
- A non-blocking escalation may follow a slower path. Communicate expectations according to impact and urgency.

These thresholds are practical guidance from Carlos's experience, not formal policy.

## Build an actionable evidence chain

Before escalating, collect the evidence available for the product and environment:

- Customer impact and urgency
- Exact timestamp and time zone
- Request ID or another correlation identifier
- Exact error message
- Customer actions leading to the symptom
- Relevant activity from Splunk or the appropriate diagnostic source
- Troubleshooting already attempted and its result
- Current hypothesis and plausible alternatives
- Why engineering involvement is needed

GitHub Enterprise Server and GitHub Enterprise Cloud require different evidence. Adapt the collection plan rather than forcing every investigation through one universal checklist.

## Use strong research pivots

1. Start with the request ID when one is available. It is often the strongest pivot for tracing a request across services and components.
2. Search Support Knowledge Base articles for known investigation steps and proven queries.
3. Search Zendesk for the exact error message in quotation marks to find prior cases.
4. Ask colleagues on shift when the evidence does not suggest a clear next step.
5. Preserve useful queries, ownership discoveries, and failure patterns for the next investigation.

## Validate signals before concluding

An interface or staff-tool indicator may not represent the underlying state accurately. Before assigning ownership or concluding root cause:

- Confirm the signal with logs, telemetry, or another authoritative source.
- Check whether the interface has known limitations.
- Keep at least one alternative explanation active until evidence rules it out.
- Route by the validated failing component, not the first visible symptom.

## Keep investigation notes continuously

Record notes as the case develops:

- What was observed
- What was checked
- What changed
- What was ruled out
- Who was consulted
- What the next investigator should do

Chronological notes reduce duplicated work and make an escalation easier for engineering to act on.

## Practical escalation check

Before submitting an escalation, confirm:

- [ ] Customer impact and urgency are clear.
- [ ] The relevant platform and environment are identified.
- [ ] Timestamps, request IDs, and exact errors are included when available.
- [ ] Investigation steps and results are documented.
- [ ] UI-derived conclusions have been validated against another source.
- [ ] Known guidance and similar tickets were checked.
- [ ] The engineering question or requested action is explicit.
- [ ] Alternative explanations are recorded.

## Related

- [[Carlos Naranjo - 2026-08-14]]
- [[Splunk Cheatsheet]]
- [[Support Bundles Cheatsheet]]
- [[1-1 Prep - Learning and Growth Areas]]
