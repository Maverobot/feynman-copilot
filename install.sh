#!/usr/bin/env bash
set -euo pipefail

# Feynman Research Agent for GitHub Copilot CLI — One-line installer
# Usage: curl -fsSL https://raw.githubusercontent.com/Maverobot/feynman-copilot/main/install.sh | bash

REPO="Maverobot/feynman-copilot"
COPILOT_HOME="${COPILOT_HOME:-$HOME/.copilot}"
CACHE_DIR="$COPILOT_HOME/marketplace-cache/feynman-copilot"
PLUGIN_DIR="$COPILOT_HOME/installed-plugins/feynman-copilot/feynman"

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

# Install as a proper Copilot CLI plugin (same pattern as superpowers-copilot)
echo ""
echo "📦 Installing as Copilot CLI plugin..."
mkdir -p "$(dirname "$PLUGIN_DIR")"

# Remove old installation if present
if [ -d "$PLUGIN_DIR" ] || [ -L "$PLUGIN_DIR" ]; then
    rm -rf "$PLUGIN_DIR"
fi

# Symlink the generated plugin directory
ln -s "$CACHE_DIR/plugins/feynman" "$PLUGIN_DIR"
echo "✅ Plugin installed: $PLUGIN_DIR"

# Also symlink agents to ~/.copilot/agents/ for direct agent access
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

# Register plugin in ~/.copilot/config.json (required for Copilot CLI discovery)
CONFIG_FILE="$COPILOT_HOME/config.json"
if [ -f "$CONFIG_FILE" ]; then
    if python3 -c "
import json, sys
config = json.load(open('$CONFIG_FILE'))
plugins = config.get('installed_plugins', [])
if any(p.get('name') == 'feynman' for p in plugins):
    sys.exit(0)  # already registered
else:
    sys.exit(1)
" 2>/dev/null; then
        echo "ℹ️  Plugin already registered in config.json"
    else
        python3 -c "
import json, datetime
config = json.load(open('$CONFIG_FILE'))
plugins = config.setdefault('installed_plugins', [])
# Remove old entry if present
plugins[:] = [p for p in plugins if p.get('name') != 'feynman']
plugins.append({
    'name': 'feynman',
    'marketplace': 'feynman-copilot',
    'version': '1.0.0',
    'installed_at': datetime.datetime.now(datetime.UTC).strftime('%Y-%m-%dT%H:%M:%S.000Z'),
    'enabled': True,
    'cache_path': '$PLUGIN_DIR'
})
json.dump(config, open('$CONFIG_FILE', 'w'), indent=4)
print('Done')
" && echo "✅ Plugin registered in config.json"
    fi
else
    echo "⚠️  $CONFIG_FILE not found — plugin may not be discovered until Copilot CLI is initialized"
fi

# Clean up old-style installation (skills in ~/.copilot/skills/)
OLD_SKILLS="$COPILOT_HOME/skills/feynman"
if [ -L "$OLD_SKILLS" ] || [ -d "$OLD_SKILLS" ]; then
    rm -rf "$OLD_SKILLS"
    echo "🔄 Cleaned up old-style skills symlink"
fi

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
SKILL_COUNT=$(find -L "$PLUGIN_DIR/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
AGENT_COUNT=$(find -L "$PLUGIN_DIR/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

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
