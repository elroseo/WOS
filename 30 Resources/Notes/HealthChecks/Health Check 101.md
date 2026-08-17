---
tags:
  - cre
  - health-checks
  - ghes
  - learning
updated: 2026-08-14
status: reference
---

# Health Check 101

> [!summary]
> A Customer Reliability Engineer (CRE) Health Check turns customer evidence into a concise, reviewable assessment of healthy signals, risks, and prioritized actions. The goal is not to reproduce every automated finding. The goal is to explain what matters, why it matters, and what should happen next.

## What a Health Check should answer

1. What environment and evidence period were reviewed?
2. What is healthy?
3. What needs attention?
4. Is the concerning signal isolated, sustained, or worsening?
5. What evidence supports each conclusion?
6. What action should the customer, GitHub, or both take?
7. What could not be assessed because evidence was unavailable?

## End-to-end workflow

### 1. Confirm scope

Before analysis, confirm:

- Customer and environment
- GitHub Enterprise Server (GHES) or GitHub Enterprise Cloud (GHEC)
- Production, staging, standalone, high availability, cluster, or geo-replication topology
- Evidence window and timezone
- Support bundle, telemetry, ticket, configuration, and prior-report inputs
- Whether separate environments require separate reports
- Expected delivery date and reviewer

### 2. Validate the evidence
For a GitHub Enterprise Server (GHES) bundle-based Health Check:

- Confirm the bundle belongs to the intended appliance.
- Record the GHES version, hostname, topology, bundle creation time, and capture-window length.
- Check which diagnostics and log sources are populated.
- Treat missing evidence as unavailable, not healthy.
- Avoid joining GHES appliance identifiers to GitHub.com datasets. The identifiers are independent and may collide.

#### Open the bundle directly with SSH

1. Open the bundle's ESB Tools staff page and copy its current SSH command or assigned `esbtools-azshell` hostname. Bundles can be pinned to different shell hosts, so do not assume a hostname copied from an older bundle is still correct.
2. If the staff page shows that extraction is required, start extraction there and wait until the bundle is ready.
3. From a normal terminal, run the bundle launcher:

```bash
ssh -t esbtools-azshell-1de6dd2.azure-eastus.github.net "/data/esb-tools/script/launch 203730"
```

4. Approve the FIDO security-key prompt when requested.
5. Confirm that the launched workspace shows the expected bundle ID, hostname, and GHES version before analyzing it.
6. Exit the remote bundle shell when finished.

> [!warning]
> The hostname and bundle ID above are an example. Always use the complete SSH command from the specific bundle's staff page. A stale or incorrect shell host can fail with `Connection closed by UNKNOWN port 65535` or a banner-exchange timeout.

#### Analyze the bundle in a new Copilot session

Use this when you want Copilot to enter the extracted bundle with the ESB analysis primer loaded:

1. Open a new local terminal. Do not run this inside the Copilot session already handling another task.
2. Start a new Copilot session with the bundle-specific SSH command:

```bash
copilot -i "Analyze GHES bundle. Run: ssh esbtools-azshell-1de6dd2.azure-eastus.github.net '/data/esb-tools/script/launch 203730 -c /app/shell_tools/copilot-primer'"
```

3. Approve the SSH and FIDO prompts.
4. In the new session, verify the bundle ID, appliance hostname, GHES version, capture window, and available diagnostics before accepting any findings.
5. Ask Copilot to keep conclusions evidence-backed and to mark missing diagnostics as unavailable rather than healthy.

For another bundle, replace both the shell hostname and bundle ID with the values from that bundle's staff page. Run separate Copilot sessions for separate appliances so evidence does not mix between environments.

### 3. Establish a baseline

Review normal and peak behavior rather than relying on one dramatic measurement. When available, compare:

- Typical versus peak resource usage
- Current values versus documented thresholds
- Current period versus a previous Health Check
- Customer symptoms and ticket history versus bundle evidence
- Healthy periods versus concerning periods

A peak without duration, denominator, or baseline is not enough to establish a capacity problem.

### 4. Analyze the major areas

A practical Health Check normally covers:

| Area                         | Example questions                                                                    |
| ---------------------------- | ------------------------------------------------------------------------------------ |
| Security and version posture | Is the release supported? Are important certificates, settings, or risks identified? |
| Configuration and resilience | Does the topology match the intended availability and recovery design?                |
| Performance and capacity     | Are CPU, memory, storage, latency, request volume, or Git workloads under pressure?   |
| Support and operations       | Are there recurring tickets, incidents, maintenance risks, or process gaps?           |

For the LLM Assist GHES customer-health workflow, the technical scorecard examines seven pillars:

1. API request volume
2. API latency
3. Application server load
4. Git operation volume
5. Git backend input/output
6. Fileserver wait
7. Git process CPU and memory

Automation gathers and summarizes evidence. The CRE still determines relevance, impact, confidence, and the recommendation.

### 5. Write evidence-backed findings

Use this pattern for every material risk:

