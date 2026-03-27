#!/usr/bin/env python3
"""Generate Copilot CLI-compatible skills and agents from the feynman submodule.

Reads the original feynman repo (skills, prompts, agents, SYSTEM.md) and produces
adapted SKILL.md and agent .md files under plugins/feynman/ with Pi-specific tool
references replaced by Copilot CLI equivalents.

Usage:
    python3 generate.py              # default: feynman submodule at ./feynman
    python3 generate.py /path/to/feynman
"""

import os
import re
import sys
import shutil
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

FEYNMAN_DIR = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).parent / "feynman"
OUTPUT_DIR = Path(__file__).parent / "plugins" / "feynman"
SKILLS_OUT = OUTPUT_DIR / "skills"
AGENTS_OUT = OUTPUT_DIR / "agents"

# Prompt file → skill directory mapping (skill dirs that reference prompts/*.md)
PROMPT_TO_SKILL = {
    "deepresearch.md": "deep-research",
    "lit.md": "literature-review",
    "draft.md": "paper-writing",
    "review.md": "peer-review",
    "audit.md": "paper-code-audit",
    "compare.md": "source-comparison",
    "replicate.md": "replication",
    "autoresearch.md": "autoresearch",
    "watch.md": "watch",
    "log.md": "session-log",
    "jobs.md": "jobs",
}

# Pi tool → Copilot CLI adaptation rules (applied as regex substitutions)
TOOL_SUBSTITUTIONS = [
    # Pi packages reference
    (r'Use the installed Pi research packages for broader web/PDF access, document parsing, citation workflows, background processes, memory, session recall, and delegated subtasks when they reduce friction\.',
     'Use Copilot CLI tools (web_search, web_fetch, task agents, bash) for web access, document parsing, citation workflows, and delegated subtasks.'),
    # background subagent execution
    (r'background subagent execution with `clarify: false, async: true`',
     'background task execution with mode: "background"'),
    # subagent dispatching
    (r'Launch parallel `researcher` subagents via `subagent`',
     'Launch parallel researcher subagents via the `task` tool (agent_type: "general-purpose")'),
    (r'`subagent`\s+using\s+`clarify:\s*false,\s*async:\s*true`',
     'the `task` tool with mode: "background"'),
    (r'`subagent_status`',
     'the `read_agent` tool'),
    (r'`subagent`',
     'the `task` tool'),
    # memory
    (r'`memory_remember`\s*\([^)]*\)',
     'writing to a file on disk'),
    (r'save.*with\s+`memory_remember`[^.]*\.',
     'save it to a file on disk so it survives context truncation.'),
    (r'`memory_remember`',
     'writing to a file on disk'),
    (r'`memory_search`',
     'reading from local files'),
    # charts
    (r'Generate charts with `pi-charts`[^.]*\.',
     'Generate charts using Mermaid diagram syntax in markdown.'),
    (r'generate charts using `pi-charts`[^.]*\.',
     'generate charts using Mermaid diagram syntax in markdown.'),
    (r'`pi-charts`',
     'Mermaid diagrams'),
    # scheduling
    (r'Use `schedule_prompt`[^.]*\.',
     'Note: Recurring scheduling is not natively available in Copilot CLI. Document the watch configuration and suggest the user set up a cron job or manual re-run.'),
    (r'`schedule_prompt`',
     'a cron job or manual re-run (schedule_prompt is not available in Copilot CLI)'),
    (r'`pi-schedule-prompt`',
     'a cron job or manual re-run'),
    # experiment tools
    (r'`init_experiment`\s*—[^\n]*',
     '`bash` — one-time session config: create experiment directory, write config file'),
    (r'`run_experiment`\s*—[^\n]*',
     '`bash` — run the benchmark command, capture output and wall-clock time'),
    (r'`log_experiment`\s*—[^\n]*',
     '`bash` — record result to JSONL, auto-commit with git, update dashboard'),
    (r'`init_experiment`',
     '`bash` (create experiment config)'),
    (r'`run_experiment`',
     '`bash` (run benchmark)'),
    (r'`log_experiment`',
     '`bash` (record result)'),
    # processes
    (r'`pi-processes`',
     '`bash` with `ps` / process management'),
    # content fetching
    (r'`fetch_content`',
     '`web_fetch`'),
]

