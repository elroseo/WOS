# Dev Environment Setup

Tracking everything installed and configured on this machine.

**Last updated:** 2026-06-17

---

## System

| Item | Detail |
|---|---|
| OS | macOS 26.5.1 (Build 25F80) |
| Architecture | Apple Silicon (arm64) |

---

## Installed Tools

All installed via [Homebrew](https://brew.sh) unless noted.

| Tool | Version | Install method | Purpose |
|---|---|---|---|
| Homebrew | 6.0.2 | `/bin/bash -c "$(curl ...)"` | Package manager for macOS |
| iTerm2 | — | `brew install --cask iterm2` | Terminal emulator |
| Fish shell | 4.7.1 | `brew install fish` | User-friendly shell |
| Git | 2.50.1 | Apple Git (pre-installed) | Version control |
| GitHub CLI (`gh`) | 2.94.0 | `brew install gh` | GitHub from the terminal |
| Copilot CLI | 1.0.64-0 | `npm install -g @githubnext/github-copilot-cli` or via GitHub | AI coding assistant |

---

## Configuration

### Fish shell
- Set as default shell (if applicable)
- Config location: `~/.config/fish/config.fish`

### GitHub CLI
- Authenticated as: **elroseo**
- Protocol: HTTPS
- Auth stored in: system keyring

### Copilot CLI
- Config location: `~/.copilot/`
- Memory: not yet enabled (run `/memory enable` to turn on)
- MCP config: `~/.copilot/mcp-config.json`

---

## Repos Created

| Repo | Location | GitHub URL | Purpose |
|---|---|---|---|
| copilot-config | `~/copilot-config` | https://github.com/elroseo/copilot-config (private) | Personal agents, skills, instructions |

---

## Symlinks (from `copilot-config/setup.sh`)

| Source | → Target |
|---|---|
| `~/copilot-config/agents` | `~/.copilot/agents` |
| `~/copilot-config/skills` | `~/.copilot/skills` |
| `~/copilot-config/instructions` | `~/.copilot/instructions` |
| `~/copilot-config/copilot-instructions.md` | `~/.copilot/copilot-instructions.md` |

---

## Obsidian

- Vault location: `~/Obsidian`
- Installed: 2026-06-17

---

## To Do

- [x] Enable Copilot memory (`/memory enable`) ✅ 2026-06-18
- [x] Explore Obsidian MCP server integration ✅ 2026-06-18
- [x] Create first real custom agent ⏫ 📅 2026-06-19 ✅ 2026-06-18
- [x] Create first real skill ⏫ 📅 2026-06-19 ✅ 2026-06-18
- [x] Set up GitHub Hub / Docs access for Copilot ⏩ 📅 2026-06-20 ✅ 2026-06-18
- [ ] Create custom ASCII art for agents/skills (ascii-motion.app) ⏬ 📅 2026-08-01
