# Audit log and compliance

| | |
|---|---|
| **Estimated Time** | 1 hour |
| **Phase** | 3 - Advanced |
| **Priority** | High |
| **Resources** | [Audit log docs](https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/reviewing-the-audit-log-for-your-organization) |
| **Status** | Not Started |
| **Topic Area** | Administration |

## Goal

Understand GitHub's audit log, a critical tool for CRE investigations and a common customer ask.

## Key concepts

- Audit log retention periods (org vs enterprise)
- Audit log streaming to external SIEMs (Splunk, Datadog, S3, Azure Event Hubs)
- Event categories and key event types to know
- Git events vs web UI events
- Querying the audit log via API
- Enterprise audit log access

## Learning tasks

- [ ] Find the audit log at org and enterprise level
- [ ] Query for specific events (e.g., all repo visibility changes in the last 30 days)
- [ ] Set up audit log streaming to a destination
- [ ] Identify which events are git events vs non-git events

## Notes

