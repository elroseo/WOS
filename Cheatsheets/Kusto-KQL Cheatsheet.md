# Kusto / KQL Cheatsheet

## What is Kusto / KQL?

Kusto is the query engine behind **Azure Data Explorer** (ADX), and **KQL** (Kusto Query Language) is the read-only language you use to interrogate it. It is built for fast, large-scale analysis of append-only telemetry — logs, metrics, traces, and events. A query starts with a **table**, then flows data left-to-right through a series of operators separated by the pipe (`|`) character, each transforming the rows that the previous step produced. It reads like a Unix pipeline and is purpose-built for "slice millions of log rows by time and dimension" investigations.

## How it's typically used

- Querying service telemetry and request logs at scale
- Time-series analysis: trends, spikes, error-rate over time
- Correlating events across services by a shared ID (request ID, repo ID, user ID)
- Building dashboards and alerts on operational data
- Ad-hoc incident investigation ("what changed at 14:32 UTC?")

## CRE perspective

Many GitHub internal investigations route through Kusto-backed telemetry. As a CRE you'll use KQL to find the needle: filter a huge table down to one customer/repo/time window, aggregate to see error rates and latency, and join across tables to follow a transaction. The skills that matter most are **time filtering early** (always narrow `Timestamp` first — it's the cheapest filter), choosing the right `summarize` aggregation, and using `bin()` for time-bucketing. Start broad with `take`/`count`, then progressively `where` your way down.

> **KQL is case-sensitive** for column/table names and most string operators. Use the `_cs`-free operators (like `has`, `contains`) for case-insensitive matching, and `==` vs `=~` for case-sensitive vs insensitive equality.

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
| `matches regex "..."` | Regular expression | — |
| `in (...)` / `in~ (...)` | Value in a set | Sensitive / insensitive |

> Prefer `has` over `contains` when matching whole words — it uses the term index and is much faster on big tables.

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

- **Filter time first**, then dimensions — it dramatically reduces scanned data.
- Use `take 10` while exploring to avoid pulling huge result sets.
- Column and table names are **case-sensitive**; many string ops are not.
- `summarize ... by bin(Timestamp, X)` is the backbone of time-series analysis.
- `arg_max(Timestamp, *)` beats `top 1 by Timestamp` when you want the latest *full row per group*.
- `render timechart` after a time-bucketed summarize for instant visuals.
- Control commands start with `.` (e.g. `.show tables`) — those are admin commands, not queries.

---

## Quick reference links

- [KQL overview (Microsoft Learn)](https://learn.microsoft.com/en-us/kusto/query/)
- [KQL operator reference](https://learn.microsoft.com/en-us/kusto/query/queries)
- [SQL → KQL cheat sheet](https://learn.microsoft.com/en-us/kusto/query/sql-cheat-sheet)
- [Best practices for KQL queries](https://learn.microsoft.com/en-us/kusto/query/best-practices)
- [[Splunk Cheatsheet]]
