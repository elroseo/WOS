# Domain 3 — Collaboration Features

## Issues

Issues track bugs, tasks, ideas, and questions.

| Feature | What it does |
|---|---|
| Assignees | Who is responsible |
| Labels | Categorize (`bug`, `enhancement`, custom colors) |
| Milestones | Group issues toward a goal/date; show % complete |
| Issue templates | Standardize what reporters provide (Markdown or **issue forms** YAML) |
| Task lists | `- [ ]` checkboxes; can track sub-issues |
| Mentions | `@user` notifies; `#123` cross-references another issue/PR |
| Reactions | 👍 etc. for lightweight feedback |
| Pin / Lock | Highlight important issues / stop further comments |

**Closing keywords** in a PR description auto-close issues on merge: `Fixes #12`, `Closes #34`, `Resolves #56`.

## Pull Requests (PRs)

A PR proposes merging changes from one branch (or fork) into another, with review and discussion.

```
1. Branch → 2. Commit → 3. Push → 4. Open PR →
5. Review + CI → 6. Address feedback → 7. Merge → 8. Delete branch
```

| PR feature | Notes |
|---|---|
| **Draft PR** | Work-in-progress; can't be merged until marked ready |
| Reviewers | Requested manually or via `CODEOWNERS` |
| Conversations | Inline comments on specific lines |
| **Suggestions** | Propose exact code edits the author can commit with one click |
| Status checks | CI results; can be required by branch protection |
| Linked issues | Auto-close via keywords |
| Files changed | Diff view (unified or split) |

### Review decisions

| Decision | Meaning |
|---|---|
| Comment | Feedback without explicit approval/rejection |
| Approve | OK to merge |
| Request changes | Blocks merge until addressed |

### Merge methods

| Method | Result |
|---|---|
| Merge commit | Keeps all commits + adds a merge commit |
| Squash and merge | Combines all PR commits into one |
| Rebase and merge | Replays commits linearly, no merge commit |

## Forks in collaboration

To contribute to a repo you can't push to: **fork → clone your fork → branch → push → open a PR to upstream** (the "fork-and-pull" model). Maintainers review and merge.

## Discussions

A forum-style space (separate from Issues) for Q&A, announcements, and open-ended conversation. Supports categories, upvotes, and marking answers.

## Notifications & communication

| Tool | Purpose |
|---|---|
| Watch | Subscribe to a repo's activity |
| `@mention` | Notify a person or team |
| Reactions | Emoji feedback |
| Saved replies | Reusable canned responses |
| Notification inbox | Web/mobile/email triage of what you're subscribed to |

## CODEOWNERS

A file (`.github/CODEOWNERS`) mapping paths to owners. When a PR touches those paths, the owners are **automatically requested as reviewers** — and can be made required via branch protection.

```
*.js        @frontend-team
/docs/      @octocat
```

## Exam traps

1. **Draft PRs can't be merged** until marked "Ready for review".
2. **Suggestions** let reviewers propose committable code, not just comment.
3. **Closing keywords** only work from the PR's target/default branch context (e.g. `Fixes #12`).
4. **Discussions ≠ Issues** — Issues are trackable work; Discussions are conversation.
5. **CODEOWNERS auto-requests** reviewers; pair with branch protection to *require* them.

## Checklist

- [ ] List issue organization tools (labels, milestones, assignees, templates)
- [ ] Name the closing keywords
- [ ] Walk the PR lifecycle and the 3 review decisions
- [ ] Explain the fork-and-pull contribution model
- [ ] Describe what CODEOWNERS does
