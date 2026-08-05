---
tags: [support, premium-plus, analytics]
created: 2026-08-05
updated: 2026-08-05
---

# Premium Plus (P+) — Most Common Ticket Topics

**Generated:** 2026-08-05 · **Window:** last 180 days (2026-02-06 to 2026-08-05)
**Scope:** All P+ customers, defined as `mapped_support_plan_at_ticket_open == "GitHub Premium Support Plus"`.

---

## Method & sources

- **Source:** Kusto `gh-analytics.eastus` cluster, `service_cs_analytics` database (reopen uses `zendesk` database).
- **Tables:** `supportv3_ticket_dim` (plan + priority), `supportv3_ticket_fact` (created/solved + resolution time + category id), `supportv3_ticket_category_dim` (category names), `zendesk.ticket_events` (reopen), `zendesk.tickets` (escalation tag).
- **P+ definition:** the canonical mapped support plan `GitHub Premium Support Plus`. Excludes `GitHub Engineering Direct (PSP)` and legacy Premium tiers.
- **Time to close:** `full_resolution_time_in_minutes_calendar` (elapsed calendar time, converted to hours). Wall-clock elapsed, so it includes customer wait, not agent effort.

**Total P+ tickets in window:** 6,998 · **Overall median time to close:** 157.0 hours (~6.5 days).

---

## Top-level category breakdown

| Category (internal codename) | What it covers                                                       | Tickets | Median close (hrs) | P90 close (hrs) | Urgent/High |
|------------------------------|----------------------------------------------------------------------|--------:|-------------------:|----------------:|------------:|
| Worktent                     | Core platform: repos, PRs, Git, migrations, sensitive-data removal   |   1,889 |              148.0 |           477.5 |         508 |
| Infrastructure               | GHES appliance: upgrades, HA/replication, performance, health checks |   1,339 |              183.4 |           670.1 |         423 |
| C2C                          | GitHub Actions (workflows, runners)                                  |     766 |              158.4 |           504.3 |         253 |
| Copilot                      | Copilot (chat, agents, enablement)                                   |     683 |              210.6 |           698.5 |         146 |
| Ecosystem                    | API, rate limits, GitHub Apps, webhooks                              |     673 |              162.6 |           482.5 |         209 |
| Access                       | Auth, SSO/SAML, SCIM, user/org admin                                 |     574 |              163.1 |           483.8 |         164 |
| Code Security                | GHAS: code scanning, secret scanning, Dependabot                     |     255 |              186.4 |           681.2 |          50 |
| S&R Account Security         | 2FA / account recovery                                               |     250 |                8.4 |           137.1 |          12 |
| BIA                          | Business-impacting / account situations                              |     152 |              145.4 |           368.9 |          56 |
| Security Incident Response   | Security incidents                                                   |      82 |              148.6 |           379.5 |          38 |

---

## Most common specific topics (top 20)

| Topic                                | Tickets | % of P+ | Median close (hrs) | P90 close (hrs) | Urgent/High |
|--------------------------------------|--------:|--------:|-------------------:|----------------:|------------:|
| Sensitive data removal               |     461 |    6.6% |               49.5 |           334.1 |          79 |
| Infrastructure (general GHES)        |     382 |    5.5% |              170.2 |           600.0 |         161 |
| Actions (general)                    |     283 |    4.0% |              152.4 |           546.7 |         103 |
| GHES Upgrade                         |     194 |    2.8% |              213.8 |           689.2 |          41 |
| Pull requests                        |     177 |    2.5% |              148.7 |           454.2 |          60 |
| API primary/secondary rate limits    |     173 |    2.5% |              146.6 |           373.6 |          64 |
| Copilot (general)                    |     155 |    2.2% |              194.8 |           568.3 |          45 |
| GitHub Apps                          |     141 |    2.0% |              162.5 |           574.6 |          34 |
| Client Connectivity                  |     136 |    1.9% |              136.3 |           423.1 |         102 |
| Repositories                         |     131 |    1.9% |              150.4 |           577.0 |          37 |
| Health Check (CRE-delivered)         |     115 |    1.6% |              207.2 |          1005.6 |           3 |
| Actions :: Workflow Runs             |     105 |    1.5% |              171.0 |           528.4 |          44 |
| Data Migration :: GEI/Octoshift      |     103 |    1.5% |              189.0 |           430.8 |          19 |
| Git                                  |      99 |    1.4% |              151.8 |           610.1 |          54 |
| BIA :: Billing Invoiced Accounts     |      99 |    1.4% |               94.3 |           364.0 |          40 |
| API (general)                        |      98 |    1.4% |              147.8 |           451.5 |          38 |
| Copilot :: Cloud Agent               |      97 |    1.4% |              304.8 |           932.2 |          16 |
| 2FA / Account Recovery               |      91 |    1.3% |                3.0 |            65.3 |           3 |
| Data Migration (general)             |      90 |    1.3% |              197.9 |           668.8 |          21 |

