---
customer: Slack
bundle_id: 203793
ghes_version: 3.20.5
zendesk: 4651782
status: engineering-confirmation-required
date: 2026-08-12
tags:
  - ghes
  - support-insight
  - merge-queue
---

# GitHub Enterprise Server Bundle Analysis: 203793

### 🚀 Quick Workaround

> **Confidence:** REPORTED for per-pull-request recovery

Disable and re-enable auto-merge on an affected pull request. Slack reported that this cleared the stuck state on the first reported pull request. Engineering reports the same workaround for the related cached merge-state defect.

**Validate:** Confirm the pull request enters the merge queue and remains enabled after the next merge-state evaluation.

**Risk:** This handles individual pull requests only. It does not prevent recurrence and may not recover every affected pull request.

## Executive Summary

Slack reports that pull requests stopped entering the merge queue after the upgrade to GitHub Enterprise Server 3.20.5, although approvals and required checks were satisfied. The issue expanded beyond the initially reported pull request and repository. The customer-facing symptom is not caused by the Elasticsearch, Kafka-lite, backup, certificate, or webhook-table findings in ghe-probe.

The strongest available evidence identifies the direct failure mechanism: affected `AutoMergeJob` executions receive `UnknownMergeState`, retry until the retry limit, and then disable auto-merge as `:not_mergeable`. The leading upstream hypothesis is a race between auto-merge evaluation and mergeability recomputation, tracked in pull-requests#25737 and its predecessor #23847. A separate GitHub Enterprise Server 3.21.4 incident traced a similar blocked merge queue symptom to a stale cached merge commit and `before_oid` mismatch, but engineering now notes that case returned `blocked`, whereas Slack's jobs remain at `unknown`.

**Overall assessment:** Observed retry-exhaustion signature; upstream cause unconfirmed. Engineering should determine whether the 3.20.5 behavior matches the unknown-state race before selecting a mitigation.

## Key Findings

| Finding                                                                         | Severity      | Status                                                                                  | Evidence Source                                                 |
| ------------------------------------------------------------------------------- | ------------- | --------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| Auto-merge jobs repeatedly receive `UnknownMergeState` and exhaust retries      | High          | OBSERVED incident signature; counts are documented in the engineering escalation        | Zendesk #4651782; engineering escalation #1457 bundle summaries |
| Auto-merge evaluation races mergeability recomputation while state is `unknown` | High          | POSSIBLE leading upstream hypothesis                                                    | repos-security#1457; pull-requests#25737 and #23847             |
| Stale cached test-merge commit / `before_oid` mismatch                          | Medium        | POSSIBLE alternative, but less aligned because the parallel incident returned `blocked` | repos-security#1457; pull-requests#5433; CPRMC playbook         |
| Disabling and re-enabling auto-merge may recover an individual pull request     | Medium        | REPORTED workaround from one pull request                                               | Zendesk #4651782 customer report                                |
| General appliance capacity is healthy                                           | Informational | OBSERVED                                                                                | Bundle 203793 diagnostics and ghe-probe                         |
| Elasticsearch/Kafka/backup/certificate findings are separate risks              | Informational | OBSERVED, not material to merge queue symptom                                           | Bundle 203793 diagnostics and ghe-probe                         |

## Bundle and Ticket Information

