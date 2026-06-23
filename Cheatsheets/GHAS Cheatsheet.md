# GHAS - GitHub Advanced Security

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

## Enabling GHAS

### GHEC
1. Enterprise settings > Policies > enable GHAS
2. Org settings > Security > enable for all/selected repos
3. Per-repo: Settings > Security > enable individual features

### GHES
1. Management Console > Security > enable GHAS
2. Same org/repo-level settings as GHEC
3. Ensure Actions is enabled (required for code scanning)
4. Ensure adequate runner capacity

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
