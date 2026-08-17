---
tags:
  - splunk
  - spl
  - troubleshooting
  - cheatsheet
audience: CRE
updated: 2026-08-17
---

# Splunk Cheatsheet

## What and when

Splunk searches machine-generated events with Search Processing Language (SPL). The most important habits are simple: confirm the platform, choose the correct data source, constrain time and scope early, inspect sample events, then aggregate.


## Platform scope


| Context | Starting point | Important distinction |
| ------- | -------------- | --------------------- |
| GitHub Enterprise Cloud (GHEC) staff telemetry | GitHub internal Splunk indexes such as `rails`, `prod-exceptions`, `prod-resque`, `catchall`, `glb`, or service-specific indexes | Index and field availability vary by service and stamp. Discover before assuming. |
| GitHub Enterprise Server (GHES) support bundles | `index=prod-esbtools` with `host`, `bundle_id`, or `splunk_ingest_id` plus an `esb_*` sourcetype | This is appliance data extracted from uploaded support bundles. |
| Customer-forwarded GHES logs | The customer's Splunk index and sourcetype conventions | GitHub cannot assume index names such as `ghes` or `github_auth`. Ask the customer how forwarding is configured. |

> **Critical:** GHES appliance identifiers are independent from GitHub.com identifiers. A GHES `repo_id`, `org_id`, or `user_id` can collide with an unrelated dotcom identifier. Never join GHES appliance IDs to GHEC snapshot tables.

## Reliable investigation workflow

1. **Confirm the platform:** GHEC, GHES support bundle, or customer-forwarded GHES logs.
2. **Pin the time:** Get the timestamp, timezone, start, end, and whether the symptom is ongoing.
3. **Identify one scope key:** Host, bundle, repository, request ID, trace ID, actor, path, job ID, or service.
4. **Discover the shape:** Run `head`, inspect available fields, and count sourcetypes or services.
5. **Search the symptom:** Error text, status code, exception class, operation, or subsystem term.
6. **Quantify:** Use `stats`, `timechart`, percentiles, and distinct counts.
7. **Correlate:** Pivot using a stable identifier and a narrow time window.
8. **Verify alternatives:** Check both platform-side and customer-side explanations before making a causal claim.

**Success criteria:** you can name the exact index/sourcetype searched, the time window, the stable identifier used to pivot, and a quantified result (count, rate, or percentile) that supports or rules out the symptom. A search that returns zero results without checking retention, format, or scope is not success; treat it as inconclusive until ruled out (see Common mistakes below).

## Safety and read-only boundary

```bash
python3 tools/splunk_auth.py --validate

python3 tools/splunk_query.py \
  --spl 'index=prod-esbtools host="<host>" | head 20' \
  --earliest '-2h' --latest 'now' \
  --max-results 20
```

All repository Splunk tooling is read only. Commands that modify state, send email, write lookups, or export results through SPL are blocked.

## Supported interface

The repository's read-only SPL tooling (`tools/splunk_auth.py`, `tools/splunk_query.py`) is the primary supported interface for this cheatsheet's examples. Splunk Web provides an interactive GUI: paste the same base search and pipes from any example below into its search bar to run the identical query. Exact Splunk Web navigation (app selection, time-range picker) is not documented here; use the CLI tooling for anything scripted or repeatable.

## Anatomy of an SPL search

```spl
index=prod-esbtools host="<host>" sourcetype=esb_exceptions earliest=-2h latest=now
| search (Error OR Exception OR timeout)
| stats count by host
| sort - count
| head 20
```

- The base search appears before the first pipe.
- Put indexed constraints such as `index`, `host`, `sourcetype`, and time in the base search.
- Each pipe transforms the current result set.
- Use `table` for inspection and `stats` or `timechart` for conclusions.

## Time ranges

| SPL | Meaning |
| --- | ------- |
| `earliest=-15m latest=now` | Last 15 minutes |
| `earliest=-2h@h latest=now` | Last 2 hours, aligned to the hour |
| `earliest=-24h@h latest=now` | Last 24 hours |
| `earliest=-7d@d latest=@d` | Seven complete days ending today |
| `earliest="08/13/2026:09:00:00" latest="08/13/2026:10:00:00"` | Explicit window |

Use a slightly wider window than the reported incident, then narrow after finding the first relevant event.

## Core commands

