---
tags:
  - ghes
  - api
  - performance
  - splunk
  - health-check
  - troubleshooting
status: reference
updated: 2026-08-17
---

# GHES API Workload Analysis Method

> [!summary]
> Analyze GitHub Enterprise Server (GHES) API pressure through volume, latency, aggregate service time, and burst concentration. Start with objective workload evidence, then narrow to actors, controllers, endpoints, integrations, and repositories.

## What and when

Use this method when a GHES appliance has persistent CPU pressure, disk latency, input/output contention, Unicorn queueing, or degraded API response times.

This is a workload review, not a root cause shortcut. A high-volume actor, expensive endpoint, or critical burst is a candidate contributor until its windows are correlated with worker queueing, system pressure, and customer-visible impact.

## Core investigation frame

Separate an immediate fault from the broader performance baseline. A failed node, repair event, or service defect may explain one symptom while sustained API and Git workloads continue to create independent pressure.

Measure API usage through three complementary lenses:

1. **Volume:** how many requests were made.
2. **Latency:** how long individual requests took.
3. **Combined impact:** total elapsed time and whether requests arrived in concentrated bursts.

Finish by organizing actions into short-, medium-, and long-term changes. This prevents a long list of observations from becoming an unactionable data dump.

## Choose the evidence window

- Use approximately seven days when contention is persistent and the goal is to identify recurring workflows.
- Compare the same peak window across multiple days when pressure occurs at predictable times.
- Use a narrow incident window when the customer reports an exact event or timestamp.
- Confirm bundle retention and coverage before interpreting a quiet period.
- Extended or overlapping bundles may duplicate events. Deduplicate with an event-specific stable identifier when one exists.

A long window is useful for workload ownership and relative ranking. It can hide peak behavior, so pair it with shorter windows when daily spikes are important.

## Start with worker capacity

Confirm the configured Unicorn worker count from diagnostics or configuration metadata.

Review the process data for:

- Requests processed per second
- Average request latency
- Worker utilization
- Total requests processed
- Differences between the fastest and slowest workers

A large difference between workers suggests an uneven request mix. Some workers may repeatedly receive expensive calls while others process short requests.

Theoretical capacity calculated from worker count and average latency is a heuristic. It helps explain unused headroom, but it is not an exact concurrency model. Scheduling, request variance, downstream dependencies, input/output waits, and internal work all affect observed throughput.

If CPU or memory is already constrained, increasing worker count is not a safe default. First determine whether latency, burst concentration, or unnecessary automation can be reduced.

## Analyze actors by volume, latency, and total time

Start with a broad actor profile:

- Sort by request count to find the largest consumers.
- Sort by average latency to find expensive request patterns.
- Sort by total elapsed time to find actors with the largest aggregate footprint.
- Retain sample size alongside averages so a small number of outliers does not outrank a sustained workload without context.

Service and personal accounts require different interpretation. A personal account making thousands of scripted calls may indicate automation that should use a GitHub App, OAuth app, or managed service account.

Normalize numbered, regional, or similarly prefixed service accounts before drawing conclusions. One application spread across multiple credentials can otherwise appear as many small consumers.

## Detect burst concentration

