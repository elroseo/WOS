---
tags:
  - ghes
  - admin
  - cli
  - cheatsheet
audience: CRE
updated: 2026-08-13
---

# GHES Cheatsheet

## What and when

GitHub Enterprise Server (GHES) is a self-hosted version of GitHub that organizations run on their own infrastructure (VMware, AWS, Azure, or GCP). It provides the same core features as github.com but within the customer's own network, giving organizations control over data, security policy, and compliance.

Use this cheatsheet when you need to check appliance status, inspect logs, test auth, or plan an upgrade for a GHES customer. Typical customers: on-premises/compliance-driven orgs, air-gapped or firewall-restricted environments, and large enterprises managing their own infrastructure.

CRE work here spans installation, upgrades, authentication configuration (LDAP, SAML, CAS), high availability and replication, backup and restore, performance troubleshooting, and connectivity issues. Understanding the `ghe-*` command line tools, log locations, and the Management Console is essential for diagnosing and resolving customer issues.

## Prerequisites and auth

- SSH access to the appliance on port 122 with an authorized admin key (`ssh -p 122 admin@HOSTNAME`).
- Management Console access at `https://HOSTNAME:8443` (setup/admin password required).
- A GitHub token with admin scope for Admin API calls (see [[#API access]]); a standard token is sufficient for the regular REST API.
- Confirm you're authorized to run customer-impacting actions (see [[#Safety and read-only boundary]]) before executing them against a production instance.

## Platform scope

- This cheatsheet covers **GHES only**. For where equivalent controls live on GitHub Enterprise Cloud (GHEC), see [[GHEC vs GHES Cheatsheet]].
- Do not assume standalone topology. Confirm whether the instance is standalone, HA, cluster, or geo-replicated before running commands, since some commands (replication, cluster) only apply to specific topologies and log paths can vary by node role.
- GHES appliance identifiers (repo_id, org_id, user_id) are independent from GitHub.com identifiers and can collide. Never join GHES data to GHEC/dotcom datasets without confirming the platform first.

## Safety and read-only boundary

| Type | Examples | Notes |
|---|---|---|
| Read-only, safe anytime | `ghe-version`, `ghe-system-info`, `ghe-check-disk-usage`, `ghe-service-list`, `ghe-repl-status`, `ghe-config --list`, log tailing, REST/Admin API `GET` calls | Safe to run without customer coordination |
| Customer-impacting | `ghe-config-apply` (brief downtime), `ghe-maintenance -s` (blocks user access), `ghe-repl-promote` (failover), `ghe-user-suspend`/`ghe-user-unsuspend`, `ghe-restore`, upgrades | Coordinate with the customer and follow their change process before running |

Never run a customer-impacting command without explicit customer authorization and, where applicable, a maintenance window.

---

## Connecting

| Method | Command |
|---|---|
| SSH to appliance | `ssh -p 122 admin@HOSTNAME` |
| Web admin console | `https://HOSTNAME:8443/setup` |
| Management console | `https://HOSTNAME:8443` |

---

## `ghe-*` admin utilities

### System status

| Command | What it does |
|---|---|
| `ghe-system-info` | Overview of system resources and versions |
| `ghe-version` | Show GHES version |
| `ghe-check-disk-usage` | Check disk space |
| `ghe-diagnostics` | Generate a diagnostics bundle |
| `ghe-support-bundle` | Create a support bundle for GitHub Support |

### Services

| Command | What it does |
|---|---|
| `ghe-service-list` | List all services and their status |
| `ghe-service-status` | Check if services are healthy |
| `systemctl status github-<service>` | Check a specific service |

### Configuration

| Command | What it does |
|---|---|
| `ghe-config --list` | List all configuration settings |
| `ghe-config <key>` | Get a specific setting |
| `ghe-config <key> <value>` | Set a configuration value |
| `ghe-config-apply` | Apply pending configuration changes (causes brief downtime) |

### Maintenance

| Command | What it does |
|---|---|
| `ghe-maintenance -s` | Enable maintenance mode (**customer-impacting:** blocks user access) |
| `ghe-maintenance -u` | Disable maintenance mode |
| `ghe-maintenance -q` | Check maintenance status |

### Replication (HA)

| Command | What it does |
|---|---|
| `ghe-repl-status` | Check replication status |
| `ghe-repl-setup <primary-ip>` | Configure as a replica |
| `ghe-repl-start` | Start replication |
| `ghe-repl-stop` | Stop replication |
| `ghe-repl-promote` | Promote replica to primary (**customer-impacting:** failover) |

### Backups

| Command | What it does |
|---|---|
| `ghe-backup` | Run a backup (from backup host, using backup-utils) |
| `ghe-restore` | Restore from backup (**customer-impacting:** overwrites current appliance state) |
| `ghe-backup-utils` | Backup utilities package |

> **Note:** Backups run from a separate backup host, not on the GHES appliance itself.

---

## Authentication and LDAP

| Command | What it does |
|---|---|
| `ghe-config auth.mode` | Check current auth mode |
| `ghe-ldap-test` | Test LDAP configuration |
| `ghe-user-admin` | Manage user accounts |
| `ghe-user-suspend <username>` | Suspend a user (**customer-impacting**) |
| `ghe-user-unsuspend <username>` | Unsuspend a user (**customer-impacting**) |

---

## Networking and SSL

| Command | What it does |
|---|---|
| `ghe-ssl-certificate-setup` | Configure SSL certificate |
| `ghe-config core.hostname` | Check/set the hostname |
| `ghe-ssl-ca-certificate-install` | Install a custom CA certificate |

---

## Log locations

| Log | Path |
|---|---|
| System logs | `/var/log/syslog` |
| GitHub app logs | `/var/log/github/` |
| Auth logs | `/var/log/github/auth.log` |
| Audit log | Available via web UI or API |
| Exceptions | `/var/log/github/exceptions.log` |
| Git operations | `/var/log/github/gitauth.log` |

### Viewing logs

```bash
# Tail a log in real time
tail -f /var/log/github/auth.log

# Search logs for a user
grep "username" /var/log/github/auth.log

# View recent exceptions
tail -100 /var/log/github/exceptions.log
```

---

## API access

### REST API

```bash
curl -H "Authorization: token TOKEN" https://HOSTNAME/api/v3/users/octocat
```

### Admin API (site admin only)

```bash
# List all users
curl -H "Authorization: token TOKEN" https://HOSTNAME/api/v3/admin/users

# Suspend a user
curl -X PUT -H "Authorization: token TOKEN" https://HOSTNAME/api/v3/users/USERNAME/suspended
```

### Rate limit check

```bash
curl -H "Authorization: token TOKEN" https://HOSTNAME/api/v3/rate_limit
```

---

## CLI procedure: routine status check (read-only)

1. `ssh -p 122 admin@HOSTNAME` to connect.
2. `ghe-version` to confirm the running version and build.
3. `ghe-system-info` for an overview of resources and versions.
4. `ghe-service-list` to confirm every service is running.
5. `ghe-check-disk-usage` to confirm free disk space.
6. `ghe-repl-status` if the topology is HA/cluster, to confirm replication health.
7. Tail `/var/log/github/exceptions.log` and `/var/log/github/auth.log` for recent errors if a symptom was reported.

**Success criteria:** every command completes without error, `ghe-service-list` shows no stopped/failed services, disk usage is within the customer's normal range, and (if applicable) replication shows healthy. Treat any command that errors, hangs, or reports a stopped/degraded component as a signal to investigate further before concluding the instance is healthy.

## CLI procedure: upgrade (customer-impacting)

1. Confirm the target version's [upgrade requirements](https://docs.github.com/en/enterprise-server/admin/upgrading-your-instance) and confirm a supported upgrade path from the current version.
2. Take and verify a backup (`ghe-backup` from the backup host) before proceeding.
3. Download the upgrade package (`.pkg` file) for the target version.
4. Enable maintenance mode: `ghe-maintenance -s`.
5. Upload the package via the Management Console or SCP (see GUI procedure below).
6. Run the upgrade.
7. Disable maintenance mode: `ghe-maintenance -u`.
8. Verify with `ghe-version`.

**Success criteria:** `ghe-version` reports the target version, `ghe-service-list` shows all services running, and `ghe-maintenance -q` confirms maintenance mode is off. If any service fails to come back up or the version does not match the target, do not disable maintenance mode; follow [[#Stop and escalate]].

## GUI procedure

The Management Console (`https://HOSTNAME:8443`) is the documented GUI equivalent for setup, configuration apply, and upgrade package upload. There is no documented GUI equivalent in this cheatsheet for replication, backups, or per-service status; use the CLI for those.

1. Sign in to the Management Console at `https://HOSTNAME:8443` with the setup/admin password.
2. Use the upgrade/package upload option to upload the `.pkg` file downloaded in the CLI procedure above (exact menu labels vary by release; confirm against the [upgrade requirements](https://docs.github.com/en/enterprise-server/admin/upgrading-your-instance) for the target version).
3. Follow the on-screen upgrade progress, then confirm completion the same way as the CLI procedure: `ghe-version` and `ghe-service-list` over SSH.

## Validation and cross-check

- Cross-check `ghe-version` output against the version shown in the Management Console.
- Cross-check `ghe-repl-status` on every node before declaring replication healthy; a single node's view is not sufficient for HA/cluster topologies.
- Cross-check log-based findings (auth failures, exceptions) against a support bundle or Splunk before concluding root cause; see [[Splunk Cheatsheet]] and [[Support Bundles Cheatsheet]].
- For a broader, repeatable evidence-collection pass across multiple pillars, use [[Health Check Runbook]].

---

## Errors and recovery

| Issue | What to check |
|---|---|
| Slow performance | `ghe-system-info`, check CPU/memory/disk |
| Auth failures | `/var/log/github/auth.log`, test LDAP with `ghe-ldap-test` |
| 502/503 errors | `ghe-service-list`, check if services are running |
| Replication lag | `ghe-repl-status` on the replica |
| Disk full | `ghe-check-disk-usage`, clean up old backups or increase disk |
| SSL issues | Check cert with `openssl s_client -connect HOSTNAME:443` |

---

## Useful one-liners

```bash
# Count all users
ghe-user-admin list | wc -l

# Find suspended users
ghe-user-admin list --suspended

# Check GHES license usage
curl -H "Authorization: token TOKEN" https://HOSTNAME/api/v3/enterprise/settings/license
```

---

## Stop and escalate

Escalate rather than continuing to push on a customer-impacting change alone when:

- A customer-impacting command (maintenance mode, config apply, replication promote, restore, upgrade) fails partway through or leaves the instance in an unclear state.
- Replication or backup evidence suggests data-loss risk.
- The instance remains in maintenance mode longer than planned with no clear path to recovery.
- Evidence points to a platform bug rather than a customer configuration issue.

Apply the general investigation and escalation judgment in [[Investigation and Escalation Judgment]], including building an evidence chain (timestamp, exact error, what was tried, current hypothesis) before escalating.

---

## Related notes and authoritative docs

- [[GHES Deep Dive#Services architecture (under the hood)]] - internal services breakdown (Unicorn, babeld, git-auth, MySQL, HAProxy, and the full service list), with key operational points for support.
- [[GHES Deep Dive#Cluster architecture (training session)]] - cluster roles, tiers, deployment/replication diagrams, and `cluster.conf` rollout.
- [[Nomad Cheatsheet]] - orchestrator commands for inspecting and bouncing GHES services.
- [[Support Bundles Cheatsheet]] - deeper investigation methodology once a support bundle exists.
- [[ESB Support Bundle Workflow]] - accessing an extracted bundle through ESB Tools.
- [[Splunk Cheatsheet]] - searching GHES support-bundle telemetry.
- [[Health Check Runbook]] - repeatable multi-pillar evidence collection for proactive reviews.
- [[GHEC vs GHES Cheatsheet]] - platform boundary reference.
- [[Investigation and Escalation Judgment]] - when and how to escalate.
- [GHES admin docs](https://docs.github.com/en/enterprise-server/admin)
- [GHES release notes](https://docs.github.com/en/enterprise-server/admin/release-notes)
- [Backup utils](https://github.com/github/backup-utils)
- [GHES API reference](https://docs.github.com/en/enterprise-server/rest)

## Freshness note

Command syntax and log paths can change across GHES releases. Verify against the release notes and admin docs linked above for the customer's specific version before running commands against a production instance. Reviewed 2026-08-13.
