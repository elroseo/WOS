---
tags:
  - docker
  - containers
  - troubleshooting
  - cheatsheet
  - runbook
audience: cre
updated: 2026-08-13
---

# Docker Cheatsheet

## What this is and when to use it

Docker packages an application and its dependencies into a **container**, a lightweight, isolated process that runs the same way on any host. Containers share the host kernel (unlike VMs), so they start fast and use fewer resources. Images are the read-only templates; containers are running instances of them.

Use this runbook when a customer's self-hosted GitHub Actions runner, a containerized service, or a customer application is misbehaving and you need to inspect container state, logs, or resource usage. GHES itself is a virtual appliance (not Docker), but Actions workflows, self-hosted runners, and many customer apps run in containers.

## Prerequisites

- Shell access to the host running Docker (a self-hosted runner host or customer application host, not the GHES appliance).
- Enough permission to run `docker` (membership in the `docker` group, or sudo).
- No special GitHub entitlement is required; this is general Docker/Linux administration knowledge applied to a customer-owned host.

## Platform scope

- **Customer-managed hosts**: self-hosted Actions runners, customer applications, and general containerized workloads. This is where this runbook applies directly.
- **GHES appliance**: on modern (containerized) GHES, services run as Docker containers, but they are supervised by Nomad. Do not run `docker` directly against the appliance; use [[Nomad Cheatsheet]] to check status, logs, and to bounce a service. Running `docker` mutating commands against a GHES appliance container fights the scheduler and is not normal CRE practice.

## Safety and read-only boundary

> [!warning] Default to read-only inspection
> Lead with `docker ps`, `docker logs`, `docker inspect`, `docker stats`, and `docker top`. Do not stop, remove, restart, or prune a customer's containers, images, volumes, or networks without the customer's explicit direction, an approved change, or Support/Engineering guidance. Direct mutation of containers on infrastructure you do not own (including a GHES appliance) is not normal CRE investigation practice.

## Quick procedure (read-only triage)

1. Confirm scope: is the affected workload a self-hosted runner, a customer application container, or (rarely) a GHES-appliance service? For a GHES-appliance service, switch to [[Nomad Cheatsheet]] instead of this procedure.
2. List containers and their current state: `docker ps` (running) or `docker ps -a` (including stopped/exited).
3. Read the failing container's logs: `docker logs <container>`, or follow in real time with `docker logs -f <container>` (add `--tail 100` to limit history).
4. Inspect full configuration for mounts, network, environment, and restart policy: `docker inspect <container>`.
5. Check live resource usage for CPU/memory/network pressure: `docker stats`.
6. Check the processes running inside the container: `docker top <container>`.
7. If the workload is Compose-based, check service status and logs: `docker compose ps`, `docker compose logs -f <service>`.
8. Check host-level disk pressure if relevant: `docker system df`.

## GUI steps

N/A. There is no supported GUI for CRE container investigation on a GHES appliance or in a standard customer environment. Docker Desktop is a local developer tool, not part of the CRE investigation workflow. Use the CLI procedure above.

## Expected output / success criteria

- `docker ps` / `docker ps -a` lists the container(s) in question with a plausible `STATUS` (e.g. `Up 3 hours`, `Exited (1) 5 minutes ago`).
- `docker logs` returns the application's stdout/stderr. An empty result can mean the container just started, does not log to stdout, or has already rotated its log, not necessarily that nothing happened.
- `docker inspect` returns valid JSON matching what the customer described (image, ports, volumes, restart policy).
- `docker stats` shows plausible CPU/memory values relative to the host's known capacity, not a hung or all-zero read.

## Validation / cross-check

- Cross-check `docker logs` findings against the exit code and reason in `docker ps -a` (`STATUS` column) and, for a crash loop, `docker inspect <container>` (`State.ExitCode`, `State.OOMKilled`).
- If the workload is orchestrated (Nomad, Kubernetes, Compose), confirm the orchestrator's view of desired versus actual state agrees with what `docker ps` shows before concluding the container itself is the problem.
- For self-hosted Actions runners, corroborate with the runner's own diagnostic logs, not just container state.

## Errors and recovery

| Issue | What to check |
|---|---|
| Container exits immediately | `docker logs <container>`, confirm the main process stays in the foreground |
| "Port already allocated" | `docker ps` for a conflicting mapping, or another host process on that port |
| Out of disk space | `docker system df`; involve the customer/owner before any `prune` action |
| Cannot connect between containers | Confirm they're on the same user-defined network, use container names not localhost |
| Permission denied on mount | Check host path ownership and SELinux/AppArmor; remediation is a customer-side change |
| Image won't pull | Check registry auth (`docker login`), network/proxy, and that the tag exists |

## Stop / escalate

Escalate or hand off when: the fix requires mutating a customer's containers/images/volumes/networks and you lack clear authorization, a GHES-appliance service is involved and Nomad-level checks aren't resolving it, or read-only inspection cannot establish a root cause within a reasonable investigation window. See [[Investigation and Escalation Judgment]] for thresholds and the evidence to collect before escalating.

---

## Mutating commands: customer-impact warning

> [!danger] Read before running anything below
> These commands stop, remove, or delete a running service or data. Confirm explicit authorization (customer request, approved change, or Support/Engineering direction) first. Never run them against a GHES appliance's containers directly; use [[Nomad Cheatsheet]] instead, since Nomad will fight and undo out-of-band `docker` changes on an appliance.