Use [[Splunk Cheatsheet#Unicorn burst and worker-pressure candidates]] for the full Search Processing Language (SPL) query.

The method:

1. Bin requests into 10-second windows.
2. Group by actor, controller, or another selected dimension.
3. Count requests and calculate aggregate elapsed time for each window.
4. Mark a `burst` when the count reaches the chosen threshold.
5. Mark a window `critical` when it bursts and contains more than 10 request-seconds of aggregate work.
6. Summarize burst and critical counts over the review period.

Set the burst threshold from the configured Unicorn worker count or another explicitly justified acceptable connection level. Do not reuse a threshold from a different appliance without validating its capacity.

The 10-second window allows reasonable request dispersion while still exposing automation that submits work in concentrated batches. The `critical` label is a prioritization heuristic. It does not prove worker exhaustion, failover, or an outage.

## Pivot the same method across dimensions

The burst query becomes more useful when the grouping field changes.

### Actor

Group by `gh_actor_login` to identify users, service accounts, and integrations submitting concentrated work.

### Controller

Replace the actor grouping with `code_namespace` to identify API controllers receiving concentrated or expensive traffic. This view is agnostic to user identity and reveals the application's endpoint dependencies.

### Endpoint-specific actor review

Filter to one controller, then group by actor. This identifies who is driving traffic to an expensive endpoint.

Pull-request endpoints deserve special attention because their latency can vary substantially by repository and pull request. A burst against an expensive pull request can have a larger impact than the same request count against a cheap endpoint.

### Request path and user agent

Use [[Splunk Cheatsheet#API integration and polling drilldown]] to verify request-path and user-agent fields before aggregation.

Look for:

- Repeated polling of the same resource
- Multiple versions of one integration
- One application split across many credentials
- Personal access tokens used for shared automation
- Development or quality-assurance workflows targeting production

### Payload and repository

When available, aggregate response or content length by actor and repository. A moderate number of requests can still be expensive when they repeatedly generate or transfer large payloads.

## Common workload patterns

### Thundering-herd repository content requests

Many deployment units or ephemeral runners may request the same repository file at the same time.

Validate whether the workflow can:

- Fetch the file once and distribute it locally
- Cache stable content
- Stagger deployments
- Avoid treating GitHub as a mass deployment distribution system

### Pull-request polling

Frequent polling for mergeability, review state, or status can be expensive and bursty.

Consider:

- Pull-request webhooks
- Lower polling frequency
- Consolidation into a GitHub App or service account
- Caching state that does not change between requests
- Dispersing checks instead of launching them simultaneously

Do not assume every pull-request API call can be replaced. Confirm the workflow's required data and event model first.

### Repository and commit data

Automation may repeatedly retrieve commit or repository data that is already available after a clone or fetch. Determine whether local Git operations can replace repeated API retrieval.

### Internal API traffic

Do not permanently exclude internal calls. Analyze them separately:

- External calls inform customer workload recommendations.
- Internal calls may reveal a product defect, inefficient internal workflow, or engineering-owned optimization opportunity.

Keep customer actions and internal engineering follow-up in separate findings.

## Correlate before concluding

For each high-impact actor or endpoint, compare the exact windows with:

- Unicorn active workers and queue depth
- CPU utilization
- Disk latency and input/output throughput
- HAProxy queueing
- Customer-visible API latency or errors
- Adjacent Git or background-job pressure

Queueing does not literally pause the CPU. It can retain request state, consume memory, increase scheduling work, and compound pressure on downstream services. State the observed mechanism precisely.

High latency during a system-wide peak may be symptomatic. Prioritize actors that submitted concentrated work before or during the pressure, not actors that merely experienced slow responses.

## Turn findings into experiments

Recommendations should be measurable:

- Stagger a script or workflow.
- Replace polling with an appropriate webhook.
- Cache stable repository content.
- Consolidate shared automation into a GitHub App or managed service account.
- Pause unnecessary non-production automation against production.
- Reduce simultaneous pull-request checks.
- Fetch repository data locally when the API adds no necessary information.
- Upgrade an integration only after confirming the current version and authoritative vendor guidance.

Re-run the same query after each change. Compare burst count, critical count, aggregate elapsed time, queue depth, and system pressure against the previous period.

## Communicate the findings

Structure the deliverable as:

1. Why the API workload was reviewed
2. Worker capacity and observed utilization
3. Request volume
4. Latency and aggregate elapsed time
5. Burst and critical windows
6. Controller and endpoint dependencies
7. Highest-impact actors or integrations
8. Short-, medium-, and long-term actions

Use annotated screenshots to make ranked outliers understandable, but preserve the query, host, time window, row count, units, and selected threshold in the investigation notes.

Avoid presenting every anomaly. Prioritize the smallest set of changes likely to produce a measurable reduction.

## Guardrails

- A theoretical throughput estimate is not an exact capacity limit.
- A critical burst is not proof of an outage.
- A high actor count does not establish causation.
- Naming conventions are investigation prompts, not evidence.
- Do not claim that Git traffic is generally low impact. Validate clone behavior, repository size, request volume, latency, and total service time.
- Verify product-version improvements, defects, and integration recommendations against current authoritative sources.
- Request a fresh bundle when recommendations depend on current actors or workflows.

## Related notes

- [[Splunk Cheatsheet#Unicorn burst and worker-pressure candidates]]
- [[Splunk Cheatsheet#API integration and polling drilldown]]
- [[Support Bundles Cheatsheet#Top-down workload pressure review]]
- [[Health Check Runbook#Workload concentration drilldown]]
- [[Investigation and Escalation Judgment]]
