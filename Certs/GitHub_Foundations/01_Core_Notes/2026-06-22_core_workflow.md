# Week 1 - Core Git and GitHub Workflow

## Git vs GitHub

| Git | GitHub |
|-----|--------|
| Open-source version control system | Cloud platform built on Git |
| Runs locally on your machine | Adds collaboration (PRs, Issues, Actions) |
| Tracks file changes over time | Hosts repos, manages access, integrates tools |
| Works offline | Requires internet for remote features |

**Key point for the exam:** Git is the engine. GitHub is the car built around it.

---

## Repositories

A repository (repo) is a project folder tracked by Git.

| Action | What it does | When to use |
|--------|-------------|-------------|
| `git init` | Create new local repo | Starting a brand new project locally |
| `git clone <url>` | Copy remote repo to local | Working on an existing project |
| Fork (GitHub) | Copy repo to your account | Contributing to someone else's project |

**Exam trap:** Forking is a GitHub concept, not a Git command. It creates a server-side copy under your account.

---

## Commits

A commit is a snapshot of your files at a point in time.

```
git add .              # Stage changes
git commit -m "msg"   # Save snapshot with message
```

Each commit has:
- A unique SHA hash (e.g., `a1b2c3d`)
- Author and timestamp
- Parent commit(s) - this forms the history graph
- A message describing what changed

**Best practice:** Small, focused commits with clear messages.

---

## Branches

Branches are movable pointers to commits. They let you work in isolation.

```
main         A---B---C
                  \
feature            D---E
```

| Command | Action |
|---------|--------|
| `git branch feature` | Create branch |
| `git checkout -b feature` | Create and switch |
| `git switch -c feature` | Same (newer syntax) |
| `git branch -d feature` | Delete branch |

**HEAD** = pointer to your current position (which branch/commit you're on).

---

## Merge Options

When bringing a branch back into main, there are three strategies:

### Merge Commit (default)
- Creates a new "merge commit" with two parents
- Preserves full branch history
- History shows the branch existed

### Squash Merge
- Combines all branch commits into one single commit on main
- Cleaner linear history
- Loses individual commit detail

### Rebase
- Replays branch commits on top of main
- Linear history (no merge commit)
- Rewrites commit SHAs (don't rebase shared branches)

**Exam tip:** Know when each is appropriate. Squash = clean history. Merge = full context. Rebase = linear without merge commits.

---

## Pull Request (PR) Lifecycle

```
1. Create branch
2. Make commits
3. Push branch to GitHub
4. Open Pull Request
5. Team reviews (comments, approvals, changes requested)
6. CI checks pass
7. Merge (merge commit / squash / rebase)
8. Branch deleted (optional cleanup)
```

PR features:
- **Draft PRs** - work in progress, not ready for review
- **Reviewers** - assigned manually or via CODEOWNERS
- **Status checks** - CI must pass before merge (if branch protection enabled)
- **Linked Issues** - `Fixes #12` in description auto-closes Issue 12 on merge

---

## Key Files in a Repo

| File | Purpose |
|------|---------|
| `README.md` | Project overview (renders on repo page) |
| `.gitignore` | Files Git should not track |
| `LICENSE` | Legal terms for using the code |
| `CONTRIBUTING.md` | How to contribute |
| `CODEOWNERS` | Auto-assign PR reviewers by file path |

---

## Exam Traps to Watch

1. **Fork vs Clone** - Fork is server-side (GitHub), clone is local.
2. **Branch = pointer** - Branches are lightweight, just pointers to a commit SHA.
3. **Squash loses history** - Individual commits are gone. The PR still shows them, but main's log won't.
4. **Rebase rewrites SHAs** - Never rebase a branch others are working on.
5. **HEAD is not the main branch** - HEAD is wherever you currently are.
6. **git pull = fetch + merge** - It's two operations in one.

---

## Session Checklist

After completing this material, you should be able to:
- [ ] Explain what Git does vs what GitHub adds
- [ ] Describe when to clone vs fork
- [ ] Draw a simple branch/merge diagram
- [ ] Name the three merge strategies and trade-offs
- [ ] List the steps in a PR lifecycle
- [ ] Identify what HEAD points to
