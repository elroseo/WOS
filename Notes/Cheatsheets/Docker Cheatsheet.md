# Docker Cheatsheet

## What is Docker?

Docker packages an application and its dependencies into a **container**, a lightweight, isolated process that runs the same way on any host. Containers share the host kernel (unlike VMs), so they start fast and use fewer resources. Images are the read-only templates; containers are running instances of them.

## CRE perspective

You will meet Docker when customers self-host runners, run GitHub Actions, package services, or debug container-based CI. GHES itself is a virtual appliance (not Docker), but Actions workflows, self-hosted runners, and many customer apps run in containers. Knowing how to inspect a container, read its logs, and check resource limits speeds up troubleshooting.

---

## Images

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

| Command | What it does |
|---|---|
| `docker system df` | Show disk used by images, containers, volumes |
| `docker system prune` | Remove stopped containers, unused networks, dangling images |
| `docker system prune -a --volumes` | Aggressive cleanup, including unused images and volumes |
| `docker info` | Daemon-wide status and config |
| `docker version` | Client and server versions |

> **Careful:** `docker system prune -a --volumes` can delete data you still need. Check `docker ps -a` and `docker volume ls` first.

---

## Common troubleshooting

| Issue | What to check |
|---|---|
| Container exits immediately | `docker logs <container>`, confirm the main process stays in the foreground |
| "Port already allocated" | `docker ps` for a conflicting mapping, or another host process on that port |
| Out of disk space | `docker system df`, then `docker system prune` |
| Cannot connect between containers | Put them on the same user-defined network, use container names not localhost |
| Permission denied on mount | Check host path ownership and SELinux/AppArmor, try `:z`/`:Z` on the volume |
| Image won't pull | Check registry auth (`docker login`), network/proxy, and the tag exists |

---

## Quick reference links

- [Docker CLI reference](https://docs.docker.com/reference/cli/docker/)
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Compose file reference](https://docs.docker.com/reference/compose-file/)
- [GitHub Actions: about self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners)
