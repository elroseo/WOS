# MCP Servers

Model Context Protocol (MCP) servers extend Copilot with live access to external systems. This tracks what I have connected, what each is for, and how to keep them healthy.

**Last updated:** 2026-07-02

---

## How MCP is wired up

- **Personal config:** `~/.copilot/mcp-config.json` - servers I add myself (stdio/http/local).
- **App-injected:** the GitHub Copilot app also provides some servers automatically (they don't appear in my personal config). These are the "plugin" servers below.
- Check status in a session with `/mcp` (or `/mcp show <name>` to inspect one).
- A backup of my config lives at `~/.copilot/mcp-config.json.bak`.

---

## Connected servers

### Personal (in `mcp-config.json`)

| Server | Type | What it gives me | Notes |
|---|---|---|---|
| **obsidian** | http (`localhost:27123`) | Read/write this vault | Needs Obsidian running with the Local REST API plugin. Powers all my skills. |
| **slack** | http (`mcp.slack.com`) | Search + read Slack messages, threads, channels, DMs, canvases | Read-only. My user ID: `U0BAX741Y1G`. |
| **HubbersMCP** | stdio (`uv` @ `~/hubbers-mcp-server`) | GitHub employee/org directory: people, titles, managers, teams, reports | Great for org charts, finding the right person, escalation paths. |

### App-injected (not in my config, provided by the Copilot app)

| Server | What it gives me | Good for |
|---|---|---|
| **github-mcp-server** | Code/issue/PR search across GitHub, file contents, Copilot Spaces | Finding code by version tag, reading repos, escalation issues |
| **revenue-mcp-server** | Salesforce, Kusto, Gainsight, Gong, licensing summaries, **GitHub docs/blog/changelog search** | Account research, product-usage telemetry, docs grounding |
| **workiq** | Microsoft 365: mail, calendar, Teams chats/channels, OneDrive/SharePoint files, people | Meeting prep, email/calendar, finding docs |

> **Tip:** `revenue-mcp-server` already does GitHub **docs search** (`search_github_docs`) and changelog/blog lookups - no separate docs server needed.

---

## Removed / disabled

| Server | Why removed | Re-enable if... |
|---|---|---|
| **oneup** | `1up` binary not installed -> failed on every session start | I install the `1up` CLI and actually need it |
| **github-docs** | `docs-mcp` binary missing **and** API key was a placeholder; **redundant** with `revenue-mcp-server` docs search | I get a real `AZURE_SEARCH_API_KEY` from the CSE team and want the CSE-backed index specifically |

*(Removed from `mcp-config.json` on 2026-07-02; still recoverable from the `.bak`.)*

---

## Which server for which question

| I want to... | Use |
|---|---|
| Find a colleague, their manager, or a team roster | **HubbersMCP** |
| Search Slack for a decision/thread | **slack** |
| Read/update my notes, tasks, daily files | **obsidian** |
| Look up a customer account, ARR, product usage | **revenue-mcp-server** |
| Check GitHub docs / changelog / blog | **revenue-mcp-server** (`search_github_docs`) |
| Search code, issues, PRs on GitHub | **github-mcp-server** |
| Check my calendar, email, Teams, or find an M365 doc | **workiq** |

---

## Maintenance

| Task | How |
|---|---|
| List/inspect servers | `/mcp`, `/mcp show <name>` |
| Edit personal servers | Edit `~/.copilot/mcp-config.json` (valid JSON), then restart the session |
| Validate config | `python3 -m json.tool ~/.copilot/mcp-config.json` |
| Restore backup | `cp ~/.copilot/mcp-config.json.bak ~/.copilot/mcp-config.json` |

---

## Related

- [[dev-environment-setup]]
- [[Custom Agents]] · [[Custom Skills]]
