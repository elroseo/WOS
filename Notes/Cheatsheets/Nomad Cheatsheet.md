---
tags:
  - nomad
  - ghes
  - orchestration
  - troubleshooting
  - cheatsheet
  - runbook
audience: cre
updated: 2026-08-13
---

# Nomad Cheatsheet

## What this is and when to use it

Nomad is HashiCorp's workload orchestrator. It schedules and supervises **jobs** (defined in HCL) across one or more nodes, keeping each service at its **desired state** and restarting it if it dies.

On modern (containerized) GHES, **most services run as Docker containers that Nomad orchestrates**. You almost never touch `docker` directly; you use Nomad to inspect status and to bounce a service, and Nomad drives the Docker backend for you. Use this runbook when a GHES service shows unhealthy, needs a restart, or you need to correlate a Docker container with its Nomad allocation.

> [!important] GHES gotchas
> - Restart a **single service** through Nomad instead of running a full `ghe-config-apply` for a minor change (a full apply can take ~40 min on a large cluster with Actions enabled).
> - Port errors (e.g. MySQL `3306`/`3307` unavailable) -> check `nomad status mysql` first.
> - After a restart you may briefly see **two allocations** (old stopped + new running); the old one is garbage-collected shortly.
> - "desired state = run, actual state = running" is healthy; watch for `dead`/`failed` allocations.
> - A container's UUID first segment matches its Nomad **allocation ID**.
> - On a true cluster, one MySQL node is also the **Nomad leader**, and many admin commands must run there.

## Prerequisites

- SSH access to the GHES appliance (or the relevant node on a cluster).
- On a cluster, know which node is the Nomad leader/MySQL primary for commands that must run there.

## Platform scope

- **GHES appliance** (standalone, HA, or cluster): this is the primary scope. On standalone, a single Nomad node runs every service; on a cluster the jobs are spread across nodes per their roles.
- Commands that must run on the leader/primary are noted where relevant; confirm the current leader with `nomad server members` before running them elsewhere.

## Safety and read-only boundary

> [!warning] Default to status, not stop/restart
> `nomad status`, `nomad node status`, `nomad alloc status`, and `nomad alloc logs` are read-only. Stopping or restarting an allocation or job changes a running service immediately. On GHES, restarting a service through Nomad is a documented, supported action, but it is still customer-impacting: confirm the target service and get authorization (customer request, approved change, or Support/Engineering direction) before bouncing anything beyond what you were explicitly asked to check.

## Quick procedure (read-only triage)

1. Confirm scope: which service is reported unhealthy, and is this standalone, HA, or a cluster?
2. Check overall job status: `nomad status` (all jobs) or `nomad status <job>` for the specific service (e.g. `github-unicorn`, `mysql`).
3. Drill into the allocation for recent events, restarts, and failures: `nomad alloc status <alloc-id>`.
4. Pull logs for the failing task: `nomad alloc logs <alloc-id>` (stdout), `nomad alloc logs -stderr <alloc-id>` (stderr), or `nomad alloc logs -f <alloc-id>` to follow.
5. If correlating with a Docker container, match the container whose UUID **starts with** the Nomad allocation ID; use `docker ps` to view it (see [[Docker Cheatsheet]]), but don't manage it with `docker` directly.
6. On a cluster, confirm node membership and roles if the service seems misplaced: `nomad node status`, `nomad server members`.
7. If a command needs to run on the primary/leader and you're unsure which node that is, check before running it, don't guess.

## GUI steps

N/A. Nomad has an upstream web UI, but it is not part of the standard, supported CRE workflow for investigating a GHES appliance. Use the CLI procedure above.

## Expected output / success criteria

- `nomad status <job>` shows the job's task group with desired count matching running count, and allocation status `running`.
- `nomad alloc status <alloc-id>` shows recent events consistent with a healthy lifecycle (no repeated `restart` or `failed` events without a clear cause).
- `nomad alloc logs` returns plausible service output, not an empty stream or a connection error.

## Validation / cross-check

- Cross-check "desired state = run, actual state = running" is genuinely healthy; a `dead` or `failed` allocation, or a state that flips repeatedly, needs further investigation before you conclude the service is fine.
- After any restart, expect to briefly see two allocations (old stopped + new running); don't mistake this for a duplicate/broken state, confirm it resolves to one running allocation shortly after.
- Cross-check a Nomad-reported failure against the underlying task's logs (`nomad alloc logs -stderr`) rather than relying on job status alone.
- On a cluster, confirm you ran leader/primary-only commands on the correct node (`nomad server members`) before trusting the result.

## Errors and recovery

| Issue | What to check |
|---|---|
| Service shows `dead`/`failed` | `nomad alloc status <alloc-id>` for recent events; then `nomad alloc logs -stderr` |
| Port unavailable (e.g. MySQL) | `nomad status mysql`, confirm the alloc is running, not stopped |
| Change didn't take effect | Did the HCL template re-render? Re-run the job or `ghe-config-apply` |
| Stale/duplicate allocation | Normal right after a restart; wait for garbage collection, re-check `nomad status` |
| Command "must run on primary" | On a cluster, run it on the **MySQL primary / Nomad leader** node |
| Service flaps after Docker action | Stop using `docker` directly; drive it through Nomad |

## Stop / escalate

Escalate when a service remains `dead`/`failed` after a supported restart attempt, when a fix appears to require editing the job's HCL template or a full `ghe-config-apply` and you're unsure of the blast radius, or when a cluster-wide symptom (misplaced jobs, leader confusion) needs Engineering input. See [[Investigation and Escalation Judgment]] for thresholds and the evidence to collect first.

---

## Mutating commands: customer-impact warning

