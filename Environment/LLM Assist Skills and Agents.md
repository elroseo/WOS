# LLM Assist — Skills & Agents Reference

Quick reference for the project skills and agents in the `github/llm-assist` repo. These load **only** when running Copilot CLI inside `~/GitHub work/llm-assist` (see [[LLM Assist in CLI]]). Personal skills in `~/.copilot/skills/` (like `today`, `week`, `eod`) load everywhere and are separate.

**Last updated:** 2026-07-29 · **Source:** `skills/` and `agents/` in the repo.

---

## Agents (`agents/`)

| Agent | Use for |
|---|---|
| **Customer Prep** | Concise customer call briefs (WorkIQ meeting context + revenue data + hiring signals). Prefers the `call-prep` skill. |
| **Roadmap Explorer** | Navigate GitHub roadmap issue hierarchies; check a feature's status/ship timing. |
| **filing-research** | Download + convert SEC 10-K / 20-F / annual reports for customer accounts to markdown. |

---

## Skills (`skills/`)

### Account & sales
| Skill | Use for |
|---|---|
| **account-health-snapshot** | Fast 1-page account health (ARR, Copilot, adoption, PRU, GHAS) from Kusto. |
| **account-plan** | Full Sales Account Plan for an enterprise customer. |
| **ae-parent-accounts** | List parent Salesforce accounts owned by an AE. |
| **bookings-billings** | Bookings + consumption billings snapshot for a rep/segment. |
| **call-prep** | Concise customer call brief before a meeting. |
| **gh-value-framework** | Map a customer's GitHub usage signals to product talking points. |
| **mcs-positioning** | MCS / Premium Plus positioning evidence report. |
| **paf** | Product Adoption Framework advisor (key actions, adoption plans). |
| **renewal-convo** | Renewal cheat sheet / batch priority list for upcoming renewals. |
| **revenue-kusto-context** | Resolve enterprise identity; navigate Revenue Kusto tables (c360, canonical). |
| **qbr-report** | Executive Quarterly Business Review for an account. |
| **squad-monthly-report** | Squad-focused monthly report (Kusto tickets + squad Slack). |
| **tbb-report** | Token Based Billing impact estimation (Seat + PRU vs hypothetical). |
| **ubb-rollup-exponential** | AIU-focused seller briefing on PRU consumption growth. |

### Copilot
| Skill | Use for |
|---|---|
| **copilot-adoption-report** | Enterprise Copilot adoption/usage report (seats, features, PRU, benchmarks). |
| **copilot-aiu-review** | Copilot AIU utilization deep-dive (distribution, power users, models, IDE). |
| **copilot-enablement-triage** | Triage unassigned Copilot enablement tickets in the queue. |
| **copilot-rate-limit-triage** | Investigate Copilot rate-limit / premium request complaints. |
| **copilot-setup-advisor** | Help AEs answer Copilot setup questions (Net New / Teams / GHE). |
| **copilot-user-usage-report** | Per-user Copilot usage (model breakdown, PRU, token telemetry). |

### Tickets & support
| Skill | Use for |
|---|---|
| **ticket-resolution** | End-to-end Zendesk ticket investigation → data-backed response. |
| **ticket-rundown** | Scan open queue, find new replies, draft responses. |
| **ticket-hunter** | Rank open tickets most likely resolvable, by tier. |
| **ticket-priority-triage** | Priority, squad routing, category, escalation target for a ticket. |
| **support-escalation-routing** | Build a structured escalation packet (repo, template, CODEOWNERS). |
| **support-kb-search** | Search internal Support KB for guidance + proven KQL/SPL. |
| **preview-feature-triage** | Cross-ref preview/beta features against open tickets. |
| **gei-migration-triage** | Triage GEI migration ticket failures. |
| **git-systems-pre-escalation-check** | 10-phase gate before filing in github/git-systems. |
| **incident-correlation** | Correlate a customer incident window against platform incidents/fixes. |
| **port-issue-filing** | Prepare + publish a Port-routed GitHub issue (after approval). |

