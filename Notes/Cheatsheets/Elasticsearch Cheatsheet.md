---
tags:
  - elasticsearch
  - ghes
  - search
  - troubleshooting
  - cheatsheet
  - runbook
audience: cre
updated: 2026-08-13
---

# Elasticsearch Cheatsheet

## What this is and when to use it

Elasticsearch is a distributed search and analytics engine built on Apache Lucene. It stores JSON **documents** in **indices**, splits each index into **shards**, and replicates shards across nodes for redundancy. You query it over a REST API.

On GHES, **every search goes through Elasticsearch**, including code, issues, PRs, and the **audit log**. Each replica node holds a full copy of the indices. Use this runbook when a customer reports broken search, duplicate or missing search results, audit-log gaps, or a failover/upgrade problem that touches search.

> [!important] GHES key points
> - Elasticsearch backs **search + audit log**; a full copy of the indices lives on each replica.
> - **Red cluster status = unassigned primary shards** = search is broken. Yellow = replicas unassigned (still functional, not redundant).
> - Symptoms to associate with ES: search returns nothing, **duplicate results**, stale results, audit-log gaps, failover problems.
> - Some GHES version jumps require running an **index migration script** before upgrading; check the release notes for the specific version.
> - Prefer the documented `ghe-*` wrappers over hitting the ES REST API directly on an appliance.

## Prerequisites

- SSH access to the GHES appliance (or a node, on a cluster/HA topology), or REST access to a self-managed Elasticsearch cluster.
- No special entitlement beyond standard GHES admin/investigation access.

## Platform scope

