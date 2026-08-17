---
tags:
  - mysql
  - database
  - ghes
  - troubleshooting
  - cheatsheet
  - runbook
audience: cre
updated: 2026-08-13
---

# MySQL Cheatsheet

## What this is and when to use it

MySQL is an open source relational database management system (RDBMS). It stores data in tables with rows and columns, queried with SQL, using a client/server model: a `mysqld` server process holds the data, and clients connect over a socket or TCP.

**MySQL is core to GHES.** It stores all the metadata: users, orgs, teams, repos, issues, pull requests, and comments (Git object data lives separately). It is also a main reason GHES upgrades and failovers need downtime, since it does not support live rolling migrations or instant primary switchover. Use this runbook for replication lag, connection/locking, and slow-query investigations, on GHES or a self-managed MySQL instance.

## Prerequisites

- For a GHES appliance: SSH access, and awareness that direct connections to the internal MySQL are not normal CRE practice (see Safety below).
- For a self-managed or customer database: connection credentials with at least read access, and the customer's authorization to connect.

## Platform scope

- **GHES appliance**: MySQL here is an internal, GHES-managed service. Do not connect and run manual writes against it; use `ghe-*` tooling, dashboards, and diagnostics first. Read-only investigation commands below may be used under Support/Engineering guidance, but this is not a default CRE action.
- **Self-managed MySQL** (customer's own database, unrelated to GHES internals): the commands below apply directly, subject to the customer's own access policy.

> [!warning]
> On a GHES appliance, do not run manual writes against the internal MySQL. Use the `ghe-*` tooling. Direct changes are unsupported and can corrupt the instance. The commands below are general MySQL knowledge for self-managed databases and investigation; treat any direct connection to a GHES-managed MySQL instance as requiring Support/Engineering guidance, not a default CRE action.

## Safety and read-only boundary

> [!warning] Default to SELECT and SHOW
> `SELECT`, `SHOW`, `DESCRIBE`, and `EXPLAIN` are read-only. `INSERT`/`UPDATE`/`DELETE`, user/privilege management, `KILL`, replication control, and restore operations mutate data or running state. Do not run any of these against a GHES-managed MySQL instance; that is not normal CRE investigation practice and requires Support/Engineering guidance or an approved change.

## Quick procedure (read-only triage)

1. Confirm platform: GHES-managed MySQL, or a self-managed/customer database you're authorized to query directly.
2. Check the server is reachable and alive: `mysqladmin -u <user> -p ping`, then `mysqladmin -u <user> -p status` for uptime and query rate.
3. Check current connections and running queries: `SHOW PROCESSLIST;` (or `SHOW FULL PROCESSLIST;` for full query text).
4. Look for long-running queries specifically:
   ```sql
   SELECT id, user, host, db, time, state, info
   FROM information_schema.processlist
   WHERE command != 'Sleep' AND time > 60
   ORDER BY time DESC;
   ```
5. If replication is in scope, check lag and errors: `SHOW REPLICA STATUS\G` (watch `Seconds_Behind_Source`/`Seconds_Behind_Master`).
6. If locking is suspected, check `SHOW ENGINE INNODB STATUS\G` and `SHOW OPEN TABLES WHERE In_use > 0;`.
7. For a slow query, confirm the plan with `EXPLAIN <query>;` before assuming an index problem.

## GUI steps

N/A for direct connection to a GHES-managed MySQL instance; there is no supported GUI for that. In a self-managed or customer environment, a GUI client (e.g. MySQL Workbench) can run the same read-only `SHOW`/`SELECT`/`EXPLAIN` checks described above; the underlying access-scope rules still apply.

## Expected output / success criteria

- `mysqladmin ping` returns `mysqld is alive`.
- `SHOW PROCESSLIST;` returns a plausible connection count and no single query stuck in the same state for an unusually long `Time`.
- `SHOW REPLICA STATUS\G` shows `Seconds_Behind_Source` (or `Seconds_Behind_Master`) at or near 0, and no non-null `Last_Error`.
- `EXPLAIN` shows the query is using an index (`type` other than `ALL`, a populated `key` column) for the rows scanned.

## Validation / cross-check

- Cross-check a "too many connections" report against `SHOW PROCESSLIST;` output and `SHOW VARIABLES LIKE 'max_connections';`, not just the error message alone.
- Cross-check sustained replication lag against write volume on the primary; a temporary lag spike during a burst of writes is not the same as a stuck replica.
- For a locking/deadlock report, confirm with `SHOW ENGINE INNODB STATUS\G` before concluding a specific transaction is the blocker.
- On GHES, cross-check any MySQL-attributed symptom against `ghe-*` diagnostics/dashboards before treating a direct query result as the final answer, since direct access is not the normal investigation path there.

## Errors and recovery

| Issue | What to check |
|---|---|
| "Too many connections" | `SHOW PROCESSLIST;`, compare against `max_connections`, look for connection leaks |
| Slow query | `EXPLAIN` it, check for missing indexes and full table scans |
| Deadlocks | `SHOW ENGINE INNODB STATUS\G`, review transaction order |
| Replication lag | `SHOW REPLICA STATUS\G`, check `Seconds_Behind_Source` |
| Table locked | `SHOW OPEN TABLES WHERE In_use > 0;`, find the blocking transaction |
| Access denied | Verify user/host, `SHOW GRANTS`, then `FLUSH PRIVILEGES` |

## Stop / escalate

Escalate when the investigation would require a write (schema change, data fix, user/privilege change, replication control, restore) against a GHES-managed instance, when replication lag or a deadlock doesn't resolve with read-only diagnosis, or when a fix on a self-managed customer database is beyond your authorized scope. See [[Investigation and Escalation Judgment]] for thresholds and the evidence to collect first.

---

## Connecting

| Command | What it does |
|---|---|
| `mysql -u <user> -p` | Connect, prompt for password |
| `mysql -u <user> -p -h <host> -P 3306` | Connect to a remote host/port |
| `mysql -u <user> -p <database>` | Connect straight into a database |
| `mysql -u <user> -p -e "SQL;"` | Run one statement and exit |
| `mysqladmin -u <user> -p ping` | Check if the server is alive |
| `mysqladmin -u <user> -p status` | Uptime, threads, queries per second |

---

## Databases and tables

| Command | What it does |
|---|---|
| `SHOW DATABASES;` | List databases |
| `USE <database>;` | Switch to a database |
| `SHOW TABLES;` | List tables in the current database |
| `DESCRIBE <table>;` | Show a table's columns and types |
| `SHOW CREATE TABLE <table>\G` | Full table definition |
| `SHOW INDEX FROM <table>;` | List indexes on a table |
| `SHOW TABLE STATUS\G` | Row counts, engine, size per table |

> **Tip:** End a statement with `\G` instead of `;` for vertical, readable output.

---

## Querying data

```sql
-- Basic select with filter and limit
SELECT id, login FROM users WHERE active = 1 ORDER BY created_at DESC LIMIT 20;

-- Count rows
SELECT COUNT(*) FROM repositories;

-- Group and aggregate
SELECT owner_id, COUNT(*) AS repo_count
FROM repositories
GROUP BY owner_id
HAVING repo_count > 100
ORDER BY repo_count DESC;

-- Join two tables
SELECT u.login, r.name
FROM repositories r
JOIN users u ON u.id = r.owner_id
WHERE r.private = 1;
```

---

## Modifying data

> [!danger] Customer impact
> `INSERT`, `UPDATE`, and `DELETE` change real data. On a GHES-managed instance, do not run these directly; that is not normal CRE investigation practice. On any database, `UPDATE`/`DELETE` without a `WHERE` clause changes every row; always run a `SELECT` with the same `WHERE` first to confirm scope.

```sql
INSERT INTO teams (name, org_id) VALUES ('platform', 42);

UPDATE users SET active = 0 WHERE last_login < '2025-01-01';

DELETE FROM sessions WHERE expires_at < NOW();
```

---

## Users and permissions

> [!danger] Customer impact
> Creating, granting, revoking, or dropping a user changes who can access the database and with what privileges. On a GHES-managed instance, do not run these directly; that is not normal CRE investigation practice.

| Command | What it does |
|---|---|
| `CREATE USER 'name'@'host' IDENTIFIED BY 'pw';` | Create a user |
| `GRANT SELECT, INSERT ON db.* TO 'name'@'host';` | Grant privileges on a database |
| `GRANT ALL PRIVILEGES ON db.* TO 'name'@'host';` | Full access to a database |
| `REVOKE INSERT ON db.* FROM 'name'@'host';` | Remove a privilege |
| `SHOW GRANTS FOR 'name'@'host';` | List a user's privileges |
| `FLUSH PRIVILEGES;` | Reload the grant tables after manual changes |
| `DROP USER 'name'@'host';` | Delete a user |

---

## Performance and diagnostics

| Command | What it does |
|---|---|
| `SHOW PROCESSLIST;` | Current connections and running queries |
| `SHOW FULL PROCESSLIST;` | Same, with full query text |
| `KILL <id>;` | Terminate a specific query/connection |
| `EXPLAIN <query>;` | Show the query plan (index use, row estimates) |
| `SHOW STATUS LIKE 'Threads_connected';` | Current connection count |
| `SHOW VARIABLES LIKE 'max_connections';` | Connection limit |
| `SHOW ENGINE INNODB STATUS\G` | InnoDB internals: locks, deadlocks, I/O |
| `SHOW OPEN TABLES WHERE In_use > 0;` | Tables currently locked |

> [!warning] `KILL` is mutating
> `KILL <id>` terminates a live query or connection immediately, which can abort in-flight customer work. Confirm the target session before running it, and prefer read-only diagnosis first.

```sql
-- Find long-running queries (over 60s)
SELECT id, user, host, db, time, state, info
FROM information_schema.processlist
WHERE command != 'Sleep' AND time > 60
ORDER BY time DESC;
```

> **Locking and downtime:** long transactions and schema changes can block others. This is why GHES uses maintenance windows for migrations. On self-managed setups, tools like `gh-ost` and `pt-online-schema-change` allow online schema changes without long locks.

---

## Replication

> [!danger] Customer impact
> `START REPLICA;` / `STOP REPLICA;` change replication state and can affect data currency or availability on the replica. Do not run these against a GHES-managed instance directly.

| Command | What it does |
|---|---|
| `SHOW REPLICA STATUS\G` | Replica health, lag, and errors (newer MySQL) |
| `SHOW MASTER STATUS\G` | Primary's current binlog position |
| `START REPLICA;` / `STOP REPLICA;` | Control replication on a replica |
| `SHOW BINARY LOGS;` | List binary logs on the primary |

> Watch `Seconds_Behind_Source` (or `Seconds_Behind_Master`) for replication lag. Sustained lag points to a slow replica or a heavy write load on the primary.

---

## Backup and restore

> [!danger] Customer impact
> Restoring (`mysql ... < backup.sql`) overwrites existing data in the target database. On GHES, use `ghe-backup`/`ghe-restore` (backup-utils) instead of raw `mysqldump`/`mysql` restore; they capture MySQL plus Git data and config together and are the supported path.

```bash
# Logical backup of one database
mysqldump -u <user> -p <database> > backup.sql

# Backup all databases
mysqldump -u <user> -p --all-databases > all.sql

# Consistent backup without locking InnoDB tables
mysqldump -u <user> -p --single-transaction <database> > backup.sql

# Restore
mysql -u <user> -p <database> < backup.sql
```

---

## Related notes and docs

- [MySQL reference manual](https://dev.mysql.com/doc/refman/en/)
- [SHOW statements](https://dev.mysql.com/doc/refman/en/show.html)
- [EXPLAIN output](https://dev.mysql.com/doc/refman/en/explain-output.html)
- [gh-ost (online schema migrations)](https://github.com/github/gh-ost)
- [[GHES Cheatsheet]] · [[Nomad Cheatsheet]]

## Freshness note

Restructured as a CRE runbook on 2026-08-13. SQL syntax reflects modern MySQL (`SHOW REPLICA STATUS`/`START REPLICA` terminology); older MySQL versions use `SHOW SLAVE STATUS`/`START SLAVE`. Confirm the customer's MySQL version before relying on exact syntax.
