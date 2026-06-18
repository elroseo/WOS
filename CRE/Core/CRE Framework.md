---
tags:
  - "#CRE"
  - "#Principles"
URL: https://github.com/github/customer-reliability-engineering/blob/main/career/cre-framework.md
---


## Summary

Brief summary of what this page covers.

## Key Points

- 

## Notes

# CRE Framework

> **Pillar**: Career — CRE growth, frameworks, and responsibilities
>
> **Audience**: All GitHub teams, leadership, and cross-functional partners who want to understand how CREs operate

The CRE Framework is the operating model that connects CRE career development, customer delivery, and tooling into a single system. It defines _how_ CREs develop expertise, _what_ they deliver, and _what tools_ enable them to do it efficiently. OARs (Objectives, Accountabilities, Results) measure success — the framework is the structure that produces it.

---

## Six pillars of CRE development

CRE growth is organized around six specialization pillars, each aligned to a strategic initiative. CREs develop expertise across all six, but specialization in specific pillars is expected as career level increases.

| Pillar | Project | Focus |
|--------|---------|-------|
| **Mentorship** | Ascend | Peer networking, knowledge sharing, career growth for CREs and cross-functional peers |
| **Technical** | Hyperscale | Deep product expertise, system diagnostics, customer needs heard and addressed |
| **Collaboration** | Conduit | CRE role clarity, cross-functional alignment with CSM, CSA, Sales, Engineering, Services |
| **Program** | Beacon | Reduce toil through optimized tooling, automation, and process improvement |
| **Innovation** | Atlas | CRE impact clarity by product area, strategic product influence, feature advocacy |
| **Customer** | Oracle | Reduce unexpected problems through proactive engagement, crisis prevention, reliability assurance |

Each pillar has three career tiers (corresponding to CRE, Senior CRE, and Staff CRE levels). Progression through tiers reflects increasing scope of impact — from individual account delivery to program-wide ownership and cross-organizational influence.

### How the pillars connect to daily work

The pillars are not abstract categories. Every CRE activity maps to one or more pillars:

- A **[health check](../stabilize/health-checks.md)** is Technical + Customer
- A **retrospective** after an Urgent ticket is Innovation + Collaboration
- **Filing [customer feedback](../advocate/customer-feedback.md)** for a product gap is Innovation + Customer
- **Building a KQL investigation query** that the whole team uses is Program + Technical
- **Mentoring a new CRE** through their first QBR is Mentorship + Customer
- **Presenting at a CRE team meeting takeover** is Mentorship + Technical

---

## Tooling ecosystem

CREs operate across a connected set of tools purpose-built for proactive, data-informed customer engagement. The tooling reduces toil, surfaces signals early, and enables CREs to spend more time on strategic work rather than manual investigation.

### CRE Dashboard

