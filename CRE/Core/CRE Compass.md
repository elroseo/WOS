---
tags:
  - CRE
  - Principles
URL: https://github.com/github/customer-reliability-engineering/blob/main/career/cre-compass.md
---
# CRE Compass

> **Pillar**: Career — CRE growth, frameworks, and responsibilities
>
> **Audience**: CREs at all levels, CRE managers, and GitHub teams who want to understand how CREs navigate the role

The CRE Compass is a guide for navigating growth, making judgment calls, and finding your own flow within the role. It builds on the [six pillars](cre-framework.md) by showing how they connect in practice — where AI helps, where humans lead, and how to develop the depth that makes a CRE irreplaceable to their customers.

---

## AI is fuel. The human is the engine.

CREs work in an AI-augmented environment. Copilot, KQL queries, LLM-Assist skills, and the CRE Dashboard automate the gathering — context assembly, ticket triage patterns, data summarization, log analysis. This frees time for the work that only a human can do: judgment, synthesis, and relationship.

The distinction matters because it shapes how CREs should invest their growth:

| What gets automated | What becomes more valuable |
|---------------------|---------------------------|
| Dashboard monitoring | Diagnosing a novel problem no model has seen |
| Routine ticket responses | Trust during a crisis |
| Pattern detection | Knowing which escalation needs urgency |
| Context gathering | Teaching someone how to think, not just solve |

> **Don't automate judgment.** Automate the gathering that gives you _time_ to judge.

The CRE who stays prescriptive will be outpaced by AI on breadth. The CRE who develops irreplaceable depth in two or three pillars while maintaining competence across all six — that's the CRE the customer can't live without.

---

## Finding your flow

There is no single "right way" to use AI or to work as a CRE. The data consistently shows that the most effective CREs find their own flow — a personal workflow that leverages AI where it helps them most, rather than following a prescribed process.

Some CREs are CLI-first. Some live in VS Code Chat. Some are heavy Coding Agent adopters. Some champion PR Review. The pattern is not _which_ tool, but _how naturally_ it fits into the person's existing workflow.

What this means for growth:

