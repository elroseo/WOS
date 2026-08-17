---
tags:
  - customer
  - paypal
  - cre
  - ghes
  - ghec
  - migration
updated: 2026-08-17
lookback: 2025-08-17 to 2026-08-17
---

# PayPal

## TL;DR

PayPal is a large hybrid GitHub Enterprise Server (GHES), GitHub Enterprise Cloud (GHEC) with Enterprise Managed Users (EMU), and GitHub Advanced Security (GHAS) account. The central program is a roughly 26,000-repository migration to EMU while keeping the remaining GHES estate stable. Migration velocity improved materially in early 2026, but the June target was not fully met and a remainder plan was still being aligned in late July. Services owns migration execution; CRE owns reliability oversight, bundle trend analysis, upgrade risk, and operational follow-through. [CRE-1] [SL-1] [SL-12] [SL-30]

The account's reliability posture is currently stable, but the year included a major code-scanning overload, migration archive/storage failures, intermittent migration blocks, disk spikes, IP allow-list problems, and certificate/NTP maintenance. Current recurring risks are migration completion, GHES end-of-support timing, LFS and large-file migrations, runner-to-storage connectivity, unsupported production modifications, disaster-recovery evidence, GitHub App scale, and post-migration workflow efficiency. [ZD-3755329] [ZD-3858956] [ZD-4094119] [CRE-1]

PayPal prefers incidents in Zendesk and long-running programs in shared repositories and Slack. Muthu is the main GHES operator in India time; Mike Hodgdon is the main GHEC/EMU administrator in Arizona. Before troubleshooting a migration ticket, confirm the current wave and ownership with Services. [CRE-1]

## Account snapshot

