---
tags:
  - haproxy
  - ghes
  - networking
  - troubleshooting
  - cheatsheet
  - runbook
audience: cre
updated: 2026-08-13
---

# HAProxy Cheatsheet

## What this is and when to use it

HAProxy (High Availability Proxy) is a fast TCP/HTTP load balancer and reverse proxy. It accepts client connections on **frontends**, applies rules (ACLs), and routes them to **backends** (pools of servers), health-checking each server and taking unhealthy ones out of rotation.

On GHES, **HAProxy is the front door**: every request (web, API, Git over HTTP/SSH) hits HAProxy before any backend service, and it is the **SSL termination point** (certs live here). Use this runbook for "the site is slow/down", 503 errors, or TLS-handshake tickets where HAProxy logs are the first thing to check.

> [!important] GHES key points
> - **Every request enters through the external/front HAProxy; SSL terminates here.**
> - Multiple instances: **front** (external), **internal**, and **cluster-proxy** (forwards to services on other cluster nodes).
> - Backend down -> **503 Service Unavailable** from HAProxy (e.g. Unicorn stopped). Backend slow -> requests queue.
> - `localhost` in logs = normal internal proxy hop, not a bug.
> - HAProxy config on GHES is **generated** by config-apply; don't hand-edit `haproxy.cfg` on an appliance, fix the underlying service or config instead.

## Prerequisites

- SSH access to the GHES appliance (or the relevant node on a cluster/HA topology).
- Access to HTTP access logs for the instance.
- For runtime-socket checks: knowledge of the socket path, which varies by environment; confirm it with Support/Engineering guidance rather than guessing.

## Platform scope

