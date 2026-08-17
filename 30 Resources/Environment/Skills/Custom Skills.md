# Custom Skills

Skills are folders of instructions and scripts that Copilot loads on demand when relevant. Unlike agents (which are full personas), skills are focused tools for specific tasks.

## Where skills live

| Location | Scope |
|---|---|
| `~/copilot-config/skills/` | Personal (all projects) |
| `.github/skills/` in a repo | That repo only |

The `copilot-config` repo is symlinked to `~/.copilot/skills/`, so skills are automatically available in every CLI session.

**Repo:** [copilot-config](https://github.com/elroseo/copilot-config)

---

## My skills

### /today

| | |
|---|---|
| **File** | `skills/today/SKILL.md` |
| **Purpose** | Daily briefing with tasks, meetings, and reminders |

**What it does:**
- Pulls overdue and due-today tasks from Obsidian
- Shows today's meetings from Outlook calendar
- Checks Slack for pending reminders
- Suggests what to focus on

**How to use:**

In Copilot CLI, just type:
```
/today
```

Or say:
```
What's on my plate today?
```

**Requires:**
- Obsidian running with Local REST API plugin (for tasks)
- WorkIQ / Microsoft 365 access (for Outlook calendar)
- Slack MCP (for reminders)

---

## Managing skills

| Command | What it does |
|---|---|
| `/skills list` | See all available skills |
| `/skills info <name>` | Details about a specific skill |
| `/skills reload` | Pick up new skills without restarting |
| `/skills` | Toggle skills on/off |

**Docs:** [Adding agent skills](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-skills)
