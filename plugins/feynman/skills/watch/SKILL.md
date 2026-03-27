---
name: watch
description: Set up a recurring research watch on a topic, company, paper area, or product surface. Use when the user asks to monitor a field, track new papers, watch for updates, or set up alerts on a research area.
---

# Watch

Create a research watch for the given topic.

Derive a short slug from the topic (lowercase, hyphens, ≤5 words). Use this slug for all files.

## Workflow

1. **Plan** — Outline the watch: what to monitor, what signals matter, what counts as a meaningful change, and the check frequency. Write to `outputs/.plans/<slug>.md`. Present to user and confirm.

2. **Baseline Sweep** — Run an initial research sweep of the topic using web search and `alpha search` for papers. Save the baseline to `outputs/<slug>-baseline.md` with a Sources section.

3. **Watch Setup** — Create a watch script at `scripts/<slug>-watch.sh` that can be run periodically to check for updates:

```bash
#!/bin/bash
# Research watch: <topic>
# Run periodically to check for updates
echo "Checking for updates on: <topic>"
echo "Last baseline: $(date -r outputs/<slug>-baseline.md)"
# Add search commands here
```

> **Note:** Automated scheduling (cron, etc.) must be set up by the user. This skill creates the baseline and watch script but cannot schedule recurring execution automatically.

4. **Deliver** — Save the baseline artifact and watch script. Inform the user how to set up periodic execution (e.g., cron job, manual re-run).