- **Observation:** What was found
- **Evidence:** Exact count, date, version, duration, peak, or affected component
- **Why it matters:** The customer-relevant impact or risk
- **Recommendation:** A specific action connected to the evidence
- **Owner and priority:** Customer, GitHub, or joint; now, next, or monitor

Separate healthy findings from risks. Prefer `Healthy`, `Watch`, `Higher risk`, or `Action recommended` over unsupported severity language.

### 6. Build the report

A strong report normally contains:

1. Scope and evidence window
2. Short executive summary
3. At-a-glance status table
4. Security and version posture
5. Configuration and resilience
6. Performance and capacity
7. Support and operational themes
8. Change since the previous Health Check, when comparable evidence exists
9. Prioritized recommendations
10. Data limitations and verified public documentation

Use the complete template and review checklist in [[Health Check Structure and Review Reference]].

#### Practical completion workflow

1. Generate the standard Health Check report and keep it as the source of truth.
2. Fill every required placeholder using verified evidence.
3. Add and interpret required Grafana screenshots for CPU, memory, load, and other relevant trends.
4. Compare against a prior Health Check when equivalent evidence exists.
5. Concentrate interpretation effort on the executive summary and prioritized recommendations.
6. Open the pull request only after the report structure, evidence, images, and customer-facing actions are complete.

Artificial intelligence can help compare periods, identify trends, fill placeholders, and draft summary language. Constrain it to the existing report structure and review its output for unsupported assumptions, unrelated context, invented sections, and customer-data leakage.

### 7. Perform self-review

Before requesting review, verify:

- [ ] Dates, versions, environments, and evidence windows are correct.
- [ ] No placeholders, temporary notes, or draft markers remain.
- [ ] Counts agree across the executive summary, tables, and recommendations.
- [ ] Every recommendation maps to an observed condition.
- [ ] Units, thresholds, and measurement windows are explicit.
- [ ] Healthy signals and risks are clearly separated.
- [ ] Missing data is identified as a limitation.
- [ ] Customer-sensitive identifiers and internal-only references are removed.
- [ ] Public documentation links resolve and support the nearby statement.
- [ ] Another reviewer can reproduce the important findings from the cited evidence.

### 8. Submit for review

The Health Check system of record is:

`github/helphub-knowledge-base/premium/health-checks/<year>/`

Typical review flow:

1. Create the report in the appropriate year directory.
2. Open a pull request in `github/helphub-knowledge-base`.
3. Request review from the designated Health Check reviewer or experienced CRE.
4. Address questions about evidence, wording, recommendations, consistency, and redaction.
5. Obtain human approval and merge the pull request.
6. Follow the engagement owner's delivery process for attaching or sharing the final customer-facing report.

Confirm the exact reviewer, filename convention, ticket update, and customer-delivery method with the engagement owner. These details may vary by account and engagement.

## LLM Assist resources

Use these repository resources for a GHES bundle-based assessment:

- `skills/ghes-customer-health/SKILL.md`: complete technical workflow
- `skills/ghes-customer-health/references/examples/single-customer-example.md`: worked report
- `skills/ghes-customer-health/references/report-template.md`: generated report structure
- `skills/ghes-customer-health/references/metric-catalog.md`: metric definitions
- `skills/ghes-customer-health/references/rubric.md`: scoring thresholds
- `skills/ghes-customer-health/references/caveats-and-degradation.md`: missing-data handling
- `skills/ghes-customer-health/references/splunk-queries.md`: supporting searches

Related vault references:

- [[Health Check Structure and Review Reference]]
- [[ESB Support Bundle Workflow]]
- [[Support Bundles Cheatsheet]]
- [[GHES Cheatsheet]]
- [[Splunk Cheatsheet]]

## Preparing for a shadowing or teaching session

A useful 40-minute preparation plan:

1. Spend 15 minutes reading the technical workflow.
2. Spend 15 minutes reading one completed Health Check and its review discussion.
3. Spend 10 minutes comparing the completed report with the template.

You do not need to memorize individual queries or thresholds. Focus on understanding how the analyst moves from evidence to interpretation and then to an action.

## Questions to ask the mentor

- Which template or prior report should I use as the starting point?
- How do you decide which automated findings deserve narrative explanation?
- How do you distinguish a real risk from a short-lived peak or expected behaviour?
- Which findings most often attract review feedback?
- Who should review the report, and how do I request that review?
- What belongs in the pull request versus the engagement ticket?
- How is the approved report delivered to the customer?
- When there are multiple environments, do we create separate reports or a combined assessment?
- What should remain internal until technical review is complete?
- Do you, or would you, consider running a healthcheck without it being one of the 4 annual ones

## Reference examples

- [Tesco Health Check pull request](https://github.com/github/helphub-knowledge-base/pull/1398)
- [Bundle verification review](https://github.com/github/helphub-knowledge-base/pull/1414)
- [Tesco final report](https://github.com/github/helphub-knowledge-base/blob/main/premium/health-checks/2026/tesco-2026-06.md)
