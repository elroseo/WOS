# SSH Cheatsheet

## What is SSH?

SSH (Secure Shell) is a protocol for securely connecting to remote machines over a network. It encrypts all traffic between your computer and the server, so passwords, commands, and data can't be intercepted. SSH uses key pairs (public + private) instead of (or in addition to) passwords for authentication.

## How it's typically used

- Logging into remote servers securely
- Running commands on remote machines
- Transferring files (SCP, SFTP)
- Git operations over SSH (pushing/pulling code)
- Port forwarding and tunneling to access internal services

## How it relates to GHES

SSH is central to GHES in two ways. First, customers use SSH keys to authenticate Git operations (`git clone git@ghes-hostname:org/repo`). Second, GHES administrators connect to the appliance itself over SSH on port 122 (`ssh -p 122 admin@HOSTNAME`) to run `ghe-*` admin commands. Common CRE scenarios include helping customers troubleshoot SSH key issues, firewall rules blocking port 22 or 122, and SSH algorithm compatibility between clients and the GHES appliance.

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

## Troubleshooting

| Issue | What to check |
|---|---|
| Permission denied (publickey) | Is the key added to the agent? Is the public key on the server? |
| Host key verification failed | Remove old entry: `ssh-keygen -R hostname` |
| Connection timed out | Check firewall, port, and hostname |
| Too many authentication failures | Specify the key explicitly with `-i` |

---

## Quick reference links

- [GitHub SSH docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [OpenSSH manual](https://www.openssh.com/manual.html)
