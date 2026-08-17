# Health Check Structure and Review Reference

> For repeatable technical evidence-collection steps (commands, queries, validation), see [[Health Check Runbook]] in this folder.

## Evidence reviewed

- **Window:** February 13 to August 13, 2026
- **Reports:** 122 completed Health Checks across 32 authors
- **System of record:** `github/helphub-knowledge-base/premium/health-checks/`
- **Low feedback:** Zero or one substantive question, correction, missing-evidence request, or material suggestion
- Bot comments, approvals without detail, status updates, and author self-comments were excluded.

All reports merged, so merge status alone does not demonstrate quality. A report with no comments may be polished, or it may have received weak review coverage.

## Authors with consistently minimal feedback

At least three Health Checks were required for a consistency assessment.

| Author | Reports | Average feedback | Median | Zero or one feedback item |
| ------ | ------: | ---------------: | -----: | ------------------------: |
| Thomas Cole (`thomasjohncole`) | 5 | 0.20 | 0 | 100% |
| Carlton Brown (`carltonbrown`) | 5 | 2.60 | 0 | 80% |
| Jonathan Hinds (`jrhinds`) | 4 | 1.00 | 1 | 75% |
| Reggie Montanhani (`regmontanhani`) | 4 | 1.75 | 0.5 | 75% |
| Steven Bennett (`appatalks`) | 3 | 0.67 | 0 | 67% |
| `urubos` | 6 | 4.83 | 1 | 67% |
| `darostegui` | 5 | 2.40 | 1 | 60% |
| Sharon Cole (`sharwren`) | 6 | 3.00 | 2.5 | 50% |

Do not copy a report based only on this ranking. Some zero-feedback reports lacked meaningful human review or merged despite automated concerns.

## Best reference model

**Liam Gallear (`liamgallear`)** is the strongest evidence-backed person to study even though he did not have the lowest raw comment count.

Across four reports:

- Every report received human approval.
- None received formal change requests.
- Raw support-bundle evidence was directly verified.
- Prior-period comparison was used when equivalent evidence existed.
- Counts, findings, and recommendations remained aligned.

Useful examples:

- [Tesco Health Check PR](https://github.com/github/helphub-knowledge-base/pull/1398)
- [Verification review](https://github.com/github/helphub-knowledge-base/pull/1414)
- [Tesco final report](https://github.com/github/helphub-knowledge-base/blob/main/premium/health-checks/2026/tesco-2026-06.md)

## Strong recurring patterns

### Structure

1. Short executive summary
2. Security and version posture
3. Configuration and resilience
4. Performance and capacity
5. Support or operational themes
6. Prior-period comparison when available
7. Numbered recommendations
8. Supporting public documentation

### Evidence and language

- Use exact counts, dates, versions, peaks, and affected components.
- Present evidence first, interpretation second, and action third.
- Separate healthy signals from risk signals.
- Use short risk language such as `Healthy`, `Watch`, `Higher risk`, and `Action recommended`.
- State the evidence window and data source clearly.
- Redact sensitive webhook, organization, repository, and infrastructure values.
- Link each recommendation to an observed condition.

### Useful tables

- Provisioned versus typical versus peak usage
- Current value versus recommended threshold
- Current period versus previous period
- Finding, evidence, impact, and recommendation

### Deliberate omissions

Good reports leave out:

- Raw output that does not affect the conclusion
- Every automated finding when several describe the same risk
- Unsupported severity language
- Customer-sensitive identifiers
- Generic recommendations with no observed evidence
- Repeated prose when a compact table is clearer

## Rough Health Check template

**`<Customer> Health Check - <Month Year>`**

## Scope

- **Platform:** GHES or GHEC
- **Evidence window:** `<start>` to `<end>`
- **Inputs reviewed:** `<support bundle, telemetry, tickets, configuration, previous report>`
- **Limitations:** `<missing evidence or freshness constraints>`

## Executive summary

- **Overall assessment:** `<Healthy | Watch | Action recommended>`
- `<Most important healthy signal>`
- `<Most important risk signal>`
- `<Highest-value customer action>`

## At a glance

| Area | Status | Evidence | Impact or risk | Recommended action |
| ---- | ------ | -------- | -------------- | ------------------ |
| Security and versions | | | | |
| Configuration and resilience | | | | |
| Performance and capacity | | | | |
| Support and operations | | | | |

## Security and version posture

### Healthy signals

- `<Finding with exact evidence>`

### Risks

- **Observation:** `<What was found>`
- **Evidence:** `<Count, version, date, or affected component>`
- **Why it matters:** `<Customer-relevant impact>`
- **Recommendation:** `<Specific action>`

## Configuration and resilience

Use the same observation, evidence, impact, and recommendation pattern.

## Performance and capacity

| Measure | Provisioned | Typical | Peak | Assessment |
| ------- | ----------: | ------: | ---: | ---------- |
| CPU | | | | |
| Memory | | | | |
| Storage | | | | |
| Request latency | | | | |

State units and measurement windows. Do not infer capacity risk from a peak without a baseline or sustained-duration evidence.

## Support and operational themes

- `<Recurring ticket or operational pattern>`
- `<Customer communication or process risk>`
- `<Relevant incident or retrospective lesson>`

## Change since the previous Health Check

| Finding | Previous period | Current period | Direction | Interpretation |
| ------- | --------------: | -------------: | --------- | -------------- |
| | | | | |

Omit this section only when comparable prior evidence is unavailable, and state that limitation.

## Prioritized recommendations

1. **`<Action>`**
   - **Evidence:** `<Observed condition>`
   - **Expected benefit:** `<Risk reduced or outcome improved>`
   - **Suggested owner:** `<Customer, GitHub, or joint>`
   - **Priority:** `<Now, next, monitor>`

## References

- `<Verified public GitHub Docs links>`

## Pre-review checklist

- [ ] Dates and evidence windows are correct.
- [ ] No template, placeholder, or `_deleteme_` text remains.
- [ ] Counts agree across summary, tables, and recommendations.
- [ ] Every recommendation maps to a documented observation.
- [ ] No recommendation contradicts the evidence.
- [ ] Links resolve and support the statement beside them.
- [ ] Sensitive values are removed or generalized.
- [ ] Units and thresholds are explicit.
- [ ] Healthy findings and risks are clearly separated.
- [ ] Prior-period comparison is included when comparable evidence exists.
- [ ] A second person can reproduce important findings from the cited evidence.

## People to learn from

| Person | Best shadowing topic | Why |
| ------ | -------------------- | --- |
| Liam Gallear | Bundle-to-report verification | Strong approval and evidence consistency across repeated reports |
| Simon Giesemann | Reviewer judgment | Good examples of separating must-fix findings from review nits |
| `MystaMax` | Security and vulnerability wording | Review evidence includes validating Common Vulnerabilities and Exposures severity claims |
| Sharon Cole | Template and consistency review | Repeated rapid identification of structural and consistency defects |
| Oskar Pienkos | Resolving broad review feedback | Useful example of turning extensive feedback into a clean final report |

## Questions for Tanya

- What changed in your final quality-assurance process between the Southern California Edison and Databricks Health Checks?
- Which parts of your organization and note-taking system make final Health Check review easier?
- Could I shadow your next Health Check from initial evidence gathering through review?

## Questions for Carlos

- What preparation step made the Intel Health Checks cleaner than some later reports?
- How do you reconcile counts across raw evidence, tables, summary language, and recommendations?
- Could we turn your pre-review process into a small reusable checklist?
