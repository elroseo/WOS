# Elasticsearch Cheatsheet

## What is Elasticsearch?

Elasticsearch is a distributed search and analytics engine built on Apache Lucene (written in Java). It stores JSON **documents** in **indices**, splits each index into **shards**, and replicates shards across nodes for redundancy. You query it over a REST API.

## CRE perspective

On GHES, **every search goes through Elasticsearch** - code, issues, PRs, and the **audit log**. Each replica node holds a full copy of the indices. It's one of the top drivers of GHES ticket load, especially around **failovers, cluster health, and duplicate/missing search results**. Some version upgrades need a manual index migration before the upgrade runs. You rarely run raw ES commands on a customer box - you use `ghe-*` wrappers - but understanding cluster health, shards, and red/yellow status makes these tickets far faster.

> [!important] GHES key points
> - Elasticsearch backs **search + audit log**; a full copy of the indices lives on each replica.
> - **Red cluster status = unassigned primary shards** = search is broken. Yellow = replicas unassigned (still functional, not redundant).
> - Symptoms to associate with ES: search returns nothing, **duplicate results**, stale results, audit-log gaps, failover problems.
> - Some GHES version jumps require running an **index migration script** before upgrading - check release notes.
> - Prefer the `ghe-*` wrappers over hitting ES directly on an appliance.

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
| `ghe-es-*` / cluster utilities | Cluster maintenance helpers (see current GHES docs) |
| Repair/reindex via docs | Follow the version-specific KB, don't hand-run ES ops |

> Always confirm the exact command against the customer's **GHES version** docs - ES tooling changes across releases.

---

## Common troubleshooting

| Symptom | What to check |
|---|---|
| Search returns nothing | ES cluster health (red?), service running (`nomad status elasticsearch`) |
| **Duplicate search results** | Stale/duplicate index state; often needs a reindex - check KB for the version |
| Cluster stuck **yellow** after failover | Unassigned replica shards; `allocation/explain`, check node count vs replica count |
| Cluster **red** | Unassigned primary shard; check disk watermarks and node membership |
| Upgrade hangs / fails at ES step | Missing pre-upgrade **index migration**; check release notes |
| High CPU / slow search | Heap pressure, large/unmerged segments, artificial query load |
| Audit log missing entries | ES indexing lag or shard issues; verify cluster health |

---

## Quick reference links

- [Elasticsearch cat APIs](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat.html)
- [Cluster health API](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-health.html)
- [Fix common cluster issues (red/yellow)](https://www.elastic.co/guide/en/elasticsearch/reference/current/fix-common-cluster-issues.html)
- [[GHES Deep Dive]] · [[GHES Cheatsheet]] · [[Support Bundles Cheatsheet]]
