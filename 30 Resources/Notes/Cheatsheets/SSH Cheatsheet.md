---
tags:
  - ssh
  - cheatsheet
  - connectivity
  - ghes
audience: CRE
updated: 2026-08-13
---

# SSH Cheatsheet

## Scope and when to use this

Use this when you need to generate or manage SSH keys, connect to a remote host, or troubleshoot SSH connectivity - including Git-over-SSH to GitHub.com/GHES and admin access to a GHES appliance or an ESB-Tools investigation host.

## Prerequisites and access

- An SSH client (built into macOS/Linux; use PuTTY or WSL on Windows).
- For GHES appliance admin access: an account with SSH admin access to the appliance and network path to port 122 - see [[GHES Cheatsheet]] for `ghe-*` commands and appliance details.
- For ESB-Tools support bundle investigation: SSH plus a registered FIDO key - see [[ESB Support Bundle Workflow]] for the full setup and bundle workflow.

## Platform scope

Covers general SSH usage (keys, agent, config, tunneling, file transfer) plus two GitHub-specific patterns: Git-over-SSH (any Git host, including GHES) and GHES appliance admin access (port 122). It does not cover ESB-Tools session mechanics in depth - see [[ESB Support Bundle Workflow]] for that.

## Safety and read-only boundary

Start with **read-only connectivity checks** (see the quick task below) before making config changes. Adding or removing keys from `~/.ssh/config` or the local agent is local-machine-only and low risk. The higher-risk actions are on the remote side (deploying new keys, changing `sshd` config, opening firewall ports) - those are the customer's own admin action, not something CRE performs unilaterally on their infrastructure.

## What is SSH?

SSH (Secure Shell) is a protocol for securely connecting to remote machines over a network. It encrypts all traffic between your computer and the server, so passwords, commands, and data can't be intercepted. SSH uses key pairs (public + private) instead of (or in addition to) passwords for authentication.

## How it's typically used

- Logging into remote servers securely
- Running commands on remote machines
- Transferring files (SCP, SFTP)
- Git operations over SSH (pushing/pulling code)
- Port forwarding and tunneling to access internal services

## How it relates to GHES

SSH is central to GHES in two ways. First, customers use SSH keys to authenticate Git operations (`git clone git@ghes-hostname:org/repo`). Second, GHES administrators connect to the appliance itself over SSH on port 122 (`ssh -p 122 admin@HOSTNAME`) to run `ghe-*` admin commands - see [[GHES Cheatsheet]]. Common CRE scenarios include helping customers troubleshoot SSH key issues, firewall rules blocking port 22 or 122, and SSH algorithm compatibility between clients and the GHES appliance.

---

## Quick task: diagnose an SSH connection problem

1. **Confirm the target and expected auth method** - hostname, port (22 for Git-over-SSH, 122 for GHES appliance admin), and which key should be used.
2. **Check the key is present and loaded** - `ls -la ~/.ssh/` and `ssh-add -l`. If the intended key isn't listed, add it: `ssh-add ~/.ssh/id_ed25519`.
3. **Test connectivity without a full session** - `ssh -T git@<hostname>` for Git hosts (no shell, just an auth check), or `ssh -p 122 admin@HOSTNAME` for a GHES appliance if admin access is expected.
4. **Increase verbosity if the connection fails** - `ssh -v` (or `-vvv`) to see exactly where it fails: DNS resolution, TCP connect, key exchange, or authentication.
5. **Compare the failure point against the troubleshooting table below** and address the specific cause.

**Expected result:** For Git-over-SSH, a successful test prints an authenticated greeting (e.g. `Hi username! You've successfully authenticated...` for GitHub.com). For a GHES appliance, you land on the admin shell/`ghe-*` command prompt.

**Verify:** Re-run the same test command after the fix and confirm it now succeeds before considering the issue resolved.

---

## Key management

| Command | What it does |
|---|---|
| `ssh-keygen -t ed25519 -C "email"` | Generate a new SSH key (recommended type) |
| `ssh-keygen -t rsa -b 4096 -C "email"` | Generate an RSA key (legacy compatibility) |
| `ls -la ~/.ssh/` | List your SSH keys |
| `cat ~/.ssh/id_ed25519.pub` | View your public key |
| `ssh-add ~/.ssh/id_ed25519` | Add key to SSH agent |
| `ssh-add -l` | List keys loaded in agent |
| `ssh-add -D` | Remove all keys from agent |