# Copilot CLI skill descriptions (from feynman prompt frontmatter + self-contained skills)
SKILL_DESCRIPTIONS = {
    "deep-research": "Run a thorough, source-heavy investigation on any topic. Use when the user asks for deep research, a comprehensive analysis, an in-depth report, or a multi-source investigation. Produces a cited research brief with provenance tracking.",
    "literature-review": "Run a literature review using paper search and primary-source synthesis. Use when the user asks for a lit review, paper survey, state of the art, or academic landscape summary on a research topic.",
    "paper-writing": "Turn research findings into a polished paper-style draft with sections, equations, and citations. Use when the user asks to write a paper, draft a report, write up findings, or produce a technical document from collected research.",
    "peer-review": "Simulate a tough but constructive peer review of an AI research artifact. Use when the user asks for a review, critique, feedback on a paper or draft, or wants to identify weaknesses before submission.",
    "paper-code-audit": "Compare a paper's claims against its public codebase. Use when the user asks to audit a paper, check code-claim consistency, verify reproducibility of a specific paper, or find mismatches between a paper and its implementation.",
    "source-comparison": "Compare multiple sources on a topic and produce a grounded comparison matrix. Use when the user asks to compare papers, tools, approaches, frameworks, or claims across multiple sources.",
    "replication": "Plan or execute a replication of a paper, claim, or benchmark. Use when the user asks to replicate results, reproduce an experiment, verify a claim empirically, or build a replication package.",
    "autoresearch": "Autonomous experiment loop that tries ideas, measures results, keeps what works, and discards what doesn't. Use when the user asks to optimize a metric, run an experiment loop, improve performance iteratively, or automate benchmarking.",
    "watch": "Set up a recurring research watch on a topic, company, paper area, or product surface. Use when the user asks to monitor a field, track new papers, watch for updates, or set up alerts on a research area.",
    "session-log": "Write a durable session log capturing completed work, findings, open questions, and next steps. Use when the user asks to log progress, save session notes, write up what was done, or create a research diary entry.",
    "jobs": "Inspect active background research work including running processes, scheduled follow-ups, and pending tasks. Use when the user asks what's running, checks on background work, or wants to see scheduled jobs.",
    "alpha-research": "Search, read, and query research papers via the `alpha` CLI (alphaXiv-backed). Use when the user asks about academic papers, wants to find research on a topic, needs to read a specific paper, ask questions about a paper, inspect a paper's code repository, or manage paper annotations.",
    "eli5": "Explain research, papers, or technical ideas in plain English with minimal jargon, concrete analogies, and clear takeaways. Use when the user says \"ELI5 this\", asks for a simple explanation of a paper or research result, wants jargon removed, or asks what something technically dense actually means.",
    "docker": "Execute research code inside isolated Docker containers for safe replication, experiments, and benchmarks. Use when the user selects Docker as the execution environment or asks to run code safely, in isolation, or in a sandbox.",
    "modal-compute": "Run GPU workloads on Modal's serverless infrastructure. Use when the user needs remote GPU compute for training, inference, benchmarks, or batch processing and Modal CLI is available.",
    "runpod-compute": "Provision and manage GPU pods on RunPod for long-running experiments. Use when the user needs persistent GPU compute with SSH access, large datasets, or multi-step experiments.",
    "preview": "Preview Markdown, LaTeX, PDF, or code artifacts in the browser or as PDF. Use when the user wants to review a written artifact, export a report, or view a rendered document.",
    "session-search": "Search past Feynman session transcripts to recover prior work, conversations, and research context. Use when the user references something from a previous session, asks \"what did we do before\", or when you suspect relevant past context exists.",
}


def parse_frontmatter(text: str) -> tuple[dict, str]:
    """Parse YAML-like frontmatter. Returns (metadata dict, body after frontmatter)."""
    m = re.match(r'^---\n(.*?)\n---\n?(.*)', text, re.DOTALL)
    if not m:
        return {}, text
    fm = {}
    for line in m.group(1).split('\n'):
        sep = line.find(':')
        if sep == -1:
            continue
        key = line[:sep].strip()
        val = line[sep + 1:].strip()
        if key:
            fm[key] = val
    return fm, m.group(2)


def apply_substitutions(text: str) -> str:
    """Apply Pi→Copilot CLI tool substitutions."""
    for pattern, replacement in TOOL_SUBSTITUTIONS:
        text = re.sub(pattern, replacement, text, flags=re.IGNORECASE)
    return text


def generate_skill(skill_dir: str, content: str, description: str) -> str:
    """Wrap skill content with Copilot CLI YAML frontmatter."""
    content = apply_substitutions(content)
    return f"---\nname: {skill_dir}\ndescription: {description}\n---\n\n{content.strip()}\n"


def process_self_contained_skill(skill_name: str, skill_md_path: Path):
    """Copy a self-contained SKILL.md, adding frontmatter if needed."""
    text = skill_md_path.read_text()
    fm, body = parse_frontmatter(text)

    desc = SKILL_DESCRIPTIONS.get(skill_name, fm.get("description", ""))
    if not desc:
        desc = f"Feynman {skill_name} skill."

    out_dir = SKILLS_OUT / skill_name
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "SKILL.md").write_text(generate_skill(skill_name, body, desc))