| Area | Current context |
| --- | --- |
| Platform | Hybrid GHES and GHEC EMU with GHAS; 14,760 licensed seats recorded |
| Environment | Production and QA GHES, each with primary and replica; large GCP instances |
| GitHub team | CRE `@regmontanhani` with `@aboutthatjazz`; CSM `@star6ix9`; CSA `@srvchawla`; Sales `@rbriantjr`; Services context `@amenocal` |
| Customer contacts | Muthu: GHES operations, Mumbai; Mike Hodgdon: GHEC/EMU administration, Arizona; Guru: senior decision-maker |
| Useful channels | `#internal-paypal`, `#github-paypal` |
| Shared repo | [githubcustomers/PayPal](https://github.com/githubcustomers/PayPal) |
| Current health | Stable, CHIP 5/5 through June 2026; no recent major GHES outage |

Source: [CRE-1]

## What changed this year

- **Migration moved from slow to high-volume execution:** January showed 132 migrations over 14 days. February reached 3,764 total. March recorded 1,694 through March 20. April reached 2,817 by April 24, and May recorded 2,231 through May 15. Most were GHES-sourced. [SL-7] [SL-10] [SL-12] [SL-17] [SL-18]
- **The operating model matured:** CRE moved from a general customer-success sync to the Tuesday Services call with Muthu, where GHES findings can be acted on, backed by asynchronous infrastructure summaries. [SL-1] [CRE-2]
- **GHES investment is constrained:** leadership wants to avoid another upgrade, but GHES 3.18 reaches end of life on October 14, 2026. If decommissioning slips, an upgrade to a supported release is required. [SL-22] [SL-40]
- **Cloud enablement expanded:** Copilot workshops, champion development, Jira-to-pull-request automation, Copilot App enablement, and metrics definition became visible workstreams alongside migration. [SL-30] [SL-31] [SL-32] [SL-35]
- **Ticket load was meaningful but controlled:** 42 Zendesk tickets were created in the period, including seven high-priority tickets. Only one remained open on August 17, and it was an account reinstatement request rather than a platform reliability issue. [ZD-ORG]

## Major incidents and trends

### 1. Code-scanning overload and 503s, September to November 2025

Harness uploaded more code-scanning results than the GHES appliance could garbage-collect. Database performance degraded, the TurboScan queue stalled, and developers received 503 responses. GitHub restored database performance and drained the queue. PayPal later re-enabled uploads with before/after bundle monitoring and was advised to reduce or reshape result volume. This remains the year's clearest major reliability incident. [ZD-3755329] [CRE-3]

### 2. Migration archive and storage failures

Archive generation failures were traced to Azure Blob Storage or its connection configuration in October 2025. Additional migration failures included stuck target repositories, runner-to-storage download timeouts, LFS and large-file history problems, and a 403 caused by stale or unsuitable credentials. The repeatable response is to identify the exact migration stage, collect verbose logs, confirm storage reachability from the runner, and involve Services for wave context. [ZD-3858956] [ZD-4094119] [SL-21] [SL-25] [SL-29]

### 3. GHES health and maintenance

The January 3.18.3 upgrade completed successfully and the post-upgrade review found healthy services, replication, databases, and Elasticsearch. A temporary root-disk spike was caused by an unlinked file still held open by `syslog-ng`; it cleared after the file handle was released. [ZD-4032643] [ZD-4050263]

April to June advisory work identified:

- NTP servers unreachable on both nodes, resolved in production by July 1. [ZD-4465392]
- Signing-key, Transport Layer Security certificate, and identity-provider certificate rotations, including a brief service restart requirement. [ZD-4473073] [CRE-2]
- MySQL buffer-pool tuning, backup-warning review, GraphQL growth, webhook retention, and long-overdue routine maintenance. [CRE-3]
- An unsupported SignalFx agent modification on production GHES that should be remembered during diagnostics. [CRE-1]

### 4. Network allow lists and integrations

PayPal-Zettle's Xcode Cloud traffic was blocked because the configured Classless Inter-Domain Routing range did not include the observed integration addresses. Strict allow lists may continue to affect cloud integrations, Copilot reporting, and migration workflows. [ZD-4073739]

## Current migration picture

- The migration scope is approximately 26,000 repositories, with thousands completed in waves during spring 2026. [CRE-1] [SL-2]
- Around 2,000 in-scope repositories remained near the June 30 deadline. Higher-risk repositories were separated by size and characteristics so they would not block simpler batches. [CRE-2]
- LFS and accidental large-file history are handled through migration archive/history-rewrite tooling, not by rewriting the source GHES repository in place, because changing source commit identities can orphan pull-request references. [CRE-2] [SL-21]
- Workflow modernization is part of the exit plan. Jenkins was being decommissioned, Harness was becoming central, and the team expects post-migration work around polling, large clones, pushes, application limits, and rate-limit efficiency. [SL-5] [SL-6]
- A final GHES sunset requires a detailed decommissioning plan, not just repository completion. [SL-5] [SL-14]

## Open items as of August 17

| Priority | Item | Next step |
| --- | --- | --- |
| High | Complete remaining migration and align leadership on the checklist | Confirm current repository remainder, failed/stuck queue, wave owner, and revised completion date [SL-30] |
| High | Avoid unsupported GHES after migration delays | Compare decommission date with GHES 3.18 and 3.19 end-of-life dates; schedule 3.20 if necessary [SL-22] [SL-40] |
| High | Runner-to-storage and archive-download failures | Validate storage credentials, network path, and tool behavior from the same runner context [CRE-2] |
| Medium | LFS and large-file repositories | Continue opt-in history-rewrite workflow and preserve pull-request metadata [SL-21] |
| Medium | Disaster recovery evidence | Reconcile the dashboard statement that recovery relies on GCP snapshots with the customer's statement that Backup Utilities run daily with ten incremental snapshots; verify through logs and a restore exercise [CRE-1] [CRE-2] |
| Medium | Formal health comparison | Compare the next review with the CY25Q4 health check and recent weekly bundle trends [ZD-3943271] |
| Medium | GitHub App scale and API efficiency | Track enterprise-wide app installation limits, Harness integration capacity, polling, clones, and rate-limit behavior [CRE-1] |
| Adoption | Copilot workshops and metrics | Define champions, one or two north-star metrics, persona-based learning, and follow-through from August sessions [SL-30] [SL-32] |

## Common requests and best CRE response

- **Migration blockers:** ask for repository, migration ID, stage, runner, storage mode, exact error, verbose logs, and current Services wave.
- **GHES operational review:** use the weekly cluster bundle, but require live backup evidence when bundle contents do not prove that Backup Utilities ran.
- **Maintenance:** support NTP, signing-key, TLS, and identity-provider rotation first in QA, then validate with a fresh production bundle.
- **Upgrade versus sunset:** tie every upgrade recommendation to the migration forecast and support end-of-life date.
- **Large repositories:** separate LFS, accidentally committed binaries, dependency ordering, and external tooling before assigning a migration wave.
- **Cloud governance:** expect questions about EMU collaborators, identity-provider mappings, forking, secrets, allow lists, and organization policy.
- **Copilot:** common asks are workshops, champions, better user-level metrics, agentic workflows, and editor/feature parity.

## References

- **[CRE-1]** [CRE Dashboard: PayPal](https://cre-dashboard.githubapp.com/customer/paypal), including July 2026 account overview, environment notes, TL;DR, and monthly reports.
- **[CRE-2]** CRE Dashboard touchpoints dated May 8, May 19, June 9, and June 23, 2026; links were unavailable in the source records.
- **[CRE-3]** CRE Dashboard monthly reports September 2025 through June 2026; individual report links were unavailable.
- **[SL-1]** [CRE engagement model and Tuesday Services cadence, May 7, 2026](https://github-grid.enterprise.slack.com/archives/CFQ8WR58T/p1778169638054489)
- **[SL-2]** [Migration status and environment analysis, March 25, 2026](https://github-grid.enterprise.slack.com/archives/CFQ8WR58T/p1774465238640089)
- **[SL-5]** [Post-migration and GHES decommissioning discussion, May 8, 2026](https://github-grid.enterprise.slack.com/archives/CFQ8WR58T/p1778254978499189)
- **[SL-6]** [Post-migration workflow and API-efficiency risk, May 8, 2026](https://github-grid.enterprise.slack.com/archives/CFQ8WR58T/p1778258456720589)
- **[SL-7]** [February migration statistics, February 20, 2026](https://github-grid.enterprise.slack.com/archives/CFQ8WR58T/p1771616132936119)
- **[SL-10]** [February migration totals, February 27, 2026](https://github-grid.enterprise.slack.com/archives/CFQ8WR58T/p1772226181827409)
- **[SL-12]** [May migration report, May 15, 2026](https://github-grid.enterprise.slack.com/archives/CFQ8WR58T/p1778886531638569)
- **[SL-14]** [GHES sunset planning, May 8, 2026](https://github-grid.enterprise.slack.com/archives/CFQ8WR58T/p1778255534654269)
- **[SL-17]** [April migration report, April 24, 2026](https://github-grid.enterprise.slack.com/archives/CFQ8WR58T/p1777067199788189)
- **[SL-18]** [March migration report, March 20, 2026](https://github-grid.enterprise.slack.com/archives/CFQ8WR58T/p1774037949999139)
- **[SL-21]** [Large-file history-rewrite migration workflow, May 19, 2026](https://github-grid.enterprise.slack.com/archives/CFFD0C6EN/p1779201931982119)
- **[SL-22]** [GHES release end-of-life guidance, June 30, 2026](https://github-grid.enterprise.slack.com/archives/CFFD0C6EN/p1782839560584599)
- **[SL-25]** [Missing migration export logs and verbose-log request, October 31, 2025](https://github-grid.enterprise.slack.com/archives/CFFD0C6EN/p1761938825314489)
- **[SL-29]** [Migration plan and five-week wave schedule, May 20, 2026](https://github-grid.enterprise.slack.com/archives/CFFD0C6EN/p1779314956908919)
- **[SL-30]** [July 31 success-sync actions](https://github-grid.enterprise.slack.com/archives/CFFD0C6EN/p1785471764797169)
- **[SL-31]** [Jira-to-pull-request Copilot discovery, June 2, 2026](https://github-grid.enterprise.slack.com/archives/CFFD0C6EN/p1780417056025709)
- **[SL-32]** [August Copilot workshops and champion planning, July 30, 2026](https://github-grid.enterprise.slack.com/archives/CFFD0C6EN/p1785423691915249)
- **[SL-35]** [Copilot App enablement, July 14, 2026](https://github-grid.enterprise.slack.com/archives/CFFD0C6EN/p1784047937960259)
- **[SL-40]** [Upgrade need if decommissioning slips, June 30, 2026](https://github-grid.enterprise.slack.com/archives/CFQ8WR58T/p1782832296084759)
- **[ZD-ORG]** Zendesk organization `260522267`, 42 tickets created August 17, 2025 to August 17, 2026; queried August 17, 2026.
- **[ZD-3755329]** [Code-scanning 503 incident](https://github.zendesk.com/agent/tickets/3755329)
- **[ZD-3858956]** [Migration archive-generation failure](https://github.zendesk.com/agent/tickets/3858956)
- **[ZD-3943271]** [CY25Q4 GHES health check](https://github.zendesk.com/agent/tickets/3943271)
- **[ZD-4032643]** [GHES 3.18.3 upgrade](https://github.zendesk.com/agent/tickets/4032643)
- **[ZD-4050263]** [Root-disk utilization spikes](https://github.zendesk.com/agent/tickets/4050263)
- **[ZD-4073739]** [PayPal-Zettle IP allow-list issue](https://github.zendesk.com/agent/tickets/4073739)
- **[ZD-4094119]** [Blocked EMU repository migration](https://github.zendesk.com/agent/tickets/4094119)
- **[ZD-4130364]** [Automated weekly GHES support bundles](https://github.zendesk.com/agent/tickets/4130364)
- **[ZD-4465392]** [Production NTP remediation](https://github.zendesk.com/agent/tickets/4465392)
- **[ZD-4473073]** [SSO failure after identity-provider certificate rotation](https://github.zendesk.com/agent/tickets/4473073)

## Evidence gaps and conflicts

- Salesforce enrichment was unavailable because Revenue MCP Salesforce authentication was not connected.
- The dashboard says disaster recovery relies on GCP snapshots and is not using Backup Utilities, while the May 19 meeting records PayPal stating that Backup Utilities run daily with ten incremental snapshots. Verify actual backup logs and restore readiness before repeating either statement as fact.
- Repository counts vary by source because some migration reporting counts temporary source/target pairs or different enterprise scopes. Use the latest migration inventory for operational planning.

