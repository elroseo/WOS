---
tags:
  - health-check
  - cre
  - learning
  - recommendations
updated: 2026-08-14
---

# Peer Summary and Recommendation Patterns

## Purpose

Reusable lessons from reviewing Summary and Recommendations sections across 437 Health Checks from 2025 and 2026 in `github/helphub-knowledge-base`.

The goal is not to copy another author's wording. Use these patterns to turn customer evidence into a short, prioritized, customer-specific action plan.

## People worth studying

| Person | Strongest technique | Useful examples |
| --- | --- | --- |
| Panagiotis Lithadiotis (Panos) | Names the workload behind each anomaly and tracks recurring offenders across review periods | `2026/sap-2026-03.md`, `2025/bloomberg-eng-2025-02.md` |
| Jessica Widener (`jesscetera`) | Combines prior-period deltas, ranked priorities, healthy findings, and phased next steps | `2026/rockfoc-2026-07.md`, `2026/moneris-solutions-2026-04.md` |
| Liam Gallear | Organizes the report around a customer event and separates blockers from monitor-only items | `2026/tesco-2026-06.md` |
| Simon Giesemann | Leads with a short ranked priority list and adds verification after changes | `2026/bmw-atc-2026-04.md`, `2026/freewheel-2026-04.md` |
| Tanya Sheoran | Separates healthy signals, recommended actions, and higher-risk findings | `2026/databricks-2026-05.md` |
| Reggie Montanhani | Uses exact period-over-period deltas and connects growth to documented platform limits | `2025/itau-2025-12.md` |
| Diego Arostegui | Surfaces meaningful security and supportability risks beyond routine tuning | `2025/hsbc-2025-08.md`, `2025/hsbc-2025-11.md` |
| Oskar Pienkos | Assigns explicit timing such as Immediate, Short-term, Medium-term, and Ongoing | `2025/visa-2025-09.md` |
| Carlos Naranjo | Connects recommendations to the customer's stated migration or growth plans | `2026/intel-2026-05.md` |

## Panos: specific customer insight

### Strengths

- Names the specific team, repository, account, or integration behind an anomaly.
- Includes the number explaining why that workload matters.
- Tracks the same offender across consecutive Health Checks.
- Connects operational findings to broader scaling limits.
- Starts some reports with the customer's reason for requesting the review.
- Provides concrete remediation rather than stopping at a warning.

### What to reuse

- For every top offender, include its identity, metric, and share of the total.
- Label recurring findings explicitly as recurring.
- Tie at least one recommendation to why the customer requested the Health Check.
- Explain the likely consequence if no action is taken.

### What to tighten

- Long flat lists can mix critical risks with routine cleanup.
- Add `Now`, `Next`, or `Monitor` to every recommendation.
- Assign a customer, GitHub, or joint owner.
- Keep customer-facing recommendations self-contained rather than relying on internal ticket references.
- Put potentially disruptive commands behind an owner, authorization, verification, and rollback step.

## Jessica Widener: trend-aware prioritization

Jessica belongs on the people-to-study list. Her reports show a progression from solid but occasionally repetitive 2025 summaries to strongly structured 2026 action plans.

### Distinctive strengths

- Uses exact prior-versus-current deltas instead of saying only that a metric increased or improved.
- Opens with what is working well before listing gaps.
- Uses ranked structures such as High/Medium or P1/P2/P3.
- Explains why a recommendation matters, not only what should change.
- Runs additional analysis when a dashboard result needs confirmation.
- Uses phased roadmaps such as 0 to 30, 30 to 60, and 60 to 90 days.
- Records recommendations resolved since the previous Health Check.
- Links recommendations to implementation documentation.

### Best examples

1. `2026/rockfoc-2026-07.md`, `Summary`
   - Status overview, healthy findings, priority recommendations, reasoning, and a phased implementation sequence.
2. `2026/moneris-solutions-2026-04.md`, `Summary`
   - Prior-period progress, an additional repository sizing analysis, ranked recommendations, and resolved findings.
3. `2026/dell-2026-01.md`, `Summary and recommendations`
   - Domain-based findings, quantified changes, and themed focus areas.
4. `2026/adobe-2026-01.md`, `Summary & Recommendations - Action items`
   - Tight priority tiers supported by before-and-after measurements.

