# Feynman for GitHub Copilot CLI

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/Skills-18-blue)](plugins/feynman/skills)
[![Agents](https://img.shields.io/badge/Agents-5-purple)](plugins/feynman/agents)
[![Source](https://img.shields.io/badge/Source-getcompanion--ai%2Ffeynman-orange)](https://github.com/getcompanion-ai/feynman)

> **Thin wrapper around [Feynman](https://github.com/getcompanion-ai/feynman) that auto-generates Copilot CLI-compatible skills and agents from the upstream source. No content is duplicated — a Python generator reads the feynman submodule and produces adapted SKILL.md / agent .md files at install time.**

## How it works

This repo includes the [feynman](https://github.com/getcompanion-ai/feynman) repo as a **git submodule**. A `generate.py` script reads the original skills, prompts, and agent definitions, then:

1. **Self-contained skills** (7) are copied with Copilot CLI YAML frontmatter added
2. **Prompt-referenced skills** (11) have their `prompts/*.md` content inlined with Pi-specific tool references replaced by Copilot CLI equivalents
3. **Agent profiles** (5) are adapted from `.feynman/agents/*.md` and `.feynman/SYSTEM.md`

When feynman updates, just re-run the installer — the generator picks up changes automatically.

## Installation

### Method 1 — Native plugin marketplace (recommended)

```bash
copilot plugin marketplace add Maverobot/feynman-copilot
copilot plugin install feynman@feynman-copilot
```

### Method 2 — One command

```bash
curl -fsSL https://raw.githubusercontent.com/Maverobot/feynman-copilot/main/install.sh | bash
```

**Requirements:** git, python3

### Method 3 — Manual / development

```bash
git clone --recurse-submodules https://github.com/Maverobot/feynman-copilot.git
cd feynman-copilot
python3 generate.py   # regenerates plugins/feynman/ from the feynman submodule
./install.sh          # or manually symlink to ~/.copilot/
```

### Verify

Start a new Copilot CLI session and run:

```
/skills list
```

You should see all 18 Feynman skills. Check agents with `/agent`.

### Optional: Install alpha CLI for paper search

```bash
npm install -g @companion-ai/alpha-hub
alpha login
```

## What's Included

### 18 Research Skills

| Skill | When it activates |
|-------|-------------------|
| **deep-research** | Deep investigation on any topic — plans, delegates, verifies, cites |
| **literature-review** | Lit review with paper triage and primary-source synthesis |
| **paper-writing** | Turn research findings into paper-style drafts with citations |
| **peer-review** | Simulated peer review with severity levels and inline annotations |
| **paper-code-audit** | Compare paper claims against public code for mismatches |
| **source-comparison** | Compare multiple sources with grounded agreement/disagreement matrix |
| **replication** | Plan or execute reproductions of papers and benchmarks |
| **alpha-research** | Search, read, and query academic papers via alpha CLI |
| **eli5** | Explain research in plain English with analogies |
| **autoresearch** | Autonomous experiment loop: edit → benchmark → keep/revert → repeat |
| **docker** | Run research code safely in isolated Docker containers |
| **modal-compute** | Serverless GPU workloads via Modal |
| **runpod-compute** | Persistent GPU pods via RunPod |
| **watch** | Baseline sweep + watch script for recurring research monitoring |
| **preview** | Render Markdown/LaTeX/PDF artifacts for visual review |
| **session-log** | Capture work, findings, open questions, and next steps |
| **session-search** | Search past session transcripts for prior context |
| **jobs** | Inspect background processes, plans, and ongoing work |

### 5 Custom Agents

| Agent | Description |
|-------|-------------|
| **feynman** | Lead research agent — plans, delegates, synthesizes, and delivers |
| **researcher** | Evidence-gathering subagent with strict integrity rules |
| **reviewer** | Skeptical but fair peer reviewer with inline annotations |
| **writer** | Turns research notes into structured briefs and drafts |
| **verifier** | Post-processes drafts with inline citations and URL verification |

## Usage

Skills activate automatically when Copilot detects relevance. You can also invoke them explicitly:

```
Use the /deep-research skill to investigate transformer scaling laws
Use the /literature-review skill to survey attention mechanism efficiency
Use the /peer-review skill to review my draft at papers/my-paper.md
Use the /eli5 skill to explain 2106.09685
```

### Select the Feynman agent directly

```
/agent
→ select "feynman"
```

Or reference it in a prompt:

```
Use the feynman agent to investigate the current state of mixture-of-experts architectures
```

### Typical Research Workflow

1. **Deep Research** → "Investigate scaling laws for sparse models"
2. **Literature Review** → Focused paper survey on the topic
3. **Paper Writing** → Draft a synthesis from collected findings
4. **Peer Review** → Simulated review to find weaknesses
5. **Replication** → Reproduce key claims from top papers

## Output Conventions

All Feynman workflows follow consistent conventions:

- **Slug-based naming:** derive a short slug from the topic (e.g., `sparse-scaling-laws`) for all files
- **Output locations:**
  - `outputs/` — research briefs, reviews, comparisons
  - `papers/` — polished paper-style drafts
  - `notes/` — session logs and scratch notes
  - `outputs/.plans/` — research plans with task ledgers
- **Provenance tracking:** deep research and lit reviews produce `.provenance.md` sidecars
- **Sources required:** every output ends with a Sources section containing direct URLs

## Differences from Pi-based Feynman

This Copilot CLI package adapts Feynman's workflows with these changes:

| Feature | Pi-based Feynman | Copilot CLI version |
|---------|------------------|---------------------|
| Subagents | Pi `subagent` tool | Copilot CLI task tool + custom agents |
| Paper search | Built-in alpha tools | `alpha` CLI via bash (requires separate install) |
| Charts | `pi-charts` package | Mermaid diagrams + markdown tables |
| Memory | `pi-memory` package | Write to file on disk |
| Scheduling | `pi-schedule-prompt` | Manual (cron/watch scripts) |
| Background processes | `pi-processes` | Standard bash background processes |
| Session search | Built-in search UI | Grep-based search of session JSONL |

## Updating

### Method 1 users

```bash
copilot plugin update feynman@feynman-copilot
```

### Method 2/3 users

```bash
curl -fsSL https://raw.githubusercontent.com/Maverobot/feynman-copilot/main/install.sh | bash
```

## Uninstalling

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Maverobot/feynman-copilot/main/uninstall.sh)
```

Or manually:

```bash
rm -rf ~/.copilot/skills/feynman
rm -f ~/.copilot/agents/{feynman,researcher,reviewer,writer,verifier}.md
rm -rf ~/.copilot/marketplace-cache/feynman-copilot
# Remove the <!-- feynman-installed --> section from ~/.copilot/copilot-instructions.md
```

## Architecture

```
feynman-copilot/
├── feynman/                    ← git submodule (upstream source of truth)
├── generate.py                 ← reads feynman/, writes plugins/feynman/
├── plugins/feynman/
│   ├── skills/*/SKILL.md       ← generated, committed for native plugin install
│   └── agents/*.md             ← generated, committed for native plugin install
├── .github/plugin/
│   └── marketplace.json        ← marketplace manifest for native plugin install
├── install.sh                  ← clone + generate + symlink
├── uninstall.sh
└── README.md
```

### Tool substitutions applied by generate.py

| Pi tool | Copilot CLI equivalent |
|---------|----------------------|
| `subagent` | `task` tool with custom agents |
| `memory_remember` | Write to file on disk |
| `pi-charts` | Mermaid diagrams in markdown |
| `schedule_prompt` | Manual (cron/watch scripts) |
| `init/run/log_experiment` | Bash scripts with git commits |
| `fetch_content` | `web_fetch` tool |
| `subagent_status` | `read_agent` tool |

## Credits

- **[Maverobot](https://github.com/Maverobot)** — Maintainer of feynman-copilot
- **[Companion AI](https://github.com/getcompanion-ai)** — Creator of [Feynman](https://github.com/getcompanion-ai/feynman)
- Copilot CLI packaging follows the pattern established by [DwainTR/superpowers-copilot](https://github.com/DwainTR/superpowers-copilot)

## License

MIT — Same as the original [Feynman](https://github.com/getcompanion-ai/feynman/blob/main/LICENSE)
