---
name: jobs
description: Inspect active background research work including running processes, scheduled follow-ups, and pending tasks. Use when the user asks what's running, checks on background work, or wants to see scheduled jobs.
---

Inspect active background work for this project.

Requirements:
- Use the `process` tool with the `list` action to inspect running and finished managed background processes.
- Use the scheduling tooling to list active recurring or deferred jobs if any are configured.
- Summarize:
  - active background processes
  - queued or recurring research watches
  - failures that need attention
  - the next concrete command the user should run if they want logs or detailed status
- Be concise and operational.
