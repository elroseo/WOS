---
tags:
  - ghes
  - ghec
  - health-check
  - cheatsheet
audience: CRE
updated: 2026-08-17
---

# Health Check Runbook

> [!summary] Scope
> This runbook covers **repeatable technical evidence collection** for a CRE Health Check: which commands and queries to run, in what order, and how to validate what you gathered. For scope confirmation, report structure, writing style, and reviewer expectations, see [[Health Check 101]] and [[Health Check Structure and Review Reference]] in CRE-Learning.

## What and when

Use this runbook when starting the technical evidence-gathering phase of a proactive Health Check, or when refreshing evidence for a follow-up report. It assumes the engagement scope (customer, environment, evidence window, deliverable date) is already confirmed; see [[Health Check 101#1. Confirm scope]] for that step.

## Prerequisites and auth

- **GHES bundle evidence:** a support bundle uploaded and extracted for the target appliance, plus SSH access to an assigned ESB shell host with FIDO authentication completed. See [[ESB Support Bundle Workflow#Prerequisites and auth]].
- **Splunk cross-checks:** a valid Splunk bearer token (`python3 tools/splunk_auth.py`). See [[Splunk Cheatsheet#Prerequisites and auth]].
- **GHEC evidence:** CRE Dashboard access (a per-user API token, `CRE_DASHBOARD_API_TOKEN`; set up with `python3 tools/auth_all.py --plugin`).
- **Kusto cross-checks (optional):** Azure CLI auth (`az login --use-device-code`). See [[Kusto-KQL Cheatsheet]].

## Platform scope

- **GHES:** evidence comes primarily from a support bundle (via ESB Tools), with optional Splunk cross-checks if the bundle is also ingested. GHES appliance identifiers (repo_id, org_id, user_id) are independent from GitHub.com identifiers and can collide.
- **GHEC:** evidence comes from the CRE Dashboard's GHEC metrics tooling and, where needed, GHEC-side Splunk/Kusto telemetry. Do not substitute a GHES bundle pillar for a GHEC customer or vice versa.
- If a customer runs both platforms, or multiple GHES environments, collect and report evidence **separately per environment**; see [[Health Check 101#1. Confirm scope]] ("Whether separate environments require separate reports").

## Safety and read-only boundary

Every step below is read-only: reading an already-captured bundle, read-only `ghe-probe`/diagnostics inside the bundle, read-only SPL, read-only KQL, and read-only CRE Dashboard API/MCP calls. This runbook does not run customer-impacting `ghe-*` commands against a live instance. If a live-instance check becomes necessary, follow [[GHES Cheatsheet#Safety and read-only boundary]] and get customer authorization first.

## CLI procedure: GHES evidence collection

1. **Confirm scope.** Customer, environment, GHES version and topology (standalone, HA, cluster, geo-replication), and evidence window. See [[Health Check 101#1. Confirm scope]].
2. **Get the bundle ready.** Confirm dashboard extraction and use your assigned ESB shell host. See steps 1 to 3 of [[ESB Support Bundle Workflow#Quick workflow]].
3. **Capture the instance profile.** From the bundle's diagnostics, record version and build SHA, topology, node role and hostname, CPU/memory capacity, disk usage and mount layout, authentication method, recent config applies or upgrades, and relevant feature flags. See [[Support Bundles Cheatsheet#3. Establish the instance profile]].
4. **Run `ghe-probe` and classify every result** as direct subsystem failure, pressure signal requiring validation, usually-a-symptom, or separate operational risk. See [[Support Bundles Cheatsheet#4. Start with ghe-probe, but classify every result]]. Treat it as a starting inventory, not a conclusion.
5. **Collect evidence for each pillar.** The LLM Assist GHES customer-health workflow (`skills/ghes-customer-health/SKILL.md`) defines seven pillars; gather at least one piece of cited evidence for each, or record an explicit evidence gap:

   | Pillar | Evidence source | Reused pattern |
   |---|---|---|
   | API request volume | `esb_production` | Discover the shape first with [[Splunk Cheatsheet#Discovery searches]], then aggregate |
   | API latency | `esb_unicorn` | [[Splunk Cheatsheet#Slow request tail]] query, adapted to the bundle's `host` |
   | Application server load | `esb_unicorn`, `esb_mpstat` | Same slow-request-tail query, plus CPU utilization samples from `esb_mpstat` |
   | Git operation volume | `esb_babeld` | [[Splunk Cheatsheet#Git fetch latency by repository]] and [[Splunk Cheatsheet#Git push failures]] queries |
   | Git backend input/output | `esb_babeld`, `esb_gitmon` | Same babeld queries plus `esb_gitmon` fileserver measurements (see [[Splunk Cheatsheet#Verified GHES support-bundle sourcetypes]]) |
   | Fileserver wait | `esb_gitmon` | No fixed example query is established for this sourcetype; adapt [[Splunk Cheatsheet#Discovery searches]] with `sourcetype=esb_gitmon` and inspect sample events before aggregating |
   | Git process CPU and memory | `esb_mpstat`, diagnostics | CPU utilization samples plus the CPU/memory capacity captured in step 3 |

   Duration and latency fields vary in units (seconds vs milliseconds) across GHES versions; confirm before comparing across pillars or bundles.
6. **Check coverage before trusting a quiet pillar.** Confirm bundle creation/upload time, standard vs extended retention, log-specific retention, and correct node(s). See [[Support Bundles Cheatsheet#2. Confirm the bundle can cover the incident]]. A pillar with no events is not automatically healthy.
7. **Establish a baseline.** Compare typical vs peak values, and this period vs the previous Health Check when a prior report exists. See [[Health Check 101#3. Establish a baseline]].
8. **Label confidence.** Use the evidence-confidence scale in [[Support Bundles Cheatsheet#Evidence and confidence]] for anything that will become a finding.


### Workload concentration drilldown

For a GitHub Enterprise Server performance review with API and Git pressure, add these pivots after the seven-pillar collection:

- Rank concentrated API actors with [[Splunk Cheatsheet#Unicorn burst and worker-pressure candidates]]. Set the 10-second threshold from the appliance's configured Unicorn worker count or an explicitly chosen acceptable connection level.
- Rank Git activity by organization and by repository with [[Splunk Cheatsheet#BabelD workload concentration by organization and repository]]. Compare request volume, total service time, average latency, and tail latency rather than sorting on one metric alone.
- For high-impact integrations, use [[Splunk Cheatsheet#API integration and polling drilldown]] to confirm repeated endpoint polling, user-agent versions, and credentials that belong to one naming family.
- Pair every workload result with system evidence from the same window. At minimum, check Unicorn queue depth or worker availability, CPU, disk input/output or latency, and customer-visible response time.

A useful recommendation names the observed workload pattern and a measurable reduction experiment. Examples include staggering a script, replacing polling with a webhook, caching a shared dependency, pausing development or quality-assurance automation against production, reducing repeated clones, or using branches instead of large fork trees. Re-run the same query after the change to measure whether burst count, aggregate elapsed time, or Git total duration decreased.

## GUI procedure

- **GHES bundle status:** the ESB/CRE Dashboard is the supported GUI touchpoint, limited to confirming or triggering bundle extraction. See [[ESB Support Bundle Workflow#GUI procedure]].
- **GHEC metrics:** the CRE Dashboard web UI is the supported interface for reviewing GHEC account metrics, historical trends, and early-warning signals. This runbook uses its API/MCP tools (`get_ghec_metrics`, `get_ghec_metrics_history`, `get_ghec_early_warning`, `get_bundle_ids`, `get_customer`) as the scriptable equivalent. Detailed web UI navigation is not documented in this vault, so use the dashboard directly for interactive review.

## CLI/API procedure: GHEC evidence collection

1. Confirm the customer and scope. See [[Health Check 101#1. Confirm scope]].
2. Pull current metrics and recent history through the CRE Dashboard tools (`get_ghec_metrics`, `get_ghec_metrics_history`).
3. Pull early-warning signals (`get_ghec_early_warning`) to check for already-flagged risk areas.
4. Cross-check with GHEC staff-telemetry starting points if a specific symptom needs deeper evidence. See [[Splunk Cheatsheet#GHEC staff telemetry starting points]].
5. Record the metrics snapshot date/window explicitly; dashboard- and Kusto-backed metrics are not necessarily real-time, so note the data's freshness alongside each finding.

## Expected outputs and success criteria

- **GHES pass:** all seven pillars have cited evidence or an explicit evidence gap, the instance profile is recorded, and a baseline comparison is included whenever a prior report exists.
- **GHEC pass:** current metrics, trend history, and early-warning signals are all retrieved, and their snapshot window is recorded.
- An evidence-collection pass that skips a pillar without recording why is incomplete, not "clean."

## Validation and cross-check

- Cross-check the bundle ID and hostname you are investigating against the dashboard record. See [[ESB Support Bundle Workflow#Validation and cross-check]].
- Probe raw log format before trusting a parsed field; an empty result after a mismatched probe is a parser gap, not evidence of no event. See [[Support Bundles Cheatsheet#State that must be checked before making claims]].
- Compare the evidence window against a healthy baseline or the previous Health Check whenever one exists, rather than relying on one snapshot.
- If both a GHES bundle and a Splunk-ingested copy of the same bundle are available, cross-check one pillar's numbers between both sources before relying on either alone.

## Errors and recovery

| Issue | What to check |
|---|---|
| A pillar shows no events | Check retention and coverage first (step 6 above); do not record it as healthy until ruled out. See [[Support Bundles Cheatsheet#2. Confirm the bundle can cover the incident]] |
| Launch cache stuck `pending` | Re-check dashboard extraction vs shell-host readiness. See [[ESB Support Bundle Workflow#3. Confirm the launch cache is ready]] |
| Duration units unclear | Confirm seconds vs milliseconds before comparing across pillars or bundles |
| CRE Dashboard call fails | Re-check the API token and entitlement; do not substitute a stale metrics snapshot without noting the gap |
| Bundle and GHEC identifiers mixed | Keep GHES appliance IDs and GHEC/dotcom IDs in separate queries; they can collide |

## Stop and escalate

Escalate rather than continuing to collect evidence alone when:

- A required data source is unavailable (bundle won't extract, Splunk/Kusto/CRE Dashboard auth cannot be restored) and there is no fallback for that pillar.
- Evidence surfaces an active, undocumented incident that needs immediate attention rather than waiting for the scheduled Health Check delivery.
- A finding implies an internal flag change or an engineering-managed service change; route that to engineering instead of recommending it directly.

Apply the general investigation and escalation judgment in [[Investigation and Escalation Judgment]], including building an evidence chain before escalating.

## Related notes and authoritative docs

- [[Health Check 101]] - end-to-end Health Check workflow, scope confirmation, and report structure.
- [[Health Check Structure and Review Reference]] - report template, review checklist, and reviewer patterns (report-writing judgment, not evidence collection).
- [[Support Bundles Cheatsheet]] - bundle investigation methodology this runbook reuses.
- [[ESB Support Bundle Workflow]] - accessing an extracted bundle through ESB Tools.
- [[Splunk Cheatsheet]] - SPL patterns reused for pillar evidence.
- [[GHES Cheatsheet]] - `ghe-*` command reference and safety boundary.
- [[Kusto-KQL Cheatsheet]] - KQL cross-checks where applicable.
- [[GHEC vs GHES Cheatsheet]] - platform boundary reference.
- [[Investigation and Escalation Judgment]] - when and how to escalate.
- `skills/ghes-customer-health/SKILL.md` and its `references/` (metric catalog, rubric, caveats, Splunk queries) in the `github/llm-assist` repo - complete technical workflow behind the seven pillars.
- [Providing data to GitHub Support, GHES 3.20](https://docs.github.com/en/enterprise-server@3.20/support/contacting-github-support/providing-data-to-github-support)

## Freshness note

The seven-pillar rubric and CRE Dashboard tool names come from the `github/llm-assist` repo's `ghes-customer-health` skill and CRE Dashboard integration. Verify against those sources if this runbook and the repo diverge. Reviewed 2026-08-13.
