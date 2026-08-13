---
tags:
  - ghes
  - esb-tools
  - support-bundles
updated: 2026-08-13
---

# ESB Support Bundle Workflow

How to access and investigate a support bundle through ESB Tools. For investigation methodology and log interpretation, see [[Support Bundles Cheatsheet]].

> [!important] Extraction and launch-cache readiness are different
> `script/launch` enters a bundle that is already available in the current ESB host's launch cache. It is **not** the extraction trigger. A dashboard may show `extracted: true` while the assigned shell host still lacks a ready launch cache.

## Quick workflow

### 1. Confirm dashboard extraction

Check the ESB/CRE Dashboard bundle record first. If the bundle is not extracted, trigger or request extraction through the approved dashboard/ESB workflow.

Do not repeatedly run `script/launch` as a substitute for extraction.

### 2. Use your assigned shell host

The `esbtools-azshell-*` hosts are session-specific. Use the hostname assigned to your authenticated session, not one copied from another investigation.

A stale or unavailable SSH session commonly appears as:

```text
Stdio forwarding request failed: Session open refused by peer
Connection closed by UNKNOWN port 65535
```

Reconnect or refresh authentication before treating this as a bundle problem.

### 3. Confirm the launch cache is ready

```bash
ssh esbtools-azshell-<yourid>.azure-eastus.github.net \
  '/data/esb-tools/script/launch <bundle-id> -c "
if test -f metadata/diagnostics.txt; then
  echo ready
elif find -L . -maxdepth 3 -path \"*/metadata/diagnostics.txt\" -print -quit | grep -q .; then
  echo ready
else
  echo pending
fi
"'
```

- `ready`: the launch workspace contains diagnostics and can be investigated.
- `pending` or “not extracted on this host”: dashboard extraction may be complete, but this shell host's launch cache is not ready.

Cluster bundles often place diagnostics under a node directory, which is why the check uses `find -L`.

### 4. Enter the bundle or run one command

```bash
# Interactive shell
ssh -t esbtools-azshell-<yourid>.azure-eastus.github.net \
  "/data/esb-tools/script/launch <bundle-id>"

# Single read-only command
ssh -t esbtools-azshell-<yourid>.azure-eastus.github.net \
  "/data/esb-tools/script/launch <bundle-id> -c 'ls -la'"
```

Start with:

1. `ghe-probe` report
2. diagnostics and instance profile
3. the customer symptom, timestamp, and relevant subsystem logs

### 5. Prefer remote analysis; copy only what you need

Bundles contain sensitive customer support data and can be large. Investigate on the ESB shell when practical. Copy specific files only when local tooling is necessary.

On a ready host, the launchable tree is normally exposed through:

```text
/mnt/tmp/esbtools/home/<bundle-id>/
```

Example:

```bash
mkdir -p ~/esb-bundles/<bundle-id>

scp esbtools-azshell-<yourid>.azure-eastus.github.net:\
/mnt/tmp/esbtools/home/<bundle-id>/github-logs/exceptions.log \
~/esb-bundles/<bundle-id>/
```

If that host-side link is absent, do not guess another path. Recheck launch-cache readiness or use `script/launch` remotely.

## Evidence availability

| Source | What it provides | Important limitation |
|---|---|---|
| Dashboard metadata | Bundle identity, diagnostics sections, profile and health metadata | Does not guarantee raw launch-cache access |
| Generated ghe-probe report | Known checks, warnings, failures, numeric signals | Findings still require classification and causation analysis |
| Generated health report | Quick automated overview | Not a substitute for interpretive incident analysis |
| Launch-cache full tree | Raw logs, detailed metadata, collectd/RRDs, product-specific evidence | May not be ready on the current host even after dashboard extraction |

> [!warning] Missing source versus parser gap
> Use **missing source** only after confirming the evidence is absent. If the source exists but your workflow did not parse it, label it **parser gap**.

## Useful read-only tools

| Tool | Use it for |
|---|---|
| `zgrep` / `zcat` / `zless` | Search compressed and uncompressed logs without extracting them |
| `jq` | Parse JSON log fields and avoid mixing unrelated events |
| `rg` | Fast search of local extracted files; probe compressed-file behavior first |
| `less -S` | Read wide log lines without wrapping |
| `sort` + `uniq -c` | Count exact normalized events after confirming the format |
| `awk` / `cut` | Extract stable fields from known text formats |
| `find -L` | Follow ESB symlinks when locating diagnostics in cluster bundles |

Probe before parsing:

```bash
# Confirm exceptions.log structure and field names
zgrep -m1 -h 'SlowRequest\|SlowQuery' github-logs/exceptions.log* | jq .

# Inspect recent request-log format
sed -n '1,3p' github-logs/unicorn.log
```

An empty scripted result after a mismatched probe is a parser failure, not proof that no event occurred.

## SSH prerequisites

If SSH fails with `Permission denied (publickey)`:

- Confirm your key is loaded with `ssh-add -l`.
- Confirm your bastion and ESB host configuration supports agent forwarding.
- Complete the required FIDO authentication.
- If a ControlMaster session expired, reconnect rather than repeatedly retrying bundle commands.

See [[SSH Cheatsheet]] for local SSH configuration and troubleshooting.

## Common mistakes

| Mistake | Correction |
|---|---|
| Assuming `script/launch` performs extraction | Confirm dashboard extraction, then confirm launch-cache readiness |
| Assuming `extracted: true` means this host is ready | Test for diagnostics through `script/launch` |
| Using `/proc` or `df -h` in the launch container as customer metrics | Use captured diagnostics, `ghe-metrics` bundle mode, disk metadata, and collectd |
| Copying the whole bundle by default | Analyze remotely and copy only required evidence |
| Treating generated health output as the conclusion | Connect evidence to the customer symptom and trace causation |
| Guessing alternate host paths | Use the ready launch workspace or the documented host launch link |

## Quick reference

- [[Support Bundles Cheatsheet]]
- [[GHES Cheatsheet]]
- [[Splunk Cheatsheet]]
- [[Kusto-KQL Cheatsheet]]
- [[SSH Cheatsheet]]