### Best shadowing topic

How to build a summary from:

1. A prior-versus-current delta.
2. A ranked priority table containing reason and action.
3. A phased next-steps timeline.

### What to tighten

- Avoid repeating stock recommendations unchanged between review periods.
- Do not explain the same recommendation in both narrative prose and an action list.
- Keep numbering consistent between priority groups.
- Put a short executive summary near the beginning when the full report is long.
- Strengthen explicit alignment with the customer's stated roadmap or business event.

## Common recommendations that require evidence

These points appear frequently across Health Checks. Include them only when the current evidence supports them:

- Upgrade to the latest supported patch.
- Update `backup-utils`.
- Replace polling with webhooks.
- Replace password authentication with tokens.
- Enable subdomain isolation.
- Clean stale queues.
- Increase diagnostic retention.

A useful recommendation identifies the affected account, configuration, workload, count, or observed failure. If the check found no issue, state that no action is currently required.

## High-value recommendation patterns

- Tie a recommendation to a scheduled upgrade, migration, disaster recovery test, or peak event.
- Compare primary and replica capacity before a failover.
- Project customer growth against a documented platform limit.
- Name the workload responsible for disproportionate API, Git, CPU, or transfer load.
- Identify an exposed credential or unsupported integration as a distinct urgent risk.
- State when a common risk was checked and not found.
- Verify whether a previous recommendation was implemented and whether the metric improved.

## Points to consider before writing

### Executive summary

- Why was the Health Check requested?
- What is the most important healthy signal?
- What is the most important risk signal?
- What is the single highest-value action?
- Could anything affect an upcoming customer event?

### Lifecycle and security

- Version and patch posture.
- Certificate and license expiry.
- Unsupported software or integrations.
- Authentication failures and legacy password usage.
- Exposed credentials.
- Security feature adoption and policy gaps.

### Capacity and performance

- Provisioned, typical, and peak usage.
- Sustained pressure versus a momentary spike.
- Worker saturation.
- Disk growth and projected exhaustion.
- Backup duration trend.
- Database or queue growth.
- Workloads driving disproportionate load.

### Resilience and operations

- Primary and replica resource parity.
- Replication and search health.
- Backup recoverability.
- Diagnostic retention.
- Pending maintenance or reboots.
- Disaster recovery impact.

### Developer and integration behavior

- Polling versus webhooks.
- Clone versus fetch behavior.
- Parallel Git operations.
- Expensive API routes.
- Rate-limit pressure.
- Webhook failures.
- Misconfigured service accounts.

### Customer and support context

- Upcoming migration, upgrade, failover, or organizational change.
- Connection to current incidents or support work.
- Whether an automated finding requires deeper investigation.
- Who owns each action.

### Trends

- Current value and previous value.
- Direction and customer-relevant interpretation.
- New versus recurring findings.
- Progress on prior recommendations.
- Growth toward documented limits.

## Recommendation format

For each recommendation, include:

- **Observation:** What was measured or found.
- **Impact:** Why it matters to this customer.
- **Action:** What should happen next.
- **Owner:** Customer, GitHub, or joint.
- **Timing:** Now, Next, or Monitor.
- **Verification:** How success will be confirmed.

Example:

> **Observation:** `<metric>` reached `<value>` against a recommended `<threshold>`.  
> **Impact:** Sustained pressure could cause `<customer consequence>`.  
> **Action:** `<specific change or investigation>`.  
> **Owner:** `<customer, GitHub, or joint>`.  
> **Timing:** `<Now, Next, or Monitor>`.  
> **Verification:** `<measurement or check showing improvement>`.

## Final drafting questions

1. Does the summary lead with why this review matters to the customer?
2. Are healthy signals and risks both visible?
3. Does every recommendation have current evidence?
4. Have specific workloads and their measurements been identified?
5. Is change since the previous Health Check clear?
6. Are recommendations ranked and assigned?
7. Is the most important action obvious within 30 seconds?
8. Are sensitive and internal-only details removed?
9. Can a second CRE reproduce the major findings?

## Related

- [[Health Check 101]]
- [[Health Check Structure and Review Reference]]
- [[Health Check Runbook]]