---

## Escalation & reopen rate by topic

Same 180-day P+ window. **Reopen** = a ticket whose status changed from `solved` back to `open`/`pending`/`hold` at least once (reconstructed from `zendesk.ticket_events`). **Escalation** = ticket carries a Zendesk `escalation` tag (proxy).

> **Data-access note:** the precise escalation link table `supportv3_escalations_issue_bridge` is access-restricted (`gh.io/bulkhead`), so escalation here is the Zendesk-tag proxy and slightly undercounts. Reopen is a full reconstruction and is reliable.

**Overall:** ~12.9% reopen rate, ~5.5% escalation rate.

| Category                   | Tickets | Reopen % | Escalation % |
|----------------------------|--------:|---------:|-------------:|
| Worktent (core platform)   |   1,889 |    14.8% |         6.9% |
| Infrastructure (GHES)      |   1,339 |    15.4% |         4.4% |
| C2C (Actions)              |     766 |    11.9% |         7.3% |
| Copilot                    |     683 |    11.1% |         7.8% |
| Ecosystem (API/Apps)       |     673 |     9.7% |         4.8% |
| Access (auth/SSO)          |     574 |    10.8% |         3.1% |
| Code Security (GHAS)       |     255 |    14.5% |         7.8% |
| S&R Account Security       |     250 |     8.8% |         1.2% |
| BIA                        |     152 |    14.5% |         5.3% |
| Security Incident Response |      82 |     9.8% |         2.4% |

**Small-volume outliers worth a glance:** T&S (30.0% reopen, n=50), S&R Compliance (25.4% reopen, n=63), S&R BIA (26.3% escalation, n=19). Low volume, but the rework rates suggest a process gap rather than technical difficulty.

### Where to spend review time (volume x reopen x escalation)

- **Infrastructure (GHES)** — highest reopen among high-volume topics (15.4%, ~206 reopened). Escalation lower (4.4%), so solved in-tier but often not first-time-right. Biggest "fix the playbook" opportunity.
- **Worktent (core platform)** — largest absolute rework pool: ~279 reopened + ~130 escalated. High volume amplifies a moderate rate; split into sub-topics (Git, PRs, Data Migration) to target.
- **Copilot & Code Security** — highest escalation rates (7.8% each). Newer/complex surfaces where support can't fully resolve. Copilot also has the slowest close and the slow Cloud Agent sub-topic. Candidate for KB/tooling + engineering partnership.
- **C2C / Actions** — high escalation (7.3%) with high volume; runner/workflow issues frequently need engineering.
- **Access** — healthy: low reopen (10.8%) and lowest escalation (3.1%) of the big topics. Leave it alone.

---

## Type + typical remedy per topic

> Remedies are the standard resolution paths for each category, **derived from GitHub Support domain knowledge, not extracted from ticket text**. Treat as the typical playbook, not a per-ticket fact.