- **GHES appliance**: primary scope of this runbook. HAProxy config is generated; don't hand-edit it.
- **Self-managed HAProxy** (customer's own load balancer in front of GHES, or an unrelated service): the log-reading and stats-socket guidance below applies the same way, but config editing may be a supported customer-side action there.

## Safety and read-only boundary

> [!warning] Default to reading logs and stats
> Reading the HTTP log line, checking backend health, and viewing stats (`show stat`, `show servers state`) are read-only. Do not disable/enable servers via the runtime socket, and do not hand-edit `haproxy.cfg` on a GHES appliance. On GHES, bounce the actual backend service through Nomad ([[Nomad Cheatsheet]]) rather than poking HAProxy directly; direct HAProxy mutation is not normal CRE investigation practice.

## Quick procedure (read-only triage)

1. Confirm the symptom: 503s, slow responses, TLS handshake failures, or intermittent errors.
2. Pull the relevant HTTP log lines and read the fields left to right: `frontend`, `backend/server`, the `Tq/Tw/Tc/Tr/Tt` timers, `status`, and the **termination state** code.
3. If `status` is 503, identify which backend was targeted and check whether that service is actually up (see [[Nomad Cheatsheet]], e.g. `nomad status github-unicorn`).
4. If timers show a large `Tw` (queue wait), suspect the backend is overloaded (`maxconn` reached) rather than HAProxy itself.
5. If TLS/cert errors, check the certificate on the HAProxy frontend since SSL terminates there (see [[SSL TLS Cheatsheet]]).
6. If a runtime socket is available and you have authorization to use it, view state read-only: `echo "show stat" | socat stdio /path/to/haproxy.sock` or `echo "show servers state" | socat stdio <sock>`.
7. Note that `localhost` entries in logs are a normal internal proxy hop, not evidence of a problem.

## GUI steps

N/A on GHES. HAProxy's optional stats web UI, when enabled in a self-managed environment, can be viewed read-only in a browser; GHES does not expose this to CREs as part of the standard investigation workflow.

## Expected output / success criteria

- The HTTP log line for the affected request shows a `frontend`/`backend` pair consistent with the reported request path, a status code, and a termination state you can classify against the reference table below.
- `show stat` (if available) reports each backend server's state (`UP`, `DOWN`, `MAINT`, `DRAIN`) matching what the logs imply.
- A 503 correlates with the targeted backend service showing a non-running state in Nomad.

## Validation / cross-check

- Cross-check a suspected backend outage against the Nomad allocation status for that service before concluding HAProxy is at fault; HAProxy is usually reporting a real downstream problem, not causing one.
- Cross-check TLS handshake failures against certificate expiry/chain on the frontend (see [[SSL TLS Cheatsheet]]) rather than assuming an HAProxy config issue.
- Confirm "everything shows `localhost`" is the expected internal hop pattern for this GHES topology before treating it as an anomaly.

## Errors and recovery

| Symptom | What to check |
|---|---|
| **503 Service Unavailable** | Backend service down/health-check failing (e.g. `nomad status github-unicorn`) |
| Site slow under load | Backend `maxconn` reached -> queueing; check timers `Tw`/`Tr` in logs |
| Intermittent errors | One backend server flapping UP/DOWN; check its health check |
| TLS/cert errors | Cert on the HAProxy frontend (SSL terminates here); check expiry/chain |
| Everything shows `localhost` | Normal internal proxy hop on GHES, not the fault |
| Connection refused | Frontend not bound / process down; check HAProxy service status |

## Stop / escalate

Escalate when a backend is confirmed down and restarting it through Nomad doesn't resolve the 503s, when HAProxy config itself appears to need a change (this must go through config-apply/Support/Engineering, not a hand-edit), or when TLS termination issues require a certificate change. See [[Investigation and Escalation Judgment]] for thresholds and the evidence to collect first.

---

## Mutating actions: customer-impact warning

> [!danger] Read before running anything below
> Disabling or enabling a server via the runtime socket changes live traffic routing immediately. Hand-editing `haproxy.cfg` on a GHES appliance is unsupported since config-apply regenerates it. Confirm authorization (customer request, approved change, or Support/Engineering direction) before any of these, and prefer bouncing the backend service through Nomad instead of touching HAProxy directly.

---

## Reading the HTTP log line

A typical HAProxy HTTP log entry (left to right):

```
client_ip:port [timestamp] frontend backend/server Tq/Tw/Tc/Tr/Tt status bytes ... termination_state ... "METHOD /uri HTTP/1.1"
```

| Field | Meaning |
|---|---|
| `frontend` | Which listener received it (e.g. the front HAProxy) |
| `backend/server` | Where it was routed (e.g. `web-unicorns/localhost`) |
| `Tq/Tw/Tc/Tr/Tt` | Timers: request wait / queue / connect / response / total (ms) |
| `status` | HTTP status returned (503 = backend unavailable) |
| **termination_state** | 2-char code explaining how the session ended (see below) |

### Termination state (first two chars)

| Code | Meaning |
|---|---|
| `--` | Normal completion |
| `sH` | Server timeout waiting for response headers |
| `sC` | Server connection timeout / refused |
| `cD` | Client aborted / data timeout |
| `PC` | Proxy denied the connection (e.g. ACL) |
| `SC` | Server closed abruptly / no healthy server |

---

## Backend & server health

| Concept | What it means |
|---|---|
| **Health check** | Periodic probe of each backend server; failing servers are removed from rotation |
| **UP / DOWN** | Server state per health checks |
| **MAINT** | Server manually disabled |
| **DRAIN** | No new sessions, existing ones finish |
| **Queue** | Requests waiting because backend `maxconn` is reached |

### Stats & runtime (where available)

> [!danger] Customer impact: disable/enable server
> `disable server` and `enable server` change live traffic routing immediately, taking a server out of or back into rotation. Confirm authorization before running either, and prefer bouncing the backend service through Nomad ([[Nomad Cheatsheet]]) instead on GHES.

| Action | How |
|---|---|
| View stats page | HAProxy stats socket / web UI (if enabled) |
| Runtime socket | `echo "show stat" \| socat stdio /path/to/haproxy.sock` |
| Server state | `echo "show servers state" \| socat stdio <sock>` |
| Disable a server | `echo "disable server <bk>/<srv>" \| socat stdio <sock>` |
| Enable a server | `echo "enable server <bk>/<srv>" \| socat stdio <sock>` |

> On GHES prefer `ghe-*`/`nomad` tooling to bounce the actual backend service rather than poking HAProxy directly.

---

## Config structure (for reading, not editing on GHES)

```
global      # process-wide settings (limits, logging, TLS)
defaults    # defaults inherited by sections below
frontend f  # what to listen on; ACLs decide the backend
  bind :443 ssl crt /path/cert.pem
  default_backend web
backend web # pool of servers + how to balance/health-check them
  balance roundrobin
  option httpchk GET /status
  server web1 127.0.0.1:8080 check
```

| Section | Purpose |
|---|---|
| `global` | Process settings: max connections, logging, TLS tuning |
| `defaults` | Shared timeouts/options for following sections |
| `frontend` | Listener + routing rules (ACLs) |
| `backend` | Server pool, load-balancing algo, health checks |
| `listen` | Combined frontend+backend in one block |

| Balance algorithm | Use |
|---|---|
| `roundrobin` | Even distribution (default) |
| `leastconn` | Send to server with fewest active connections |
| `source` | Sticky by client IP hash |

---

## Related notes and docs

- [HAProxy configuration manual](https://docs.haproxy.org/)
- [HTTP log format & termination states](https://www.haproxy.com/documentation/haproxy-configuration-tutorials/logging/)
- [[GHES Deep Dive]] · [[GHES Cheatsheet]] · [[SSL TLS Cheatsheet]] · [[Nomad Cheatsheet]]

## Freshness note

Restructured as a CRE runbook on 2026-08-13. Log format, termination-state codes, and runtime-socket commands reflect standard HAProxy behavior; confirm the exact socket path and whether it's enabled on the customer's instance before relying on the runtime-socket commands.
