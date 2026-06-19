# GitHub Actions - enterprise patterns and troubleshooting

| | |
|---|---|
| **Estimated Time** | 3+ hours |
| **Phase** | 3 - Advanced |
| **Priority** | High |
| **Resources** | [Administering Actions docs](https://docs.github.com/en/actions/administering-github-actions) |
| **Status** | Not Started |
| **Topic Area** | Actions & CI/CD |

## Goal

Understand how Actions behaves in enterprise contexts and how to troubleshoot common issues CREs encounter.

## Key concepts

- Actions policies at org and enterprise level
- Allowed actions lists and internal marketplace
- Self-hosted runner groups and access controls
- Larger runners (GitHub-hosted)
- Actions usage billing and limits
- Runner scale sets (Actions Runner Controller / ARC)
- OIDC for cloud provider authentication (AWS, Azure, GCP)
- Reusable workflows and caller/called workflow patterns

## Learning tasks

- [ ] Configure an org-level Actions policy to restrict to verified creators only
- [ ] Set up a runner group scoped to specific repos
- [ ] Implement OIDC-based AWS auth in a workflow (no long-lived secrets)
- [ ] Write a reusable workflow and call it from another repo
- [ ] Audit Actions usage and understand the billing breakdown

## Notes

