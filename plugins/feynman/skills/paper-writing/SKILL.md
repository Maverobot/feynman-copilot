---
name: paper-writing
description: Turn research findings into a polished paper-style draft with sections, equations, and citations. Use when the user asks to write a paper, draft a report, write up findings, or produce a technical document from collected research.
---

# Paper Writing

Write a paper-style draft for the given topic.

Derive a short slug from the topic (lowercase, hyphens, ≤5 words). Use this slug for all files.

## Workflow

1. **Outline** — Before writing, outline the draft structure: proposed title, sections, key claims, source material, and a verification log for critical claims/figures/calculations. Write to `outputs/.plans/<slug>.md`. Present to user and confirm before proceeding.

2. **Write** — Use the writer subagent to produce the draft from collected notes and research files. Include at minimum: title, abstract, problem statement, related work, method or synthesis, evidence or experiments, limitations, conclusion.

3. **Cite** — Use the verifier subagent to add inline citations and verify sources.

4. **Quality Check** — Before delivery, sweep the draft for any claim stronger than its support. Mark tentative results as tentative. Remove unsupported numerics.

5. **Deliver** — Save exactly one draft to `papers/<slug>.md`. Use clean Markdown with LaTeX where equations materially help. Use Mermaid for architectures and pipelines. End with a Sources appendix with direct URLs.
