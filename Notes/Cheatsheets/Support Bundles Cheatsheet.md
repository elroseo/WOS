# Support Bundles Cheatsheet

## What is a support bundle?

A support bundle is a gzip-compressed tar archive (`.tar.gz`) that a GHES administrator generates and shares with GitHub Support to help diagnose an issue. It packages a **diagnostics file** (a snapshot of the instance's settings and environment) together with **sanitized log files** from across every major subsystem. Authentication tokens, keys, and secrets are stripped from the logs before the archive is built, so the bundle is safe to share. It is the single most important artifact for offline troubleshooting because Support has no direct access to the customer's environment.

## How it's typically used

- A customer reports an issue; Support asks them to generate and upload a bundle
- The engineer unpacks it and reads logs to reconstruct what happened without touching the live system
- Used to investigate auth failures, 500 errors, performance problems, replication lag, upgrade failures, and email/webhook delivery issues
- The diagnostics file gives the "shape" of the instance (version, topology, load, config); the logs give the timeline of events

## CRE perspective

Deciphering a bundle is core CRE work. You need to know **which log answers which question** so you don't waste time. The workflow is: read `ghe-config.log` / diagnostics first to understand the instance, correlate the customer's reported timestamp against the relevant subsystem log, then pivot across logs (e.g. `haproxy.log` → `github-logs/production.log` → `exceptions.log`) to follow a single request through the stack. Always confirm the GHES **version** and **topology** (standalone, HA pair, or cluster) before interpreting anything, because paths and behavior differ.

---

## Bundle types

| Type | Contents | Time range |
|---|---|---|
| Diagnostic file | Plaintext settings + environment snapshot only | Point-in-time |
| Support bundle | Diagnostics file + sanitized logs | Last **2 days** (default) |
| Extended support bundle | Diagnostics file + sanitized logs | Last **8 days** |

---

## Generating a bundle

| Scenario | Command |
|---|---|
| Standard bundle (SSH) | `ssh -p122 admin@HOSTNAME -- 'ghe-support-bundle -o' > bundle.tgz` |
| Extended bundle | `ssh -p122 admin@HOSTNAME -- 'ghe-support-bundle -o -e' > bundle.tgz` |
| Cluster / HA bundle | `ssh -p122 admin@HOSTNAME -- 'ghe-cluster-support-bundle -o' > cluster-bundle.tgz` |
| Diagnostics only | `ssh -p122 admin@HOSTNAME -- 'ghe-diagnostics' > diagnostics.txt` |
| Management Console | Site admin → Management Console → **Support** → **Download support bundle** |

> **Cluster note:** Always use `ghe-cluster-support-bundle` for clustered or geo-replicated instances — it gathers logs from **every node**, not just the one you SSH'd into.

---

## Unpacking

```bash
# Extract
tar xzf bundle.tgz
cd <bundle-dir>

# See the top-level layout
ls -la

# Find the largest logs (often where the action is)
du -ah . | sort -rh | head -20

# Search every log for an error across the whole bundle
grep -rin "error\|exception\|fatal" . | less

# Follow one timestamp window across all logs
grep -rin "2026-06-25T14:3" .
```

---

## Directory layout (what lives where)

| Path | Subsystem | What you'll find |
|---|---|---|
| `ghe-config.log` / diagnostics file | Config | Version, SHAs, topology, hostname, auth mode, license, load |
| `github-logs/` | Rails app (frontend) | App requests, errors, audit, exceptions |
| `babeld-logs/` | Git proxy (babeld) | Git over SSH/HTTPS routing, fetch/push proxying |
| `system-logs/` | OS / load balancer | `haproxy.log`, `syslog`, kernel, dmesg |
| `enterprise-manage-logs/` | Management Console | Config apply, MC errors |
| `configuration-logs/` | Config runs | Output of `ghe-config-apply` runs |
| `elasticsearch-logs/` | Search | Indexing, search cluster health |
| `alambic-logs/` | Storage (LFS/avatars/assets) | Object storage operations |
| `hookshot-logs/` | Webhooks | Webhook delivery and retries |
| `codeload-logs/` | Archive downloads | `git archive` / zip/tarball downloads |
| `pages-logs/` | GitHub Pages | Pages builds and serving |
| `lfs-server-logs/` | Git LFS | Large file storage transactions |
| `mail-logs/mail.log` | SMTP | Outbound email delivery |
| `collectd/logs/collectd.log` | Metrics | collectd daemon (feeds monitoring) |
| `registry-logs/` | Packages / registry | Container & package registry |
| `svn-bridge-logs/` | SVN bridge | Subversion compatibility |
| `task-dispatcher-logs/` | Background jobs | Async/resque-style job dispatch |

---

## The most useful logs (start here)

| Question | Log to read |
|---|---|
| What is this instance? (version, topology, auth, license) | Diagnostics file / `ghe-config.log` |
| Site throwing 500s? | `github-logs/exceptions.log` |
| App-level request detail | `github-logs/production.log` |
| Who did what, when? | `github-logs/audit.log` |
| LDAP / SAML / CAS auth failing? | `github-logs/auth.log` |
| 502 / 503 / routing / which node? | `system-logs/haproxy.log` |
| Git clone/fetch/push problems | `babeld-logs/babeld.log` |
| Config apply broke something | `configuration-logs/` + `enterprise-manage-logs/` |
| Search broken / slow indexing | `elasticsearch-logs/github-enterprise.log` |
| Webhooks not arriving | `hookshot-logs/` |
| Email not sending | `mail-logs/mail.log` |
| LFS push/pull errors | `lfs-server-logs/` |

---

## Reading the diagnostics file

Scan for these first — they frame every other interpretation:

| Field | Why it matters |
|---|---|
| Version + SHA | Determines feature set, known bugs, correct doc version |
| Topology | Standalone vs HA vs cluster changes log locations and failure modes |
| Private mode / SSL settings | Affects auth and connectivity symptoms |
| Auth method | LDAP vs SAML vs built-in changes where to look for login failures |
| License (seats, expiry) | Expired/over-limit licenses cause access issues |
| Load + process listing | High load points to performance root cause |
| Disk usage | Full disk causes 500s, failed pushes, stuck jobs |
| Repo / user counts | Sizing context for performance complaints |

---

## Log sanitization

These directories are **scrubbed of tokens, keys, and secrets** before bundling, so don't expect to find raw credentials:

`alambic-logs` · `babeld-logs` · `codeload-logs` · `enterprise-manage-logs` · `github-logs` · `hookshot-logs` · `lfs-server-logs` · `semiotic-logs` · `task-dispatcher-logs` · `pages-logs` · `registry-logs` · `render-logs` · `svn-bridge-logs`

---

## Investigation playbook

1. **Confirm the instance** — open the diagnostics file: version, topology, auth mode, disk, load.
2. **Pin the timestamp** — get the exact time (and timezone) of the customer's symptom.
3. **Pick the entry log** — map the symptom to a subsystem using the tables above.
4. **Follow the request** — pivot across logs for the same time window:
   `haproxy.log` (did it route?) → `production.log` (did the app handle it?) → `exceptions.log` (did it blow up?).
5. **Check resources** — cross-reference `collectd` / load / disk if symptoms look like saturation.
6. **Correlate config changes** — check `configuration-logs/` for a recent `ghe-config-apply` near the incident.
7. **Summarize** — version, topology, timeline, root-cause log line, and next step.

---

## Common patterns to grep for

```bash
# 500s and their backtraces
grep -n "Error\|Exception" github-logs/exceptions.log

# Auth failures (LDAP/SAML)
grep -in "failed\|invalid\|denied" github-logs/auth.log

# Backend marked down by the load balancer
grep -in "backend\|down\|no server available" system-logs/haproxy.log

# Slow requests (look for high durations in production.log)
grep -nE "duration=|completed in [0-9]{4,}ms" github-logs/production.log

# Recent config applies
grep -in "applying\|finished\|failed" configuration-logs/* enterprise-manage-logs/*
```

---

## Quick reference links

- [Providing data to GitHub Support](https://docs.github.com/en/enterprise-server@latest/support/contacting-github-support/providing-data-to-github-support)
- [Command-line utilities (`ghe-support-bundle`, `ghe-cluster-support-bundle`)](https://docs.github.com/en/enterprise-server@latest/admin/administering-your-instance/administering-your-instance-from-the-command-line/command-line-utilities)
- [About the audit log for your enterprise](https://docs.github.com/en/enterprise-server@latest/admin/monitoring-activity-in-your-enterprise/reviewing-audit-logs-for-your-enterprise/about-the-audit-log-for-your-enterprise)
- [[ESB Support Bundle Workflow]] - pulling a bundle down via esbtools (extract first, then scp)
- [[GHES Cheatsheet]]
