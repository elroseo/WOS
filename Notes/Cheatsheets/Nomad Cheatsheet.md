# Nomad Cheatsheet

## What is Nomad?

Nomad is HashiCorp's workload orchestrator. It schedules and supervises **jobs** (defined in HCL) across one or more nodes, keeping each service at its **desired state** and restarting it if it dies. It is a lighter-weight alternative to Kubernetes: a single binary that handles scheduling, health, and placement.

## CRE perspective

On modern (containerized) GHES, **most services run as Docker containers that Nomad orchestrates**. You almost never touch `docker` directly — you use Nomad to inspect status and to bounce a service, and Nomad drives the Docker backend for you. A container's UUID first segment matches its Nomad **allocation ID**. On a true cluster, one MySQL node is also the **Nomad leader**, and many admin commands must run there. `ghe-config-apply` renders per-service Nomad HCL templates and then starts the jobs.

> [!important] GHES gotchas
> - Restart a **single service** through Nomad instead of running a full `ghe-config-apply` for a minor change (a full apply can take ~40 min on a large cluster with Actions enabled).
> - Port errors (e.g. MySQL `3306`/`3307` unavailable) → check `nomad status mysql` first.
> - After a restart you may briefly see **two allocations** (old stopped + new running); the old one is garbage-collected shortly.
> - "desired state = run, actual state = running" is healthy; watch for `dead`/`failed` allocations.

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
| Bounce a service | **Use Nomad**, not `docker stop` — Nomad manages the Docker backend |

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

## Common troubleshooting

| Issue | What to check |
|---|---|
| Service shows `dead`/`failed` | `nomad alloc status <alloc-id>` for recent events; then `nomad alloc logs -stderr` |
| Port unavailable (e.g. MySQL) | `nomad status mysql` — confirm the alloc is running, not stopped |
| Change didn't take effect | Did the HCL template re-render? Re-run the job or `ghe-config-apply` |
| Stale/duplicate allocation | Normal right after a restart; wait for garbage collection, re-check `nomad status` |
| Command "must run on primary" | On a cluster, run it on the **MySQL primary / Nomad leader** node |
| Service flaps after Docker action | Stop using `docker` directly; drive it through Nomad |

---

## Quick reference links

- [Nomad CLI reference](https://developer.hashicorp.com/nomad/docs/commands)
- [Nomad job specification (HCL)](https://developer.hashicorp.com/nomad/docs/job-specification)
- [Nomad concepts: jobs, allocations, evaluations](https://developer.hashicorp.com/nomad/docs/concepts)
- [[GHES Deep Dive]] · [[Docker Cheatsheet]] · [[GHES Cheatsheet]]