- **Bundle ID**: 203793
- **Installation**: `slack-github.com`
- **GitHub Enterprise Server Version**: 3.20.5
- **Bundle Date**: 2026-08-12
- **Topology**: HA primary with one replica
- **Primary Capacity**: 192 CPUs and 1,519,765 MiB memory
- **Zendesk**: [#4651782](https://github.zendesk.com/agent/tickets/4651782), open, high priority
- **Reported symptom**: Mergeable pull requests remain waiting for requirements and do not enter the merge queue.
- **Onset**: First known occurrence on the first business day after the 3.20.5 upgrade.
- **Known affected pull requests**: Customer supplied multiple examples, including one captured close to bundle 203793.

## Evidence and Analysis

### Finding 1: AutoMergeJob retry exhaustion disables auto-merge

**Classification**: Incident mechanism  
**Confidence**: OBSERVED

The Slack escalation reports repeated `AutoMergeJob::UnknownMergeState` exceptions. Bundle analysis recorded in the engineering escalation reports retries reaching and exceeding the 20-attempt limit. After exhaustion, `auto_merge_request.disable(:not_mergeable)` disables auto-merge until a user re-enables it.

The ticket independently confirms the visible effect:

- The pull request is `mergeable: true`.
- The merge UI reports that merging is blocked or waiting for requirements; this is presentation text, not evidence that the underlying merge-state enum is `blocked`.
- The required review and Buildkite status are satisfied.
- Disabling and re-enabling auto-merge recovered the first reported pull request.
- A second and then additional pull requests showed the same behavior.

The engineering escalation's bundle-203793 analysis documents 360 `UnknownMergeState` exceptions, 337 retried jobs, 19 stopped jobs plus one job at attempt 21, zero successful auto-merges in the bundle window, and spread to three repositories. These counts are preserved in repos-security#1457 and are the source of record for this report.

**Causation chain**:

```text
[Pull request does not enter merge queue]
  <- [auto-merge is disabled as :not_mergeable]
  <- [AutoMergeJob exhausts retries]
  <- [merge-state evaluation repeatedly returns unknown]
```

**Counter-hypothesis**: A missing or failed required check could produce a blocked pull request. The customer confirmed the configured required status was passing, no code-scanning rule applied, and toggling auto-merge refreshed the state without changing branch protection. This makes a missing-check configuration less likely.

### Finding 2: An unknown-state recomputation race is the leading hypothesis

**Classification**: Root-cause hypothesis  
**Confidence**: POSSIBLE

Engineering linked the Slack examples more closely to [pull-requests#25737](https://github.com/github/pull-requests/issues/25737), which tracks `AutoMergeJob::UnknownMergeState` on GitHub Enterprise Server. In that mechanism, a review or similar event triggers auto-merge evaluation while the pull request's cached mergeability is still `unknown` and its merge commit is being recomputed. The job raises `UnknownMergeState`, retries, and can eventually disable auto-merge as `:not_mergeable`.

This matches Slack's exact exception class, retry exhaustion, and recovery after forcing a fresh evaluation. The related [pull-requests#23847](https://github.com/github/pull-requests/issues/23847) tracks the same broader defect: auto-merge should not disable itself when mergeability is temporarily unknown.

**Counter-hypothesis: cached `before_oid` mismatch.** A parallel GitHub Enterprise Server 3.21.4 escalation compared the cached merge commit's first parent with the current branch base and found they differed. `RuleEngine::StatusCheckEvaluator` then evaluated unrelated status contexts and returned a blocked state.

The mechanism has historical precedent:

1. [pull-requests#5433](https://github.com/github/pull-requests/issues/5433) documented stale `merge_commit_sha` behavior in 2022. Engineering showed that when the base branch advanced before the background merge-commit job refreshed the cached merge commit, the old base parent no longer matched `before_oid`; unrelated checks were evaluated.
2. [github#234851](https://github.com/github/github/pull/234851) changed merge box rendering so it only displays merge-commit checks when the decision basis equals the pull request's merge commit. That fixed presentation for the earlier incident but does not by itself prove the current merge queue state path is fixed in 3.20.5.
3. The [CPRMC caching playbook](https://github.com/github/pull-requests/blob/main/first-responder/merge-commit-caching.md) states that cached merge commits refresh on head change, merge-base change, merge attempt, or an eligible read after cache expiry.
4. In [repos-security#1457](https://github.com/github/repos-security/issues/1457), engineering reports that enabling `use_cached_before_oid` on a staging GitHub Enterprise Server 3.21.4 installation prevented reproduction.

Slack's reported workaround also fits the caching mechanism: toggling auto-merge triggers a fresh evaluation and can clear the stale state.

However, engineering explicitly distinguishes the incidents: the `before_oid` case returns `blocked`, while Slack remains at `unknown`. This makes the recomputation race a closer match, but neither upstream cause is confirmed for GitHub Enterprise Server 3.20.5. Engineering also reports that `auto_merge_proceed_on_unknown_merge_state` is not currently a viable customer mitigation because its rollout exposed another mergeability dependency.

**Counter-signal: persistent rather than transient state.** The bundle-203793 summary reports that 133 of 337 retries occurred at attempt 1 and interprets the pattern as persistently stuck merge state rather than a transient computation delay. This weakens a simple short-lived race explanation and requires engineering to inspect the recomputation timeline before confirming the hypothesis.

**Ruled-out version-specific alternative: Spokes permissions.**  
**Confidence: OBSERVED.**

pull-requests#25737 also documents `git-merge-tree` permission failures in the gitrpcd/Spokes container after the Ubuntu Focal-to-Noble base-image change. Engineering scopes that mechanism to GitHub Enterprise Server 3.21 and later in [git-systems#6542](https://github.com/github/git-systems/issues/6542) and [git-systems#6672](https://github.com/github/git-systems/issues/6672). Bundle 203793 is version 3.20.5, so that specific permission mechanism is unlikely to explain this incident.

### Finding 3: Appliance capacity is not the bottleneck

**Classification**: Ruled-out capacity hypothesis  
**Confidence**: OBSERVED

Bundle 203793 reports:

- 15-minute load: 50.01 on 192 CPUs, a load/CPU ratio of 0.26
- average Unicorn worker utilization: 31.42%
- average gitauth worker utilization: 5.3%
- Elasticsearch cluster: green
- no HAProxy maxconn saturation
- no MySQL connection-limit errors
- no out-of-memory kills

The load/CPU ratio is below 0.5, so CPU capacity is not the bottleneck. The incident is feature-state specific rather than appliance-wide saturation.

### Finding 4: Other ghe-probe failures are separate operational risks

**Classification**: Non-material observations for this incident  
**Confidence**: OBSERVED

Bundle 203793 also reports:

- unaliased duplicate Elasticsearch indices (`commits-2`, `pull-requests-3`)
- five Kafka-lite partitions with committed offsets below retained data
- no recent backup-utils attempts in appliance diagnostics
- expired certificates in the custom CA inventory
- large webhook tables with daily pt-archiver jobs

None of these findings participates in the merge queue merge-state path. They should be handled separately and must not be presented as the cause of stuck auto-merge jobs.

## Recommendations

### Immediate

1. Try the reported per-pull-request workaround: disable and re-enable auto-merge, then verify queue entry. It has been reported successful for one affected pull request but is not yet validated across the incident.
2. Keep [repos-security#1457](https://github.com/github/repos-security/issues/1457) and Zendesk #4651782 linked. The engineering issue already includes the Slack 3.20.5 report.
3. Ask Repos Security engineering to compare, for an affected Slack pull request:
   - whether auto-merge evaluation began while mergeability was `unknown`
   - the mergeability recomputation timing and triggering event
   - cached merge commit first parent, current branch base SHA, and evaluated `before_oid` to rule in or out the alternative cached-parent defect
   - whether the fix tracked in pull-requests#23847 is present in 3.20.5

### Engineering-managed mitigation

Do not advise the customer to enable internal feature flags directly. Engineering should determine whether a supported backport, hotpatch, or repository-level mitigation is appropriate. Do not recommend `auto_merge_proceed_on_unknown_merge_state`; engineering reports it is not a viable mitigation. The CPRMC playbook describes repository opt-out as a last-ditch, temporary mitigation that requires Pull Requests team coordination.

### Separate health follow-up

Track the Elasticsearch alias state, backup verification, Kafka offset range, and expired custom CAs outside this incident. These do not block the merge queue investigation.

## Validation Summary

- **Causation**: The retry-exhaustion signature is observed. The cached unknown-state recomputation race is the leading upstream hypothesis. The cached `before_oid` defect is an alternative confirmed only in the parallel 3.21.4 investigation.
- **Supportability**: Customer guidance is limited to the reported UI workaround. Feature flags and CPRMC opt-out remain engineering-managed.
- **Commands**: No customer-facing shell command is recommended.
- **Artifact/style**: Technical and style validation passed. Merge readiness remains blocked on engineering confirmation of the upstream cause.

## Follow-Up Actions

### Immediate customer handling

- [ ] Confirm whether toggling auto-merge recovers each newly affected pull request.
- [ ] Record repository, pull request, head SHA, base SHA, and exact timestamp for each recurrence.
- [ ] Update Zendesk #4651782 with engineering's chosen mitigation.

### Recurrence prevention

- [ ] 🏷️ `needs-code-fix` - Determine whether 3.20.5 requires a backport or hotpatch for cached `before_oid` handling.
- [ ] 🏷️ `needs-monitoring` - Alert on repeated `AutoMergeJob::UnknownMergeState` and retry exhaustion.
- [ ] 🏷️ `needs-ghe-probe-check` - Consider detecting sustained `UnknownMergeState` retry exhaustion.

### Investigation gaps

- [ ] **[Blocking]** Confirm whether affected Slack pull requests entered auto-merge evaluation while mergeability recomputation was still `unknown`.
- [ ] **[Blocking]** Confirm whether the fix tracked in pull-requests#23847 is present in GitHub Enterprise Server 3.20.5.
- [ ] **[Non-blocking]** Compare cached merge parent, current base, and `before_oid` on an affected pull request to rule out the alternative defect.

## Prior Art and References

- [Zendesk #4651782](https://github.zendesk.com/agent/tickets/4651782) - Slack incident timeline and reported workaround
- [repos-security#1457](https://github.com/github/repos-security/issues/1457) - active cross-customer engineering escalation
- [pull-requests#5433](https://github.com/github/pull-requests/issues/5433) - origin of the stale merge-commit parent/check-evaluation pattern
- [pull-requests#25737](https://github.com/github/pull-requests/issues/25737) - GitHub Enterprise Server unknown-state retry and recomputation-race escalation
- [pull-requests#23847](https://github.com/github/pull-requests/issues/23847) - canonical auto-merge-on-unknown race and auto-disable defect
- [git-systems#6542](https://github.com/github/git-systems/issues/6542) and [git-systems#6672](https://github.com/github/git-systems/issues/6672) - GitHub Enterprise Server 3.21 Spokes permission alternative
- [github#234851](https://github.com/github/github/pull/234851) - earlier merge box rendering fix
- [CPRMC caching operational playbook](https://github.com/github/pull-requests/blob/main/first-responder/merge-commit-caching.md)
- Slack `#github-slack`, August 10, 2026 - Slack noted merge queue issues after upgrade and linked Zendesk #4651782
- Slack `#support-ops`, August 12, 2026 - bundle 203793 associated with Zendesk #4651782

## Confidence

**Overall confidence**: Medium

The customer-visible retry-exhaustion mechanism has strong supporting evidence. The workaround is reported from one affected pull request. The exact upstream cause remains possible until engineering confirms the recomputation timeline and 3.20.5 fix status. The stale cached-parent defect remains a lower-confidence alternative because its observed terminal state differs.
