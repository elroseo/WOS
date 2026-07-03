# ESB Support Bundle Workflow

How to pull a support bundle down via esbtools (the internal ESB tooling) and get set up to investigate the logs. For what the logs mean and how to read them, see [[Support Bundles Cheatsheet]].

> [!important] Always extract the bundle first
> A raw bundle is just a `.tar.gz`. You must **launch/extract it on the shell server before you can browse or `scp` any file**. The extracted tree only exists at `/mnt/tmp/esbtools/<bundle-id>/extracted/` *after* the launch step runs. Skipping this is the number one reason `scp` fails with "No such file" or the connection looks broken.

---

## The workflow (in order)

### 1. Find the right shell server

The `esbtools-azshell-*` boxes are **ephemeral and assigned per session**. The hostname in the docs (e.g. `ed39142`) is just an example. Use *your* assigned shell server hostname, not a copied one. A wrong hostname shows up as:

```
Stdio forwarding request failed: Session open refused by peer
Connection closed by UNKNOWN port 65535
```

### 2. Extract the bundle on the shell server

```bash
ssh -t esbtools-azshell-<yourid>.azure-eastus.github.net "/data/esb-tools/script/launch <bundle-id>"
```

### 3. Confirm the extracted path exists

```bash
ssh esbtools-azshell-<yourid>.azure-eastus.github.net "ls /mnt/tmp/esbtools/<bundle-id>/extracted/"
```

### 4. Copy it down with scp

`scp` syntax is `scp <remote source> <local target>`. The part **after** the space is where it lands on your Mac.

```bash
# A single file
scp esbtools-azshell-<yourid>.azure-eastus.github.net:/mnt/tmp/esbtools/<bundle-id>/extracted/github-logs/production.log ~/esb-bundles/

# The whole extracted bundle (recursive)
scp -r esbtools-azshell-<yourid>.azure-eastus.github.net:/mnt/tmp/esbtools/<bundle-id>/extracted/ ~/esb-bundles/<bundle-id>/
```

Bundles are saved locally to `~/esb-bundles/`. (Plan: reorganise later into `<customer>/esb-bundles/<bundle-id>/`.)

---

## Web UI vs shell server

| Method | When to use | Limit |
|---|---|---|
| Web UI browse (`https://esbtools-staff.githubapp.com/bundles/<bundle-id>/browse`) | Quick look at a small file | View/download capped at **10 MB** per file |
| Shell server + `scp` | Any file over 10 MB, or grabbing many files / whole bundle | None practical |

---

## Prerequisites (SSH must be working)

This all rides on the bastion + agent forwarding setup. If `scp` or `ssh` fails with `Permission denied (publickey)`:

- Load your key locally: `ssh-add -l` should list your key. If empty: `ssh-add --apple-use-keychain ~/.ssh/id_ed25519`.
- The `bastion.githubapp.com` and `esbtools-azshell-*` host blocks need `ForwardAgent yes`.
- Use the **full** hostname `bastion.githubapp.com`, never `ssh bastion`.
- If a stale connection is being reused, drop it: `ssh -O exit bastion.githubapp.com`.

See [[SSH Cheatsheet]] for the full config.

---

## Tools to investigate the logs

Once the bundle is on your Mac (or you're on the shell server), these are the tools that do the work. Bundle logs are often gzipped, so reach for the `z*` variants.

### Local, on the extracted files

| Tool | Use it for |
|---|---|
| `grep -rin "pattern" .` | Search all logs recursively for an error, user, or timestamp |
| `ripgrep` (`rg`) | Much faster recursive search; `rg -z` also searches inside `.gz` files |
| `zcat` / `gzcat` / `zless` / `zgrep` | Read or search gzipped logs without unzipping them |
| `less -S` | Page through wide log lines without wrapping (`-S` = chop long lines) |
| `tail -f` / `tail -n 200` | Follow or read the end of a log |
| `awk` / `cut` | Extract fields (status codes, durations, IPs) from structured lines |
| `sort` + `uniq -c` | Count and rank repeated errors: `grep ... \| sort \| uniq -c \| sort -rn` |
| `jq` | Parse JSON-formatted log lines |
| `du -ah . \| sort -rh \| head` | Find the biggest logs, usually where the action is |

```bash
# Top 20 repeated exceptions across the bundle
zgrep -rh "Exception" github-logs/ | sort | uniq -c | sort -rn | head -20

# Follow one incident timestamp window across every log
grep -rin "2026-07-03T14:3" .
```

### Platform tools

| Tool | Use it for | Note |
|---|---|---|
| **Splunk** | Searching indexed GHES/production logs at scale, dashboards, time-series | See [[Splunk Cheatsheet]] |
| **Kusto / KQL** | Querying telemetry and CRE investigation datasets | See [[Kusto-KQL Cheatsheet]] |
| **esbtools Web UI** | Quick browse of small files without downloading | 10 MB per-file cap |

> The bundle tells you *what happened on the box*; Splunk and Kusto help you correlate it against fleet-wide telemetry and history.

---

## Quick reference links

- [[Support Bundles Cheatsheet]] - what each log contains and the investigation playbook
- [[GHES Cheatsheet]] - `ghe-*` utilities and log locations on the appliance
- [[Splunk Cheatsheet]] · [[Kusto-KQL Cheatsheet]] · [[SSH Cheatsheet]]
