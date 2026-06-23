# GitHub Actions Deep Dive

## What it is

GitHub Actions is GitHub's built-in CI/CD and workflow automation platform. Workflows are defined in YAML, triggered by events (push, PR, schedule, manual, etc.), and executed on runners.

## Why it matters

Actions is one of the most common sources of enterprise customer questions. Understanding workflows, runners, secrets, and enterprise patterns is essential for CRE work.

## How Actions benefit dev teams

1. **Frees up time.** Developers write and commit code, but before that they must scan, compile, package, test, and deploy. Actions automates all of this.
2. **Speeds up shipping and lowers risk.** Computers are less error-prone and more efficient at executing routine steps in order. Eliminates manual intervention, saves time for higher-value tasks.

## Runners

Runners are the machines that execute workflows.

### GitHub-hosted runners

- Managed by GitHub in the cloud
- Pre-configured VMs (Ubuntu, Windows, macOS)
- Larger runners available (2-64 vCPU, GPU)
- Charged per minute of compute time
- Per-minute rate varies by OS and machine size

### Self-hosted runners

- Customer-managed machines (on-prem, cloud VMs, containers)
- Free of charge for Actions usage
- Customer responsible for configuration, maintenance, security, and patching
- Actions Runner Controller (ARC) for Kubernetes-based autoscaling

### Free minutes by plan

Every GitHub plan includes a monthly Actions allowance:

| Plan | Free minutes/month | Storage |
|------|-------------------|---------|
| Free | 2,000 | 500 MB |
| Team | 3,000 | 2 GB |
| Enterprise | 50,000 | 50 GB |

After free minutes are consumed, charges accrue per runner type. Pricing details: https://docs.github.com/en/enterprise-cloud@latest/billing/concepts/product-billing/github-actions#per-minute-rates

## Core concepts

### Workflow anatomy

```
Workflow (.yml file)
├── Trigger (on: push, pull_request, schedule, workflow_dispatch...)
├── Job 1
│   ├── runs-on: (runner selection)
│   ├── Step 1: actions/checkout
│   ├── Step 2: run script
│   └── Step 3: use an action
└── Job 2 (can depend on Job 1 via `needs:`)
```

### Key components

| Component | What it does |
|-----------|-------------|
| **Triggers** | Events that start a workflow (push, PR, cron, manual, API) |
| **Jobs** | Groups of steps that run on the same runner |
| **Steps** | Individual tasks (run a command or use an action) |
| **Actions** | Reusable units of code (from Marketplace or custom) |
| **Runners** | Machines that execute jobs |
| **Artifacts** | Files persisted between jobs or after workflow completion |
| **Caches** | Dependency caches to speed up workflows |

### Secrets, variables, and environments

- **Secrets:** encrypted values, masked in logs, scoped to repo/org/environment
- **Variables:** plaintext config values, scoped to repo/org/environment
- **Environments:** deployment targets with protection rules (required reviewers, wait timers, branch restrictions)
- **GITHUB_TOKEN:** auto-generated token scoped to the repo, configurable permissions

### Matrix strategy

Run jobs across multiple configurations (OS, language version, etc.):

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    node: [18, 20, 22]
```

### Concurrency

Prevent duplicate runs or limit parallel jobs:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

## Reusability patterns

| Pattern | Use case |
|---------|----------|
| **Reusable workflows** | Share entire workflow definitions across repos (`workflow_call` trigger) |
| **Composite actions** | Bundle multiple steps into a single reusable action |
| **Starter workflows** | Org-level templates for new repos |

## Security

### OIDC for cloud auth

- Eliminates long-lived cloud credentials
- Workflow requests short-lived token from cloud provider (AWS, Azure, GCP)
- Configured via trust policies on the cloud side

### Permissions

- `GITHUB_TOKEN` permissions configurable per workflow or job
- Default can be set to read-only at org/repo level
- Principle of least privilege recommended

### Enterprise policies

- Restrict which actions can be used (allow list, verified creators only)
- Runner groups with org/repo access controls
- Required workflows (enforce CI across repos)
- Fork pull request policies

## Billing model

- **Included minutes** vary by plan (see table above)
- **Minute multipliers:** macOS = 10x, Windows = 2x, Linux = 1x
- **Larger runners** billed at higher per-minute rates
- **Storage** for artifacts and caches counts toward limits
- **Self-hosted runners** = no per-minute charge

## Enterprise features

- **Runner groups:** scope runners to specific orgs or repos
- **Required workflows:** enforce compliance checks across all repos
- **Actions policies:** control which actions are allowed
- **Audit log:** track workflow runs, secret access, policy changes
- **Larger runners:** up to 64 vCPU for demanding builds
- **GPU runners:** for ML/AI workloads

> [!tip] CRE tips
> - "Why are my Actions slow?" is a top-5 customer question. Check: caching, runner size, unnecessary steps, matrix bloat.
> - Self-hosted runner security: never use self-hosted runners on public repos (fork PRs can execute arbitrary code).
> - OIDC adoption is a quick win for customers still using long-lived cloud keys.
> - Required workflows are powerful for compliance teams but can frustrate developers. Recommend clear communication.
> - Billing surprises often come from macOS runners (10x multiplier) or forgotten scheduled workflows.
