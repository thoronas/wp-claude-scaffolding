#!/bin/bash
# install.sh — Symlink WordPress Claude global config from this repo to ~/.claude/
#
# Run once per developer machine after cloning this repo.
# Symlinks mean edits to files in global/ are reflected in ~/.claude/ immediately.
#
# Usage:
#   chmod +x global/install.sh
#   ./global/install.sh

set -e

GLOBAL_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing WordPress Claude global config..."
echo "  Source: $GLOBAL_DIR"
echo "  Target: $CLAUDE_DIR"
echo ""

# Ensure target directories exist
mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/rules"

# Skills — link each skill subdirectory
echo "Skills:"
for skill_dir in "$GLOBAL_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  ln -sfn "$skill_dir" "$CLAUDE_DIR/skills/$skill_name"
  echo "  ✓ skills/$skill_name"
done

# Agents — link each agent file
echo "Agents:"
for agent_file in "$GLOBAL_DIR/agents"/*.md; do
  agent_name=$(basename "$agent_file")
  ln -sf "$agent_file" "$CLAUDE_DIR/agents/$agent_name"
  echo "  ✓ agents/$agent_name"
done

# Rules — link each rule file
echo "Rules:"
for rule_file in "$GLOBAL_DIR/rules"/*.md; do
  rule_name=$(basename "$rule_file")
  ln -sf "$rule_file" "$CLAUDE_DIR/rules/$rule_name"
  echo "  ✓ rules/$rule_name"
done

echo ""
echo "Done. Claude Code will pick up these skills, agents, and rules in all projects."
echo "To update: edit files in global/. Symlinks keep ~/.claude/ in sync automatically."
