---
tags:
  - git
  - github
  - cheatsheet
  - troubleshooting
audience: CRE
updated: 2026-08-13
---

# Git and GitHub Cheatsheet

## Scope and when to use this

This cheatsheet covers two different things, kept in separate parts below:

- **Part 1: Normal developer workflow** - the everyday Git/GitHub commands and process any engineer uses (issue → branch → commit → PR → review → merge).
- **Part 2: CRE troubleshooting workflow** - how to diagnose a customer's broken clone/push/pull/auth against github.com or GHES. This is a different mode: you're isolating a failure, not writing code.

Use Part 1 as a command reference. Use Part 2 when a customer reports they can't connect, authenticate, or push/pull.

## Prerequisites and access

- Git installed locally, and the GitHub CLI (`gh`) if you want to use the `gh` command examples.
- For Part 2 (troubleshooting): the customer's remote URL/hostname, and enough context to know whether they're on github.com or GHES.

## What is Git and GitHub?

Git is a version control system that tracks changes to files over time. It lets you save snapshots of your work (commits), create separate lines of development (branches), and collaborate with others by merging changes together. Every developer on a project has a full copy of the history on their machine.

**GitHub** is the cloud platform built on top of Git. It adds collaboration features like pull requests, issues, code review, and CI/CD. The **GitHub CLI** (`gh`) lets you do most GitHub tasks from your terminal.

## Platform scope

GHES runs a full GitHub instance on a customer's own infrastructure. Git commands work the same way, but remotes point to the GHES hostname instead of github.com. The `gh` CLI works with GHES too (authenticate with `gh auth login --hostname your-ghes.com`). As a CRE, you may help customers troubleshoot Git connectivity, authentication, and push/pull issues against their GHES instance - see Part 2 below.

## How it's typically used

- Tracking code changes across a team
- Branching for features, bug fixes, and experiments
- Code review through pull requests before merging
- Releasing and tagging versions

---

## Part 1: Normal developer workflow

Here's how Git and GitHub fit together in a real project, from start to finish:

### 1. Start with an issue

Someone creates a **GitHub Issue** describing a bug, feature request, or task. This is the "why" behind the change.

```
gh issue create --title "Fix login timeout" --body "Users are getting logged out after 5 minutes"
```

### 2. Create a branch from `main`

The `main` branch is the source of truth (the current stable code). You never work directly on `main`. Instead, create a branch for your change.

```
git checkout main              # Start from main
git pull                       # Make sure it's up to date
git checkout -b fix/login-timeout   # Create your branch
```

**Branch naming conventions** vary by team, but common patterns are:
- `feature/description` for new features
- `fix/description` for bug fixes
- `docs/description` for documentation

### 3. Make changes and commit

Work on your code, then save your progress with commits. Each commit is a snapshot with a message explaining what changed.

```
git add -A
git commit -m "Increase session timeout to 30 minutes"
```

You can make multiple commits on a branch. Each one should be a logical unit of work.

### 4. Push your branch and open a Pull Request

Push your branch to GitHub, then open a PR. The PR is where the team reviews your changes before they go into `main`.

```
git push -u origin fix/login-timeout
gh pr create --title "Fix login timeout" --body "Closes #42. Increases session timeout to 30 minutes."
```

> **Tip:** Writing "Closes #42" in the PR body automatically links and closes the issue when the PR is merged.

A **pull request** is a collaboration area where work in one branch is reviewed before merging it into another branch. It has different tabs to manage the conversation and easily review changes.

