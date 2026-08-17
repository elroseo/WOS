---
tags:
  - ghes
  - troubleshooting
  - support-bundles
  - cheatsheet
audience: CRE
updated: 2026-08-17
---

# Support Bundles Cheatsheet

> [!summary] The rule to remember
> **Start from the customer-visible symptom and a concrete timestamp or request.** Use general health signals to explain that evidence, not as a substitute for it. A dramatic anomaly is not a root cause until you can connect it to the reported impact.

## What and when

A GHES support bundle is a point-in-time capture of an appliance's logs, diagnostics, and configuration. Use this cheatsheet when investigating a reported GHES incident from an uploaded bundle, whether accessed through ESB Tools or forwarded to Splunk.

## Prerequisites and auth

- A support bundle uploaded and extracted for the affected appliance; see [[ESB Support Bundle Workflow]] for dashboard extraction and SSH access to the ESB shell host.
- Alternatively, Splunk access if the bundle's data has been ingested into `index=prod-esbtools`; see [[Splunk Cheatsheet]] for authentication.

## Platform scope

This cheatsheet covers **GHES support bundles only**. GHES appliance identifiers (repo_id, org_id, user_id) are independent from GitHub.com identifiers and can collide; never join GHES bundle data to GHEC/dotcom datasets. For GHEC-side investigation, use the appropriate GHEC telemetry source instead (see [[Splunk Cheatsheet]] platform scope and [[Kusto-KQL Cheatsheet]]).

## Safety and read-only boundary