| Topic                          | Type                        | Typical remedy / solution                                                                                          |
|--------------------------------|-----------------------------|-------------------------------------------------------------------------------------------------------------------|
| Sensitive data removal         | Request (self-service-able) | Guide through `git filter-repo` / BFG, cache invalidation, and (for public forks) escalate to purge the reference. |
| GHES Infrastructure / Perf     | Break-fix / advisory        | Support-bundle analysis (ESB-Tools), resource/config tuning, HA/replication health review, capacity guidance.     |
| GHES Upgrade                   | Advisory / planned          | Pre-upgrade readiness review, hotpatch vs full-upgrade guidance, rollback plan, post-upgrade after-action check.  |
| Actions (workflows/runners)    | Break-fix / config          | Runner registration/scaling fixes, ARC guidance, workflow YAML debugging, self-hosted runner connectivity.        |
| Copilot / Cloud Agent          | Enablement / usage          | Seat assignment, policy/feature-flag config, rate-limit/premium-request triage, network allowlist, IDE setup.     |
| Pull requests / Repos / Git    | Break-fix                   | Git object/ref repair, large-repo and LFS guidance, merge/diff behavior clarification.                            |
| API rate limits                | Advisory                    | Explain primary vs secondary limits, review request patterns, recommend conditional requests / GraphQL, backoff.  |
| GitHub Apps                    | Config                      | App permissions/installation, webhook delivery, token/JWT auth debugging.                                         |
| Data Migration (GEI/Octoshift) | Project-based               | Migration tooling triage (bbs2gh/ado2gh/ghe-migrator), failure-pattern diagnosis, re-run guidance.                |
| Access (SSO/SAML/SCIM)         | Config / break-fix          | SAML/SCIM provisioning fixes, org/enterprise membership, PAT/OAuth troubleshooting.                               |
| 2FA / Account Recovery         | Request                     | Identity verification + recovery flow. Fastest to close (~3h median).                                             |
| Health Check                   | CRE-delivered engagement    | Scheduled proactive review; long "close" time reflects engagement duration, not an incident.                     |
| Code Security (GHAS)           | Config / advisory           | Code-scanning/CodeQL setup, secret-scanning config, Dependabot alerts tuning.                                     |

---

## Reading the numbers (caveats)

- **Median close time is elapsed calendar time**, so long values (Copilot ~211h, Infrastructure ~183h, Health Check ~207h) are dominated by scheduled/planned work and customer-side wait, not agent effort.
- **Copilot :: Cloud Agent is the slowest topic (~305h median)** and worth a closer look; it may reflect newer/complex features where remedies aren't yet mature.
- **Health Check** and **Upgrade** are proactive/planned engagements; high "time to close" is expected and healthy.
- **Fast-closing topics** (2FA recovery ~3h, Sensitive data removal ~50h) are well-defined request flows.
- **Highest urgent/high concentration:** Worktent (508), Infrastructure (423), C2C/Actions (253), Client Connectivity (102) — most likely to be customer-impacting incidents.
- The blank category row (156 tickets, ~0.5h close) is uncategorized/auto-closed and can be ignored for topic analysis.
- Data freshness: `service_cs_analytics` is current through 2026-08-05 12:00 UTC; recent tickets may still be open and will pull medians up as they resolve.

---

## Still to look at (next metrics)

Done: topic volume, time-to-close, reopen rate, escalation rate. Remaining from the shortlist:

3. **Submitted vs current priority** — where customers over-signal urgency vs where we under-triage (`priority_at_creation` vs `priority_at_solved`).
4. **CSAT by topic** — pair satisfaction with volume; high-volume + low-CSAT = top fix.
5. **Repeat customers per topic** — systemic (many accounts) vs account-specific (coaching / health-check opportunity).
6. **Month-over-month trend** — is a topic growing or a one-off spike.
7. **Deflection candidates** — high-volume, fast-close, low-complexity topics for docs/automation.

---

## Related

- This note is the single source of truth (repo copy removed).
- [[LLM Assist Skills and Agents]] · relevant skills: `pplus-cre-value-report`, `qbr-report`, `ticket-priority-triage`
