# GitHub Enterprise Cloud vs GitHub Enterprise Server

## Quick Comparison

| | GHEC | GHES |
|---|---|---|
| **Hosting** | GitHub-hosted (SaaS) | Self-hosted (customer infrastructure) |
| **Updates** | Always up-to-date, latest features immediately | Customer controls updates, periodic releases |
| **Scaling** | Automatic, no infra maintenance | Customer manages and scales |
| **Best for** | Minimal ops overhead, rapid new features | Control over data residency, networking, compliance |

---

## GHEC (GitHub Enterprise Cloud)

### What it is
- SaaS product hosted and managed by GitHub
- Accessed via github.com with enterprise-level features on top

### Key features
- **Enterprise Managed Users (EMU)** - IdP-controlled accounts, no personal GitHub account needed
- **Data residency** - choose region (US, EU, Australia) for data storage
- **IP allow lists** - restrict access to specific IP ranges
- **SAML SSO** - enforce identity provider authentication
- **Audit log streaming** - send logs to SIEM (Splunk, Datadog, etc.)
- **GitHub Connect** - optionally link to GHES instances
- **Actions hosted runners** - GitHub-managed, larger runners available
- **99.9% SLA** - guaranteed uptime

### When customers choose GHEC
- Want GitHub to handle infrastructure
- Need latest features as soon as they ship
- Comfortable with cloud-hosted data (with residency options)
- Want to reduce operational burden on their team

---

## GHES (GitHub Enterprise Server)

### What it is
- Self-hosted appliance (VM image) deployed on customer's own infrastructure
- Runs on VMware, AWS, GCP, Azure, or bare metal
- Completely isolated from github.com

### Key features
- **Full network control** - can run air-gapped, behind firewalls, VPN-only
- **Data sovereignty** - all data stays on customer hardware, any location
- **Custom auth** - LDAP, SAML, CAS, or built-in authentication
- **Backup utilities** - `ghe-backup-utils` for disaster recovery
- **Clustering** - high availability and horizontal scaling (enterprise only)
- **Release cadence** - new feature releases every ~3 months, patch releases more frequently
- **Management Console** - web UI for appliance configuration
- **SSH admin access** - `ghe-*` CLI tools for troubleshooting

### When customers choose GHES
- Regulatory requirements demand on-premises data
- Need air-gapped or fully isolated environments
- Want complete control over update timing
- Have strict network/firewall policies
- Government, finance, defence, healthcare common verticals

---

## Key Differences for CRE

| Area | GHEC | GHES |
|------|------|------|
| **Troubleshooting** | GitHub Support handles infra | Customer manages infra, CRE helps with app-level issues |
| **Logs** | Audit log API, streaming | SSH access to logs, support bundles |
| **Upgrades** | Automatic | Customer plans and executes (CRE may advise) |
| **Downtime** | GitHub manages incidents | Customer responsible for HA/DR |
| **Feature parity** | Always latest | Lags behind GHEC by weeks/months |
| **Auth** | SAML SSO, EMU | LDAP, SAML, CAS, built-in |
| **Actions** | GitHub-hosted + self-hosted runners | Self-hosted runners only |
| **Packages** | GitHub Packages (cloud) | GitHub Packages (local storage) |

---

## Common CRE Scenarios

**GHEC customer asks:** "Why don't I see feature X?"
- Check if it's EMU-only or requires specific plan tier
- Check if data residency region affects availability

**GHES customer asks:** "Why don't I see feature X?"
- Check their GHES version (`/stafftools` or Management Console)
- Feature may not have shipped to GHES yet
- May need upgrade to latest release

**Migration questions:**
- GHES to GHEC is common (cloud adoption)
- Tools: `gh-migrator`, GitHub Enterprise Importer (GEI)
- Key concerns: CI/CD pipelines, self-hosted runners, SSO reconfiguration

---

## Version Info (as of 2026)

- GHES releases: 3.x series (check [enterprise.github.com](https://enterprise.github.com) for latest)
- GHEC: continuously deployed
- Feature flags may gate new features on both platforms