Reading a support bundle (logs, diagnostics, metadata) is read-only and safe. This cheatsheet does not cover running commands against a live customer appliance; for that, and for which `ghe-*` commands are customer-impacting, see [[GHES Cheatsheet#Safety and read-only boundary]].

## First five minutes

### 1. Write down the incident frame

- **What failed?** Expected versus actual behavior
- **When?** Exact timestamp, timezone, duration, and recurrence
- **Which object?** Repository, pull request, workflow run, user, request ID, webhook GUID, or Git operation
- **Scope?** One user/repository/node or instance-wide
- **What changed?** Upgrade, config apply, certificate, network, identity provider, storage, or workload change
- **Business impact?** Broken, delayed, intermittent, or merely noisy

> [!tip] Ask only for what the bundle cannot tell you
> When a bundle exists, find concrete examples in the logs first. Ask the customer for missing business context, confirmation of the time window, or identifiers that cannot be reconstructed.

### 2. Confirm the bundle can cover the incident

| Check | Why it matters |
|---|---|
| Bundle creation/upload time | Establishes the end of the evidence window |
| Standard or extended bundle | Standard is approximately 2 days; extended is approximately 8 days |
| Log-specific retention | Busy firehose logs may rotate much sooner than the nominal bundle range |
| Correct node(s) included | Cluster and geo-replication investigations need multi-node evidence |
| Clock and timezone | Prevents searching the wrong hour |

Do not conclude “nothing happened” until you have checked both retention and parser/log format. An empty result can mean no event, rotated evidence, a wrong timestamp, a wrong node, or a query that does not match that GHES version.

### 3. Establish the instance profile

Check the diagnostics before interpreting any log:

- GHES version and build SHA
- standalone, HA, cluster, or geo-replication topology
- node role and hostname
- CPU and memory capacity
- disk usage and mount layout
- authentication method
- recent configuration applies or upgrade
- relevant feature flags and configuration values

> [!warning] ESB container trap
> Commands such as `df -h`, `/proc/loadavg`, and `/proc/meminfo` inside an ESB launch container describe the **ESB container**, not the customer appliance. Use captured bundle files, diagnostics, `ghe-metrics` in support-bundle mode, and collectd/RRD evidence.

### 4. Start with ghe-probe, but classify every result

| Classification | Examples | What to do |
|---|---|---|
| **Direct subsystem failure** | Replication broken, backup failed, certificate expired | Investigate that subsystem directly and verify impact |
| **Pressure signal requiring validation** | High load, disk use, large tables, connection limits | Ask what caused it and whether it overlaps the incident |
| **Usually a symptom** | Queue backlog, rejected connection, timeout, retry storm | Trace upstream to the first saturation or failure point |
| **Separate operational risk** | Unrelated warning outside the affected path | Record separately; do not call it the incident cause |

**ghe-probe is a starting inventory, not a root-cause report.**

## Symptom-to-evidence map

| Customer symptom | Start with | Then correlate |
|---|---|---|
| UI/API slow or timing out | `github-logs/exceptions.log*` slow-request events | `unicorn.log`/request logs, collectd RRDs, MySQL/GitRPC timing |
| 500 errors | `github-logs/exceptions.log*` | Request ID, controller, `production.log`/`unicorn.log` |
| Git clone/fetch/push slow or failing | `babeld-logs/babeld.log*` | GitRPC timing, storage/network evidence, HAProxy |
| Authentication failure | `github-logs/auth.log*` | IdP/LDAP response, user scope, time drift, certificate/config changes |
| Webhook delayed or missing | Hookshot/Aqueduct delivery and dequeue evidence | Queue age, retries, destination response, event creation |
| Workflow or runner issue | Actions logs and `ghe-actions-dump` when available | Queue/circuit breaker, runner state, Nomad, storage/network |
| Search/indexing issue | Elasticsearch logs and index status | Cluster health, aliases, indexing lag, application exception |
| Email delivery issue | `mail-logs/mail.log*` | SMTP response, DNS/TLS, queue/retry timeline |
| Config/upgrade regression | `configuration-logs/`, `enterprise-manage-logs/` | Exact apply/upgrade time, version-specific known issues |
| PR/branch appears stale | Event/merge-state propagation evidence | Background jobs and cached state; this may not be request latency |
| Replication problem | Replication diagnostics and node-specific logs | Network, storage, database/repository lag, outage duration |

## The investigation workflow

1. **Pin a concrete example.** Find the affected request, exception, job, webhook, Git operation, or object transition.
2. **Build the timeline.** Search a narrow time window first, then widen deliberately.
3. **Pivot by stable identifiers.** Prefer request ID, job ID, trace ID, repository ID, pull request ID, or webhook GUID over vague text.
4. **Measure the symptom.** Duration, error rate, queue age, retry attempts, lag, or failed transitions.
5. **Check the denominator.** Counts alone are workload-sensitive. Compare slow events with total traffic, failures with attempts, or queue growth with enqueue/dequeue rates.
6. **Corroborate with time-series evidence.** A point-in-time diagnostic snapshot does not prove what happened during the incident.
7. **Trace upstream.** Keep asking “what caused this?” until you reach the first demonstrated saturation or failure point.
8. **Test counter-hypotheses.** State at least one plausible alternative and what evidence supports or weakens it.
9. **Check version-specific prior art.** Similar symptoms can have different mechanisms across GHES releases.
10. **Separate findings.** Distinguish the incident mechanism, possible upstream cause, ruled-out hypotheses, and unrelated health risks.

**Success criteria:** a completed pass through this workflow produces at least one finding using the template below, with a stated confidence label, cited evidence path, and a counter-hypothesis considered. An investigation that stops at "here is an anomaly" without connecting it to the reported symptom has not met success criteria.

## GUI procedure

The primary supported interface for bundle investigation is CLI-based (SSH into the ESB shell host, then `zgrep`/`jq`/`rg` as shown below). A bundle dashboard UI also exists and can generate a self-service report, but its detailed navigation is not documented in this vault; use it only for the extraction-status check described in [[ESB Support Bundle Workflow]], and treat its generated report as a starting inventory, not a substitute for the CLI investigation in this cheatsheet.

## Evidence and confidence

| Label | Use when |
|---|---|
| **CONFIRMED** | Direct mechanism is demonstrated with specific evidence for this incident |
| **PROBABLE** | Multiple independent signals support the mechanism, with meaningful alternatives ruled out |
| **POSSIBLE** | Plausible and supported by some evidence, but a critical link is missing |
| **OBSERVED** | The signal is directly present, but its causal role is not established |
| **REPORTED** | Customer, Support, or engineering states it, but you have not independently demonstrated it |
| **RULED OUT** | Evidence shows it did not materially participate in the incident |

> [!important] Do not let the conclusion outrun the evidence
> An exception count proves that an exception occurred. It does not automatically prove why it occurred or that it caused the customer symptom.

### Finding template

```markdown
### Finding: <short statement>

- **Classification:** incident mechanism / upstream hypothesis / operational risk / ruled out
- **Confidence:** OBSERVED / POSSIBLE / PROBABLE / CONFIRMED
- **Evidence:** exact metric, log event, time window, and source path
- **Customer impact:** how this maps to the reported symptom
- **Causation chain:** symptom <- mechanism <- upstream cause
- **Counter-hypothesis:** alternative and the evidence for/against it
- **Evidence gap:** what is still needed
- **Next step:** validated, supported action
```

## Performance-specific guardrails

- **Load is a pressure signal, not proof of CPU saturation.** Linux load also includes tasks blocked in uninterruptible sleep.
- A low load-to-CPU ratio can rule CPU pressure out; a high ratio requires CPU, process, and I/O corroboration.
- High per-request CPU time means that request was CPU-bound. It does not alone prove host-wide saturation.
- High request idle time means off-CPU time. It can include I/O, locks, downstream calls, scheduling, or GVL waits.
- Compare the incident window with a healthy baseline or adjacent bundles whenever possible.
- Broad controller impact shows scope, not mechanism. A shared dependency can affect many endpoints.

### Top-down workload pressure review

When an appliance shows recurring load, disk latency, request queueing, and broad GitHub Actions or continuous integration activity, stay at the system-and-workload level until evidence justifies a narrower trace.

1. Review one to two weeks of retained metrics when available. Mark repeated pressure windows before zooming into one exception or repair event.
2. Correlate load with CPU utilization, disk latency, input/output throughput, Unicorn queue depth, and request latency. A virtualization plateau near a fixed percentage can indicate host scheduling or throttling, but the graph alone does not prove the hypervisor caused the incident.
3. Confirm the configured Unicorn worker count from diagnostics or configuration metadata. More workers are not a safe default mitigation when CPU or memory is already constrained.
4. Use [[Splunk Cheatsheet#Unicorn burst and worker-pressure candidates]] to rank concentrated API actors. Treat the output as candidate workload pressure, then compare the exact windows with worker queueing and system metrics.
5. Use [[Splunk Cheatsheet#BabelD workload concentration by organization and repository]] to separate high-volume Git traffic from individually expensive repository operations.
6. Drill into integrations only after concentration is demonstrated. Check repeated endpoint polling, user-agent versions, token naming families, development or quality-assurance traffic against production, caching opportunities, and webhook alternatives.
7. Prefer workload reductions that the customer can validate: stagger automation, reduce polling, cache stable dependencies, pause unnecessary non-production jobs, prefer branches over repeated large forks, and reduce clone frequency for large repositories.
8. Ask for a fresh bundle when the recommendation depends on current actors, repositories, or integration behavior. Old bundle data supports historical findings only.

Do not equate a graph correlation, a high actor count, or an expensive repository with root cause. State what was observed, the mechanism it could pressure, the alternative hypotheses considered, and the evidence needed to confirm impact. Screenshots are useful for communicating ranked outliers, but preserve the query, time window, host, row count, and units in the investigation notes.

### Retention reality

| Source | Typical behavior | Best use |
|---|---|---|
| `unicorn.log` / `production.log` | High-volume and may retain only a short recent window | Recent requests and request-ID correlation |
| `exceptions.log*` | Often reaches further back | Slow requests, slow queries, exceptions |
| collectd RRDs | Longer history, downsampled | Confirm incident window and system mechanism |
| Diagnostics | Point-in-time snapshot | Instance profile and state near bundle creation |

## State that must be checked before making claims

If your analysis refers to any of these, inspect its actual bundle state:

- `metadata/mysql_row_count.txt` for table-size claims
- `metadata/configs/` or diagnostics for configuration claims
- `metadata/feature_flags.txt` for feature-flag claims
- `docker/images.txt` before assuming an image exists
- `docker/ps.txt` before claiming a container was healthy or stopped
- `metadata/kafka-lite-metadata.json` and related metrics for offset/capacity claims
- node-specific evidence for HA/cluster conclusions

Unchecked configuration, table, feature-flag, or version-parity assumptions should remain **POSSIBLE**.

## Useful search patterns

Probe the file format before trusting a parser. Fields and formats drift between GHES versions.

```bash
# Inspect one structured exception before writing a jq query
zgrep -m1 -h 'SlowRequest\|SlowQuery' github-logs/exceptions.log* | jq .

# Count exception classes without losing structure
zgrep -hF -e 'Slow' -e 'github-slow-' github-logs/exceptions.log* \
  | jq -r '.class // empty' | sort | uniq -c | sort -nr | head -20

# Search a narrow timestamp across compressed and uncompressed logs
zgrep -h '2026-08-13T16:2' path/to/log* 2>/dev/null

# Rank exact repeated messages only after confirming the log format
zgrep -h 'PATTERN' path/to/log* | sort | uniq -c | sort -nr | head -20
```

Prefer structured fields over broad searches for `error`, `exception`, or `slow`. Broad searches mix unrelated classes, expected noise, and different semantics.

## Common traps

| Trap | Better approach |
|---|---|
| Starting with the busiest subsystem | Start with the affected request/event and tie subsystem evidence to it |
| Treating every ghe-probe failure as the incident cause | Classify it and prove materiality |
| Searching the whole bundle without a time or identifier | Begin with a narrow window and stable ID |
| Raw counts without traffic context | Calculate a rate or explicitly note the missing denominator |
| Empty query means healthy | Check retention, format, node, timestamp, and valid empty-result handling |
| Using a similar incident as proof | Confirm version, code path, state, and distinguishing signals |
| Assuming a workaround proves root cause | Treat recovery as supporting evidence, not causal proof |
| Recommending an internal flag or service change | Validate supportability and route engineering-managed changes to engineering |
| Reporting only anomalies | Include ruled-out hypotheses and relevant healthy baselines |
| Trusting generated output without interpretation | Verify source data, explain impact, and distinguish observation from cause |

## CRE review lessons

These recurring lessons were inferred from review comments and issue discussions in `github/customer-reliability-engineering`:

1. **Empty results are a real test case.** A health-check fix for bundles with no failed logins initially misread a non-useful return value as data. Reviewers required validation against both a bundle with failures and one without them. See [PR #677](https://github.com/github/customer-reliability-engineering/pull/677).
2. **Understand field semantics before filtering.** Slow events could be identified through different JSON keys (`class` and `app`). Review feedback moved the query toward structured `jq` parsing and validated it against a real bundle. See [PR #430](https://github.com/github/customer-reliability-engineering/pull/430).
3. **Verify what the tool already does.** A documentation change was challenged because it assumed report output was not already written to a file. Inspect actual behavior before documenting a workaround. See [PR #4416](https://github.com/github/customer-reliability-engineering/pull/4416).
4. **Generated health output is not interpretive analysis.** CREs explicitly distinguished the bundle UI's self-service report from the interpretive CLI health check. Automation gathers evidence; the analyst still determines relevance and causation. See [PR #3231](https://github.com/github/customer-reliability-engineering/pull/3231).
5. **Automation should be observable and kept current.** Reviewers valued a one-command workflow but requested progress visibility and noted that queries evolve. Record versions, show what ran, and revisit old parsers. See [PR #318](https://github.com/github/customer-reliability-engineering/pull/318).
6. **A standard bundle may not contain all product evidence.** CRE planning identified gaps for Actions diagnostics and kafka-lite metadata/metrics, plus the need for graceful version-aware collection. State missing-source gaps rather than fabricating conclusions. See [issue #5675](https://github.com/github/customer-reliability-engineering/issues/5675).

## Bundle creation reference

GitHub's GHES 3.20 documentation uses:

```bash
# Standard support bundle, approximately 2 days
ssh -p 122 admin@HOSTNAME -- 'ghe-support-bundle -o' > support-bundle.tgz

# Extended support bundle, approximately 8 days
ssh -p 122 admin@HOSTNAME -- 'ghe-support-bundle -o -x' > support-bundle.tgz
```

For cluster or geo-replication configurations, use the documented `ghe-cluster-support-bundle` workflow so evidence is gathered from all required nodes.

> [!warning] Handle bundles as sensitive support data
> GitHub sanitizes authentication tokens, keys, and secrets in specified log directories, but diagnostics and logs still contain customer, hostname, configuration, activity, and licensing information. Share them only through approved support systems and access-controlled locations.

## Reactive versus proactive analysis

- **Reactive incident:** start from the reported symptom, exact window, and affected request/object. Use GBAO or the relevant troubleshooting workflow.
- **Proactive health/trend review:** compare multiple bundles, show trends and baselines, suppress verified known false positives, and call out source gaps.

Do not use a weekly health threshold alone to explain a specific incident.

## Stop and escalate

Escalate rather than continuing to search the bundle alone when:

- The bundle cannot cover the incident window (see the retention and coverage checks above) and no alternative source (Splunk, a second bundle, customer-forwarded logs) is available.
- Evidence points to a platform bug rather than a customer configuration or workload issue.
- A finding requires an internal flag change or an engineering-managed service change; route that to engineering rather than recommending it directly.
- The investigation has run past the customer's urgency window with no credible next step.

Apply the general investigation and escalation judgment in [[Investigation and Escalation Judgment]], including building an evidence chain (timestamp, exact error, what was tried, current hypothesis) before escalating.

## Quick reference

- [[ESB Support Bundle Workflow]]: accessing an extracted bundle through ESB Tools
- [[GHES Cheatsheet]]
- [[Splunk Cheatsheet]]
- [[Kusto-KQL Cheatsheet]]
- [[Health Check Runbook]] - repeatable multi-pillar evidence collection built on this methodology
- [[Investigation and Escalation Judgment]]
- [Providing data to GitHub Support, GHES 3.20](https://docs.github.com/en/enterprise-server@3.20/support/contacting-github-support/providing-data-to-github-support)
- [GHES command-line utilities](https://docs.github.com/en/enterprise-server@3.20/admin/administering-your-instance/administering-your-instance-from-the-command-line/command-line-utilities)

## Freshness note

Log formats, field names, and bundle contents drift between GHES releases. Verify the bundle's version before reusing a parsing pattern, and confirm the linked docs still match the customer's release series. Reviewed 2026-08-13.