### GHES / support bundles
| Skill | Use for |
|---|---|
| **esb-bundle-query** | Investigate GHES support bundles via ESB-Tools SSH. |
| **bundle-timeline** | Chronological system-event timeline from a GHES bundle. |
| **ghes-customer-health** | Splunk-grounded GHES health assessment (7 pillars, R/Y/G). |
| **ghes-bundle-spike-attribution** | Attribute a GHES CPU/API/5xx/load spike to a client/user/path. |
| **ghes-dependency-triage** | Triage GHES systemd service dependency cascade failures. |
| **ghes-upgrade-after-action** | Post-upgrade after-action health report for GHES. |

### Kusto
| Skill | Use for |
|---|---|
| **kusto-ad-hoc-query** | One-off read-only KQL / discovery command. |
| **kusto-investigation-runner** | Run queries + export investigation artifacts (CSV/JSON). |
| **kusto-metadata-search** | Find which table/function has a field. |
| **kusto-schema-explorer** | Cache + inspect Kusto schemas. |
| **kusto-schema-cache-cleanup** | Prune stale schema cache. |
| **kusto-saved-query-authoring** | Turn an ad-hoc query into a saved-query markdown file ("save query"). |
| **kusto-auth-whoami** | Identify which Azure identity is used for Kusto. |
| **kusto-permissions-report** | Report likely ADX roles for the signed-in identity. |
| **kusto-mcp-readonly-server** | Interactive MCP-based schema discovery/queries under guardrails. |
| **pii-guardrails** | Validate the staff PII lookup guardrail (Manager Override). |

### Research & knowledge
| Skill | Use for |
|---|---|
| **github-brain** | Answer any GitHub question with verified, sourced research. |
| **github-issues-search** | Search Issues/PRs/Discussions across github/* repos. |
| **changelog-research** | Already-shipped changes via the public GitHub Changelog. |
| **roadmap-research** | Upcoming ship items from roadmap issue hierarchies. |
| **customer-feedback-research** | Search github/customer-feedback for asks/duplicates. |
| **api-route-lookup** | REST API route ownership + related source. |
| **hubber-lookup** | Look up hubbers from the org chart (github/thehub). |
| **oncall-shift-lookup** | A person's upcoming PagerDuty on-call shifts. |

### Slack & Splunk
| Skill | Use for |
|---|---|
| **slack-search** | Search Slack messages/channels/threads (read-only). |
| **slack-channel-discovery** | Discover channels the user belongs to. |
| **splunk-ad-hoc-query** | One-off read-only Splunk SPL search. |
| **splunk-search-with-sid** | Dispatch SPL to mint a real SID + shareable deep-link. |

### Reports & documents
| Skill | Use for |
|---|---|
| **pdf-document-generator** | Create/convert documents to PDF. |
| **pptx-presentation-generator** | Branded GitHub PowerPoint decks. |
| **word-document-generator** | Generate .docx Word documents. |
| **monorepo-review** | Monorepo health review (GLB traffic + repo metadata + guidance). |
| **pplus-cre-value-report** | Premium Plus CRE Value & Impact report. |
| **llm-assist-adoption-report** | Adoption/engagement report for the llm-assist repo itself. |
| **ghas-poc-readiness** | Pre-POC readiness check for GHAS engagements. |
| **digital-revenue-rescue** | Diagnose metered revenue discrepancies (DS reps). |

### Quality, voice & housekeeping
| Skill | Use for |
|---|---|
| **rubber-duck** | Cross-model critique of code/findings/deliverables (claim sourcing). |
| **voice-profile** | Calibrate + apply the SE's personal writing voice for drafts. |
| **terminology-guardrails** | Strip internal codenames/jargon from customer-facing text. |
| **ready-to-perform** | Strict morning readiness gate before ticket investigation. |
| **daily-briefing** | Calendar + important email daily rundown via WorkIQ. |
| **inbox-triage** | Shared reliability/cursor/voice rules for inbox/Slack triage. |
| **scratchpad-cleanup** | Prune stale files from scratchpad/ and tmp/. |

---

## Related

- [[LLM Assist in CLI]]
- [[dev-environment-setup]]
- [[MCP Servers]]
- Full index in the repo: `skills/README.md`, `agents/README.md`