| Command | Use |
| ------- | --- |
| `search` | Filter by terms or extracted fields |
| `where` | Filter with expressions or calculated conditions |
| `fields` | Keep or remove fields from the result payload |
| `table` | Display selected fields in a stable order |
| `stats` | Aggregate counts, values, sums, and percentiles |
| `timechart` | Show a metric over time |
| `top` / `rare` | Find common or unusual values |
| `eval` | Calculate or normalize fields |
| `rex` | Extract a field from raw text with regex |
| `bin` | Place timestamps or numeric values into buckets |
| `dedup` | Remove duplicate events using a stable event key |
| `sort` | Order results |
| `head` | Limit result volume |

Prefer `stats ... by <key>` over `transaction` or `join`. It is usually cheaper and easier to verify.

## Discovery searches

### Discover GHES bundle hosts and bundles

```spl
index=prod-esbtools earliest=-14d latest=now
| stats dc(bundle_id) as bundle_count latest(bundle_id) as latest_bundle values(ghes_version) as versions by host
| sort - bundle_count
```

### Discover sourcetypes for one GHES appliance

```spl
index=prod-esbtools host="<host>" earliest=-14d latest=now
| stats count by sourcetype
| sort - count
```

### Inspect sample events before assuming fields

```spl
index=prod-esbtools host="<host>" sourcetype=esb_production earliest=-1h latest=now
| table _time host sourcetype _raw
| head 20
```

### Discover values for a candidate field

```spl
index=prod-esbtools host="<host>" sourcetype=esb_babeld earliest=-1h latest=now
| top limit=20 cmd
```

## Verified GHES support-bundle sourcetypes

| Sourcetype | Primary use | Useful fields or terms |
| ---------- | ----------- | ---------------------- |
| `esb_exceptions` | Application exceptions | Exception class, error text, stack context |
| `esb_production` | Rails application requests | Request path, controller, status, request ID, duration |
| `esb_unicorn` | Web worker request load | Duration, CPU, queue and worker activity |
| `esb_syslog` | Operating system and service logs | Service name, OOM, disk, kernel, restart messages |
| `esb_haproxy` | Load-balancer traffic | Backend, frontend, status, queue, connection errors |
| `esb_babeld` | Git transport | `repo`, `cmd`, `proto`, `duration_ms`, `fs_host`, `id`, `code`, `msg` |
| `esb_gitmon` | Fileserver Git measurements | `request_id`, CPU, wall time, program, repository context |
| `esb_resqued` | Background jobs | `gh.job.name`, `gh.job.active_job_id`, `gh.repo.id`, `TraceId`, `SpanId` |
| `esb_mpstat` | CPU pressure | Host and CPU utilization samples |

Schema varies by GHES version. Verify the fields present in each bundle.

## GHEC staff telemetry starting points
These are starting points, not universal routes. Confirm the owning service and current schema.

| Starting search | Typical use |
| --------------- | ----------- |
| `index=rails` | GitHub.com web and API request activity |
| `index=prod-exceptions` | Application and background-job exceptions |
| `index=prod-resque` | Background-job execution |
| `index=prod-quoroner` | Killed SQL queries and request-linked database timeouts |
| `index=catchall service.name=<service>` | Moda and service-specific application logs |
| `index=catchall gh_approle=<app-role-*>` | Host logs for applications not running on Moda |
| `index=alambic` | Object-storage proxy activity |
| `index=catchall gh.infra.app=lfs-server` | Git Large File Storage service logs |
| `index=rails path_info="/lfs/<owner>/<repo>/*"` | LFS requests routed through Rails |

GLB logs have been evacuated from Splunk and must be queried in Kusto. Do not use the older `index=glb` examples without first confirming historical data is required.

For data-resident GHEC, verify the stamp and regional endpoint before searching. Do not assume staffship telemetry contains resident customer data.

## Common GitHub search terms

Start with identifiers when available. Add symptom terms second.

### Correlation and identity

| Purpose | Terms and fields to try |
| ------- | ----------------------- |
| Request correlation | `request_id`, `request-id`, `X-GitHub-Request-Id`, `id`, `TraceId`, `SpanId`, `trace_id`, `correlation_id` |
| Repository scope | `repo`, `repository`, `repo_id`, `repository_id`, `owner`, `network_id` |
| Organization or enterprise | `org`, `organization_id`, `business_id`, `enterprise`, `customer_id` |
| Actor scope | `actor`, `actor_id`, `user_id`, `login`, `fp_sha256`, `gh.auth.fingerprint` |
| Host or deployment | `host`, `host.name`, `stamp`, `deployment.environment`, `service.name`, `gh.infra.app` |
| Background job | `gh.job.name`, `active_job_class`, `gh.job.active_job_id`, `job_id`, `aqueduct_id`, `queue` |

