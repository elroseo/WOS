# GHAS Deep Dive

## What GHAS is

**GitHub Advanced Security (GHAS) is the historical umbrella term for GitHub's paid security suite.** In current packaging, public docs increasingly split it into **GitHub Code Security** and **GitHub Secret Protection**.

**Customers still say GHAS all the time.** In practice, you should map their question to the current product language, then answer in the older GHAS framing if that helps the conversation.

## Packaging and licensing

### Current packaging model

| Packaging term | What it includes |
| --- | --- |
| **GitHub Secret Protection** | Secret scanning, push protection, and related secret leak prevention capabilities |
| **GitHub Code Security** | Code scanning, premium Dependabot capabilities, dependency review, security overview, security campaigns, Copilot Autofix for code scanning |
| **GitHub Advanced Security** | Bundle term that may include both of the above |

### How licensing works

**Licensing is based on unique active committers to repositories with the product enabled.** The measurement window is **90 days**.

Key points:

- **Public repositories on GitHub.com** get several security features for free
- **Private and internal repositories** need the relevant paid security product
- **Private GHEC usage is not automatically included with the base enterprise seat in public docs**, it is purchased as a security product on top of Team or Enterprise, unless a customer's contract says otherwise
- **GHES uses subscription-style licensing** for these capabilities, and hybrid customers can sync usage between GHES and cloud to avoid unnecessary double-counting

> [!note]
> **CRE translation tip:** if a customer asks whether GHAS is "included," verify whether they mean contract packaging, platform eligibility, or public-repo availability. Those are different answers.

## Code Scanning

### What it does

**Code scanning finds vulnerabilities and coding errors in source code and surfaces them as security alerts.** It can run with **CodeQL** or with third-party tools that upload **SARIF** results.

### Setup choices

| Setup type | Best for | Notes |
| --- | --- | --- |
| **Default setup** | Fast rollout, lower admin overhead | GitHub auto-configures CodeQL scanning, runs on push, PR activity, and a weekly schedule |
| **Advanced setup** | Complex builds and fine-grained control | Customer edits workflows, build steps, queries, runners, and triggers |
| **External CI with SARIF upload** | Existing scanning outside GitHub Actions | Good when customers keep analysis in another CI system |

### CodeQL

**CodeQL is GitHub's code analysis engine.** It treats code like data, builds a database for the codebase, runs queries, and turns the results into alerts.

#### Supported languages

- **C/C++**
- **C#**
- **Go**
- **Java/Kotlin**
- **JavaScript/TypeScript**
- **Python**
- **Ruby**
- **Rust**
- **Swift**
- **GitHub Actions workflows**

#### How it works

1. **Create a CodeQL database** from the codebase
2. **Run CodeQL queries** against that database
3. **Publish results as code scanning alerts** in GitHub

#### Default setup vs advanced setup

| Topic | **Default setup** | **Advanced setup** |
| --- | --- | --- |
| Speed to enable | Fastest | Slower |
| Build customization | Minimal | Full control |
| Query customization | Limited but improving | Full control |
| Best for | Standard repos | Complex monorepos, compiled builds, special runners |

#### Custom queries and CodeQL packs

**Customers can run more than the default query suite.** Additional queries can come from published **CodeQL query packs** or internal packs stored in repositories.

**Model packs** can extend analysis to libraries and frameworks that are not modeled by default. Public docs describe model packs as **public preview**.

### Third-party SARIF integration

**Code scanning is not CodeQL-only.** Third-party analyzers can upload results in **SARIF 2.1.0** and show alerts in the same GitHub experience.

### Copilot Autofix

**Copilot Autofix suggests targeted fixes for supported code scanning alerts.** It uses code scanning context plus LLMs to propose remediation.

Useful conversation points:

- Public docs say it is available for **all public repositories on GitHub.com**
- It is also available for **private or internal repos with GitHub Code Security**
- It does **not** require a separate GitHub Copilot subscription
- It is tied to **CodeQL-based scanning**

> [!note]
> **Version note:** Copilot Autofix reached GA for CodeQL alerts on cloud in 2024 and expanded alert coverage in 2025. GHES availability can lag cloud, verify the target version.

### Pull request checks and enforcement

**Code scanning can show results directly in pull requests.** Alerts appear as annotations and in the **Code scanning results** check.

**Customers can enforce severity-based failures.** By default, high-severity results can fail checks, and admins can tune which severities should block merges.

## Secret Scanning

### What it does

**Secret scanning detects exposed credentials and tokens in repositories.** It helps customers find leaks after the fact and, with push protection, block them before they land.

### Partner patterns vs custom patterns

| Pattern type | What it means |
| --- | --- |
| **Partner patterns** | GitHub-supported secret formats from providers like cloud platforms and SaaS vendors |
| **Custom patterns** | Customer-defined regex patterns for internal secret formats |

