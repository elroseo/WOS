# Domain 2 — Working with GitHub Repositories

## What a repository contains

A repo holds your project's files, full version history, branches, and settings. It can also contain community/health files that GitHub recognizes specially.

| File | Purpose |
|---|---|
| `README.md` | Overview; renders on the repo home page |
| `.gitignore` | Patterns of files Git should not track |
| `LICENSE` | Legal terms for using the code |
| `CONTRIBUTING.md` | How to contribute |
| `CODE_OF_CONDUCT.md` | Community behavior standards |
| `SECURITY.md` | How to report vulnerabilities |
| `CODEOWNERS` | Auto-assign reviewers by file path |

## Repository visibility

| Visibility | Who can see it |
|---|---|
| **Public** | Anyone on the internet |
| **Private** | Only you + people/teams you grant access |
| **Internal** | Any member of your enterprise (used in orgs/enterprises for InnerSource) |

## Creating a repository

- **New** from scratch (optionally initialize with README, `.gitignore`, license).
- **From a template** — a repo marked as a template; creates a fresh repo with the files but **no commit history**.
- **Fork** — server-side copy of someone else's repo under your account (keeps link to upstream).
- **Import** — bring in a repo from another VCS/host.

## Cloning options

| Method | URL form |
|---|---|
| HTTPS | `https://github.com/owner/repo.git` |
| SSH | `git@github.com:owner/repo.git` |
| GitHub CLI | `gh repo clone owner/repo` |

## Branches

- The **default branch** (usually `main`) is what people see first and the base for new PRs.
- Branches are lightweight pointers enabling isolated work.
- You can rename, set a new default, and protect branches in settings.

## Tags and releases

| Concept | Meaning |
|---|---|
| **Tag** | A named pointer to a specific commit (often a version, e.g. `v1.2.0`) |
| **Release** | A GitHub layer on top of a tag: title, notes, and downloadable assets |

## GitHub Pages

Static website hosting **directly from a repository**. Serves from a branch (e.g. `main` or `gh-pages`) or a `/docs` folder; supports Jekyll. Site URL: `https://<user>.github.io/<repo>`.

## Managing files in the web UI

- Create/edit/delete files in the browser; each save is a commit.
- Upload files via drag-and-drop.
- Edit history per file, **Blame** view (who changed each line), and raw view.

## Finding your way around

| Feature | What it shows |
|---|---|
| Code search / `t` file finder | Find files and code |
| Commits | Full history |
| Blame | Line-by-line authorship |
| Insights → Network/Graphs | Forks, contributors, traffic |
| Topics | Tags that make repos discoverable |
| Stars / Watch | Bookmark / subscribe to notifications |

## Repository roles (intro — full detail in Domain 6)

| Role | Can |
|---|---|
| Read | Clone, pull, open issues/PRs |
| Triage | Manage issues/PRs without write |
| Write | Push to non-protected branches |
| Maintain | Manage repo without sensitive settings |
| Admin | Full control incl. settings, access |

## Exam traps

1. **Template vs fork** — a template gives a clean repo with **no history**; a fork keeps history and an upstream link.
2. **Internal visibility** exists only within enterprises/orgs.
3. **Tag ≠ Release** — a release wraps a tag with notes/assets.
4. **Pages serves static sites** from a repo branch/folder.
5. Editing a file in the web UI **creates a commit** (optionally on a new branch via a PR).

## Checklist

- [ ] List recognized community/health files
- [ ] Compare public / private / internal
- [ ] Explain template vs fork vs import
- [ ] Define tag vs release
- [ ] Describe what GitHub Pages does
