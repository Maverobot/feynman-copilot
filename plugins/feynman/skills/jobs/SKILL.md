---
name: jobs
description: Inspect active background research work including running processes, scheduled follow-ups, and pending tasks. Use when the user asks what's running, checks on background work, or wants to see scheduled jobs.
---

# Jobs

Inspect active background work for this project.

## What to Check

1. **Running processes** — Use `ps aux` or check for running background jobs in the terminal
2. **Git status** — Check `git status` for uncommitted changes from ongoing work
3. **Autoresearch state** — Check if `autoresearch.md` and `autoresearch.jsonl` exist (indicates an active experiment loop)
4. **Plan artifacts** — Check `outputs/.plans/` for active research plans with incomplete task ledgers
5. **Watch scripts** — Check `scripts/*-watch.sh` for configured research watches

## Output

Summarize concisely:
- Active background processes
- Ongoing research plans and their status
- Any failures that need attention
- The next concrete action the user should take
