---
name: docker
description: Execute research code inside isolated Docker containers for safe replication, experiments, and benchmarks. Use when the user selects Docker as the execution environment or asks to run code safely, in isolation, or in a sandbox.
---

# Docker Sandbox

Run research code inside Docker containers while staying on the host. The container gets the project files, runs the commands, and results sync back.

## When to Use

- Running untrusted code from a paper's repository
- Experiments that install packages or modify system state
- Any time the user asks to run something "safely" or "isolated"

## How It Works

1. Build or pull an appropriate base image for the research code
2. Mount the project directory into the container
3. Run experiment commands inside the container
4. Results write back to the mounted directory

## Running Commands

For Python research code (most common):

```bash
docker run --rm -v "$(pwd)":/workspace -w /workspace python:3.11 bash -c "
  pip install -r requirements.txt &&
  python train.py
"
```

For projects with a Dockerfile:

```bash
docker build -t experiment .
docker run --rm -v "$(pwd)/results":/workspace/results experiment
```

For GPU workloads:

```bash
docker run --rm --gpus all -v "$(pwd)":/workspace -w /workspace pytorch/pytorch:latest bash -c "
  pip install -r requirements.txt &&
  python train.py
"
```

## Choosing the Base Image

| Research type | Base image |
| --- | --- |
| Python ML/DL | `pytorch/pytorch:latest` or `tensorflow/tensorflow:latest-gpu` |
| Python general | `python:3.11` |
| Node.js | `node:20` |
| R / statistics | `rocker/r-ver:4` |
| Julia | `julia:1.10` |
| Multi-language | `ubuntu:24.04` with manual installs |

## Persistent Containers

For iterative experiments, create a named container:

```bash
docker create --name <name> -v "$(pwd)":/workspace -w /workspace python:3.11 tail -f /dev/null
docker start <name>
docker exec <name> bash -c "pip install -r requirements.txt"
docker exec <name> bash -c "python train.py"
```

Clean up with `docker stop <name> && docker rm <name>`.

## Notes

- Mounted workspace syncs results back automatically
- Add `--network none` for full isolation
- For GPU access, Docker must have the NVIDIA Container Toolkit