- **GHES appliance**: this is the primary scope of this runbook. Elasticsearch is an internal service; access it through the documented `ghe-*` wrappers and `nomad status elasticsearch`, not ad hoc REST calls, unless Support/Engineering directs otherwise.
- **Self-managed Elasticsearch** (customer's own cluster, unrelated to GHES): the REST API commands below apply directly.

## Safety and read-only boundary

> [!warning] Default to read-only cluster health checks
> `GET` requests (`_cluster/health`, `_cat/*`, `_cluster/allocation/explain`) are read-only and safe to run at any time. Mutating endpoints (`_forcemerge`, `_cache/clear`, allocation settings changes, reindex/migration operations) change cluster state and can affect customer-visible search availability. Do not run them against a GHES appliance directly; that is not normal CRE investigation practice and should go through Support/Engineering guidance or an approved change.

## Quick procedure (read-only triage)

1. Confirm the symptom: search returns nothing, duplicate results, stale results, an audit-log gap, or a failover/upgrade issue.
2. Check overall cluster health: `GET _cluster/health` or `GET _cat/health?v` for a one-line summary (green/yellow/red, node and shard counts).
3. If red or yellow, break it down per index: `GET _cluster/health?level=indices` and `GET _cat/indices?v`.
4. Identify unassigned shards: `GET _cat/shards?v` (filter for `UNASSIGNED`), then `GET _cluster/allocation/explain` for the reason.
5. Cross-check that the service itself is up: `nomad status elasticsearch` (see [[Nomad Cheatsheet]]).
6. Check disk pressure, since ES stops allocating shards past its watermark: `ghe-check-disk-usage`.
7. If the customer reports an upgrade issue, check the release notes for a required pre-upgrade index migration before assuming a cluster problem.

## GUI steps

N/A. GHES does not ship a supported Elasticsearch GUI (no Kibana). Use the REST/`ghe-*` procedure above.

## Expected output / success criteria

- `_cluster/health` / `_cat/health?v` returns a `status` field of `green`, `yellow`, or `red`, plus plausible node and shard counts (non-zero, matching the known topology).
- `_cat/indices?v` lists the expected indices with reasonable document counts and sizes; an empty or missing index for a known feature is worth investigating further.
- `nomad status elasticsearch` shows the allocation in a `running` state.

## Validation / cross-check

- A **red** status must show at least one shard as `UNASSIGNED` in `_cat/shards?v`; if not, re-check you queried the right cluster/node.
- Cross-check a "duplicate results" report against index state (a stale/duplicate index after an interrupted reindex) rather than assuming it's a query-side bug.
- Confirm disk watermark suspicions with `ghe-check-disk-usage` output, not just cluster-health text.
- For audit-log gaps, correlate the missing time window with any observed cluster health dip in the same window.

## Errors and recovery

| Symptom | What to check |
|---|---|
| Search returns nothing | ES cluster health (red?), service running (`nomad status elasticsearch`) |
| **Duplicate search results** | Stale/duplicate index state; often needs a reindex, check the KB for the version |
| Cluster stuck **yellow** after failover | Unassigned replica shards; `allocation/explain`, check node count vs replica count |
| Cluster **red** | Unassigned primary shard; check disk watermarks and node membership |
| Upgrade hangs / fails at ES step | Missing pre-upgrade **index migration**; check release notes |
| High CPU / slow search | Heap pressure, large/unmerged segments, artificial query load |
| Audit log missing entries | ES indexing lag or shard issues; verify cluster health |

## Stop / escalate

Escalate when cluster status is red and the cause isn't a straightforward disk/node issue you can resolve read-only, when a required index migration or reindex is unclear for the customer's exact version, or when any mutating ES action seems necessary. Route mutating actions through Support/Engineering rather than hand-running them. See [[Investigation and Escalation Judgment]] for escalation thresholds and the evidence to gather first.

---

## Mutating endpoints: customer-impact warning

> [!danger] Read before running anything below
> These are mutating REST calls or maintenance operations that can affect search availability or index integrity. Confirm authorization (Support/Engineering guidance or an approved change) before running any of them, and prefer the documented `ghe-*` wrappers over the raw REST endpoint on a GHES appliance.

---

## Cluster health & status

| Command (REST) | What it shows |
|---|---|
| `GET _cluster/health` | Overall status (green/yellow/red), node & shard counts |
| `GET _cluster/health?level=indices` | Health broken down per index |
| `GET _cat/health?v` | One-line cluster health summary |
| `GET _cat/nodes?v` | Nodes, roles, heap, CPU, load |
| `GET _cat/indices?v` | Indices with doc counts, size, health |
| `GET _cat/shards?v` | Every shard, its node, and state |
| `GET _cat/allocation?v` | Disk usage and shard count per node |

```bash
# On a host running ES locally (default port 9200)
curl -s localhost:9200/_cluster/health?pretty
curl -s "localhost:9200/_cat/indices?v&health=red"
```

| Status | Meaning |
|---|---|
| 🟢 green | All primary + replica shards assigned |
| 🟡 yellow | All primaries assigned, some replicas not (no redundancy) |
| 🔴 red | At least one **primary** shard unassigned - data/search unavailable |

---

## Diagnosing unassigned shards

| Command | What it shows |
|---|---|
| `GET _cluster/allocation/explain` | Why a specific shard is unassigned |
| `GET _cat/shards?v \| grep UNASSIGNED` | List all unassigned shards |
| `GET _cluster/health?level=shards` | Shard-level health detail |

Common causes: node left the cluster, disk **watermark** exceeded (ES stops allocating), or a failed/interrupted migration.

| Setting | Purpose |
|---|---|
| `cluster.routing.allocation.disk.watermark.low` | Stop allocating new shards to a node |
| `cluster.routing.allocation.disk.watermark.high` | Move shards off a too-full node |
| `cluster.routing.allocation.enable` | Enable/disable shard allocation (set during maintenance) |

---

## Indices

> [!danger] Customer impact
> `POST <index>/_forcemerge` and `POST <index>/_cache/clear` mutate cluster state on a running index. Forcemerge is expensive and can add load during an incident; do not run either against a GHES appliance without Support/Engineering guidance.

| Command | What it does |
|---|---|
| `GET <index>/_count` | Number of documents in an index |
| `GET <index>/_mapping` | Field types for an index |
| `GET <index>/_settings` | Index settings (shards, replicas) |
| `GET _cat/indices?v&s=store.size:desc` | Indices sorted by size |
| `POST <index>/_forcemerge` | Merge segments (reclaim space; expensive) |
| `POST <index>/_cache/clear` | Clear caches |

---

## GHES wrappers (prefer these on an appliance)

| Command | What it does |
|---|---|
| `ghe-check-disk-usage` | Check disk pressure (ES is sensitive to it) |
| `nomad status elasticsearch` | Confirm the ES service/allocation is running |

> [!warning] No verified wrapper syntax beyond the two commands above
> This file does not have verified syntax for a dedicated `ghe-es-*` cluster-maintenance or reindex/migration command. Do not guess flags. Check the current version-specific [GHES command-line utilities](https://docs.github.com/en/enterprise-server@latest/admin/administering-your-instance/administering-your-instance-from-the-command-line/command-line-utilities) reference and the version's release notes/KB for the documented repair or migration procedure before running anything beyond the two confirmed commands above.

---

## Related notes and docs

- [Elasticsearch cat APIs](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat.html)
- [Cluster health API](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-health.html)
- [Fix common cluster issues (red/yellow)](https://www.elastic.co/guide/en/elasticsearch/reference/current/fix-common-cluster-issues.html)
- [GHES command-line utilities](https://docs.github.com/en/enterprise-server@latest/admin/administering-your-instance/administering-your-instance-from-the-command-line/command-line-utilities)
- [[GHES Deep Dive]] · [[GHES Cheatsheet]] · [[Support Bundles Cheatsheet]] · [[Nomad Cheatsheet]]

## Freshness note

Restructured as a CRE runbook on 2026-08-13. REST endpoint syntax is standard Elasticsearch and should be stable across versions, but always confirm the `ghe-*` wrapper set against the customer's specific GHES version docs before relying on anything not already verified in this file.
