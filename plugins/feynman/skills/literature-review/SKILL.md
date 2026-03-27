---
name: literature-review
description: Run a literature review using paper search and primary-source synthesis. Use when the user asks for a lit review, paper survey, state of the art, or academic landscape summary on a research topic.
---

# Literature Review

Investigate the given topic as a literature review.

Derive a short slug from the topic (lowercase, hyphens, ≤5 words). Use this slug for all files.

## Workflow

1. **Plan** — Outline the scope: key questions, source types to search (papers, web, repos), time period, expected sections, and a task ledger plus verification log. Write the plan to `outputs/.plans/<slug>.md`. Present to user and confirm before proceeding.

2. **Gather** — Use the researcher subagent when the sweep is wide enough to benefit from delegated paper triage. For narrow topics, search directly. Use `alpha search` for papers and `web_search` for current context. Researcher outputs go to `<slug>-research-*.md`. Do not silently skip assigned questions; mark them `done`, `blocked`, or `superseded`.

3. **Synthesize** — Separate consensus, disagreements, and open questions. When useful, propose concrete next experiments or follow-up reading. Use Mermaid diagrams for taxonomies or method pipelines. Use markdown tables for quantitative comparisons across papers. Before finishing the draft, sweep every strong claim against the verification log and downgrade anything that is inferred or single-source critical.

4. **Cite** — Use the verifier agent to add inline citations and verify every source URL in the draft.

5. **Verify** — Use the reviewer agent to check the cited draft for unsupported claims, logical gaps, and single-source critical findings. Fix FATAL issues before delivering. Note MAJOR issues in Open Questions.

6. **Deliver** — Save the final literature review to `outputs/<slug>.md`. Write a provenance record at `outputs/<slug>.provenance.md` listing: date, sources consulted vs. accepted vs. rejected, verification status, and intermediate research files used.