**Custom patterns** can be defined at the **enterprise, organization, or repository** level, and can also support **push protection**.

### Push protection

**Push protection blocks supported secrets before the push is accepted.** It is one of the strongest customer-facing prevention stories in the suite.

Important nuances:

- It covers a subset of high-confidence secret patterns
- It may skip very large or complex pushes
- It usually shows only a limited number of detected secrets at a time
- It does not block secrets that already have open alerts in the repo

### Validity checks

**Secret scanning can validate some secret types.** This helps distinguish active from inactive tokens and reduce noisy triage.

### Bypass controls

**Bypass is a control point, not a failure.** Customers can allow bypass paths when a developer believes the secret is intentional, while still creating visibility for security teams.

CRE language to use:

- Block by default where possible
- Allow controlled bypass where necessary
- Monitor bypass activity as a signal

### Non-provider patterns and generic secrets

**Not all secrets are provider-issued tokens.** GitHub also supports broader detection categories such as non-provider patterns and generic secret detection.

Key distinctions:

- **Default alerts** are the main supported and high-confidence pattern set
- **Generic alerts** are broader and can carry more false positives
- Customers should tune workflow expectations accordingly

**AI-detected generic secrets** are best positioned as broader leak coverage, not perfect precision.

## Dependabot

### Dependabot Alerts

**Dependabot alerts flag vulnerable dependencies using the dependency graph plus advisory intelligence.** This is often the first supply chain view customers see.

### Dependabot Security Updates

**Dependabot security updates open pull requests to patch vulnerable dependencies automatically.** It targets the minimum fixed version when possible.

### Dependabot Version Updates

**Version updates keep dependencies current even when there is no known vulnerability.** This is about hygiene, not just urgent patching.

### Dependency graph

**The dependency graph is the foundation.** It parses manifests and lock files, can ingest submitted dependency data, and powers alerts, dependency review, and supply chain visibility.

### Dependency review

**Dependency review shows the security impact of dependency changes in pull requests.** It helps teams catch risky packages before merge, not just after release.

### Grouped updates

**Grouped security updates reduce PR noise.** Dependabot can group vulnerable dependencies by ecosystem, and customers can add more granular grouping rules in `dependabot.yml`.

### Auto-dismiss low impact alerts

**GitHub preset auto-triage rules can auto-dismiss low-impact development-scoped alerts.** Public docs call out an npm-focused preset for development dependencies.

**Important CRE nuance:** this reduces noise, but it is not the same as turning off detection. Auto-dismissed alerts remain visible, reportable, and can reopen if metadata changes.

## Security Overview

**Security overview is the at-scale dashboard.** It helps organizations and enterprises see security posture across repositories instead of repo by repo.

Main value areas:

- **Organization and enterprise dashboards**
- **Risk and coverage views**
- **Enablement and alert trends**
- **Detection, remediation, and prevention metrics**
- **CSV export for deeper analysis**

**Default-branch caveat:** public docs note that security overview metrics are based on the **default branches** of repos the viewer can access.

## Other Security Features

### Private vulnerability reporting

**Private vulnerability reporting gives researchers a structured private way to report vulnerabilities on public repos.** It reduces the risk of unsafe public disclosure.

### Security advisories

**Repository security advisories** let maintainers coordinate, draft, patch, and publish vulnerability disclosures inside GitHub.

### SECURITY.md

**`SECURITY.md` tells users how to report vulnerabilities.** It is basic, but customers appreciate that it sets clear policy and process.

### Repository security settings

**Most of the suite is activated and governed from repository, organization, or enterprise security settings.** The product gets more powerful as customers move from per-repo enablement to policy-driven rollout.

## Suggested customer framing

| Customer need | Lead with |
| --- | --- |
| "Find risky code" | **Code scanning, CodeQL, SARIF, Autofix** |
| "Stop leaked credentials" | **Secret scanning, push protection, custom patterns** |
| "Fix vulnerable packages" | **Dependabot alerts, security updates, dependency review** |
| "Show me risk across the estate" | **Security overview, policies, at-scale enablement** |

> [!note]
> **Version note:** GHAS terminology is evolving. During 2024 and 2025, public docs increasingly shifted from the single GHAS label to **GitHub Code Security** and **GitHub Secret Protection**. Many field conversations still use GHAS as shorthand.

> [!tip]
> **CRE tips**
> - Ask whether the customer wants **detection**, **prevention**, or **remediation**. That maps quickly to the right feature set.
> - Ask whether they are on **GHEC or GHES**, and if GHES, ask the **exact version**.
> - Ask how they want to roll out, **repo by repo**, **org policy**, or **enterprise policy**.
> - For noisy customers, lead with **push protection**, **dependency review**, and **auto-triage**, because noise control matters almost as much as detection.
