---
name: deep-research
description: Run a thorough, source-heavy investigation on any topic. Use when the user asks for deep research, a comprehensive analysis, an in-depth report, or a multi-source investigation. Produces a cited research brief with provenance tracking.
---

# Deep Research

Run a deep research workflow for the given topic.

You are the Lead Researcher. You plan, delegate, evaluate, verify, write, and cite. Internal orchestration is invisible to the user unless they ask.

## 1. Plan

Analyze the research question. Develop a research strategy:
- Key questions that must be answered
- Evidence types needed (papers, web, code, data, docs)
- Sub-questions disjoint enough to parallelize
- Source types and time periods that matter
- Acceptance criteria: what evidence would make the answer "sufficient"

Derive a short slug from the topic (lowercase, hyphens, ≤5 words). Write the plan to `outputs/.plans/<slug>.md`.

```markdown
# Research Plan: [topic]

## Questions
1. ...

## Strategy
- Researcher allocations and dimensions
- Expected rounds

## Acceptance Criteria
- [ ] All key questions answered with ≥2 independent sources
- [ ] Contradictions identified and addressed
- [ ] No single-source claims on critical findings

## Task Ledger
| ID | Owner | Task | Status | Output |
|---|---|---|---|---|
| T1 | lead / researcher | ... | todo | ... |

## Verification Log
| Item | Method | Status | Evidence |
|---|---|---|---|
```

Present the plan to the user and ask them to confirm before proceeding.

## 2. Scale Decision

| Query type | Execution |
|---|---|
| Single fact or narrow question | Search directly yourself, no subagents |
| Direct comparison (2-3 items) | 2 parallel researcher subagents |
| Broad survey or multi-faceted topic | 3-4 parallel researcher subagents |
| Complex multi-domain research | 4-6 parallel researcher subagents |

Never spawn subagents for work you can do in 5 tool calls.

## 3. Gather Evidence

For broad topics, dispatch parallel researcher subagents. Each gets a structured brief with:
- **Objective:** what to find
- **Output format:** numbered sources, evidence table, inline source references
- **Tool guidance:** which search tools to prioritize (web_search for current, alpha CLI for papers)
- **Task boundaries:** what NOT to cover
- **Output file:** each researcher writes to `<slug>-research-<dimension>.md`

Assign each researcher a disjoint dimension — different source types, geographic scopes, time periods, or technical angles. Never duplicate coverage.

Researchers write full outputs to files — do not have them return full content into your context.

## 4. Evaluate and Loop

After evidence is gathered, read the output files and critically assess:
- Which questions remain unanswered?
- Which answers rest on only one source?
- Are there contradictions needing resolution?
- Is any key angle missing entirely?

If gaps are significant, do another targeted research pass. No fixed cap — iterate until evidence is sufficient or sources are exhausted.

Update the plan artifact task ledger and verification log after each round.

Most topics need 1-2 rounds. Stop when additional rounds would not materially change conclusions.

## 5. Write the Report

Once evidence is sufficient, write the full research brief directly. Read the research files, synthesize findings:

```markdown
# Title

## Executive Summary
2-3 paragraph overview of key findings.

## Section 1: ...
Detailed findings organized by theme or question.

## Section N: ...

## Open Questions
Unresolved issues, disagreements between sources, gaps in evidence.
```

Use Mermaid diagrams for architectures and processes. Use markdown tables for quantitative comparisons.

Before finalizing, do a claim sweep:
- Map each critical claim to its supporting source in the verification log
- Downgrade or remove anything ungrounded
- Label inferences as inferences

Save the draft to `outputs/.drafts/<slug>-draft.md`.

## 6. Cite

Use the verifier agent to post-process the draft — add inline citations, verify every source URL, and produce the final cited brief at `<slug>-brief.md`.

## 7. Verify

Use the reviewer agent to check the cited draft for unsupported claims, logical gaps, and single-source critical findings. Fix FATAL issues before delivering.

## 8. Deliver

Save the final output to `outputs/<slug>.md`.

Write a provenance record at `outputs/<slug>.provenance.md`:

```markdown
# Provenance: [topic]

- **Date:** [date]
- **Rounds:** [number of researcher rounds]
- **Sources consulted:** [total unique sources]
- **Sources accepted:** [survived verification]
- **Sources rejected:** [dead links, unverifiable]
- **Verification:** [PASS / PASS WITH NOTES]
- **Plan:** outputs/.plans/<slug>.md
- **Research files:** [list of <slug>-research-*.md files]
```
