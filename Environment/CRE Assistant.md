# CRE Assistant

Local CRE assistant that runs via Copilot CLI + MCP servers. No cloud deployment, no shared infrastructure - data stays on your laptop.

**Repo:** `github/cre-assistant` · **Added:** 2026-08-05

---

## Quick start

### 1. Prerequisites

```bash
brew install copilot-cli gh
gh auth login
```

### 2. Clone and onboard

```bash
gh repo clone github/cre-assistant
cd cre-assistant
copilot -i "Run CRE Assistant onboarding"
```

Onboarding auto-installs dependencies (**llm-assist**, **cre-dashboard-mcp**, **WorkIQ**, **GBAO**, **Azure CLI**), collects your info, and generates config files. MCP servers are auto-configured during onboarding.

### 3. Extra setup

- **MCP servers:** auto-configured; for manual setup see the repo's MCP Setup Guide.
- **Outlook categories:** see the repo's Outlook Categories Guide.

### 4. Run it

```bash
copilot -p "Start my CRE morning routine"
```

---

## Notes

- Bundles `llm-assist` as a dependency, so it overlaps with [[LLM Assist in CLI]] (llm-assist skills come along for the ride).
- `-i` = interactive onboarding; `-p` = one-shot prompt.

## Related

- [[LLM Assist in CLI]] · [[dev-environment-setup]] · [[MCP Servers]]