### Generic failures

`error`, `exception`, `fatal`, `panic`, `failed`, `failure`, `timeout`, `deadline exceeded`, `context canceled`, `retry`, `exhausted`, `unavailable`

### HTTP and API

`400`, `401`, `403`, `404`, `409`, `422`, `429`, `500`, `502`, `503`, `504`, `rate limit`, `secondary limit`, `abuse`, `throttle`, `path_info`, `method`, `status`, `elapsed`, `duration`

### Authentication and identity

`SAML`, `SSO`, `SCIM`, `LDAP`, `OAuth`, `OIDC`, `2FA`, `login`, `session`, `token`, `signature`, `certificate`, `x509`, `TLS`, `expired`, `unauthorized`, `forbidden`, `permission denied`

### Git transport

`git-upload-pack`, `git-receive-pack`, `clone`, `fetch`, `push`, `packfile`, `ref`, `hook`, `pre-receive`, `spokes`, `babeld`, `gitmon`, `fs_host`, `duration_ms`, `auth_status`, `creason`

### Actions and runners

`workflow_run`, `workflow_job`, `runner`, `registration`, `queued`, `dispatch`, `pickup`, `heartbeat`, `lost communication`, `cancel`, `timeout`, `scale set`, `ARC`

### Storage and repository data

`disk full`, `no space left`, `read-only`, `object storage`, `alambic`, `LFS`, `blob`, `replica`, `quorum`, `checksum`, `corrupt`, `migration`, `restore`, `backup`

### Performance and capacity

`slow`, `latency`, `duration`, `queue`, `saturation`, `OOM`, `out of memory`, `killed process`, `CPU`, `load average`, `memory pressure`, `connection pool`, `circuit breaker`

### Search and indexing

`Elasticsearch`, `OpenSearch`, `index`, `shard`, `unassigned`, `cluster health`, `red`, `yellow`, `mapping`, `reindex`, `search timeout`

### Networking

`connection refused`, `connection reset`, `reset by peer`, `broken pipe`, `EOF`, `DNS`, `NXDOMAIN`, `TLS handshake`, `certificate verify`, `proxy`, `HAProxy`, `backend DOWN`, `no server available`

## Common investigation patterns

### Error volume by sourcetype

```spl
index=prod-esbtools host="<host>" (error OR exception OR fatal OR panic) earliest=-2h latest=now
| stats count by sourcetype
| sort - count
```

### Exception classes

```spl
index=prod-esbtools host="<host>" sourcetype=esb_exceptions earliest=-2h latest=now
| rex field=_raw "(?<exception>[A-Za-z0-9_:]+(?:Error|Exception))"
| stats count by exception
| sort - count
| head 25
```

### HTTP status trend

```spl
index=prod-esbtools host="<host>" sourcetype=esb_haproxy earliest=-2h latest=now
| timechart span=5m count by status
```

If `status` is not extracted, inspect `_raw` and use `rex` for the bundle's HAProxy format.

### Slow request tail

```spl
index=prod-esbtools host="<host>" sourcetype=esb_unicorn earliest=-2h latest=now
| stats count avg(duration) median(duration) perc95(duration) perc99(duration) max(duration) by host
```

Verify whether the duration field is measured in seconds or milliseconds before interpreting it.

### Git fetch latency by repository

```spl
index=prod-esbtools host="<host>" sourcetype=esb_babeld cmd=git-upload-pack repo="<owner>/<repo>" earliest=-2h latest=now
| rex "duration_ms=(?<d>[\d.]+)"
| stats count perc95(d) perc99(d) max(d) by fs_host
| sort - perc99(d)
```

### Git push failures

```spl
index=prod-esbtools host="<host>" sourcetype=esb_babeld cmd=git-receive-pack repo="<owner>/<repo>" earliest=-2h latest=now
| search code!=0 OR auth_status=failed OR error OR failed
| table _time id repo proto fs_host duration_ms prerx code msg creason
| sort _time
```

