---
name: autoresearch
description: Autonomous experiment loop that tries ideas, measures results, keeps what works, and discards what doesn't. Use when the user asks to optimize a metric, run an experiment loop, improve performance iteratively, or automate benchmarking.
---

# Autoresearch

Start an autonomous experiment optimization loop.

## Step 1: Gather

If `autoresearch.md` and `autoresearch.jsonl` already exist in the working directory, ask the user if they want to resume or start fresh.

Otherwise, collect from the user before doing anything:
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
- **Docker** — run inside a container (use the docker skill)
- **Modal** — use Modal's serverless GPUs (use the modal-compute skill)
- **RunPod** — provision a GPU pod (use the runpod-compute skill)

Do not proceed without a clear answer.

## Step 3: Confirm

Present the full plan before starting:

```
Optimization target: [metric] ([direction])
Benchmark command:   [command]
Files in scope:      [files]
Environment:         [chosen environment]
Max iterations:      [N]
```

Ask the user to confirm. Do not start without explicit approval.

## Step 4: Run

### Baseline
Run the benchmark command and record the baseline metric.

### Iteration Loop
For each iteration:
1. **Edit** — make a targeted change to improve the metric
2. **Commit** — `git add -A && git commit -m "autoresearch: iteration N — <description>"`
3. **Run** — execute the benchmark command, capture output and wall-clock time
4. **Log** — append result to `autoresearch.jsonl`:
   ```json
   {"iteration": N, "description": "...", "metric": VALUE, "improved": true/false, "timestamp": "..."}
   ```
5. **Decide** — if improved, keep the change. If not, `git revert HEAD --no-edit`
6. **Repeat** — until max iterations or no more improvements found

### Dashboard
Maintain `autoresearch.md` with a running summary table:

| Iteration | Description | Metric | Δ | Kept |
|-----------|-------------|--------|---|------|

## Subcommands

- Start/resume: invoke this skill with your optimization idea
- Stop: the user can interrupt at any time
- Clear: delete `autoresearch.md`, `autoresearch.sh`, `autoresearch.jsonl` and start fresh
