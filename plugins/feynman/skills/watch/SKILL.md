---
name: feynman:watch
description: Set up a recurring research watch on a topic, company, paper area, or product surface. Use when the user asks to monitor a field, track new papers, watch for updates, or set up alerts on a research area.
---

Create a research watch for: $@

Derive a short slug from the watch topic (lowercase, hyphens, no filler words, ≤5 words). Use this slug for all files in this run.

Requirements:
- Before starting, outline the watch plan: what to monitor, what signals matter, what counts as a meaningful change, and the check frequency. Write the plan to `outputs/.plans/<slug>.md`. Present the plan to the user and confirm before proceeding.
- Start with a baseline sweep of the topic.
- Note: Recurring scheduling is not natively available in Copilot CLI. Document the watch configuration and suggest the user set up a cron job or manual re-run.
- Save exactly one baseline artifact to `outputs/<slug>-baseline.md`.
- End with a `Sources` section containing direct URLs for every source used.