---

## SSH agent

```bash
eval "$(ssh-agent -s)"        # Start the SSH agent
ssh-add ~/.ssh/id_ed25519     # Add your key
```

On macOS, add this to `~/.ssh/config` to persist keys across reboots:

```
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

---

## Connecting

| Command | What it does |
|---|---|
| `ssh user@host` | Connect to a remote host |
| `ssh -p 2222 user@host` | Connect on a specific port |
| `ssh -i ~/.ssh/mykey user@host` | Connect with a specific key |
| `ssh -v user@host` | Verbose output (debugging) |
| `ssh -vvv user@host` | Extra verbose (deep debugging) |

---

## SSH config file (`~/.ssh/config`)

Save connection shortcuts:

```
Host myserver
  HostName 192.168.1.100
  User admin
  Port 2222
  IdentityFile ~/.ssh/id_ed25519

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
```

Then just use: `ssh myserver`

---

## Tunneling and port forwarding

| Command | What it does |
|---|---|
| `ssh -L 8080:localhost:80 user@host` | Local forward (access remote port 80 on local 8080) |
| `ssh -R 8080:localhost:80 user@host` | Remote forward (expose local port 80 on remote 8080) |
| `ssh -D 1080 user@host` | Dynamic/SOCKS proxy |
| `ssh -N -L 8080:localhost:80 user@host` | Forward only, no shell |

---

## File transfer (SCP and SFTP)

| Command | What it does |
|---|---|
| `scp file.txt user@host:/path/` | Copy file to remote |
| `scp user@host:/path/file.txt .` | Copy file from remote |
| `scp -r folder/ user@host:/path/` | Copy directory recursively |
| `sftp user@host` | Interactive file transfer session |

---

## GitHub SSH setup

```bash
# 1. Generate key
ssh-keygen -t ed25519 -C "your-email@github.com"

# 2. Copy public key
pbcopy < ~/.ssh/id_ed25519.pub

# 3. Add to GitHub: Settings > SSH and GPG keys > New SSH key

# 4. Test connection
ssh -T git@github.com
```

Expected output: `Hi username! You've successfully authenticated...`

---

## Errors and recovery

| Issue | What to check |
|---|---|
| Permission denied (publickey) | Is the key added to the agent? Is the public key on the server? |
| Host key verification failed | Remove old entry: `ssh-keygen -R hostname` |
| Connection timed out | Check firewall, port, and hostname |
| Too many authentication failures | Specify the key explicitly with `-i` |
| `Stdio forwarding request failed: Session open refused by peer` | Stale or unavailable ESB-Tools shell host session - see [[ESB Support Bundle Workflow]] to reconnect/refresh before treating it as a bundle problem |

## Stop and escalate if

- The failure is on the GHES appliance side itself (sshd service down, appliance unreachable on port 122 from an expected network path) - this points to appliance health, not client SSH config. Move to [[GHES Cheatsheet]] and consider a support bundle.
- An ESB-Tools shell host stays unreachable after reconnecting/refreshing - follow [[ESB Support Bundle Workflow]] and escalate per that workflow if it persists.
- You're asked to bypass host key verification for a production host without confirming the fingerprint out of band - don't; verify the fingerprint through a trusted channel first.

---

## Quick reference links

- [GitHub SSH docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [OpenSSH manual](https://www.openssh.com/manual.html)

## Related links

- [[ESB Support Bundle Workflow]] - SSH access into support bundle investigation hosts
- [[GHES Cheatsheet]] - `ghe-*` admin commands and appliance access
- [[Git and GitHub Cheatsheet]] - Git-over-SSH troubleshooting in the broader push/pull context

## Freshness note

Core SSH commands and config syntax are stable. GHES port conventions (122 for admin, 22 for Git) and ESB-Tools session mechanics can change between releases - cross-check against [[GHES Cheatsheet]] and [[ESB Support Bundle Workflow]] if something here doesn't match what you observe. Last reviewed: 2026-08-13.