def process_prompt_skill(prompt_file: str, skill_name: str):
    """Read the referenced prompt, apply substitutions, generate SKILL.md."""
    prompt_path = FEYNMAN_DIR / "prompts" / prompt_file
    if not prompt_path.exists():
        print(f"  ⚠ Prompt not found: {prompt_path}")
        return

    text = prompt_path.read_text()
    fm, body = parse_frontmatter(text)

    desc = SKILL_DESCRIPTIONS.get(skill_name, fm.get("description", ""))
    if not desc:
        desc = f"Feynman {skill_name} skill."

    out_dir = SKILLS_OUT / skill_name
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "SKILL.md").write_text(generate_skill(skill_name, body, desc))


def process_agent(agent_path: Path, agent_name: str):
    """Read a .feynman/agents/*.md file and produce a Copilot CLI agent .md."""
    text = agent_path.read_text()
    fm, body = parse_frontmatter(text)

    desc = fm.get("description", f"Feynman {agent_name} subagent.")
    body = apply_substitutions(body)

    out = f"---\nname: {agent_name}\ndescription: |\n  {desc}\n---\n\n{body.strip()}\n"
    (AGENTS_OUT / f"{agent_name}.md").write_text(out)


def process_lead_agent():
    """Generate the lead feynman agent from .feynman/SYSTEM.md."""
    system_path = FEYNMAN_DIR / ".feynman" / "SYSTEM.md"
    if not system_path.exists():
        print("  ⚠ SYSTEM.md not found")
        return

    text = system_path.read_text()
    body = apply_substitutions(text)

    desc = (
        'Research-first AI agent. Use when the user needs deep investigation, '
        'evidence synthesis, literature reviews, paper audits, or any research-heavy task.'
    )

    out = f"---\nname: feynman\ndescription: |\n  {desc}\n---\n\n{body.strip()}\n"
    (AGENTS_OUT / "feynman.md").write_text(out)


def main():
    print(f"🔬 Generating Copilot CLI skills and agents from: {FEYNMAN_DIR}")
    print(f"   Output: {OUTPUT_DIR}")
    print()

    if not FEYNMAN_DIR.exists():
        print(f"❌ Feynman directory not found: {FEYNMAN_DIR}")
        print("   Run: git submodule update --init")
        sys.exit(1)

    # Clean output (preserve .claude-plugin and README.md)
    if SKILLS_OUT.exists():
        shutil.rmtree(SKILLS_OUT)
    if AGENTS_OUT.exists():
        shutil.rmtree(AGENTS_OUT)
    SKILLS_OUT.mkdir(parents=True)
    AGENTS_OUT.mkdir(parents=True)

    # Copy .claude-plugin metadata if present in the repo's plugins dir
    repo_plugin_meta = Path(__file__).parent / "plugins" / "feynman" / ".claude-plugin"
    out_plugin_meta = OUTPUT_DIR / ".claude-plugin"
    if repo_plugin_meta.exists():
        if out_plugin_meta.exists():
            shutil.rmtree(out_plugin_meta)
        shutil.copytree(repo_plugin_meta, out_plugin_meta)

    # Process prompt-referenced skills
    print("📝 Processing prompt-referenced skills:")
    for prompt_file, skill_name in sorted(PROMPT_TO_SKILL.items()):
        print(f"   {skill_name} ← prompts/{prompt_file}")
        process_prompt_skill(prompt_file, skill_name)

    # Process self-contained skills
    print("\n📦 Processing self-contained skills:")
    skills_dir = FEYNMAN_DIR / "skills"
    if skills_dir.exists():
        for skill_path in sorted(skills_dir.iterdir()):
            if not skill_path.is_dir():
                continue
            skill_name = skill_path.name
            skill_md = skill_path / "SKILL.md"
            if not skill_md.exists():
                continue
            if skill_name not in PROMPT_TO_SKILL.values():
                print(f"   {skill_name}")
                process_self_contained_skill(skill_name, skill_md)

    # Process agents
    print("\n🤖 Processing agents:")
    agents_dir = FEYNMAN_DIR / ".feynman" / "agents"
    if agents_dir.exists():
        for agent_path in sorted(agents_dir.iterdir()):
            if agent_path.suffix == ".md":
                agent_name = agent_path.stem
                print(f"   {agent_name}")
                process_agent(agent_path, agent_name)

    # Lead agent
    print("   feynman (lead agent)")
    process_lead_agent()

    # Summary
    skill_count = sum(1 for _ in SKILLS_OUT.iterdir() if _.is_dir())
    agent_count = sum(1 for _ in AGENTS_OUT.iterdir() if _.suffix == ".md")
    print(f"\n✅ Generated {skill_count} skills and {agent_count} agents")


if __name__ == "__main__":
    main()
