---
name: source-comparison
description: Compare multiple sources on a topic and produce a grounded comparison matrix. Use when the user asks to compare papers, tools, approaches, frameworks, or claims across multiple sources.
---

# Source Comparison

Compare sources for the given topic.

Derive a short slug from the comparison topic (lowercase, hyphens, ≤5 words). Use this slug for all files.

## Workflow

1. **Plan** — Outline the comparison: which sources to compare, which dimensions to evaluate, expected output structure. Write to `outputs/.plans/<slug>.md`. Present to user and confirm.

2. **Gather** — Use the researcher subagent to gather source material when the comparison set is broad. Use `alpha search` for papers and `web_search` for current context.

3. **Build Matrix** — Create a comparison matrix covering:

| Source | Key Claim | Evidence Type | Caveats | Confidence |
|--------|-----------|---------------|---------|------------|

   Use Mermaid diagrams for method or architecture comparisons. Use markdown tables for quantitative metrics.

4. **Cite** — Use the verifier subagent to verify sources and add inline citations.

5. **Distinguish** — Clearly separate agreement, disagreement, and uncertainty.

6. **Deliver** — Save exactly one comparison to `outputs/<slug>-comparison.md`. End with a Sources section with direct URLs.
