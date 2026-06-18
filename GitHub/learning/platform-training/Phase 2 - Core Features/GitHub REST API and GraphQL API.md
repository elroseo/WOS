# GitHub REST API and GraphQL API

| | |
|---|---|
| **Estimated Time** | 2 hours |
| **Phase** | 2 - Core Features |
| **Priority** | High |
| **Resources** | [REST API docs](https://docs.github.com/en/rest) |
| **Status** | Not Started |
| **Topic Area** | APIs & Integrations |

## Goal

Become proficient with GitHub's APIs, essential for CRE work involving automation, diagnostics, and helping customers build integrations.

## Key concepts

- REST API structure, authentication (PATs, GitHub Apps, OAuth)
- Rate limiting: primary and secondary limits
- REST vs GraphQL, when to use each
- GraphQL schema and common queries
- Pagination (cursor-based vs page-based)
- Conditional requests and ETags
- Enterprise-specific API endpoints

## Learning tasks

- [ ] Authenticate to the REST API with a fine-grained PAT and make 5 different calls
- [ ] Hit the rate limit intentionally and observe the headers
- [ ] Write a GraphQL query to list repos with their last push time across an org
- [ ] Use the Octokit SDK to automate a multi-step workflow
- [ ] Query the audit log via API and filter for specific events

## Notes

