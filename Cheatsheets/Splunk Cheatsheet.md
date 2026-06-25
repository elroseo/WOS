# Splunk Cheatsheet

## What is Splunk?

Splunk is a platform for searching, monitoring, and analyzing machine-generated data — primarily logs. It ingests data from many sources, indexes it, and lets you query it with **SPL** (Search Processing Language). Like KQL, SPL is a piped language: a search starts by selecting events, then flows them through commands separated by `|`, each refining or transforming the result. Splunk's strengths are full-text search across heterogeneous logs, real-time alerting, field extraction from unstructured text, and dashboards.

## How it's typically used

- Centralized log aggregation from many hosts and services
- Searching unstructured/semi-structured logs by keyword and field
- Building alerts on error conditions and thresholds
- Correlating events across systems by shared fields
- Operational dashboards and reporting

## How it relates to GHES

GHES customers frequently forward their instance logs to Splunk via **log forwarding** (syslog forwarding configured in the Management Console / `ghe-config`). This means that when investigating a GHES issue you may be searching the same logs you'd find in a support bundle (`github-logs`, `babeld-logs`, `haproxy`, `auth.log`, audit log) — but live, searchable, and correlated across time in Splunk. As a CRE, knowing SPL lets you find auth failures, 500 spikes, and audit events in a customer's Splunk far faster than scrolling raw files. Key skills: filter by `index`/`sourcetype`/`host` early, extract fields, and use `stats`/`timechart` to quantify.

> **GHES tie-in:** GHES forwards logs over syslog. In Splunk these usually arrive under a dedicated `index` and split by `sourcetype` (e.g. the originating log file). Always scope your search to the right `index` and time range first.

---

## Anatomy of a search

```spl
index=ghes sourcetype=github_audit         <- 1. select events (+ implicit time range)
  earliest=-1h latest=now                   <- 2. time bounds
| search action=repo.destroy                <- 3. filter
| stats count by actor                       <- 4. aggregate
| sort -count                                <- 5. sort
| head 20                                     <- 6. limit
```

Events flow left-to-right; each `|` passes results to the next command. **The first line is the base search** — keep it as specific as possible (index, sourcetype, host, keywords) because it determines how much data Splunk scans.

---

## Time range (set it first)

| Token | Meaning |
|---|---|
| `earliest=-15m latest=now` | Last 15 minutes |
| `earliest=-24h@h` | Last 24 hours, snapped to the hour |
| `earliest=-7d@d` | Last 7 days, snapped to midnight |
| `earliest="06/25/2026:14:00:00"` | Explicit timestamp |
| `@d` / `@h` / `@m` | "Snap to" day / hour / minute boundary |

Or use the time-range picker in the UI — it applies the same bounds.

---

## Core SPL commands

| Command | What it does |
|---|---|
| `search` | Filter events (implicit as the first line) |
| `where` | Filter using expressions/functions (`where len(x)>5`) |
| `fields a, b` | Keep only these fields (speeds up search) |
| `table a, b, c` | Output as a tidy table |
| `rename a AS b` | Rename a field |
| `eval new = expr` | Compute a new field |
| `stats` | Aggregate (the workhorse) |
| `timechart` | Aggregate over time (auto time-bucketed) |
| `chart` | Aggregate into a matrix (by two dimensions) |
| `top` / `rare` | Most / least common values |
| `dedup field` | Remove duplicate events by field |
| `sort -field` | Sort (`-` = descending) |
| `head N` / `tail N` | First / last N results |
| `rex` | Extract fields with regex |
| `transaction` | Group related events into one |
| `lookup` | Enrich with an external table |

---

## Filtering effectively

```spl
index=ghes sourcetype=github_auth host=ghe01 ("failed" OR "invalid")
| where result="failure"
```

| Technique | Example |
|---|---|
| Scope the base search | `index=ghes sourcetype=github_exceptions` |
| Keyword (full text) | `index=ghes error` |
| Field equality | `status=500` |
| Boolean logic | `(500 OR 502) NOT 404` |
| Wildcards | `host=ghe* path="/api/*"` |
| Comparison (`where`) | `| where duration_ms > 2000` |

> Adding `index`, `sourcetype`, and `host` to the base search is the single biggest performance win — it limits the buckets Splunk has to scan.

---

## Aggregating with `stats`

```spl
index=ghes sourcetype=github_request earliest=-1h
| stats count AS total,
        count(eval(status>=500)) AS errors,
        avg(duration_ms) AS avg_ms,
        p95(duration_ms) AS p95_ms
        by host
| eval error_rate = round(100*errors/total, 2)
| sort -error_rate
```

