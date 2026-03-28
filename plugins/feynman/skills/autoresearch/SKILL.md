---
name: autoresearch
description: Autonomous experiment loop that tries ideas, measures results, keeps what works, and discards what doesn't. Use when the user asks to optimize a metric, run an experiment loop, improve performance iteratively, or automate benchmarking.
---

Start an autoresearch optimization loop for: $@

This command uses pi-autoresearch.

## Step 1: Gather

If `autoresearch.md` and `autoresearch.jsonl` already exist, ask the user if they want to resume or start fresh.
If `CHANGELOG.md` exists, read the most recent relevant entries before resuming.

Otherwise, collect the following from the user before doing anything else:
- What to optimize (test speed, bundle size, training loss, build time, etc.)
- The benchmark command to run
- The metric name, unit, and direction (lower/higher is better)
- Files in scope for changes
- Maximum number of iterations (default: 20)

## Step 2: Environment

Ask the user where to run:
- **Local** — run in the current working directory
- **New git branch** — create a branch so main stays clean
- **Virtual environment** — create an isolated venv/conda env first
- **Docker** — run experiment code inside an isolated Docker container
- **Modal** — run on Modal's serverless GPU infrastructure. Write Modal-decorated scripts and execute with `modal run`. Best for GPU-heavy benchmarks with no persistent state between iterations. Requires `modal` CLI.
- **RunPod** — provision a GPU pod via `runpodctl` and run iterations there over SSH. Best for experiments needing persistent state, large datasets, or SSH access between iterations. Requires `runpodctl` CLI.

Do not proceed without a clear answer.

## Step 3: Confirm

Present the full plan to the user before starting:

```
Optimization target: [metric] ([direction])
Benchmark command:   [command]
Files in scope:      [files]
Environment:         [chosen environment]
Max iterations:      [N]
```

Ask the user to confirm. Do not start the loop without explicit approval.

## Step 4: Run

Initialize the session: create `autoresearch.md`, `autoresearch.sh`, run the baseline, and start looping.

Each iteration: edit → commit → `bash` (run benchmark) → `bash` (record result) → keep or revert → repeat. Do not stop unless interrupted or `maxIterations` is reached.
After the baseline and after meaningful iteration milestones, append a concise entry to `CHANGELOG.md` summarizing what changed, what metric result was observed, what failed, and the next step.

## Key tools

- `bash` — one-time session config: create experiment directory, write config file
- `bash` — run the benchmark command, capture output and wall-clock time
- `bash` — record result to JSONL, auto-commit with git, update dashboard

## Subcommands

- `/autoresearch <text>` — start or resume the loop
- `/autoresearch off` — stop the loop, keep data
- `/autoresearch clear` — delete all state and start fresh
