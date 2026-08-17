# GHEC Deep Dive

## What it is

**GitHub Enterprise Cloud (GHEC) is GitHub's enterprise SaaS deployment.** GitHub hosts the service, customers manage identities, policy, repositories, and organizations.

**It is the default recommendation for most enterprises.** Customers get the fastest feature velocity, the least infrastructure overhead, and the broadest access to newer GitHub platform capabilities.

## Who it is for

- **Cloud-first enterprises** that want central governance without running GitHub infrastructure.
- **Global engineering orgs** that need multiple organizations, centralized billing, and enterprise-wide policy.
- **Regulated customers** that can meet requirements with SaaS controls, identity integration, auditability, and optionally data residency.

## Core value

| Area | What GHEC gives you | Why it matters |
| --- | --- | --- |
| **Operations** | GitHub runs availability, upgrades, and platform maintenance | Less platform ownership for the customer |
| **Governance** | Enterprise account with policy inheritance across organizations | Consistent controls at scale |
| **Identity** | SAML SSO, OIDC for EMUs, SCIM, team sync, enterprise roles | Easier user lifecycle management |
| **Security** | Audit log, streaming, IP allow lists, security products, policy controls | Better enterprise governance and detection |
| **Velocity** | Fastest access to new cloud-only features | Fewer parity gaps and less waiting |

## Key features

| Feature | What it does | Notes |
| --- | --- | --- |
| **Enterprise Managed Users (EMUs)** | User accounts are provisioned and controlled by the customer's IdP instead of user-owned personal accounts. | Separate enterprise type. Best for strict identity control. |
| **Data residency** | Stores customer code and core user data in a selected region on a dedicated **GHE.com** subdomain. | Public docs currently list **EU, Australia, US, and Japan**. Some billing, support, and limited telemetry data can still live outside region. |
| **Audit log streaming** | Streams enterprise audit events to external tooling for SIEM and long-term analysis. | Good for regulated and security-mature customers. |
| **SAML SSO** | Enforces centralized authentication while users keep personal GitHub.com accounts. | Best fit for standard GHEC, not EMU. |
| **OIDC for EMUs** | Lets Entra-backed EMU enterprises use OIDC for sign-in. | EMU-specific path. |
| **IP allow lists** | Restricts access to enterprise resources from approved IP ranges. | Common control for contractor and office-network policies. |
| **SCIM provisioning** | Automates account lifecycle from the IdP. | Enterprise-level SCIM is for **EMUs**. Non-EMU customers typically use org-level SCIM. |
| **Private networking for hosted compute** | Lets customers use network configurations for GitHub-hosted compute, including Azure private networking for hosted runners. | Important for Actions in controlled environments. |

## EMUs vs regular GHEC

| Topic | **Regular GHEC** | **GHEC with EMUs** |
| --- | --- | --- |
| User identity | Users keep **personal GitHub accounts** | Users sign in with **managed user accounts** created by the enterprise |
| Access model | GitHub account linked to external identity | Enterprise fully owns lifecycle and access |
| Public activity | Users can still operate on GitHub.com outside enterprise policies | Managed users are limited to enterprise-owned work and cannot create public content outside the enterprise |
| Authentication | SAML SSO is common | OIDC or SAML, plus SCIM provisioning |
| Best for | Enterprises that want strong SSO with user flexibility | Enterprises that want strict identity boundary and account ownership |

## Compliance and certifications

**GHEC is the stronger answer when customers ask for GitHub's public compliance posture.** Public GitHub trust materials commonly reference certifications and attestations such as:

- **SOC 1 Type 2**
- **SOC 2 Type 2**
- **SOC 3**
- **ISO/IEC 27001**
- **PCI DSS attestation**
- **CSA assessments and certifications**
- **FedRAMP Tailored** (scope-specific, verify current authorization details)

> [!note]
> **Always verify current scope in the GitHub Trust Center.** Certifications apply to defined services and boundaries, not automatically to every feature or every customer architecture.

## Networking

### Private networking

**Private networking in GHEC mainly shows up around hosted compute, especially Actions runners.** Customers can create network configurations to control outbound access and connect GitHub-hosted compute to private resources.

**Azure private networking for GitHub-hosted runners is a key talking point.** It helps customers keep GitHub-managed CI/CD infrastructure while still enforcing network policy inside their own Azure environment.

### GitHub Connect

**GitHub Connect matters when a customer is hybrid, not when they are GHEC-only.** It bridges GHES to GitHub Enterprise Cloud for selected capabilities like license sync, Dependabot-backed vulnerability data, unified search, and unified contributions.

## Administration hierarchy

**The hierarchy is enterprise account, organizations, repositories.** Repositories belong to organizations, not directly to the enterprise account.

- **Enterprise account** handles top-level billing, policy, roles, and governance.
- **Organizations** own repositories, teams, discussions, packages, and most day-to-day collaboration surfaces.
- **Repositories** hold code and repo-local settings, while still inheriting relevant enterprise and org policy.

## Billing model

**GHEC bills from the enterprise account.** Billing is centralized across the enterprise and its organizations.

Typical bill components:

- **Enterprise seats**, based on unique users in the enterprise
- **Consumption-based usage**, such as overage for Actions or Codespaces
- **Add-on products**, such as Copilot and security offerings

**Payment models vary.** Customers may pay by card, PayPal, Azure subscription, or invoice, depending on how the account was set up.

## Migration paths

### From GHES

**GHES to GHEC is common when customers want less infrastructure and faster feature access.** Public docs support migration to GHEC with **GitHub Enterprise Importer** from **GHES 3.4.1+**.

**For GHE.com specifically, Enterprise Live Migrations are the strategic path for some customers.** Public docs note availability in supported patch releases of **GHES 3.17 and later**, especially to reduce downtime and help with large monorepos.

### From other platforms

**GitHub Enterprise Importer is the default migration story.** Public docs list support for migrations to GHEC from:

- **Azure DevOps Cloud**
- **Bitbucket Server / Data Center 5.14+**
- **GitHub.com**
- **GitHub Enterprise Server 3.4.1+**

## Common positioning

- Choose **regular GHEC** when customers want enterprise governance but are fine with personal GitHub identities.
- Choose **EMU-based GHEC** when customers need strong identity ownership and clean account separation.
- Choose **GHE.com with data residency** when SaaS is acceptable but geography and data handling matter.

> [!tip]
> **CRE tips**
> - Ask whether the customer wants **personal accounts or managed accounts**. That often decides regular GHEC vs EMU.
> - Ask whether the customer means **data residency**, **private networking**, or **full self-hosting**. Those are different requirements.
> - If a customer is comparing GHEC to GHES, lead with **operating model**, not feature lists.
> - For hybrid estates, ask whether they need **GitHub Connect**, **license sync**, or a staged GHES to GHEC migration.
