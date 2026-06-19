# Answer Key - Baseline Quiz (20 Questions)

---

### Q1. B) Git is a version control system; GitHub is a hosting platform for Git repos
**Why:** Git is the open-source distributed VCS that runs locally. GitHub adds collaboration features (PRs, Issues, Actions) on top of hosted Git repos.

---

### Q2. B) Downloads a copy of a remote repository to your local machine
**Why:** `git clone` creates a local copy of the full repo including all history and branches.

---

### Q3. B) A copy of someone else's repo under your own account
**Why:** Forking creates a personal copy you control. You can then submit PRs back to the original (upstream) repo.

---

### Q4. B) `git checkout -b new-branch`
**Why:** The `-b` flag creates the branch and switches to it in one command. (`git switch -c new-branch` also works in newer Git versions.)

---

### Q5. B) A pointer to the current branch/commit you are on
**Why:** HEAD always points to your current position in the commit graph. It moves when you checkout branches or commits.

---

### Q6. B) Merge commit preserves all individual commits; squash combines them into one
**Why:** A merge commit keeps the full branch history. Squash condenses all branch commits into a single commit on the target branch, keeping history clean.

---

### Q7. B) `.gitignore`
**Why:** This file tells Git which files/folders to exclude from tracking. Common entries: `node_modules/`, `.env`, build artifacts.

---

### Q8. B) A proposal to merge changes from one branch into another
**Why:** PRs are GitHub's collaboration mechanism. They show the diff, allow discussion and review, and gate the merge.

---

### Q9. C) Only the repo owner and collaborators with write access
**Why:** Even in public repos, merge rights require write (or higher) permissions. Anyone can view and comment, but not merge.

---

### Q10. B) Provide documentation and an overview of the project
**Why:** README.md renders on the repo's main page. It's the first thing visitors see - should explain what the project is, how to use it, and how to contribute.

---

### Q11. D) All of the above
**Why:** GitHub recognizes `Fixes`, `Closes`, and `Resolves` (plus their variants like `Fix`, `Close`, `Resolve`) as closing keywords. Any of them auto-close the linked issue when the PR merges.

---

### Q12. B) An automated workflow triggered by events in your repo
**Why:** GitHub Actions are CI/CD workflows defined in YAML. They run on triggers like push, PR, schedule, or manual dispatch.

---

### Q13. B) `.github/workflows/`
**Why:** GitHub looks specifically in `.github/workflows/` for YAML workflow files. Other locations are ignored.

---

### Q14. B) A tool that automatically opens PRs to update vulnerable dependencies
**Why:** Dependabot monitors your dependency files, checks for known vulnerabilities, and opens PRs with version bumps.

---

### Q15. B) Secret scanning
**Why:** Secret scanning detects patterns like API keys, tokens, and passwords in your commits. Code scanning (different feature) looks for code vulnerabilities using CodeQL.

---

### Q16. C) Write
**Why:** Read = view only. Triage = manage issues/PRs but can't push code. Write = push to non-protected branches, create branches, open/merge PRs.

---

### Q17. B) A branch with rules that restrict who/how changes can be pushed or merged
**Why:** Branch protection rules can require PR reviews, status checks, signed commits, and block force pushes. They guard important branches like `main`.

---

### Q18. B) Automatically assigning reviewers when specific files are changed in a PR
**Why:** CODEOWNERS maps file paths to teams/users. When a PR touches those files, the owners are automatically requested as reviewers.

---

### Q19. B) Host static websites directly from a repo
**Why:** GitHub Pages serves static HTML/CSS/JS from a branch or folder. Used for project docs, blogs, and portfolios. No server-side code execution.

---

### Q20. D) GitHub Enterprise Cloud
**Why:** SAML SSO is an Enterprise Cloud feature. It lets organizations enforce identity provider authentication. Free, Pro, and Team plans do not support SAML.

---

## Quick Reference - Tricky Distinctions

| Concept | Key Point |
|---------|-----------|
| Fork vs Clone | Fork = copy on GitHub (your account). Clone = copy on your machine. |
| Merge vs Squash vs Rebase | Merge = full history. Squash = one commit. Rebase = linear replay. |
| Secret scanning vs Code scanning | Secrets = leaked credentials. Code = vulnerability patterns (CodeQL). |
| Read vs Triage vs Write | Read = view. Triage = manage issues. Write = push code. |
| CODEOWNERS vs Branch protection | CODEOWNERS = auto-assigns reviewers. Branch protection = enforces rules. |