- **Watch what works for you, then accelerate it.** If you find yourself writing the same KQL query repeatedly, save it. If Copilot helps you draft retrospectives faster, lean into that. If you prefer building investigation prompts, contribute to [LLM-Assist](https://github.com/github/llm-assist).
- **Don't force a framework.** Instead of asking "How should I use AI?", ask "How am I _already_ using it — and where could I go deeper?"
- **Measure adoption by what people choose to use** — not what they're told to use. Happiness drives innovation. Create the conditions, then get out of the way.

---

## The six pillars in practice

The [six pillars](cre-framework.md) — Mentorship, Technical, Collaboration, Program, Customer, Innovation — are not silos. They converge. A great CRE synthesizes across all of them:

> A health check surfaces a migration risk (**Customer** pillar) that you diagnose technically (**Technical** pillar) and communicate cross-functionally (**Collaboration** pillar) while mentoring a junior CRE through the resolution (**Mentorship** pillar) and documenting the playbook (**Program** pillar) so the team learns from it (**Innovation** pillar). AI helped with the data at every step. The sequence itself — the judgment about what matters and in what order — was entirely human.

### Where AI helps, where humans lead

| Pillar | AI accelerates | Human leads |
|--------|---------------|-------------|
| **Mentorship** | Summarize ticket patterns for coaching; generate training materials from docs; surface SME knowledge gaps from data | Read a mentee's confidence in the room; design a 90-day onboarding journey; build trust through consistent presence |
| **Technical** | Gather reproduction steps across repos; file structured bug reports from logs; monitor dashboards for anomalies | Diagnose novel issues no model has seen; build credibility with Engineering over time; know what "normal" looks like per customer |
| **Collaboration** | Prepare QBR data summaries; aggregate customer signals across tools; draft talking points for sales calls | Translate timelines for a frustrated VP; drive coordination when no one else will; be the most credible technical voice |
| **Program** | Generate templates from repeated workflows; auto-track project board status; summarize cadence call action items | Know when the process is broken, not slow; own a deadline and deliver against it; run a meeting the customer values |
| **Customer** | Pre-load health check data; pattern-match for crisis prevention; surface account risk signals | Deliver a health check the customer acts on; manage temperature during long issues; turn a red account green over months |
| **Innovation** | Automate repetitive personal workflows; prototype tools faster (ship-to-learn); generate data for AI-driven deliverables | Decide what to automate and measure impact; drive team adoption (the hard part); redesign programs around AI (frontier work) |

### The human edges

Each pillar has a human edge — the thing AI cannot replicate:

- **Mentorship**: Teaching how to _think_ about a problem can't be prompted
- **Technical**: Architecture "why" is what enables the hardest diagnoses
- **Collaboration**: Customers see one GitHub — making that real requires judgment
- **Program**: Programs that outlast you require vision, not just velocity
- **Customer**: Crisis trust is earned by humans, not computed
- **Innovation**: P/0 is proof with numbers — measurable, team-wide impact

---

## Decision frameworks

CREs face judgment calls daily. These frameworks help navigate common decision points without creating decision lock.

### When to escalate vs. handle yourself

| Signal | Action |
|--------|--------|
| You've identified the root cause and have a path to resolution | Handle it — own the proactive work |
| The issue requires Engineering code changes or product decisions | Escalate via [customer-feedback](https://github.com/github/customer-feedback) with business impact framing |
| Temperature is rising and the customer needs a trusted voice | Step in for temperature management, but keep SE ticket ownership |
| The work crosses into architecture design or professional services | Refer to CSA or [Expert Services](https://github.com/services) |

### When to use Technical Advisory Hours

[TAH](../stabilize/technical-advisory.md) is a scope lever, not a default. Use it when the work is valuable but outside standard entitlements:
- **Use TAH**: Joining a weekend upgrade bridge, deep non-production log review, extended playbook review
- **Don't use TAH**: Regular cadence calls, health check delivery, Urgent ticket response

If TAH is consistently exhausted early, the engagement model needs re-evaluation — not more hours.

### When to defer vs. deliver a health check

| Situation | Guidance |
|-----------|----------|
| Customer is mid-upgrade or major migration | Defer — the environment is in flux and findings will be stale |
| Customer has an active Urgent ticket affecting the same systems | Defer — focus on resolution first |
| Customer declined the [health check](../stabilize/health-checks.md) | Document the declination, deliver when next requested |
| Customer hasn't submitted a bundle and won't engage | Document the gap in monthly reporting — you can't force participation |

### Navigating cross-functional engagements

| Team | Your role | Their role | Watch for |
|------|-----------|------------|-----------|
| **CSM** | Provide technical risk context for renewal conversations | Own commercial relationship, pricing, expansion | Conflicting promises about CRE availability or scope |
| **CSA** | Refer architecture and implementation questions | Own solution architecture, adoption strategy | Being pulled into design work that belongs with the CSA |
| **Sales** | Surface CRE value through monthly reports and TTARs | Own pipeline, prospecting, deal structure | Being asked to join sales calls without clear CRE relevance |
| **Engineering** | File detailed [customer-feedback](https://github.com/github/customer-feedback) with reproduction steps | Own product fixes, feature development | Customers expecting you to guarantee fix timelines |
| **Expert Services** | Identify when work exceeds CRE scope and refer cleanly | Deliver extended consulting, custom engagements | Absorbing services-level work under TAH when it should be a referral |

---

## Growth across levels

### CRE (Foundation)

Focus on delivering exceptional customer work. Master the operational cadence — cadence calls, health checks, monthly reports, retrospectives. Build depth in the **Technical** and **Customer** pillars through direct account experience.

At this level, AI helps you move faster on the fundamentals: drafting reports, preparing for calls, running queries. The growth edge is learning what the data _means_ — developing the pattern recognition that turns information into insight.

### Senior CRE (Bridge)

Approximately 10–25% of your time shifts to team and program contributions. You're no longer just delivering for your accounts — you're making the team better through mentoring, process improvements, and cross-functional collaboration.

The **Mentorship** and **Collaboration** pillars become critical. Your AI usage matures from individual productivity to team-scale impact: building saved queries others use, writing prompts that become shared workflows, identifying patterns across accounts that inform program decisions.

### Staff CRE (Strategic)

You own a program-wide responsibility area. The shift is from _doing the work_ to _designing how the work gets done_. Staff CREs choose a specialization path — Advanced Technical Leadership, Strategic Customer Engagement, Mentorship & Team Leadership, or Program Development & Management — and drive change beyond their customer set.

At this level, all six pillars should be active, with deep specialization in two or three. The **Program** and **Innovation** pillars differentiate Staff from Senior: Staff own the program, Seniors lead projects within it.

> Think quarters ahead, not just weeks. Shape how the team operates, learns, and scales.

---

## What CREs build

CREs are not just consumers of tools — they build and contribute to the ecosystem that makes the team more effective. Examples of CRE-built contributions:

- **Investigation queries** — Saved KQL queries in the [query library](https://github.com/github/llm-assist/tree/main/saved-queries) organized by customer focus.
- **Copilot skills and prompts** — Reusable investigation workflows in [LLM-Assist](https://github.com/github/llm-assist/tree/main/.github) for ticket hunting, bundle analysis, QBR generation, upgrade after-action reports
- **Account plans and monorepo reviews** — AI-generated, human-validated reports that inform sales conversations and customer strategy
- **Retrospectives and playbooks** — After-action analysis that becomes institutional knowledge, reducing the need for CRE involvement in similar future tickets
- **Process automation** — GitHub Actions workflows, ChatOps commands, and dashboard enhancements that reduce toil for the whole team
- **Team meeting takeovers** — Knowledge sharing sessions where CREs present deep dives on topics they've mastered

Building is how CREs develop the **Program** and **Innovation** pillars. Every query saved, prompt refined, or playbook documented compounds — it makes the next CRE faster, the next investigation clearer, and the next customer interaction more informed.

---

## The convergence moment

The pillars converge. AI doesn't converge. You do.

Your technical depth informs your customer engagement. Your customer insight drives your innovation. Your collaboration makes your mentorship real. The "connecting the dots" moment — the thing the customer draws value from — is irreplaceably human.

AI tools are fuel. They give you time to think, surface data you'd otherwise miss, and handle the repetitive gathering that used to consume hours. But the synthesis — deciding what matters, in what order, for which customer, right now — that's the engine. That's you.

---

## FAQ

**How do I know which pillars to specialize in?**

Start by noticing where you naturally gravitate. If you find yourself mentoring new CREs without being asked, that's the Mentorship pillar. If you're building automation that the team adopts, that's Program. Talk to your manager about aligning your natural strengths with team gaps. Depth in two or three pillars, competence across all six — that's the target.

**What if I'm not comfortable with AI tooling yet?**

Start where you already work. If you're familiar with the terminal, definitely try Copilot CLI. If you're in VS Code, try Copilot Chat. If you review PRs, try Copilot PR Review. The entry point matters less than the habit. Once you find one flow that saves you time, the rest follows naturally.

**How do I avoid decision lock when multiple teams are involved?**

Name the decision that needs to be made, identify who owns it, and propose a path forward. CREs are trusted to coordinate — not to wait for permission. If the decision isn't yours (pricing, product roadmap, architecture), redirect to the owner with context. If it _is_ yours (when to deliver a health check, how to frame a retrospective, whether to join a call), make it and document why.

**What does "connecting the dots" look like in practice?**

It's noticing that a customer's recent Urgent ticket, their upcoming GHES EOL deadline, and their CSM's renewal concern are all the same problem. It's seeing that three different customers hit the same Actions runner scaling issue and filing one customer-feedback issue with all three data points. It's connecting a mentee's question about bundle analysis to a saved query that another CRE built six months ago. AI surfaces the data. You see the pattern.
