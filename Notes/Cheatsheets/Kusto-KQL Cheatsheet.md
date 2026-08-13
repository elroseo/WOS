---
tags:
  - kusto
  - kql
  - cheatsheet
  - read-only
audience: CRE
updated: 2026-08-13
---

# Kusto / KQL Cheatsheet

## Scope and when to use this

Use this when you need KQL syntax or query patterns to investigate GitHub's internal telemetry (or any Kusto-backed data) during a customer investigation. This is a **generic KQL reference** - it does not name specific GitHub clusters, databases, or tables. Confirm those against your current schema cache or routing documentation before querying.

## Prerequisites and access

- Azure CLI authentication: `az login --use-device-code`, or confirm an existing token with `az account get-access-token --resource https://kusto.kusto.windows.net`.
- Entitlement/access to the specific Kusto cluster and database you need for the investigation.
- A Kusto client - the Kusto MCP tools, the Azure Data Explorer web UI, or any tool that can execute KQL.

## Safety and read-only boundary

All Kusto usage here is **read-only**. KQL queries never modify data. Commands that start with `.` (control commands, e.g. `.show tables`) are a separate category - some are read-only (`.show`), others are administrative/mutating and are out of scope for this cheatsheet. Don't run a `.` command unless you know it's read-only.

## Platform scope

This cheatsheet covers general KQL syntax and investigation patterns, not any specific GitHub Kusto cluster, database, or table. Names and schemas vary by investigation - always verify them against your current schema cache or routing documentation rather than reusing a name from a past investigation.

## What is Kusto / KQL?

Kusto is the query engine behind **Azure Data Explorer** (ADX), and **KQL** (Kusto Query Language) is the read-only language you use to interrogate it. It is built for fast, large-scale analysis of append-only telemetry - logs, metrics, traces, and events. A query starts with a **table**, then flows data left-to-right through a series of operators separated by the pipe (`|`) character, each transforming the rows that the previous step produced. It reads like a Unix pipeline and is purpose-built for "slice millions of log rows by time and dimension" investigations.

## How it's typically used

- Querying service telemetry and request logs at scale
- Time-series analysis: trends, spikes, error-rate over time
- Correlating events across services by a shared ID (request ID, repo ID, user ID)
- Building dashboards and alerts on operational data
- Ad-hoc incident investigation ("what changed at 14:32 UTC?")

## CRE perspective

Many GitHub internal investigations route through Kusto-backed telemetry. As a CRE you'll use KQL to find the needle: filter a huge table down to one customer/repo/time window, aggregate to see error rates and latency, and join across tables to follow a transaction. The skills that matter most are **time filtering early** (always narrow `Timestamp` first - it's the cheapest filter), choosing the right `summarize` aggregation, and using `bin()` for time-bucketing. Start broad with `take`/`count`, then progressively `where` your way down.

> **KQL is case-sensitive** for column/table names and most string operators. Use the `_cs`-free operators (like `has`, `contains`) for case-insensitive matching, and `==` vs `=~` for case-sensitive vs insensitive equality.

---

## Quick task: investigate a symptom with KQL

1. **Confirm access** - verify `az login` / your token is valid for the target cluster.
2. **Confirm the table, schema, and grain first** - run `TableName | getschema` (or check the schema cache) before writing filters. Don't guess column names.
3. **Filter time first** - add `| where Timestamp > ago(...)` (or the equivalent time column) as the first or second line, before other filters.
4. **Sanity-check the row count** - run `| count`, or note the row count of your filtered result, before summarizing. Zero rows or an unexpectedly huge number is a signal to revisit your filters, not a result to trust.
5. **Inspect sample rows** - `| take 10` and review 3-5 rows to confirm the columns and values match what you expect (correct shape, no unexpected nulls).
6. **Aggregate** - once the filtered/sampled data looks right, add your `summarize`/`join`/`render` logic.
7. **Cross-check** - where possible, validate the finding against a second query or data source before treating it as conclusive.

**Expected result:** A query that returns a reasonable, explainable row count, with sample rows that match the expected shape, and an aggregate result you can defend if asked "how do you know?"