| `stats` function | Result |
|---|---|
| `count` | Number of events |
| `count(eval(<cond>))` | Conditional count |
| `dc(field)` | Distinct count |
| `sum(field)` / `avg(field)` | Sum / mean |
| `min` / `max` / `median` | Extremes / median |
| `p95(field)` / `perc95(field)` | 95th percentile |
| `values(field)` / `list(field)` | Collect unique / all values |
| `latest(field)` / `earliest(field)` | Most / least recent value |
| `by field` | Group results (like GROUP BY) |

---

## Time-series with `timechart`

```spl
index=ghes sourcetype=github_exceptions earliest=-6h
| timechart span=10m count by host
```

- `timechart` always buckets by `_time` automatically; use `span=5m`/`1h` to set granularity.
- `by <field>` produces one series per value — great for spotting which host/service spiked.

---

## Field extraction with `rex`

```spl
index=ghes sourcetype=haproxy
| rex field=_raw "backend (?<backend>\S+) .* status (?<status>\d{3})"
| stats count by backend, status
```

- `rex` pulls named capture groups out of raw text into searchable fields.
- Use when logs aren't already parsed into fields.
- `(?<name>pattern)` defines a field called `name`.

---

## Correlating events

```spl
// Group all events for a request into one transaction
index=ghes (sourcetype=github_request OR sourcetype=babeld)
| transaction request_id maxspan=30s
| where eventcount > 1
```

| Tool | Use |
|---|---|
| `transaction <field>` | Stitch related events by a shared key + time window |
| `join` | SQL-style join to a subsearch (use sparingly — costly) |
| `lookup` | Enrich events with a static CSV/KV table |
| `stats ... by <key>` | Often a faster alternative to `transaction` |

---

## GHES investigation patterns

```spl
// 1. Auth failures over time
index=ghes sourcetype=github_auth earliest=-24h
| timechart span=1h count(eval(result="failure")) AS failures

// 2. 500 error spike, by endpoint
index=ghes sourcetype=github_request status>=500 earliest=-6h
| top limit=15 path

// 3. Audit log — who deleted repos
index=ghes sourcetype=github_audit action="repo.destroy"
| table _time, actor, repo

// 4. Slow Git operations (babeld)
index=ghes sourcetype=babeld earliest=-1h
| rex field=_raw "elapsed=(?<elapsed_ms>\d+)"
| where elapsed_ms > 5000
| table _time, host, elapsed_ms, _raw

// 5. HAProxy backends going down
index=ghes sourcetype=haproxy ("backend" AND ("DOWN" OR "no server"))
| stats count by host, _raw
```

---

## Useful `eval` functions

| Function | Use |
|---|---|
| `if(cond, a, b)` | Inline conditional |
| `case(c1,v1, c2,v2, true,default)` | Multi-branch |
| `coalesce(a, b)` | First non-null |
| `len(x)` | String length |
| `lower(x)` / `upper(x)` | Case conversion |
| `round(x, n)` | Round |
| `strftime(_time, "%F %T")` | Format a timestamp |
| `mvcount(x)` / `mvindex(x,n)` | Multi-value field handling |

---

## Tips & gotchas

- **Scope the base search** (`index`, `sourcetype`, `host`) and **set the time range** before anything else.
- Use `fields`/`table` early to drop unneeded data and speed things up.
- Prefer `stats by` over `transaction` and `join` when you can — it scales far better.
- `_raw` is the original event text; `_time` is the parsed timestamp.
- `count(eval(<cond>))` is the SPL idiom for conditional counts inside `stats`.
- Wildcards at the *start* of a term (`*error`) are slow — anchor them where possible.
- Save common searches as **reports** or **alerts** once they prove useful.

---

## SPL ↔ KQL quick map

| Concept | SPL | KQL |
|---|---|---|
| Filter | `search` / `where` | `where` |
| Select columns | `fields` / `table` | `project` |
| Aggregate | `stats count by x` | `summarize count() by x` |
| Over time | `timechart span=5m count` | `summarize count() by bin(Timestamp,5m)` |
| Top N | `top N field` | `top N by field` |
| Add field | `eval y = ...` | `extend y = ...` |
| Distinct count | `dc(field)` | `dcount(field)` |
| Sort | `sort -field` | `order by field desc` |

---

## Quick reference links

- [Splunk Search Reference (all commands)](https://docs.splunk.com/Documentation/Splunk/latest/SearchReference/WhatsInThisManual)
- [Splunk Search Tutorial](https://docs.splunk.com/Documentation/Splunk/latest/SearchTutorial/WelcometotheSearchTutorial)
- [SPL `stats` functions](https://docs.splunk.com/Documentation/Splunk/latest/SearchReference/CommonStatsFunctions)
- [GHES log forwarding](https://docs.github.com/en/enterprise-server@latest/admin/monitoring-and-managing-your-instance/monitoring-your-instance/log-forwarding)
- [[Support Bundles Cheatsheet]] · [[Kusto-KQL Cheatsheet]]