- **Conversation** - A general log of the pull request activity. It also provides an open space for fellow collaborators and the community to provide ideas, suggestions, and general feedback.
- **Commits** - A list of only the commits unique to the proposed branch.
- **Checks** - The results of any automations applied to the pull request using [GitHub Actions](https://github.com/features/actions). 
- **Files Changed** - A [Diff](https://docs.github.com/en/get-started/learning-about-github/github-glossary#diff) view that easily shows the proposed changes in a before/after view. It also has options to add comments and reviews in context.

 You can [create a draft pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) for unfinished work. This can help avoid accidental merges or premature reviews.
### 5. Code review

Teammates review the PR on GitHub:
- They read the diff (line-by-line comparison of changes)
- They leave comments or ask questions
- They can **approve**, **request changes**, or just **comment**

You can push more commits to the same branch to address feedback. The PR updates automatically.

### 6. CI/CD with GitHub Actions

When you open or update a PR, **GitHub Actions** can automatically:
- Run tests to make sure nothing is broken
- Lint the code for style issues
- Build the project to check for errors
- Run security scans

These checks show up on the PR as green (passed) or red (failed). Most teams require all checks to pass before merging.

### 7. Merge the PR

Once the PR is approved and checks pass, merge it into `main`:

```
gh pr merge --squash --delete-branch
```

**Merge strategies:**
- **Merge commit**: keeps all individual commits, adds a merge commit
- **Squash**: combines all commits into one clean commit (most common)
- **Rebase**: replays your commits on top of main (linear history)

### 8. The cycle repeats

After merging, your branch is deleted and `main` now includes your change. The linked issue closes automatically. On to the next issue!

### Visual summary

```
Issue created
    ↓
Branch from main
    ↓
Make changes + commit
    ↓
Push branch + open PR
    ↓
Code review + Actions run
    ↓
Merge to main (issue auto-closes)
    ↓
Repeat
```

---

## Part 2: CRE troubleshooting workflow

Use this when a customer reports they can't clone, push, pull, or authenticate against GitHub.com or GHES. This is different from Part 1 above: here you are isolating a broken connection or permission problem, not writing code.

**Platform scope:** Works the same way for github.com and GHES, except the remote hostname (and possibly the SSH port, if the customer has changed defaults) differ. Git-over-SSH uses port 22; GHES appliance admin SSH is a separate connection on port 122 (see [[SSH Cheatsheet]] and [[GHES Cheatsheet]]) and is not the same thing as a customer's Git-over-SSH port.

**Safety and read-only boundary:** Start with read-only diagnostic commands (`git remote -v`, `git ls-remote`, `gh auth status`, `ssh -T`). Don't run destructive commands (`git push --force`, `git reset --hard`, branch deletion) against a customer's repository without their explicit confirmation, and don't perform them on their behalf without them present.

### Quick task: diagnose a clone/push/pull failure

1. **Confirm the remote URL** - `git remote -v`. Check the hostname matches github.com or the customer's GHES hostname, and that the protocol (HTTPS vs SSH) matches what they intend to authenticate with.
2. **Test connectivity without touching the repo** - `git ls-remote <url>` (read-only; lists refs without cloning). For SSH: `ssh -T git@<hostname>` (see [[SSH Cheatsheet]]).
3. **Check authentication state** - `gh auth status` for HTTPS/CLI-based auth. For SSH, confirm the key is loaded (`ssh-add -l`) and the matching public key is registered on the account or appliance.
4. **Reproduce the exact failing command** with `-v`, or `GIT_TRACE=1 git <command>` for verbose output, to see where it fails: DNS, TCP, TLS/SSH handshake, or authorization.
5. **Compare the error message** against the table below to classify the failure.

**Expected result:** You can classify the failure as network/connectivity, authentication, or authorization (permission), and give the customer a specific next step instead of a generic "try again."

**Verify:** Once the customer applies a fix (new key, corrected remote URL, restored permissions), re-run `git ls-remote <url>` or push to a scratch branch to confirm before closing the ticket.

### Errors and recovery

| Symptom | Likely cause | Next step |
|---|---|---|
| `remote: Support for password authentication was removed` | Customer is using a password instead of a token/SSH key over HTTPS | Have them run `gh auth login`, or use a personal access token |
| `Permission denied (publickey)` | SSH key not loaded, not registered, or wrong key used | See [[SSH Cheatsheet]] troubleshooting section |
| `fatal: repository not found` | Wrong URL, typo, or the authenticated account/token lacks access to that repo | Confirm the remote URL and that the authenticated account has access |
| `Could not resolve host` | DNS/network issue, VPN not connected, or wrong GHES hostname | Confirm the customer is on the required network path to reach the GHES hostname |
| `! [rejected] ... (fetch first)` / non-fast-forward push rejected | Local branch is behind the remote | `git pull --rebase` (or merge) before pushing again; don't force-push without the customer's explicit confirmation |

### Stop and escalate if

- The failure looks like it's inside GHES infrastructure (5xx errors, service unavailable, appliance-side auth backend down) rather than the client - move to [[GHES Cheatsheet]] and consider a support bundle investigation ([[Support Bundles Cheatsheet]]).
- The customer needs a force-push or history rewrite on a shared branch - confirm with them explicitly and make sure they understand the impact; this is their decision to make on their own repository, not something CRE performs for them.
- Authentication fails against an SSO-protected org and the standard `gh auth login` flow doesn't resolve it - escalate rather than guessing at a workaround.

---

## Command reference (quick lookup tables)

Everyday Git/GitHub commands, grouped by task. This is normal developer workflow reference (Part 1 above), not the troubleshooting workflow in Part 2.

## Setup

| Command | What it does |
|---|---|
| `git config --global user.name "Name"` | Set your Git username |
| `git config --global user.email "email"` | Set your Git email |
| `git config --list` | View current config |
| `gh auth login` | Authenticate GitHub CLI |
| `gh auth status` | Check login status |

> **How auth works on this machine:** you authenticate once with `gh auth login` (HTTPS), and `gh` installs itself as git's credential helper (`credential.https://github.com.helper = !gh auth git-credential`). After that, `git clone`/`pull`/`push` over HTTPS "just work" with no tokens to paste, because git asks `gh` for credentials automatically. No SSH key needed for GitHub.com pushes.

---

## Repos

| Command | What it does |
|---|---|
| `git init` | Initialize a new repo |
| `git clone <url>` | Clone an existing repo |
| `gh repo create <name> --private` | Create a new repo on GitHub |
| `gh repo create <name> --private --source=. --push` | Create and push existing folder |
| `gh repo list` | List your repos |

---

## Branching

| Command | What it does |
|---|---|
| `git branch` | List local branches |
| `git branch -a` | List all branches (including remote) |
| `git checkout -b <name>` | Create and switch to a new branch |
| `git switch <name>` | Switch to an existing branch |
| `git branch -d <name>` | Delete a local branch |
| `git push origin --delete <name>` | Delete a remote branch |

---

## Everyday workflow

```bash
git status                    # See what's changed
git add -A                    # Stage all changes
git commit -m "message"       # Commit with a message
git push                      # Push to remote
git pull                      # Pull latest from remote
```

---

## Staging and committing

| Command | What it does |
|---|---|
| `git add <file>` | Stage a specific file |
| `git add -A` | Stage everything |
| `git add -p` | Stage changes interactively (chunk by chunk) |
| `git commit -m "msg"` | Commit staged changes |
| `git commit --amend` | Edit the last commit message |
| `git reset HEAD <file>` | Unstage a file |
| `git stash` | Temporarily save uncommitted changes |
| `git stash pop` | Restore stashed changes |

---

## Viewing history

| Command | What it does |
|---|---|
| `git log --oneline` | Compact commit history |
| `git log --oneline --graph` | Visual branch history |
| `git diff` | See unstaged changes |
| `git diff --staged` | See staged changes |
| `git show <commit>` | Show details of a specific commit |
| `git blame <file>` | See who changed each line |

---

## Pull requests (GitHub CLI)

| Command | What it does |
|---|---|
| `gh pr create` | Open a new PR (interactive) |
| `gh pr create --title "..." --body "..."` | Open a PR inline |
| `gh pr create --draft` | Open as a draft PR |
| `gh pr list` | List open PRs |
| `gh pr view` | View current branch's PR |
| `gh pr status` | See your PR overview |
| `gh pr checks` | Check CI status |
| `gh pr merge` | Merge (interactive, pick strategy) |
| `gh pr merge --squash` | Squash merge |
| `gh pr merge --squash --delete-branch` | Squash merge and clean up branch |
| `gh pr close` | Close without merging |

### The PR workflow

```bash
git checkout -b feature/my-change     # 1. Create branch
# ... make changes ...
git add -A && git commit -m "msg"     # 2. Commit
git push -u origin feature/my-change  # 3. Push
gh pr create --title "My change"      # 4. Open PR
# ... review happens ...
gh pr merge --squash --delete-branch  # 5. Merge and clean up
```

---

## Issues (GitHub CLI)

| Command | What it does |
|---|---|
| `gh issue list` | List open issues |
| `gh issue create` | Create a new issue |
| `gh issue view <number>` | View an issue |
| `gh issue close <number>` | Close an issue |
| `gh issue comment <number> --body "..."` | Add a comment |

---

## Remotes

| Command | What it does |
|---|---|
| `git remote -v` | List remotes |
| `git remote add origin <url>` | Add a remote |
| `git remote set-url origin <url>` | Change remote URL |
| `git fetch` | Download remote changes (without merging) |
| `git pull --rebase` | Pull and rebase instead of merge |

---

## Undoing things

| Command | What it does |
|---|---|
| `git checkout -- <file>` | Discard changes to a file |
| `git reset --soft HEAD~1` | Undo last commit, keep changes staged |
| `git reset --hard HEAD~1` | Undo last commit, discard changes |
| `git revert <commit>` | Create a new commit that undoes a previous one |

> **Warning:** `--hard` is destructive. Use with caution.

---

## Tags

| Command | What it does |
|---|---|
| `git tag v1.0.0` | Create a lightweight tag |
| `git tag -a v1.0.0 -m "Release"` | Create an annotated tag |
| `git push origin v1.0.0` | Push a tag to remote |
| `git tag -l` | List all tags |

---

## Useful aliases

Add these to your git config (`git config --global alias.<name> "<command>"`):

```bash
git config --global alias.st "status"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.lg "log --oneline --graph --all"
```

Then use `git st`, `git co`, `git br`, `git lg`.

---

## Quick reference links

- [Set up Git (GitHub Docs)](https://docs.github.com/en/get-started/git-basics/set-up-git)
- [Git docs](https://git-scm.com/doc)
- [GitHub CLI manual](https://cli.github.com/manual/)
- [GitHub Docs](https://docs.github.com)

## Related links

- [[SSH Cheatsheet]] - key management and connectivity troubleshooting for Git-over-SSH
- [[GHES Cheatsheet]] - `ghe-*` admin commands and appliance access
- [[GHEC vs GHES Cheatsheet]] - platform differences that affect auth and troubleshooting
- [[Support Bundles Cheatsheet]] - when a connectivity issue points to appliance-side infrastructure

## Freshness note

Core Git commands and the PR/review workflow are stable. `gh` CLI flags and GHES auth behavior can change between releases - if a command in Part 1 or Part 2 doesn't match what you observe, check `gh --version` and the customer's GHES release notes. Last reviewed: 2026-08-13.
