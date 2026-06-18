# Git and GitHub Cheatsheet

## What is Git?

Git is a version control system that tracks changes to files over time. It lets you save snapshots of your work (commits), create separate lines of development (branches), and collaborate with others by merging changes together. Every developer on a project has a full copy of the history on their machine.

**GitHub** is the cloud platform built on top of Git. It adds collaboration features like pull requests, issues, code review, and CI/CD. The **GitHub CLI** (`gh`) lets you do most GitHub tasks from your terminal.

## How it's typically used

- Tracking code changes across a team
- Branching for features, bug fixes, and experiments
- Code review through pull requests before merging
- Releasing and tagging versions

## How it relates to GHES

GHES runs a full GitHub instance on your own infrastructure. Git commands work the same way, but remotes point to your GHES hostname instead of github.com. The `gh` CLI works with GHES too (authenticate with `gh auth login --hostname your-ghes.com`). As a CRE, you may help customers troubleshoot Git connectivity, authentication, and push/pull issues against their GHES instance.

---

## The typical development workflow

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

## Setup

| Command | What it does |
|---|---|
| `git config --global user.name "Name"` | Set your Git username |
| `git config --global user.email "email"` | Set your Git email |
| `git config --list` | View current config |
| `gh auth login` | Authenticate GitHub CLI |
| `gh auth status` | Check login status |

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

- [Git docs](https://git-scm.com/doc)
- [GitHub CLI manual](https://cli.github.com/manual/)
- [GitHub Docs](https://docs.github.com)
