# Domain 4 — Modern Development

## GitHub Actions (CI/CD + automation)

Automates workflows in response to repository events (build, test, deploy, and more).

| Concept | Definition |
|---|---|
| **Workflow** | An automated process defined in a YAML file in `.github/workflows/` |
| **Event** | The trigger (e.g. `push`, `pull_request`, `schedule`, `workflow_dispatch`) |
| **Job** | A set of steps that run on the same runner |
| **Step** | An individual task: a shell command or an action |
| **Action** | A reusable unit of code (often from the Marketplace) |
| **Runner** | The machine that executes a job (GitHub-hosted or self-hosted) |

```yaml
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test
```

- **Jobs run in parallel** by default; use `needs:` to sequence them.
- **GitHub-hosted runners** (Ubuntu/Windows/macOS) vs **self-hosted** (your own infra).
- **Secrets** store credentials securely for use in workflows.

## GitHub Packages

A package-hosting service integrated with repos and permissions. Supports npm, NuGet, Maven, RubyGems, and **container images** (GitHub Container Registry, `ghcr.io`). Packages share the repo's access control.

## GitHub Codespaces

Cloud-hosted **dev environments** — a configurable container you open in the browser or VS Code. Defined by a `devcontainer.json`. Lets you code without local setup.

## GitHub Copilot

AI pair-programmer that suggests code and answers questions in your editor, CLI, and on GitHub. Tiers include Copilot Free, Pro, Business, and Enterprise; features include code completion and Copilot Chat.

## Editor & tooling integrations

| Tool | Integration |
|---|---|
| VS Code | First-class GitHub + Codespaces + Copilot support |
| GitHub CLI (`gh`) | Manage PRs/issues/repos/Actions from terminal |
| GitHub Desktop | GUI Git client |
| github.dev | Press `.` in a repo for a lightweight web editor |

## GitHub Marketplace

A catalog of **Actions** and **Apps** that extend GitHub — CI tools, code quality, project management, security, and more.

## Apps & webhooks (automation building blocks)

| Mechanism | Use |
|---|---|
| **Webhooks** | Send an HTTP payload to a URL when events happen |
| **GitHub Apps** | First-class integrations with fine-grained permissions, acting on their own identity |
| **OAuth Apps** | Act on behalf of a user |

## Exam traps

1. **Workflow files live in `.github/workflows/`** as YAML.
2. **Jobs are parallel by default**; `needs:` creates dependencies.
3. **Action vs workflow** — an action is a reusable step; a workflow is the whole automated process.
4. **Codespaces = cloud dev environment**, not a CI runner.
5. **Packages inherit repo permissions** and support container images via `ghcr.io`.

## Checklist

- [ ] Define workflow / event / job / step / action / runner
- [ ] Recognize a basic workflow YAML
- [ ] Explain GitHub-hosted vs self-hosted runners
- [ ] Describe Packages, Codespaces, and Copilot
- [ ] Distinguish webhooks vs GitHub Apps