### Background-job mix

```spl
index=prod-esbtools host="<host>" sourcetype=esb_resqued earliest=-2h latest=now
| rex "gh\.job\.name=\"(?<job_name>[^\"]+)\""
| top limit=25 job_name
```

### Follow one trace

```spl
index=prod-esbtools host="<host>" TraceId="<trace_id>" earliest=-15m latest=+15m
| table _time sourcetype host.name service.name gh.job.name SpanId code.namespace code.function Body _raw
| sort _time
```

### GHEC rate-limit reasons

```spl
index=rails gh.rate_limit.secondary.limit_reason=* earliest=-2h latest=now
| top limit=20 gh.auth.fingerprint path_info gh.rate_limit.secondary.limit_reason
```

### GHEC LFS errors by status

```spl
index=rails path_info="/lfs/<owner>/<repo>/*" earliest=-2h latest=now
| stats count avg(elapsed) perc95(elapsed) by status
| sort - count
```

### Service-specific GHEC errors

```spl
index=catchall gh.infra.app="<service>" (error OR exception OR timeout) earliest=-2h latest=now
| timechart span=5m count by host
```


### GHEC latency by controller and action

```spl
index=rails deployment.environment=production catalog_service="<catalog_service>" earliest=-2h latest=now
| eval controller_action=controller."#".action
| stats count median(elapsed) perc95(elapsed) perc99(elapsed) max(elapsed) by controller_action
| sort - perc99(elapsed)
```

### GHEC timed-out requests

```spl
index=rails timeout=true earliest=-2h latest=now
| stats count by controller action catalog_service
| sort - count
```

### Killed SQL queries for one request

```spl
index=prod-quoroner earliest=-15m latest=+15m
| rex field=query "request_id:(?<request_id>.*?)[,|*]"
| search request_id="<request_id>"
| table _time request_id query
| sort _time
```


### Unicorn burst and worker-pressure candidates

Use this to rank actors whose requests arrive in concentrated 10-second windows and whose aggregate request time exceeds the same 10-second window.

```spl
index=prod-esbtools host="<host>" sourcetype=esb_unicorn gh_actor_login!=nil earliest=-7d latest=now
| bin _time span=10s
| stats count AS short_count
    sum(elapsed) AS short_elapsed
    avg(elapsed) AS short_avg_elapsed
    BY gh_actor_login _time
| eval burst=if(short_count >= <MAX_CONNECTIONS_IN_10S>, 1, 0)
| eval total_load=short_count * short_avg_elapsed
| eval critical=if(burst=1 AND total_load > 10, 1, 0)
| stats sum(short_count) AS count
    sum(short_elapsed) AS total_elapsed
    avg(short_avg_elapsed) AS avg_elapsed
    sum(burst) AS burst
    sum(critical) AS critical
    BY gh_actor_login
| eval chance=if(burst > 0, round((critical / burst) * 100, 2), 0)
| sort - critical - burst - count
```

Replace `<MAX_CONNECTIONS_IN_10S>` before running. A practical starting value is the configured Unicorn worker count, or the maximum number of connections in 10 seconds considered acceptable for the appliance. Confirm the worker count from bundle diagnostics and configuration metadata; do not copy a threshold from another appliance.

Interpretation:

- `burst` counts 10-second windows where the actor met or exceeded the selected threshold.
- `total_load` is the aggregate request time in that window because `count * avg(elapsed)` equals the sum of elapsed time.
- `critical` counts burst windows with more than 10 request-seconds of aggregate work.
- `chance` is the percentage of that actor's burst windows that also crossed the aggregate-work threshold.

This query identifies workload-concentration candidates. It does not prove that an actor caused worker exhaustion, failover, or an outage. Confirm the units of `elapsed`, compare the windows with Unicorn queue depth and worker availability, and corroborate with CPU, input/output, HAProxy queueing, and customer-visible latency.

For a top result, inspect whether actor names represent one application split across numbered or regional credentials. Aggregate the naming family when separate tokens may hide the application's combined load.

### BabelD workload concentration by organization and repository

Start broad to determine whether Git traffic is concentrated in one organization. Verify that `repo` and `duration_ms` are extracted and that `repo` uses the `owner/repository` shape.

