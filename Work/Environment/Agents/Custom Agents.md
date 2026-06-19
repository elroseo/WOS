# Custom Agents

Custom agents are specialized Copilot personas defined in Markdown files. They tailor Copilot's expertise for specific tasks and workflows.

## Where agents live

| Location | Scope |
|---|---|
| `~/copilot-config/agents/` | Personal (all projects) |
| `.github/agents/` in a repo | That repo only |

The `copilot-config` repo is symlinked to `~/.copilot/agents/`, so agents are automatically available in every CLI session.

**Repo:** [copilot-config](https://github.com/elroseo/copilot-config)

---

## My agents

### cre-learning

| | |
|---|---|
| **File** | `agents/cre-learning.agent.md` |
| **Purpose** | Aligns all training and development work with the 6 CRE pillars |
| **When to use** | Learning paths, certification prep, training plans, career development |

**What it does:**
- Tags learning content with the relevant CRE pillars (Mentorship, Technical, Collaboration, Program, Innovation, Customer)
- Ensures learning paths cover all 6 pillars over time
- Connects learning to practical CRE outputs (health checks, QBRs, monthly reports)
- References CRE tooling ecosystem where relevant

**How to use:**

In Copilot CLI:
```
/agent              # browse and select cre-learning
```

Or reference it in a prompt:
```
Use the cre-learning agent to create a study plan for GHAS
```

Or from the command line:
```bash
copilot --agent=cre-learning --prompt "Review my certification progress"
```

---

## Creating a new agent

1. Create a file in `~/copilot-config/agents/` named `my-agent.agent.md`
2. Add YAML frontmatter with `name` and `description` (required)
3. Write the agent's instructions in Markdown below the frontmatter
4. Commit and push to the copilot-config repo

**Template:**

```markdown
---
name: my-agent
description: What this agent does and when to use it.
# tools: ["read", "edit", "search"]  # omit for all tools
---

You are a [role]. Your responsibilities:
- ...
- ...
```

**Docs:** [Creating custom agents](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/create-custom-agents)