---

## Images

> [!warning] Customer impact
> `docker rmi` and `docker image prune` delete images. Confirm nothing still depends on the image first (see `docker ps -a` for containers created from it).

| Command | What it does |
|---|---|
| `docker images` | List local images |
| `docker pull <image>:<tag>` | Download an image (e.g. `ubuntu:22.04`) |
| `docker build -t <name>:<tag> .` | Build an image from a Dockerfile in the current dir |
| `docker rmi <image>` | Remove an image |
| `docker image prune` | Remove dangling (unused) images |
| `docker history <image>` | Show the layers that make up an image |
| `docker tag <image> <new>:<tag>` | Add a new tag to an image |

---

## Containers

> [!warning] Customer impact
> `docker start\|stop\|restart`, `docker rm`, and `docker container prune` change or remove a running/stopped service. Read-only commands (`docker ps`, `docker ps -a`) are always safe to run first.

| Command | What it does |
|---|---|
| `docker ps` | List running containers |
| `docker ps -a` | List all containers, including stopped |
| `docker run <image>` | Create and start a container |
| `docker run -it <image> bash` | Run interactively with a shell |
| `docker run -d <image>` | Run detached (in the background) |
| `docker start\|stop\|restart <container>` | Control a container's lifecycle |
| `docker rm <container>` | Remove a stopped container |
| `docker rm -f <container>` | Force-remove a running container |
| `docker container prune` | Remove all stopped containers |

### Common `docker run` flags

| Flag | Purpose |
|---|---|
| `-d` | Detached / background |
| `-it` | Interactive with a TTY |
| `--name <name>` | Give the container a name |
| `-p <host>:<container>` | Publish a port (e.g. `-p 8080:80`) |
| `-v <host>:<container>` | Mount a volume or bind mount |
| `-e KEY=value` | Set an environment variable |
| `--rm` | Auto-remove the container when it exits |
| `--restart unless-stopped` | Restart policy for long-running services |

---

## Inspecting and debugging

| Command | What it does |
|---|---|
| `docker logs <container>` | Show a container's stdout/stderr |
| `docker logs -f <container>` | Follow logs in real time |
| `docker exec -it <container> bash` | Open a shell inside a running container |
| `docker inspect <container>` | Full JSON detail (config, mounts, network) |
| `docker stats` | Live CPU, memory, and network per container |
| `docker top <container>` | Processes running inside a container |
| `docker diff <container>` | Files changed since the container started |
| `docker port <container>` | Show port mappings |

```bash
# Get a container's IP address
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container>

# Follow the last 100 log lines
docker logs --tail 100 -f <container>
```

---

## Volumes and data

> [!warning] Customer impact
> `docker volume rm` and `docker volume prune` delete data. Named volumes are often the only copy of a container's persistent state; confirm what's using a volume before removing it.

| Command | What it does |
|---|---|
| `docker volume ls` | List volumes |
| `docker volume create <name>` | Create a named volume |
| `docker volume inspect <name>` | Show volume details |
| `docker volume rm <name>` | Remove a volume |
| `docker volume prune` | Remove unused volumes |

> **Note:** Named volumes persist data beyond the container's life. Bind mounts (`-v /host/path:/container/path`) map a host directory straight into the container.

---

## Networking

| Command | What it does |
|---|---|
| `docker network ls` | List networks |
| `docker network create <name>` | Create a user-defined network |
| `docker network connect <net> <container>` | Attach a container to a network |
| `docker network inspect <name>` | Show network details and connected containers |

> Containers on the same user-defined network can reach each other by container name (built-in DNS).

---

## Docker Compose

Defines multi-container apps in a `docker-compose.yml` file.

| Command | What it does |
|---|---|
| `docker compose up` | Start all services defined in the compose file |
| `docker compose up -d` | Start detached |
| `docker compose down` | Stop and remove services, networks |
| `docker compose ps` | List services and status |
| `docker compose logs -f <service>` | Follow logs for a service |
| `docker compose exec <service> bash` | Shell into a running service |
| `docker compose build` | Build or rebuild service images |

---

## System and cleanup

> [!danger] Customer impact
> `docker system prune` and `docker system prune -a --volumes` can delete data you still need, including stopped containers, images, and volumes the customer intended to keep. Check `docker ps -a` and `docker volume ls` first, and confirm authorization before running either.

| Command | What it does |
|---|---|
| `docker system df` | Show disk used by images, containers, volumes |
| `docker system prune` | Remove stopped containers, unused networks, dangling images |
| `docker system prune -a --volumes` | Aggressive cleanup, including unused images and volumes |
| `docker info` | Daemon-wide status and config |
| `docker version` | Client and server versions |

---

## Related notes and docs

- [[Nomad Cheatsheet]]: how GHES actually manages its own containers
- [[GHES Deep Dive]]
- [Docker CLI reference](https://docs.docker.com/reference/cli/docker/)
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Compose file reference](https://docs.docker.com/reference/compose-file/)
- [GitHub Actions: about self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners)

## Freshness note

Restructured as a CRE runbook on 2026-08-13. Command syntax reflects the Docker CLI reference at that time. Reconfirm flags with `docker <command> --help` or the current Docker docs before relying on them, especially around Compose v2 syntax differences.
