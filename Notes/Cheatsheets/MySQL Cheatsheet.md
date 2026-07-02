# MySQL Cheatsheet

## What is MySQL?

MySQL is an open source relational database management system (RDBMS). It stores data in tables with rows and columns, and you query it with SQL. It uses a client/server model: a `mysqld` server process holds the data, and clients connect over a socket or TCP to run queries.

## CRE perspective

**MySQL is core to GHES.** It stores all the metadata: users, orgs, teams, repos, issues, pull requests, and comments (Git object data lives separately). It is also the main reason GHES upgrades and failovers need downtime, because it does not support live rolling migrations or instant primary switchover. On an appliance you rarely touch it directly, but understanding replication, locking, and slow queries helps explain performance and downtime behaviour to customers.

> [!warning]
> On a GHES appliance, do not run manual writes against the internal MySQL. Use the `ghe-*` tooling. Direct changes are unsupported and can corrupt the instance. The commands below are general MySQL knowledge for self-managed databases and investigation.

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

```sql
INSERT INTO teams (name, org_id) VALUES ('platform', 42);

UPDATE users SET active = 0 WHERE last_login < '2025-01-01';

DELETE FROM sessions WHERE expires_at < NOW();
```

> **Careful:** `UPDATE` and `DELETE` without a `WHERE` clause change every row. Run a `SELECT` with the same `WHERE` first to confirm the scope.

---

## Users and permissions

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

| Command | What it does |
|---|---|
| `SHOW REPLICA STATUS\G` | Replica health, lag, and errors (newer MySQL) |
| `SHOW MASTER STATUS\G` | Primary's current binlog position |
| `START REPLICA;` / `STOP REPLICA;` | Control replication on a replica |
| `SHOW BINARY LOGS;` | List binary logs on the primary |

> Watch `Seconds_Behind_Source` (or `Seconds_Behind_Master`) for replication lag. Sustained lag points to a slow replica or a heavy write load on the primary.

---

## Backup and restore

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

> **On GHES:** use `ghe-backup` / `ghe-restore` (backup-utils) rather than raw `mysqldump`. They capture MySQL plus Git data and config together.

---

## Common troubleshooting

| Issue | What to check |
|---|---|
| "Too many connections" | `SHOW PROCESSLIST;`, raise `max_connections`, look for connection leaks |
| Slow query | `EXPLAIN` it, check for missing indexes and full table scans |
| Deadlocks | `SHOW ENGINE INNODB STATUS\G`, review transaction order |
| Replication lag | `SHOW REPLICA STATUS\G`, check `Seconds_Behind_Source` |
| Table locked | `SHOW OPEN TABLES WHERE In_use > 0;`, find the blocking transaction |
| Access denied | Verify user/host, `SHOW GRANTS`, then `FLUSH PRIVILEGES` |

---

## Quick reference links

- [MySQL reference manual](https://dev.mysql.com/doc/refman/en/)
- [SHOW statements](https://dev.mysql.com/doc/refman/en/show.html)
- [EXPLAIN output](https://dev.mysql.com/doc/refman/en/explain-output.html)
- [gh-ost (online schema migrations)](https://github.com/github/gh-ost)
