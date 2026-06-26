# Domain 5 — Project Management

## GitHub Projects (Projects v2)

A flexible, spreadsheet-meets-board planning tool that lives on top of Issues and Pull Requests. Projects can be owned by a **user** or an **organization** and can pull items from multiple repos.

| Capability | Detail |
|---|---|
| Items | Issues, PRs, and **draft issues** (notes that aren't yet real issues) |
| Custom fields | Text, Number, Date, Single-select, Iteration |
| Built-in fields | Status, Assignees, Labels, Milestone, Repository |
| Views | Save multiple filtered/sorted layouts of the same data |

## Project views

| View | Best for |
|---|---|
| **Table** | Spreadsheet-style editing of many items + fields |
| **Board** | Kanban columns (e.g. Todo / In Progress / Done) grouped by a field |
| **Roadmap** | Timeline view using date/iteration fields |

## Built-in automation

Projects include **workflows** (e.g. when an item is closed, set Status = Done; auto-add new issues). Combined with **GitHub Actions**, you can drive more advanced automation.

## Issue organization tools

| Tool | Purpose |
|---|---|
| **Labels** | Categorize and filter (color-coded) |
| **Milestones** | Group issues/PRs toward a goal; track % complete |
| **Assignees** | Assign responsibility |
| **Task lists** | Checkboxes; can create trackable sub-issues |
| **Linked PRs** | Connect work to the issue it resolves |

## Filtering & search

Filter items by field values (`status:"In Progress"`, `assignee:@me`, `label:bug`). Insights/charts visualize progress (e.g. items by status over time).

## Classic Projects (legacy)

Older **Projects (classic)** were simple per-repo Kanban boards. They've been superseded by Projects v2, which is more powerful and spans repos. Know that the modern Projects experience is the default.

## Exam traps

1. **Projects v2 spans repositories** and is owned by a user or org — not limited to one repo.
2. **Draft issues** live only in the project until converted to real issues.
3. **Milestones track progress** with a percent-complete bar; labels do not.
4. **Iterations** are a custom field type for sprint-style planning.
5. The same project data can be shown through **multiple views** (table/board/roadmap).

## Checklist

- [ ] Describe Projects v2 and what items it can hold
- [ ] Compare table / board / roadmap views
- [ ] Explain labels vs milestones vs assignees
- [ ] Define draft issues and iterations
- [ ] Note built-in project automation/workflows
