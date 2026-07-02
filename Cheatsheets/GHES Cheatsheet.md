# GHES Cheatsheet

## What is GHES?

GitHub Enterprise Server (GHES) is a self-hosted version of GitHub that organizations run on their own infrastructure. It provides the same features as github.com (repos, pull requests, actions, packages, etc.) but within the customer's own network. This gives organizations full control over their data, security policies, and compliance requirements. GHES runs as a virtual appliance on platforms like VMware, AWS, Azure, or GCP.

## How it's typically used

- Organizations that need to keep code on-premises for compliance or security
- Companies that need to integrate GitHub with internal systems behind a firewall
- Environments with strict network controls where github.com access is limited
- Large enterprises that want GitHub features with their own infrastructure management

## CRE perspective

You'll help customers with installation, upgrades, authentication configuration (LDAP, SAML, CAS), high availability and replication, backup and restore, performance troubleshooting, and connectivity issues. Understanding the `ghe-*` command line tools, log locations, and the management console is essential for diagnosing and resolving customer issues.

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
| `ghe-maintenance -s` | Enable maintenance mode |
| `ghe-maintenance -u` | Disable maintenance mode |
| `ghe-maintenance -q` | Check maintenance status |

### Replication (HA)

| Command | What it does |
|---|---|
| `ghe-repl-status` | Check replication status |
| `ghe-repl-setup <primary-ip>` | Configure as a replica |
| `ghe-repl-start` | Start replication |
| `ghe-repl-stop` | Stop replication |
| `ghe-repl-promote` | Promote replica to primary (failover) |

### Backups

| Command | What it does |
|---|---|
| `ghe-backup` | Run a backup (from backup host, using backup-utils) |
| `ghe-restore` | Restore from backup |
| `ghe-backup-utils` | Backup utilities package |

> **Note:** Backups run from a separate backup host, not on the GHES appliance itself.

---

## Authentication and LDAP

| Command | What it does |
|---|---|
| `ghe-config auth.mode` | Check current auth mode |
| `ghe-ldap-test` | Test LDAP configuration |
| `ghe-user-admin` | Manage user accounts |
| `ghe-user-suspend <username>` | Suspend a user |
| `ghe-user-unsuspend <username>` | Unsuspend a user |

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

## Upgrades

1. Download the upgrade package (`.pkg` file)
2. Enable maintenance mode: `ghe-maintenance -s`
3. Upload via management console or SCP
4. Run the upgrade
5. Disable maintenance mode: `ghe-maintenance -u`
6. Verify with `ghe-version`

> **Important:** Always take a backup before upgrading. Check the [upgrade requirements](https://docs.github.com/en/enterprise-server/admin/upgrading-your-instance) for your target version.

---

## Common troubleshooting

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

## Quick reference links

- [GHES admin docs](https://docs.github.com/en/enterprise-server/admin)
- [GHES release notes](https://docs.github.com/en/enterprise-server/admin/release-notes)
- [Backup utils](https://github.com/github/backup-utils)
- [GHES API reference](https://docs.github.com/en/enterprise-server/rest)


---

## Related notes

- [[GHES Deep Dive#Services architecture (under the hood)]] - internal services breakdown (Unicorn, babeld, git-auth, MySQL, HAProxy, and the full service list), with key operational points for support.