**Verify:** Re-run step 4 (row count) and step 5 (sample rows) after any change to your `where` clauses - a small edit can silently change which rows match.

---

## Anatomy of a query

```kql
TableName                                  // 1. source table
| where Timestamp > ago(1h)                // 2. filter (do time first!)
| where Region == "westus2"
| summarize count() by bin(Timestamp, 5m)  // 3. aggregate
| order by Timestamp asc                   // 4. sort
| take 100                                 // 5. limit
```

Data flows top-to-bottom; each `|` passes its output to the next operator.

---

## Core operators

| Operator | What it does |
|---|---|
| `take N` / `limit N` | Return N arbitrary rows (fast sampling) |
| `where <predicate>` | Filter rows (use early and often) |
| `project col1, col2` | Select/rename/compute specific columns |
| `project-away col` | Drop columns |
| `extend new = expr` | Add a computed column |
| `summarize agg() by group` | Aggregate (GROUP BY) |
| `count` | Count rows |
| `distinct col` | Unique values |
| `order by col [asc|desc]` | Sort (alias: `sort by`) |
| `top N by col` | Top N rows by a column |
| `join kind=inner (T2) on Key` | Combine two tables |
| `union T1, T2` | Stack rows from multiple tables |
| `render timechart` | Visualize the result |

---

## Time filtering (do this first)

| Expression | Meaning |
|---|---|
| `ago(1h)` / `ago(30m)` / `ago(7d)` | Relative to now |
| `where Timestamp > ago(1d)` | Last 24 hours |
| `where Timestamp between (datetime(2026-06-25 14:00) .. datetime(2026-06-25 15:00))` | Explicit window (UTC) |
| `bin(Timestamp, 5m)` | Round timestamps into 5-minute buckets |
| `now()` / `startofday(now())` | Current time / midnight today |

---

## Aggregation with `summarize`

```kql
Requests
| where Timestamp > ago(1h)
| summarize
    total   = count(),
    errors  = countif(StatusCode >= 500),
    p95ms   = percentile(DurationMs, 95),
    avgms   = avg(DurationMs)
  by bin(Timestamp, 5m), Service
| extend errorRate = round(100.0 * errors / total, 2)
| order by Timestamp asc
```

| Aggregation function | Result |
|---|---|
| `count()` | Number of rows |
| `countif(predicate)` | Conditional count |
| `dcount(col)` | Distinct count |
| `sum(col)` / `avg(col)` | Sum / mean |
| `min(col)` / `max(col)` | Extremes |
| `percentile(col, 95)` | 95th percentile (latency!) |
| `make_list(col)` / `make_set(col)` | Collect values into an array |
| `arg_max(Timestamp, *)` | The full row with the latest timestamp per group |

---

## String matching

| Operator | Matches | Case |
|---|---|---|
| `==` | Exact equality | Sensitive |
| `=~` | Exact equality | Insensitive |
| `has` | Whole-term match (indexed, fast) | Insensitive |
| `contains` | Substring (slower) | Insensitive |
| `startswith` / `endswith` | Prefix / suffix | Insensitive |
| `matches regex "..."` | Regular expression | - |
| `in (...)` / `in~ (...)` | Value in a set | Sensitive / insensitive |

> Prefer `has` over `contains` when matching whole words - it uses the term index and is much faster on big tables.

---

## Joining and correlating

```kql
// Follow a request from the frontend into the backend
FrontendLogs
| where Timestamp > ago(1h) and RequestId == "abc-123"
| join kind=inner (
    BackendLogs
    | where Timestamp > ago(1h)
) on RequestId
| project Timestamp, RequestId, Frontend=StatusCode, Backend=BackendStatus
```

| `join kind=` | Keeps |
|---|---|
| `inner` | Only matching rows from both (default-ish) |
| `leftouter` | All left rows + matches |
| `fullouter` | Everything from both |
| `leftanti` | Left rows with **no** match (great for "missing" checks) |

---

## Investigation patterns

