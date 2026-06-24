# Lab Progression

All labs use a single sandbox repo: `github-foundations-sandbox`

---

## Lab 01: Initialize Repo and Commit History
**Topics:** repo creation, README, commit basics, `git log`

- [ ] Create repo on GitHub with README 📅 2026-07-02
- [ ] Clone locally, edit README, commit with meaningful message
- [ ] Make 3-4 commits to build history
- [ ] Explore `git log --oneline` and commit SHAs

---

## Lab 02: Feature Branch + PR + Merge
**Topics:** branching, PR lifecycle, merge options

- [ ] Create feature branch (`feature/add-profile`)
- [ ] Make changes, push branch, open PR
- [ ] Review the diff, add a comment
- [ ] Merge with squash, observe commit history difference

---

## Lab 03: Issue Linking
**Topics:** Issues, closing keywords, cross-references

- [ ] Create an Issue ("Add contributing guidelines")
- [ ] Create branch, make changes
- [ ] Open PR with `Fixes #1` in the description
- [ ] Merge and confirm Issue auto-closes

---

## Lab 04: Basic GitHub Actions Workflow
**Topics:** workflow files, triggers, runners, jobs, steps

- [ ] Create `.github/workflows/hello.yml`
- [ ] Trigger: `on: push`
- [ ] Job: run `echo "Hello from Actions"` on `ubuntu-latest`
- [ ] Push and observe the Actions tab

---

## Lab 05: Branch Protection + Review Simulation
**Topics:** rulesets, required reviews, status checks

- [ ] Enable branch protection on `main` (require PR)
- [ ] Try pushing directly to `main` (should fail)
- [ ] Open PR, observe required review notice
- [ ] Approve and merge (use a second account or bypass if needed)

---

## Notes

- Do each lab in order. They build on the same repo.
- Take notes in `01_Core_Notes/` as you go.
- Log any surprises or wrong assumptions in the [[Mistake Log]].
