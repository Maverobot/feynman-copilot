---
name: peer-review
description: Simulate a tough but constructive peer review of an AI research artifact. Use when the user asks for a review, critique, feedback on a paper or draft, or wants to identify weaknesses before submission.
---

# Peer Review

Review the given AI research artifact.

Derive a short slug from the artifact name (lowercase, hyphens, ≤5 words). Use this slug for all files.

## Workflow

1. **Plan** — Outline what will be reviewed, the review criteria (novelty, empirical rigor, baselines, reproducibility, etc.), and any verification checks needed for claims, figures, and metrics. Present the plan to the user and confirm before proceeding.

2. **Gather Evidence** — Use the researcher subagent to gather evidence on the artifact — inspect the paper, code, cited work, and any linked experimental artifacts. Save to `<slug>-research.md`. For small or simple artifacts where evidence gathering is overkill, skip to the review step.

3. **Review** — Use the reviewer subagent with the research file to produce the peer review with inline annotations. The review should include structured assessment (strengths, weaknesses with severity levels, questions for authors, verdict) AND inline annotations quoting specific passages.

4. **Iterate** — If the review finds FATAL issues and you fix them, run one more verification-style review pass before delivering.

5. **Deliver** — Save exactly one review artifact to `outputs/<slug>-review.md`. End with a Sources section with direct URLs for every inspected external source.
