---
tags:
  - ghas
  - security
  - ghec
  - ghes
  - cheatsheet
audience: CRE
updated: 2026-08-13
---

# GHAS - GitHub Advanced Security

## Scope and when to use this

Use this cheatsheet when a customer asks about enabling, licensing, or troubleshooting GitHub Advanced Security (GHAS) features - code scanning, secret scanning, push protection, Dependabot, or security overview - on GHEC or GHES. For the underlying platform differences that affect GHAS availability, see [[GHEC vs GHES Cheatsheet]].

**Platform scope:** Applies to both GHEC and GHES. Where behavior differs, it is called out per feature and in the GHES version table at the end.

## Prerequisites and access

- Organization owner or enterprise admin access (customer-side) to view or change GHAS settings.
- A valid GHAS license/entitlement for the org or enterprise - GHAS is an add-on, not included in the base Enterprise license.
- For GHES: Management Console access, and SSH/appliance access if you need to check configuration at the appliance level (see [[GHES Cheatsheet]]).

## Safety and read-only boundary

CRE's role here is diagnostic and advisory. Enabling or disabling GHAS features, changing security policies, or modifying repository/org settings are customer admin actions performed in their own tenant. Don't make these changes on a customer's production instance yourself - walk them through the steps, or use a sandbox/non-production org if you need to demonstrate the flow.

## What is GHAS?

GitHub Advanced Security (GHAS) is a suite of security features for finding and fixing vulnerabilities in code. It includes:

1. **Code scanning** - finds vulnerabilities in your code (powered by CodeQL)
2. **Secret scanning** - detects leaked credentials/tokens in commits
3. **Dependabot** - alerts on vulnerable dependencies + auto-PRs to fix
4. **Security overview** - org/enterprise-wide security dashboard
5. **Push protection** - blocks secrets before they're committed

GitHub’s Advanced Security products:

- Help organizations shift security left in a way that integrates seamlessly and painlessly into a developer’s workflow
- Prevent secrets and a range of other vulnerabilities from being introduced into code
- Offer on-point, concise suggestions for how to remediate any potential problems
- Provide accurate results, low false positive rates, and the ability to keep developers in the tool they’re already using
---

## GHAS on GHEC vs GHES

| Feature | GHEC | GHES |
|---------|------|------|
| **Code scanning** | ✅ Full (cloud CodeQL) | ✅ Full (runs on Actions runners) |
| **Secret scanning** | ✅ Full | ✅ Full (from GHES 3.1+) |
| **Push protection** | ✅ Full | ✅ Full (from GHES 3.6+) |
| **Dependabot alerts** | ✅ Full | ✅ (needs GitHub Connect or manual sync) |
| **Dependabot updates** | ✅ Auto PRs | ✅ From GHES 3.8+ (needs internet for registries) |
| **Security overview** | ✅ Full | ✅ From GHES 3.5+ |
| **Custom patterns** | ✅ | ✅ From GHES 3.5+ |
| **AI-powered fixes** | ✅ (Copilot Autofix) | ✅ Limited (version-dependent) |
| **Default setup** | ✅ One-click enable | ✅ From GHES 3.9+ |

---

## Licensing

| | GHEC | GHES |
|---|---|---|
| **Included free** | Dependabot alerts, secret scanning (public repos) | Dependabot alerts (with Connect) |
| **GHAS license required** | Code scanning, secret scanning (private repos), push protection, security overview | All GHAS features |
| **Sold as** | Per-committer license add-on | Per-committer license add-on |

**Key point:** GHAS is an add-on purchase for both GHEC and GHES. It's not included in the base Enterprise license.

---

## Code Scanning

### How it works
- **CodeQL** - GitHub's semantic code analysis engine
- Runs as a GitHub Actions workflow (or external CI)
- Analyses code on push, PR, or schedule
- Results appear as PR annotations and in Security tab

### GHEC specifics
- Default setup: one click to enable (no workflow file needed)
- GitHub-hosted runners handle the compute
- Always has latest CodeQL version

### GHES specifics
- Needs Actions enabled on the instance
- Runs on self-hosted runners (resource-intensive)
- CodeQL bundle updated with GHES releases (may lag behind)
- Default setup available from 3.9+
- For older versions: manual workflow configuration required

---

## Secret Scanning

### What it detects
- API keys, tokens, passwords, private keys
- 200+ partner patterns (AWS, Azure, Slack, etc.)
- Custom patterns (regex-based)

### Push Protection
- Blocks pushes containing detected secrets at `git push` time
- User can bypass with justification (logged in audit log)
- Admins see all bypasses in security overview

### GHEC vs GHES differences
- GHEC: always scanning, latest patterns
- GHES: patterns updated with releases, custom patterns from 3.5+
- GHES: push protection from 3.6+
- Both: partner alerts notify the service provider (e.g., AWS revokes key)

---

## Dependabot

### Three components
1. **Dependabot alerts** - notifies about known vulnerabilities in dependencies
2. **Dependabot security updates** - auto-PRs to fix vulnerable versions
3. **Dependabot version updates** - auto-PRs to keep deps current (not security-specific)

### GHEC vs GHES differences