The [CRE Dashboard](https://cre-dashboard.githubapp.com/) is the centralized interface between _all Hubbers_ and CRE-related efforts. It provides a single, easy-to-consume view of a customer's reliability story: recent incidents, emerging patterns, risks, and follow-through on past commitments.

Key capabilities:
- **Customer overview** — environment summary, recent activity, support status, metrics
- **[Monthly reporting](../elevate/monthly-reporting.md)** — structured summaries with CHIP ratings, ticket analysis, and opportunities to elevate
- **Action items** — tracked tasks with due dates, status, and resolution summaries
- **Meeting history** — logged discussions, decisions, and follow-ups
- **[TAH tracking](../stabilize/technical-advisory.md)** — Technical Advisory Hours usage and remaining balance
- **Automated insights** — CRE-agent (Copilot-backed) distills prior month data into leadership-ready Top Tier Account Reports (TTARs)

The dashboard is accessible to all GitHubbers via Okta and is designed to enable Sales, CSMs, CSAs, and leadership to understand CRE value and customer posture without needing to contact the CRE directly.

### Investigation tooling

CREs use AI-assisted investigation tools to analyze customer data across multiple sources:

| Tool | Purpose |
|------|---------|
| **[KQL query library](https://github.com/github/llm-assist/tree/main/saved-queries)** | Standardized Kusto/ADX queries for customer metrics, telemetry, ticket analysis, and pillar-specific investigations |
| **[LLM-Assist](https://github.com/github/llm-assist/tree/main/.github)** | Copilot-powered skills and prompts for natural language investigation — ticket hunting, bundle analysis, QBR generation, upgrade after-action reports, and account planning |
| **Splunk** | Operational log investigation for GHES environments |
| **ESB-Tools** | Support bundle analysis — node health, service status, known issues, upgrade readiness |
| **gheboot** | Spin up test GHES environments (HA clusters, DR setups, geo-replication) for validation and reproduction |

LLM-Assist integrates multiple data sources (Kusto, Splunk, ESB, Zendesk, GitHub Issues, CRE Dashboard) through a single Copilot interface. Skills range from ad-hoc query execution to structured investigation playbooks and full report generation.

### Operational tools

| Tool | Purpose |
|------|---------|
| **Zendesk** | Ticket tracking, SLA monitoring, customer communication |
| **ChatOps** | Live troubleshooting reference and command lookup |
| **GitHub Actions** | Automated ticket tagging, customer tracking, notification workflows |
| **Server Upgrade Assistant** | GHES upgrade path assessment and planning |
| **ghe-metrics** | CPU load analysis, log aggregation, performance pattern identification |
| **Project Boards** | Track customer assignments, CRE projects, and team initiatives |

---

## How the framework connects

The framework is not a set of disconnected tools and processes. Each layer feeds into the next:

```
    ┌────────────────────────────────────────────┐
    │ 6 Pillars — Define specialization & growth │
    └─────────────────────┬──────────────────────┘
                          │
          ┌───────────────┼────────────────┐
          ▼               │                ▼
    ┌───────────┐         ▼         ┌────────────┐
    │    CRE    │    ┌─────────┐    │ LLM-Assist │
    │ Dashboard │    │   KQL   │    │  Skills &  │
    └─────┬─────┘    │  Query  │    │  Prompts   │
          │          │ Library │    └──────┬─────┘
          │          └────┬────┘           │
          └───────────────┼────────────────┘
                          ▼
        ┌────────────────────────────────────┐
        │ Customer Data:                     │
        │   Zendesk, Splunk, GitHub Issues,  │
        │   ESB, CRE Dashboard API, Kusto    │
        └─────────────────┬──────────────────┘
                          ▼
        ┌────────────────────────────────────┐
        │ Outputs:                           │
        │   Monthly Reports, Account Plans,  │
        │   Health Checks, Retrospectives,   │
        │   Customer Feedback, QBRs, TTARs   │
        └────────────────────────────────────┘
```

- **Pillars** guide what a CRE focuses on developing
- **Tooling** enables efficient investigation and reporting
- **Delivery cadence** (detailed in [CRE Responsibilities](cre-responsibilities.md)) ensures consistent, predictable output
- **Outputs** demonstrate CRE value to the customer and to GitHub leadership

---

## Career progression within the framework

CRE career progression is documented in the [career resources](../resources/) folder. The framework shapes how progression works:

| Level | Framework expectation |
|-------|----------------------|
| **CRE** | Deliver across all six pillars for assigned accounts. Build depth in Technical and Customer pillars through direct account work. |
| **Senior CRE** | All CRE expectations plus mentoring, escalation assistance for non-assigned accounts, process improvement contributions, and demonstrable impact across Mentorship and Collaboration pillars. |
| **Staff CRE** | All Senior CRE expectations plus ownership of a program-wide responsibility area. Staff CREs choose a specialization path — Advanced Technical Leadership, Strategic Customer Engagement, Mentorship & Team Leadership, or Program Development & Management. |

The FY26 strategy positions CRE as a **Senior+ function**, staffed by Senior and Staff-level CREs who bring deep technical expertise and strategic customer engagement capabilities.

---

## How other teams interact with the CRE Framework

| Team | What to know |
|------|-------------|
| **Sales / Account Executives** | The CRE Dashboard surfaces customer health, CRE deliverables, and risk signals. TTARs and monthly reports are available without contacting the CRE directly. |
| **CSMs** | CRE monthly reports and QBR contributions feed directly into renewal and expansion conversations. Alignment on customer expectations prevents conflicting promises. |
| **CSAs** | CREs focus on reliability; CSAs focus on solution architecture. The boundary is important — CREs refer architecture and implementation work to CSAs. |
| **Engineering / Product** | CREs file [customer feedback](../advocate/customer-feedback.md) with business impact framing, surface product gaps through Innovation pillar work, and produce retrospectives that identify upstream fixes. |
| **Support Engineers** | SEs own reactive tickets. CREs provide environment context, join calls for temperature management, and produce retrospectives that identify empowerment opportunities. |
| **Expert Services** | Work exceeding CRE scope (extended consulting, custom development, architecture reviews) is referred to Expert Services. Clean handoffs start with the CRE identifying the boundary early. |

---

## FAQ

**What is the difference between the framework and OARs?**

OARs define _what to deliver_ and _how success is measured_ (95% IR, 4.65 CSAT, monthly summaries on time). The framework defines _how CREs develop expertise_ (six pillars), _what tools they use_ (dashboard, KQL, LLM-Assist), and _what processes they follow_. OARs are the scorecard; the framework is the operating model.

**Where does the CRE Framework live?**

The framework is distributed across several locations: the [CRE Wiki](https://github.com/github/customer-reliability-engineering/wiki) contains operational playbooks and process documentation; the [CRE Dashboard](https://cre-dashboard.githubapp.com/) is the centralized customer management interface; the [customer-reliability-engineering](https://github.com/github/customer-reliability-engineering) repository holds GitHub-wide facing documentation; and [LLM-Assist](https://github.com/github/llm-assist) repositories contain investigation tooling.

**How do I know which pillar to focus on?**

All CREs operate across all six pillars through their daily work. Specialization becomes more important at Senior and Staff levels. Talk to your manager about which pillars align with your career goals and where the team has gaps.

**Is the tooling ecosystem required or optional?**

The CRE Dashboard is required — it is where monthly reports, customer data, and action items are tracked. KQL and LLM-Assist are strongly encouraged and increasingly central to efficient CRE delivery, but adoption scales from casual (quick queries) to power user (multi-source investigations and automated report generation).