```spl
index=prod-esbtools host="<host>" sourcetype=esb_babeld repo="*/*" earliest=-7d latest=now
| eval org=mvindex(split(repo, "/"), 0)
| stats count AS request_count
    sum(duration_ms) AS total_duration_ms
    avg(duration_ms) AS avg_duration_ms
    perc95(duration_ms) AS p95_duration_ms
    max(duration_ms) AS max_duration_ms
    BY org
| sort - request_count
```

Then rank repositories by total time spent servicing Git traffic:

```spl
index=prod-esbtools host="<host>" sourcetype=esb_babeld repo="*/*" earliest=-7d latest=now
| stats count AS request_count
    sum(duration_ms) AS total_duration_ms
    avg(duration_ms) AS avg_duration_ms
    perc95(duration_ms) AS p95_duration_ms
    max(duration_ms) AS max_duration_ms
    BY repo
| sort - total_duration_ms
```

Review both dimensions:

- **High volume, low latency:** frequent fetch or polling behavior can still consume substantial aggregate disk and Git service time.
- **Lower volume, high latency:** large repositories, clones, monorepositories, or expensive operations can dominate total service time.
- **Naming signals:** development, quality-assurance, test, shared-library, and core repository names are prompts for validation, not conclusions.
- **Fork-heavy workflows:** determine whether large repositories are repeatedly forked when a branch-based workflow could meet the same need.
- **Repeated shared dependencies:** check whether automation repeatedly fetches a stable shared library without an appropriate cache.

BabelD may not expose a reliable end-user identity for each Git operation. If actor attribution is required, inspect the available fields first and correlate with a stable request ID, source address, or another service that records authenticated identity. Do not invent an actor field.

### API integration and polling drilldown

After identifying a high-impact `gh_actor_login`, inspect sample events to confirm the extracted request-path and user-agent field names for that GHES version:

```spl
index=prod-esbtools host="<host>" sourcetype=esb_unicorn gh_actor_login="<actor>" earliest=-2h latest=now
| table _time gh_actor_login elapsed *agent* *target* *path* _raw
| head 20
```

Then aggregate using the confirmed fields:

```spl
index=prod-esbtools host="<host>" sourcetype=esb_unicorn gh_actor_login="<actor>" earliest=-7d latest=now
| stats count AS request_count
    sum(elapsed) AS total_elapsed
    avg(elapsed) AS avg_elapsed
    BY <request_path_field> <user_agent_field>
| sort - total_elapsed
```

Look for repeated polling of the same pull request or endpoint, multiple integration versions, and one application spread across many credentials. Potential mitigations include staggering scripts, caching stable data, using webhooks instead of frequent polling, updating an integration after vendor review, and pausing non-production automation against the production appliance. Treat these as customer-side options to validate, not proof that a named vendor or integration is defective.

## Field-tested query patterns

These sanitized patterns were found in recent Slack troubleshooting threads and Zendesk investigations. Treat them as starting points, not permanent schemas. Confirm the index, field names, data residency, and retention before relying on a result.

### Primary rate-limit headroom over time

Use the primary rate-limit key when you need to see how close an installation or other principal came to exhausting its allowance.

```spl
index=api-gateway gh.rate_limit.primary.key="<rate-limit-key>" earliest=-24h latest=now
| timechart span=1m min(gh.rate_limit.primary.remaining) as minimum_remaining
```

