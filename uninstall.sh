#!/usr/bin/env bash
set -euo pipefail

# Feynman Research Agent for GitHub Copilot CLI — Uninstaller

COPILOT_HOME="${COPILOT_HOME:-$HOME/.copilot}"
CACHE_DIR="$COPILOT_HOME/marketplace-cache/feynman-copilot"
SKILLS_DST="$COPILOT_HOME/skills/feynman"
AGENTS_DIR="$COPILOT_HOME/agents"
INSTRUCTIONS_FILE="$COPILOT_HOME/copilot-instructions.md"

echo "🔬 Feynman Research Agent — Uninstaller"
echo "========================================"
echo ""

# Remove skills
if [ -L "$SKILLS_DST" ] || [ -d "$SKILLS_DST" ]; then
    rm -rf "$SKILLS_DST"
    echo "✅ Skills removed"
else
    echo "ℹ️  Skills not found (already removed)"
fi

# Remove agents
for agent in feynman researcher reviewer writer verifier; do
    agent_path="$AGENTS_DIR/$agent.md"
    if [ -L "$agent_path" ] || [ -f "$agent_path" ]; then
        rm -f "$agent_path"
        echo "✅ Agent removed: $agent"
    fi
done

# Remove custom instructions block
if [ -f "$INSTRUCTIONS_FILE" ]; then
    if grep -q "<!-- feynman-installed -->" "$INSTRUCTIONS_FILE" 2>/dev/null; then
        # Remove from marker to end of the feynman block
        sed -i '/<!-- feynman-installed -->/,/^$/d' "$INSTRUCTIONS_FILE"
        # Clean up any trailing blank lines
        sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$INSTRUCTIONS_FILE"
        echo "✅ Custom instructions cleaned up"
    fi
fi

# Remove cache
if [ -d "$CACHE_DIR" ]; then
    rm -rf "$CACHE_DIR"
    echo "✅ Cache removed"
fi

echo ""
echo "🗑️  Feynman uninstalled. Start a new Copilot CLI session for changes to take effect."
