# Domain 1 — Introduction to Git and GitHub

> Exam weight: ~the foundation everything else builds on. Pairs with [[2026-06-22_core_workflow]] (hands-on Git workflow).

## What is Git?

Git is a **free, open-source distributed version control system (DVCS)** created by Linus Torvalds in 2005. "Distributed" means every clone is a full copy of the project *and* its entire history — you can commit, branch, and view history offline.

| Concept | Meaning |
|---|---|
| Version control | Tracks changes to files over time, lets you revert |
| Distributed | Every clone has the full history (vs centralized like SVN) |
| Local-first | Commits, branches, diffs work without a network |
| Snapshot-based | Git stores snapshots of the whole project, not just diffs |

## What is GitHub?

GitHub is a **cloud-based hosting platform built on top of Git**. Git handles version control; GitHub adds collaboration, access control, and a web UI on top.

| Git provides | GitHub adds |
|---|---|
| Commits, branches, merges, history | Remote hosting of repositories |
| Local repository operations | Pull requests, Issues, Discussions |
| The version-control engine | Actions (CI/CD), Packages, Pages, Codespaces |
| — | Access control, teams, security features |

**Exam framing:** *Git is the engine; GitHub is the platform built around it.* Git ≠ GitHub. Alternatives to GitHub include GitLab and Bitbucket (also built on Git).

## The three Git states

| State | Where | Command to move forward |
|---|---|---|
| Working directory | Your edited files | `git add` → staging |
| Staging area (index) | Changes marked for next commit | `git commit` → repository |
| Repository (.git) | Committed snapshots/history | `git push` → remote |

## Core Git vocabulary

| Term | Definition |
|---|---|
| Repository | A project tracked by Git (the `.git` folder + files) |
| Commit | A saved snapshot, identified by a unique SHA hash |
| Branch | A movable pointer to a commit; enables parallel work |
| HEAD | Pointer to your current branch/commit |
| Remote | A hosted copy of the repo (e.g. `origin` on GitHub) |
| Clone | A local copy of a remote repository |
| Fork | A server-side copy of a repo under your GitHub account |

## Essential commands

```bash
git init                 # Start a new local repo
git clone <url>          # Copy a remote repo locally
git status               # See what's changed
git add <file>           # Stage changes
git commit -m "message"  # Save a snapshot
git push                 # Upload commits to remote
git pull                 # fetch + merge from remote
git branch               # List branches
git switch -c <name>     # Create + switch to a branch
```

> `git pull` = `git fetch` (download) + `git merge` (integrate).

## GitHub account types

| Account | Who it's for |
|---|---|
| Personal account | An individual; owns repos and is a member of orgs |
| Organization | Shared account for groups; contains teams + repos, no sign-in of its own |
| Enterprise account | Top-level container managing multiple organizations (billing, policy) |

## GitHub plans / products

| Plan | Notes |
|---|---|
| GitHub Free | Unlimited public & private repos, Actions/Packages minutes, community support |
| GitHub Team | Paid org plan: protected branches, code owners, more Actions minutes |
| GitHub Enterprise Cloud (GHEC) | Hosted by GitHub; SAML SSO, advanced security, enterprise admin |
| GitHub Enterprise Server (GHES) | Self-hosted appliance you run on your own infrastructure |

> **Public vs private** repos are free. Advanced **security** features and **enterprise** admin/identity are what you pay for.

## Ways to use GitHub

| Surface | Use |
|---|---|
| Web (github.com) | Full UI in the browser |
| GitHub Desktop | GUI Git client for Windows/macOS |
| GitHub CLI (`gh`) | GitHub from the terminal (PRs, issues, repos) |
| GitHub Mobile | iOS/Android app for notifications, reviews |
| Codespaces | Cloud dev environments in the browser/VS Code |
| GitHub Copilot | AI pair-programmer |

## Supporting concepts

- **Markdown** — lightweight formatting used in READMEs, issues, PRs, comments. (See [[GitHub Markdown Cheatsheet]].)
- **Gist** — a shareable snippet/file, backed by a Git repo; can be public or secret.
- **README.md** — renders automatically on the repo home page; a profile README (repo named after your username) renders on your profile.

## Exam traps

1. **Fork is GitHub, not Git** — there's no `git fork` command.
2. **Distributed** — every clone has full history; Git is not centralized.
3. **Organizations don't log in** — people log in to personal accounts and act within orgs.
4. **GHEC vs GHES** — Cloud is GitHub-hosted; Server is self-hosted.
5. **Git stores snapshots**, not file-by-file diffs.

## Checklist

- [ ] Define Git vs GitHub and name alternatives
- [ ] Describe the three Git states and the commands between them
- [ ] List the three account types
- [ ] Distinguish Free / Team / GHEC / GHES
- [ ] Explain gists, READMEs, and Markdown's role