Source: [Zendesk #4665651](https://github.zendesk.com/agent/tickets/4665651)

### Rate-limited requests versus total traffic

```spl
index=api-gateway gh.rate_limit.primary.key="<rate-limit-key>" earliest=-7d latest=now
| timechart span=1h
    count as total_requests
    count(eval('gh.rate_limit.primary.remaining'=0)) as rate_limited_requests
```

Use `gh.rate_limit.primary.exceeded=true` as an alternative filter when that field is present. Inspect sample events first because rate-limit fields can differ between indexes.

Sources: [Zendesk #4659409](https://github.zendesk.com/agent/tickets/4659409), [Zendesk #4635029](https://github.zendesk.com/agent/tickets/4635029)

### Follow an exact request ID

```spl
index=rails gh.request_id="<request-id>" earliest=-15m latest=+15m
| table _time gh.request_id controller action http.method http.target http.status_code elapsed timeout
| sort _time
```

If the index does not extract `gh.request_id`, search the exact request ID as quoted raw text. Reuse the same value in `prod-exceptions`, `prod-resque`, `api-gateway`, or the owning service's index.

Sources: [Slack thread](https://github-grid.enterprise.slack.com/archives/C046568U26R/p1771942411972689), [Zendesk #4633913](https://github.zendesk.com/agent/tickets/4633913)

### Compare webhook delivery by hook and commit

```spl
index=prod-hookshot gh.hookshot.hook_id="<hook-id>" push_sha="*<commit-sha-prefix>*" earliest=-24h latest=now
| table _time gh.hookshot.hook_id push_sha _raw
| sort _time
```

Run the same search for one commit that produced a delivery and one that did not. This provides a positive control before concluding that no webhook was generated.

Source: [Slack thread](https://github-grid.enterprise.slack.com/archives/CTZS8Q692/p1772633734255119)

### Inspect Secure Shell authentication by fingerprint

```spl
index=rails-gitauth gh.gitauth.fingerprint_sha256="<fingerprint>" earliest=-24h latest=now
| table _time gh.request_id gh.gitauth.status gh.gitauth.key gh.gitauth.ssh_cert.result gh.gitauth.reason
| sort _time
```

Pivot from a returned request ID when you need one authentication attempt:

```spl
index=rails-gitauth gh.request_id="<request-id>" earliest=-15m latest=+15m
| table _time gh.request_id gh.gitauth.status gh.gitauth.key gh.gitauth.ssh_cert.result gh.gitauth.fingerprint_sha256 gh.gitauth.member gh.gitauth.reason
| sort _time
```

Source: [Zendesk #4567097](https://github.zendesk.com/agent/tickets/4567097)

### Trace repository authentication activity

```spl
index=reposd gh.reposd.service=reposd-gitauth "<owner>/<repo>" earliest=-2h latest=now
| table _time gh.request_id gh.repo.name_with_owner gh.gitauth.action gh.gitauth.status http.client_ip network.protocol.name
| sort _time
```

Add a known client IP, request ID, or credential fingerprint only when necessary. Treat credential-derived values and client addresses as sensitive, and redact them before sharing.

Sources: [Slack thread](https://github-grid.enterprise.slack.com/archives/C02LE2XV5DM/p1770316468515839), [Zendesk #4598039](https://github.zendesk.com/agent/tickets/4598039)

### Identify concentrated anonymous 5xx traffic

```spl
index=rails controller=SignupsController status=5** NOT gh.actor.id=* earliest=-30m latest=now
| stats count by ja3_hash ja4_fp ja4h_fp
| sort - count
| head 20
```

Fingerprint concentration is an investigation signal, not proof of malicious traffic. Compare it with the normal distribution and the timing of the spike.

Source: [Slack thread](https://github-grid.enterprise.slack.com/archives/C0ANT8LDLF7/p1777683325759259)

### Group repeated error messages

```spl
index="<service-index>" (error OR exception) earliest=-2h latest=now
| cluster field=exception.message showcount=true
| table cluster_count exception.message
| sort - cluster_count
```

Use this when the same underlying failure contains small variations that make exact text grouping noisy. Validate clusters against raw events before treating them as one cause.

Source: [Slack thread](https://github-grid.enterprise.slack.com/archives/C0ADGH0D9B2/p1785855936207509)

### Count unique requests instead of log lines

```spl
index="<service-index>" "<symptom>" earliest=-24h latest=now
| timechart span=1h dc(gh.request_id) as affected_requests
```

This avoids overstating impact when a single request emits several log events.

Source: [Slack thread](https://github-grid.enterprise.slack.com/archives/C0AH8M0MVUK/p1786645712223329)

## Correlation guidance
| Starting evidence | Useful pivot |
| ----------------- | ------------ |
| `request_id` | Search the exact value in `rails`, `prod-exceptions`, `prod-resque`, and other likely indexes within a tight time window |
| `esb_babeld.id` | Pivot to `esb_gitmon request_id` for fileserver-side measurements |
| `TraceId` | Search `esb_production`, `esb_resqued`, `esb_babeld`, and `esb_syslog` |
| Repository name | Add operation, protocol, and host before aggregating |
| Background job ID | Deduplicate overlapping bundles using `gh.job.active_job_id` |
| Fileserver host | Compare latency, error, and operation mix across `fs_host` values |

For GitHub.com requests, `request_id` is the strongest general-purpose pivot because it follows the request lifecycle. Start in the index where the symptom appeared, then reuse the exact ID in related indexes.

Overlapping GHES bundles can contain duplicate events. Use the event-specific stable key, such as `esb_babeld.id` or `gh.job.active_job_id`, before counting.

## SPL functions worth remembering

| Function | Use |
| -------- | --- |
| `count` | Event count |
| `dc(field)` | Distinct count |
| `count(eval(condition))` | Conditional count |
| `avg(field)` / `median(field)` | Typical value |
| `perc95(field)` / `perc99(field)` | Tail behavior |
| `min(field)` / `max(field)` | Range and extremes |
| `values(field)` | Unique values |
| `latest(field)` / `earliest(field)` | Boundary values |
| `coalesce(a,b)` | First non-null value |
| `if(condition,a,b)` | Conditional value |
| `case(...)` | Multiple conditions |
| `strftime(_time,"%F %T")` | Readable timestamp |

## Common mistakes

- Starting with `index=*` or a multi-day window.
- Assuming the same index and field names exist across GHEC, GHES bundles, and customer Splunk.
- Searching only `_raw` when a reliable extracted field exists.
- Treating `fields` as a substitute for a selective base search.
- Using `join` or `transaction` before trying `stats by`.
- Counting overlapping bundle events without deduplication.
- Treating a high event count as proof of impact without a baseline.
- Ignoring timezone differences between the customer report, appliance, and Splunk.
- Assuming a zero-result search proves an event did not happen.
- Joining GHES appliance IDs to dotcom datasets.
- Making a causal claim without checking an alternative hypothesis.

## SPL to KQL quick map

| Concept | SPL | KQL |
| ------- | --- | --- |
| Filter | `search` / `where` | `where` |
| Select fields | `fields` / `table` | `project` |
| Add a field | `eval` | `extend` |
| Aggregate | `stats count by x` | `summarize count() by x` |
| Time buckets | `timechart span=5m count` | `summarize count() by bin(timestamp, 5m)` |
| Distinct count | `dc(field)` | `dcount(field)` |
| Top values | `top field` | `top N by field` |
| Sort descending | `sort - field` | `order by field desc` |

## Stop and escalate

Escalate rather than continuing to search alone when:

- The data source needed to confirm or rule out impact is unavailable (index down, auth expired and cannot be restored, bundle not yet extracted) and there is no fallback source.
- A zero-result search cannot be explained by retention, format, node, or timestamp, and the investigation has run past the customer's urgency window.
- Evidence suggests a platform-side incident rather than a customer-side issue.
- You are unsure whether a query pattern is safe or read only.

Apply the general investigation and escalation judgment in [[Investigation and Escalation Judgment]], including building an evidence chain (timestamp, request/trace ID, exact error, what was searched, current hypothesis) before escalating.

## Related notes and references
- [[Support Bundles Cheatsheet]]
- [[ESB Support Bundle Workflow]]
- [[Kusto-KQL Cheatsheet]]
- [[GHES Cheatsheet]]
- [[Health Check Runbook]] - repeatable multi-pillar evidence collection using these Splunk patterns.
- [[Investigation and Escalation Judgment]]
- `data-explorers/splunk-data-explorer/schema-cache/README.md`
- `data-explorers/splunk-data-explorer/telemetry-maps/babeld-telemetry.md`
- `data-explorers/splunk-data-explorer/telemetry-maps/resqued-otel-telemetry.md`
- [Splunk Search Reference](https://docs.splunk.com/Documentation/Splunk/latest/SearchReference/WhatsInThisManual)
- [Splunk Search Tutorial](https://docs.splunk.com/Documentation/Splunk/latest/SearchTutorial/WelcometotheSearchTutorial)
- [GHES log forwarding](https://docs.github.com/en/enterprise-server@latest/admin/monitoring-activity-in-your-enterprise/exploring-user-activity-in-your-enterprise/log-forwarding)
- [GitHub Splunk Cookbook](https://thehub.github.com/epd/engineering/dev-practicals/performance/tools/splunk/)
- [GitHub Splunk guides](https://thehub.github.com/epd/engineering/products-and-services/internal/splunk/)
- [Splunk Education](https://education.splunk.com)

## Freshness note

Index names, sourcetypes, and field availability drift as services migrate (for example, GLB logs moved from Splunk to Kusto). Verify index and field names still resolve before relying on an example query. Reviewed 2026-08-13.