---
name: replication
description: Plan or execute a replication of a paper, claim, or benchmark. Use when the user asks to replicate results, reproduce an experiment, verify a claim empirically, or build a replication package.
---

# Replication

Design a replication plan for the given paper or claim.

## Workflow

1. **Extract** — Use the researcher subagent to pull implementation details from the target paper and any linked code.

2. **Plan** — Determine what code, datasets, metrics, and environment are needed. Be explicit about what is verified, what is inferred, what is still missing, and which checks will determine success.

3. **Environment** — Before running anything, ask the user where to execute:
   - **Local** — run in the current working directory
   - **Virtual environment** — create an isolated venv/conda env first
   - **Docker** — run inside an isolated Docker container (use the docker skill)
   - **Modal** — run on Modal's serverless GPU infrastructure (use the modal-compute skill)
   - **RunPod** — provision a GPU pod on RunPod (use the runpod-compute skill)
   - **Plan only** — produce the replication plan without executing

4. **Execute** — If the user chose an execution environment, implement and run the replication steps. Save notes, scripts, raw outputs, and results to disk. Do not call the outcome replicated unless the planned checks actually passed.

5. **Report** — End with a Sources section containing paper and repository URLs.

Do not install packages, run training, or execute experiments without confirming the execution environment first.
