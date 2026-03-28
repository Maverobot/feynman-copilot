---
name: source-comparison
description: Compare multiple sources on a topic and produce a grounded comparison matrix. Use when the user asks to compare papers, tools, approaches, frameworks, or claims across multiple sources.
---

Compare sources for: $@

Derive a short slug from the comparison topic (lowercase, hyphens, no filler words, ≤5 words). Use this slug for all files in this run.

Requirements:
- Before starting, outline the comparison plan: which sources to compare, which dimensions to evaluate, expected output structure. Write the plan to `outputs/.plans/<slug>.md`. Present the plan to the user and confirm before proceeding.
- Use the `researcher` subagent to gather source material when the comparison set is broad, and the `verifier` subagent to verify sources and add inline citations to the final matrix.
- Build a comparison matrix covering: source, key claim, evidence type, caveats, confidence.
- Generate charts using Mermaid diagram syntax in markdown. Use Mermaid for method or architecture comparisons.
- Distinguish agreement, disagreement, and uncertainty clearly.
- Save exactly one comparison to `outputs/<slug>-comparison.md`.
- End with a `Sources` section containing direct URLs for every source used.
