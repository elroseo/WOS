# wos

My **work operating system**: the Obsidian vault and Copilot CLI setup I use to run my day as a CRE at GitHub.

It is version controlled with `obsidian-git` so notes, config, and tooling stay backed up and portable.

## What's inside
- **Environment/** - my Copilot CLI setup: custom agents, skills, [[Environment/MCP Servers|MCP servers]], and development environment notes
- **Templates/** - reusable Obsidian templates for 1-on-1s, meeting notes, incidents, and hub notes
- **Notes/Cheatsheets/** - quick references for Kusto Query Language (KQL), Splunk, GitHub Enterprise Server (GHES), GitHub Advanced Security (GHAS), Git, and supporting technologies
- **Notes/** - product deep dives, hub notes, and consolidated meeting notes
- **CRE-Learning/** - role-specific practices, investigation methods, and reusable CRE guidance
- **Training & Development/** - certification paths, study notes, and formal development planning
- **Accounts/** - durable customer-specific context and generated account snapshots
- **Support Insights/** - reusable patterns and findings that apply across support cases or customers
- **People/** - lightweight profiles, 1-on-1 context, and my [[People/CRE Team & Org|team and org chart]]
- **Daily/** - daily plans generated on demand by the `today` skill
- **Voice/** - writing style, tone guide, and goals
- **.obsidian/** - vault configuration and plugins

## How I use it

- **Morning**: run the `today` skill for a daily briefing (tasks, meetings, Slack)
- **Before meetings**: run the `meeting` skill to prep context and notes
- **End of day**: run the `eod` skill for a summary and shareable update
- **Friday**: run the `week` skill for a weekly review

Skills read and write to this vault through the Obsidian Local REST API plugin.
