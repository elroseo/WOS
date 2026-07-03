# HAProxy Cheatsheet

## What is HAProxy?

HAProxy (High Availability Proxy) is a fast TCP/HTTP load balancer and reverse proxy. It accepts client connections on **frontends**, applies rules (ACLs), and routes them to **backends** (pools of servers), health-checking each server and taking unhealthy ones out of rotation.

## CRE perspective

On GHES, **HAProxy is the front door**: every request - web, API, Git over HTTP/SSH - hits HAProxy before any backend service, and it is the **SSL termination point** (certs live here). There are multiple HAProxy instances (external/front, internal, and on a cluster a **cluster-proxy** that forwards to services on other nodes). Seeing `localhost` hops in logs is normal because requests are proxied between internal processes. When a backend is down you'll see HAProxy return a **503**; when it's overloaded, connection queueing. Reading HAProxy logs and stats is often step one in "the site is slow/down" tickets.

> [!important] GHES key points
> - **Every request enters through the external/front HAProxy; SSL terminates here.**
> - Multiple instances: **front** (external), **internal**, and **cluster-proxy** (forwards to services on other cluster nodes).
> - Backend down -> **503 Service Unavailable** from HAProxy (e.g. Unicorn stopped). Backend slow -> requests queue.
> - `localhost` in logs = normal internal proxy hop, not a bug.
> - HAProxy config on GHES is **generated** by config-apply - don't hand-edit `haproxy.cfg` on an appliance; fix the underlying service or config.

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

## Common troubleshooting

| Symptom | What to check |
|---|---|
| **503 Service Unavailable** | Backend service down/health-check failing (e.g. `nomad status github-unicorn`) |
| Site slow under load | Backend `maxconn` reached -> queueing; check timers `Tw`/`Tr` in logs |
| Intermittent errors | One backend server flapping UP/DOWN; check its health check |
| TLS/cert errors | Cert on the HAProxy frontend (SSL terminates here) - check expiry/chain |
| Everything shows `localhost` | Normal internal proxy hop on GHES, not the fault |
| Connection refused | Frontend not bound / process down; check HAProxy service status |

---

## Quick reference links

- [HAProxy configuration manual](https://docs.haproxy.org/)
- [HTTP log format & termination states](https://www.haproxy.com/documentation/haproxy-configuration-tutorials/logging/)
- [[GHES Deep Dive]] · [[GHES Cheatsheet]] · [[SSL TLS Cheatsheet]] · [[Nomad Cheatsheet]]