```kql
// 1. Error-rate spike over time
ServiceLogs
| where Timestamp > ago(6h)
| summarize errors = countif(Level == "Error"), total = count() by bin(Timestamp, 10m)
| extend rate = 100.0 * errors / total
| render timechart

// 2. Top failing operations
ServiceLogs
| where Timestamp > ago(1d) and Level == "Error"
| summarize n = count() by Operation
| top 10 by n

// 3. Everything for one customer/repo in a window
ServiceLogs
| where Timestamp between (datetime(2026-06-25 14:00) .. datetime(2026-06-25 15:00))
| where RepositoryId == 1234567
| order by Timestamp asc

// 4. Latest state per entity
DeployEvents
| summarize arg_max(Timestamp, *) by ServiceName
```

---

## Handy scalar functions

| Function | Use |
|---|---|
| `strcat(a, b)` | Concatenate strings |
| `split(s, ",")` | Split into an array |
| `extract(regex, n, s)` | Pull a capture group out of text |
| `parse_json(s)` | Parse a JSON string into a dynamic object |
| `tostring()` / `toint()` / `todatetime()` | Type casts |
| `iff(cond, a, b)` | Inline if/else |
| `case(c1, v1, c2, v2, default)` | Multi-branch |
| `coalesce(a, b)` | First non-null |

---

## Tips & gotchas

- **Filter time first**, then dimensions - it dramatically reduces scanned data.
- Use `take 10` while exploring to avoid pulling huge result sets.
- Column and table names are **case-sensitive**; many string ops are not.
- `summarize ... by bin(Timestamp, X)` is the backbone of time-series analysis.
- `arg_max(Timestamp, *)` beats `top 1 by Timestamp` when you want the latest *full row per group*.
- `render timechart` after a time-bucketed summarize for instant visuals.
- Control commands start with `.` (e.g. `.show tables`) - those are admin commands, not queries.
- Check schema first (`| getschema` or the schema cache) before assuming a column exists - Kusto tables don't necessarily mirror any REST/GraphQL API schema.
- Avoid `column_ifexists()` on GitHub's gh-analytics clusters - it isn't supported there. Confirm the correct column name against the schema instead.

---

## Errors and recovery

| Symptom | Likely cause | Next step |
|---|---|---|
| `SEM0100: column 'X' not found` (HTTP 400) | Column name guessed incorrectly | Re-check the schema with `| getschema` or the schema cache; don't assume a name exists just because it's a "standard" field elsewhere |
| Query times out or scans a huge data volume | Time filter missing, or applied too late in the pipeline | Move the time filter to the top of the query and narrow the window |
| `column_ifexists()` fails | Not supported on GitHub's gh-analytics clusters | Check the schema cache for the correct column name and reference it directly |
| Zero rows returned unexpectedly | Time window, casing, or join key mismatch | Temporarily widen the time window, verify `==` vs `=~` case sensitivity, and check join key cardinality |

## Stop and escalate if

- You need write/administrative access (creating tables, altering retention, running mutating control commands) - this is out of scope for a CRE investigation; route to the team that owns the cluster.
- Access/entitlement is denied for a cluster or database you need - request the correct entitlement rather than working around it.
- A query result seems to contradict the customer's reported symptom - don't conclude root cause from a single query; cross-check a second table or data source (see [[Splunk Cheatsheet]] for the equivalent Splunk-side check).

---

## Quick reference links

- [KQL overview (Microsoft Learn)](https://learn.microsoft.com/en-us/kusto/query/)
- [KQL operator reference](https://learn.microsoft.com/en-us/kusto/query/queries)
- [SQL → KQL cheat sheet](https://learn.microsoft.com/en-us/kusto/query/sql-cheat-sheet)
- [Best practices for KQL queries](https://learn.microsoft.com/en-us/kusto/query/best-practices)

## Related links

- [[Splunk Cheatsheet]] - equivalent investigation workflow for Splunk-backed data

## Freshness note

KQL syntax and core operators are stable, but cluster/database/table names and schemas change often. Confirm current names and schema against your schema cache or routing documentation before relying on any example here. Last reviewed: 2026-08-13.
