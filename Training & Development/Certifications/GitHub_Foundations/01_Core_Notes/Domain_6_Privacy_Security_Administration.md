# Domain 6 — Privacy, Security, and Administration

## Authentication methods

| Method | Use |
|---|---|
| Username + password | Basic sign-in (must add 2FA) |
| **2FA / MFA** | Second factor (TOTP app, SMS, security key); GitHub now requires it for many contributors |
| **Passkeys** | Passwordless sign-in |
| **SSH keys** | Authenticate Git operations over SSH |
| **Personal Access Tokens (PATs)** | Tokens for HTTPS Git, API, CLI |
| GPG/SSH signing keys | **Verify** commit/tag authorship (signing ≠ authentication) |

### Personal Access Tokens

| Type | Notes |
|---|---|
| **Fine-grained PAT** | Scoped to specific repos + granular permissions, with expiry (recommended) |
| **Classic PAT** | Broad scopes across all your repos (legacy) |

> Treat tokens like passwords. Prefer fine-grained PATs with the least privilege and an expiration date.

## Repository permission levels

| Role | Key abilities |
|---|---|
| **Read** | View, clone, pull, open issues/PRs |
| **Triage** | Manage issues/PRs (labels, assign, close) without code write |
| **Write** | Push to non-protected branches |
| **Maintain** | Manage the repo without destructive/sensitive settings |
| **Admin** | Full control incl. settings, access, delete |

Access can be granted to **individuals**, **teams**, or **outside collaborators** (people outside the org given access to specific repos).

## Organization & enterprise admin

| Concept | Detail |
|---|---|
| Org **Owner** | Full admin over the organization |
| Org **Member** | Standard member |
| **Teams** | Nestable groups used to manage access at scale; can sync with IdP groups |
| Base permissions | Default access members get to org repos |
| **SAML SSO / SCIM** | Enterprise identity & automated provisioning (GHEC) |
| **Audit log** | Record of who did what, when (org/enterprise) |

## Security features

| Feature | What it does |
|---|---|
| **Dependabot alerts** | Warn about vulnerable dependencies |
| **Dependabot security updates** | Auto-open PRs to fix vulnerable deps |
| **Dependabot version updates** | Keep dependencies up to date (`dependabot.yml`) |
| **Dependency graph** | Maps the project's dependencies |
| **Code scanning (CodeQL)** | Static analysis to find vulnerabilities/errors in code |
| **Secret scanning** | Detects committed secrets/credentials; push protection blocks them |
| **Security advisories** | Privately discuss, fix, and disclose vulnerabilities (CVE) |
| **`SECURITY.md`** | Tells people how to report vulnerabilities |

> **GitHub Advanced Security (GHAS)** bundles code scanning, secret scanning, and dependency review for private/enterprise repos. Many features are **free on public repos**.

## Branch protection & rulesets

Protect important branches by requiring:
- Pull request reviews (and approvals) before merge
- Status checks to pass
- Up-to-date branches, signed commits, linear history
- Restrictions on who can push

**Rulesets** are the newer, more flexible way to apply these rules (and can target multiple branches/tags).

## Exam traps

1. **Signing keys verify identity; they don't authenticate sign-in.** SSH keys/PATs authenticate.
2. **Fine-grained PATs > classic** — scoped, least-privilege, expiring.
3. **Triage and Maintain** are the "in-between" roles people forget (Read < Triage < Write < Maintain < Admin).
4. **Dependabot has three modes**: alerts, security updates, version updates.
5. **Secret scanning push protection** can block a secret *before* it's committed.
6. **Outside collaborator** = access to specific repos without org membership.

## Checklist

- [ ] List authentication methods and what signing keys are for
- [ ] Distinguish fine-grained vs classic PATs
- [ ] Order the 5 repository roles and their abilities
- [ ] Name the Dependabot modes + code/secret scanning
- [ ] Describe branch protection / rulesets and the audit log
