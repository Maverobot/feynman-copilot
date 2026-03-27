#!/usr/bin/env bash
set -euo pipefail

# Feynman Research Agent for GitHub Copilot CLI — One-line installer
# Usage: curl -fsSL https://raw.githubusercontent.com/Maverobot/feynman-copilot/main/install.sh | bash

REPO="Maverobot/feynman-copilot"
COPILOT_HOME="${COPILOT_HOME:-$HOME/.copilot}"
CACHE_DIR="$COPILOT_HOME/marketplace-cache/feynman-copilot"

echo "🔬 Feynman Research Agent for GitHub Copilot CLI — Installer"
echo "============================================================"
echo ""

# Check prerequisites
if ! command -v git &> /dev/null; then
    echo "❌ Git is required but not installed."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required for skill generation but not found."
    exit 1
fi

if ! command -v copilot &> /dev/null; then
    echo "⚠️  GitHub Copilot CLI not found in PATH."
    echo "   Install it first: https://github.com/github/copilot-cli"
    echo "   Continuing anyway (skills will be available when Copilot CLI is installed)..."
    echo ""
fi

if ! command -v alpha &> /dev/null; then
    echo "ℹ️  alpha CLI not found. Paper search skills require it."
    echo "   Install with: npm install -g @companion-ai/alpha-hub"
    echo "   Then run: alpha login"
    echo ""
fi

# Clone or update the repo (with submodules)
if [ -d "$CACHE_DIR" ]; then
    echo "📦 Updating existing cache..."
    cd "$CACHE_DIR"
    git pull --quiet 2>/dev/null || {
        echo "   Cache update failed, re-cloning..."
        rm -rf "$CACHE_DIR"
        git clone --quiet --recurse-submodules "https://github.com/$REPO.git" "$CACHE_DIR"
    }
    git submodule update --init --quiet 2>/dev/null
else
    echo "📦 Cloning repository..."
    mkdir -p "$(dirname "$CACHE_DIR")"
    git clone --quiet --recurse-submodules "https://github.com/$REPO.git" "$CACHE_DIR"
fi

# Generate skills and agents from feynman submodule
echo ""
echo "⚙️  Generating Copilot CLI skills from feynman source..."
cd "$CACHE_DIR"
python3 generate.py

# Link skills
SKILLS_SRC="$CACHE_DIR/plugins/feynman/skills"
SKILLS_DST="$COPILOT_HOME/skills/feynman"

mkdir -p "$COPILOT_HOME/skills"
if [ -L "$SKILLS_DST" ] || [ -d "$SKILLS_DST" ]; then
    echo "🔄 Removing old skills link..."
    rm -rf "$SKILLS_DST"
fi
ln -s "$SKILLS_SRC" "$SKILLS_DST"
echo "✅ Skills linked: $SKILLS_DST → $SKILLS_SRC"

# Link agents
AGENTS_SRC="$CACHE_DIR/plugins/feynman/agents"
AGENTS_DIR="$COPILOT_HOME/agents"
mkdir -p "$AGENTS_DIR"

for agent_file in "$AGENTS_SRC"/*.md; do
    agent_name=$(basename "$agent_file")
    agent_dst="$AGENTS_DIR/$agent_name"
    if [ -L "$agent_dst" ] || [ -f "$agent_dst" ]; then
        rm -f "$agent_dst"
    fi
    ln -s "$agent_file" "$agent_dst"
    echo "✅ Agent linked: $agent_name"
done

# Add custom instructions if not already present
INSTRUCTIONS_FILE="$COPILOT_HOME/copilot-instructions.md"
MARKER="<!-- feynman-installed -->"

if [ -f "$INSTRUCTIONS_FILE" ] && grep -q "$MARKER" "$INSTRUCTIONS_FILE" 2>/dev/null; then
    echo "ℹ️  Custom instructions already configured."
else
    echo "" >> "$INSTRUCTIONS_FILE"
    cat >> "$INSTRUCTIONS_FILE" << 'INSTRUCTIONS'

<!-- feynman-installed -->
## Feynman Research Skills

You have Feynman research skills installed. When the user asks about research, papers,
literature reviews, or any investigative task, check if a relevant Feynman skill applies.

Available research skills: deep-research, literature-review, paper-writing, peer-review,
paper-code-audit, source-comparison, replication, alpha-research, eli5, autoresearch,
docker, modal-compute, runpod-compute, watch, preview, session-log, session-search, jobs.

Available research agents: feynman (lead), researcher, reviewer, writer, verifier.

Key conventions:
- Evidence over fluency. Prefer primary sources over commentary.
- Derive a slug from the topic for all file naming (lowercase, hyphens, ≤5 words).
- Output locations: outputs/ for briefs, papers/ for drafts, notes/ for logs.
- Every output includes a Sources section with direct URLs.
- Do not say "verified" or "confirmed" without actual evidence.
INSTRUCTIONS
    echo "✅ Custom instructions updated: $INSTRUCTIONS_FILE"
fi

# Count installed items
SKILL_COUNT=$(find -L "$SKILLS_DST" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
AGENT_COUNT=$(find "$AGENTS_SRC" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo "🎉 Feynman installed successfully!"
echo ""
echo "   Skills: $SKILL_COUNT research skills available"
echo "   Agents: $AGENT_COUNT research agents available"
echo ""
echo "   Next steps:"
echo "   1. Start a new Copilot CLI session: copilot"
echo "   2. Verify skills: /skills list"
echo "   3. Verify agents: /agent"
echo "   4. Try: 'Use the /deep-research skill to investigate scaling laws'"
echo ""
echo "   Optional: Install alpha CLI for paper search:"
echo "   npm install -g @companion-ai/alpha-hub && alpha login"
echo ""
echo "   To update: run this script again"
echo "   To uninstall: bash <(curl -fsSL https://raw.githubusercontent.com/$REPO/main/uninstall.sh)"