> [!danger] Read before running anything below
> Stopping or restarting a job/allocation interrupts a live customer-facing service, even briefly. Confirm the target service and get authorization before running any of the commands in "Restarting / bouncing a service" below. Never manage a GHES-appliance container with `docker stop`/`docker rm` directly; that fights the scheduler, since Nomad will try to restore its desired state.

---

## Cluster and node status

| Command | What it does |
|---|---|
| `nomad status` | List all jobs and their status |
| `nomad node status` | List nodes in the Nomad cluster |
| `nomad node status <node-id>` | Detail for one node (drivers, resources, allocations) |
| `nomad server members` | Show server (leader/follower) membership |
| `nomad agent-info` | Local agent runtime info |

> On a standalone GHES you'll see a single Nomad node running every service; on a true cluster the jobs are spread across nodes per their roles.

---

## Jobs and allocations

> [!warning] Customer impact
> `nomad job run`, `nomad job stop`, and `nomad job stop -purge` start, stop, or remove a job. `nomad job plan` is a safe dry-run. Confirm the target job and get authorization before running the mutating forms.

| Command | What it does |
|---|---|
| `nomad status <job>` | Status of a specific job (e.g. `github-unicorn`, `mysql`) |
| `nomad job status <job>` | Same, explicit subcommand form |
| `nomad alloc status <alloc-id>` | Detail for one allocation (events, restarts, placement) |
| `nomad job run <file>.hcl` | Submit / start a job from an HCL spec |
| `nomad job stop <job>` | Stop a job (drains its allocations) |
| `nomad job stop -purge <job>` | Stop and remove the job from state |
| `nomad job plan <file>.hcl` | Dry-run: show what a submit would change |
| `nomad job inspect <job>` | Show the job's full submitted spec |

```bash
# See where a service is placed and its desired vs actual state
nomad status github-unicorn

# Follow an allocation's recent events (restarts, failures)
nomad alloc status <alloc-id>
```

---

## Logs and exec

| Command | What it does |
|---|---|
| `nomad alloc logs <alloc-id>` | Print an allocation's stdout |
| `nomad alloc logs -stderr <alloc-id>` | Print stderr |
| `nomad alloc logs -f <alloc-id>` | Follow logs in real time |
| `nomad alloc logs <alloc-id> <task>` | Logs for a specific task in the alloc |
| `nomad alloc exec -i -t <alloc-id> /bin/bash` | Open a shell inside a running allocation |
| `nomad alloc fs <alloc-id>` | Browse the allocation's filesystem |

> On GHES, service logs also land under `/var/log/<service>` and app logs under `/var/log/github`; config-apply logs to `/data/user/common/ghe-config.log`.

---

## Restarting / bouncing a service (GHES pattern)

> [!danger] Customer impact
> Every command in this section interrupts the running service, even briefly, while Nomad reschedules it. Confirm the target service and get authorization before running any of these. Direct container/service mutation on GHES outside this documented Nomad pattern (e.g. hand-editing Docker or the job spec) is not normal CRE investigation practice and may need Support or Engineering guidance.

| Command | What it does |
|---|---|
| `nomad status <service>` | Confirm current allocation and state |
| `nomad alloc stop <alloc-id>` | Reschedule an allocation (Nomad starts a fresh one) |
| `nomad job restart <job>` | Restart a job's allocations (newer Nomad) |
| `sudo nomad job run <template>.hcl` | Re-run a rendered service template (needs sudo on GHES) |

```bash
# Typical GHES flow: stop and let Nomad reschedule a single service
nomad status github-unicorn        # note the alloc id + node
sudo nomad alloc stop <alloc-id>   # Nomad spins up a replacement
nomad status github-unicorn        # verify: two allocs briefly, then one running
```

---

## Nomad ↔ Docker relationship

| Check | Command |
|---|---|
| Nomad's view of a service | `nomad status <service>` → allocation ID |
| Docker's view | `docker ps` → container whose UUID **starts with** the alloc ID |
| Bounce a service | **Use Nomad**, not `docker stop` - Nomad manages the Docker backend |

> Manually stopping the container with Docker fights the scheduler: Nomad sees the desired state is still "run" and will try to bring it back. Always go through Nomad.

---

## Job spec (HCL) essentials

GHES ships rendered HCL templates per service; you rarely author them, but understanding the shape helps when reading `nomad job inspect`.

```hcl
job "example" {
  datacenters = ["dc1"]
  type        = "service"          # service | batch | system

  group "app" {
    count = 1                      # number of allocations

    task "server" {
      driver = "docker"
      config {
        image = "example:latest"
      }
      resources {
        cpu    = 500               # MHz
        memory = 256               # MB
      }
    }
  }
}
```

| Concept | Meaning |
|---|---|
| **job** | Top-level unit of work you submit |
| **group** | Set of tasks scheduled together on one node; `count` sets replicas |
| **task** | A single process/container (has a driver, e.g. `docker`) |
| **allocation** | A running instance of a group placed on a node |
| **evaluation** | Nomad's scheduling decision that produces allocations |

---

## Related notes and docs

- [Nomad CLI reference](https://developer.hashicorp.com/nomad/docs/commands)
- [Nomad job specification (HCL)](https://developer.hashicorp.com/nomad/docs/job-specification)
- [Nomad concepts: jobs, allocations, evaluations](https://developer.hashicorp.com/nomad/docs/concepts)
- [[GHES Deep Dive]] · [[Docker Cheatsheet]] · [[GHES Cheatsheet]]

## Freshness note

Restructured as a CRE runbook on 2026-08-13. `nomad job restart` syntax applies to newer Nomad versions; confirm the customer's Nomad version supports it before relying on it over the `alloc stop` pattern.