| | GHEC | GHES |
|---|---|---|
| **Advisory database** | Real-time from GitHub Advisory Database | Synced via GitHub Connect (or manual) |
| **Alerts** | Automatic | Needs GitHub Connect enabled |
| **Security updates** | Automatic PRs | From GHES 3.8+ |
| **Version updates** | Full support | From GHES 3.8+ (needs internet access to registries) |
| **Grouped updates** | ✅ | Version-dependent |

**GHES gotcha:** Without GitHub Connect, Dependabot can't access the advisory database. Air-gapped instances need manual vulnerability data import.

---

## Security Overview

Enterprise and org-level dashboards showing:
- Which repos have GHAS enabled
- Open alert counts by severity
- Secret scanning coverage
- Code scanning coverage
- Trends over time

### GHEC vs GHES
- GHEC: always available at enterprise level
- GHES: from 3.5+, progressively more features added each release

---

## Common CRE Scenarios

**"Code scanning is slow"**
- GHES: check runner resources (CodeQL needs 8GB+ RAM, 2+ cores)
- GHEC: check if using default setup vs custom workflow
- Large monorepos may need query suite tuning

**"Secret scanning missed a secret"**
- Check if it's a supported pattern
- Custom patterns may be needed for internal token formats
- Check if push protection was bypassed (audit log)

**"Dependabot alerts not showing on GHES"**
- Verify GitHub Connect is enabled and syncing
- Check `ghe-config app.dependency-graph.enabled`
- Air-gapped? Manual advisory sync needed

**"We want GHAS but we're on GHES 3.4"**
- Many features require 3.5+, push protection needs 3.6+, default setup needs 3.9+
- Strongly recommend upgrading before enabling GHAS

---

## Quick task: enable GHAS for a repository

Use this when a customer asks "how do I turn on GHAS" or you need to walk them through the enablement path.

### GHEC

1. **Enterprise settings > Policies** - confirm GHAS is allowed at the enterprise policy level.
2. **Org settings > Security** - enable GHAS for all repositories, or select specific repositories.
3. **Per-repo: Settings > Security** - enable individual features (code scanning, secret scanning, push protection, Dependabot) if they aren't already turned on at the org level.

### GHES

1. **Management Console > Security** - enable GHAS at the appliance level (requires a valid GHAS license applied to the instance).
2. **Org/repo settings** - same navigation as GHEC, once GHAS is enabled at the appliance level.
3. **Confirm Actions is enabled** - code scanning runs as an Actions workflow; without Actions enabled, code scanning cannot run.
4. **Confirm runner capacity** - CodeQL analysis is resource-intensive (8GB+ RAM, 2+ cores recommended); insufficient runner capacity causes scans to queue or fail.

### Expected result

The repository's Security tab shows the enabled features with an active status, and code scanning/secret scanning start running on the next push or scheduled scan. On GHES, the Management Console should also show a valid GHAS license.

### Verify

- Repo Security tab shows the feature as **enabled**, not just "available."
- Check a recent (or trigger a test) push and confirm a code scanning/secret scanning result appears in the Security tab.
- For push protection, confirm a test secret is blocked at `git push` - use a placeholder/test pattern, never a real credential.

### Errors and recovery

| Symptom | Likely cause | Next step |
|---|---|---|
| Feature toggle is greyed out | Missing GHAS license, or below the required GHES version | Check license status and compare the customer's GHES version against the feature table below |
| Code scanning never runs | Actions not enabled, or (on older GHES versions) no workflow file present | Confirm Actions is enabled; check for a CodeQL workflow file if the version predates default setup |
| Enabled but no alerts appear | First scan hasn't completed yet, or the branch/path is excluded | Check the workflow run status; check any `codeql-config.yml` exclusions |
| Dependabot alerts missing on GHES | GitHub Connect not enabled/syncing | Verify GitHub Connect status; air-gapped instances need a manual advisory import |

### Stop and escalate if

- The customer reports a licensing entitlement mismatch (feature enabled in the UI, but billing shows no GHAS seats) - escalate to the account team, this is not a technical fix.
- Management Console shows GHAS as licensed but the toggle still fails to enable - escalate to GitHub Support with a support bundle.
- Anyone asks you to help bypass push protection for a real, currently-valid secret - don't assist; direct them to rotate the credential first, then address the block.

---

## Quick Reference - Feature Availability by GHES Version

| GHES Version | Features Added |
|---|---|
| 3.1 | Secret scanning |
| 3.4 | Code scanning GA, Dependabot alerts |
| 3.5 | Security overview, custom secret patterns |
| 3.6 | Push protection |
| 3.8 | Dependabot security/version updates |
| 3.9 | Code scanning default setup |
| 3.10+ | Copilot Autofix, grouped Dependabot |

---

## Related links

- [[GHEC vs GHES Cheatsheet]] - platform differences that affect GHAS availability
- [[GHES Cheatsheet]] - `ghe-*` admin commands and Management Console access
- [About GitHub Advanced Security](https://docs.github.com/en/enterprise-cloud@latest/get-started/learning-about-github/about-github-advanced-security)

## Freshness note

GHAS feature availability and licensing details change frequently, and GHAS product naming/packaging has evolved over time (for example, into separate Code Security and Secret Protection offerings). Verify current entitlements and feature availability against the customer's specific GHES release and enterprise license before advising, rather than relying solely on the version table above. Last reviewed: 2026-08-13.
