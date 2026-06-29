#!/bin/bash
# retrofit-vault.sh — Wire Obsidian vault integration into an existing scaffolded project.
#
# Writes .claude/reference/vault-brief-pointer.md and adds a ## Cross-Project Context
# section to CLAUDE.md. Safe to re-run: existing entries are not duplicated.
#
# Usage (fully non-interactive):
#   bin/retrofit-vault.sh --target /path/to/repo --project-slug my-project
#
# Usage (interactive prompts for missing values):
#   bin/retrofit-vault.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Defaults ──────────────────────────────────────────────────────────────────

TARGET=""
PROJECT_SLUG=""

# ── Arg parsing ───────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case $1 in
    --target)       TARGET="$2";       shift 2 ;;
    --project-slug) PROJECT_SLUG="$2"; shift 2 ;;
    *)
      echo "Unknown flag: $1"
      echo "Usage: $0 [--target PATH] [--project-slug SLUG]"
      exit 1
      ;;
  esac
done

# ── Interactive prompts for missing values ─────────────────────────────────────

prompt_value() {
  local _var="$1"
  local _prompt="$2"
  if [[ -z "${!_var}" ]]; then
    read -rp "$_prompt " _val
    eval "$_var=\"\$_val\""
  fi
}

prompt_value TARGET       "Target directory (absolute path):"
prompt_value PROJECT_SLUG "Project slug (e.g. my-project):"

# Expand ~ in TARGET
TARGET="${TARGET/#\~/$HOME}"

# ── Cross-platform sed helper ──────────────────────────────────────────────────

sedi() {
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

# ── Validation ─────────────────────────────────────────────────────────────────

if [[ -z "${OBSIDIAN_VAULT:-}" ]]; then
  echo "Error: OBSIDIAN_VAULT is not set."
  echo "Add the following to ~/.zshenv and restart your shell:"
  echo ""
  echo '  export OBSIDIAN_VAULT="$HOME/Documents/Obsidian Vault/"'
  exit 1
fi

if [[ ! -d "$OBSIDIAN_VAULT" ]]; then
  echo "Error: OBSIDIAN_VAULT is set but directory not found: $OBSIDIAN_VAULT"
  echo "Check the path and update ~/.zshenv."
  exit 1
fi

if [[ -z "$TARGET" ]]; then
  echo "Error: target directory is required."
  exit 1
fi

if [[ ! -d "$TARGET/.claude" ]]; then
  echo "Error: '$TARGET' does not look like a scaffolded project (no .claude/ directory)."
  echo "Run bin/init.sh first, or pass the correct --target path."
  exit 1
fi

if [[ -z "$PROJECT_SLUG" ]]; then
  echo "Error: project slug is required."
  exit 1
fi

# Resolve vault path as a literal string (not an env-var reference)
VAULT_RESOLVED="$(cd "$OBSIDIAN_VAULT" && pwd)"
VAULT_BRIEF_PATH="$VAULT_RESOLVED/wiki/synthesis/$PROJECT_SLUG-brief.md"

echo ""
echo "Vault integration summary:"
echo "  Target:      $TARGET"
echo "  Project:     $PROJECT_SLUG"
echo "  Vault brief: $VAULT_BRIEF_PATH"
echo ""
read -rp "Proceed? [Y/n]: " _confirm
if [[ "$_confirm" =~ ^[Nn]$ ]]; then
  echo "Aborted."
  exit 0
fi

echo ""
echo "Wiring vault integration..."

# ── Write vault-brief-pointer.md ──────────────────────────────────────────────

POINTER_FILE="$TARGET/.claude/reference/vault-brief-pointer.md"
mkdir -p "$TARGET/.claude/reference"

cat > "$POINTER_FILE" <<EOF
# Vault Brief Pointer

Project slug: $PROJECT_SLUG
Vault brief: $VAULT_BRIEF_PATH

## Session start instruction

At the start of every session, before writing any code, read the vault brief at:

  $VAULT_BRIEF_PATH

This file contains cross-project context, active initiatives, and decisions that span
multiple repositories. Copy or open the path above in Obsidian to view or edit it.
EOF

echo "  ✓ .claude/reference/vault-brief-pointer.md"

# ── Append ## Cross-Project Context to CLAUDE.md ─────────────────────────────

CLAUDE_MD="$TARGET/CLAUDE.md"
SECTION_HEADER="## Cross-Project Context"

if [[ -f "$CLAUDE_MD" ]] && grep -qF "$SECTION_HEADER" "$CLAUDE_MD"; then
  echo "  ✓ CLAUDE.md (Cross-Project Context section already present)"
else
  printf '\n%s\n\nSee `.claude/reference/vault-brief-pointer.md` for the Obsidian vault brief\npath and session-start instruction.\n' \
    "$SECTION_HEADER" >> "$CLAUDE_MD"
  echo "  ✓ CLAUDE.md (appended Cross-Project Context section)"
fi

# ── Add vault-brief-pointer.md to .gitignore ──────────────────────────────────

GITIGNORE="$TARGET/.gitignore"
POINTER_ENTRY=".claude/reference/vault-brief-pointer.md"

if [[ -f "$GITIGNORE" ]] && grep -qF "$POINTER_ENTRY" "$GITIGNORE"; then
  echo "  ✓ .gitignore (vault-brief-pointer.md already listed)"
else
  printf '\n# Obsidian vault pointer — machine-local, not committed\n%s\n' \
    "$POINTER_ENTRY" >> "$GITIGNORE"
  echo "  ✓ .gitignore (added vault-brief-pointer.md entry)"
fi

# ── Completion summary ─────────────────────────────────────────────────────────

echo ""
echo "Vault integration complete."
echo ""
echo "Next step:"
echo "  Create the vault brief in Obsidian at:"
echo "    $VAULT_BRIEF_PATH"
echo ""
echo "  The brief is read by Claude at session start for cross-project context."
echo "  A minimal starting template:"
echo ""
echo "    # $PROJECT_SLUG — Project Brief"
echo "    [One sentence: what this project is and who it's for.]"
echo ""
echo "    ## Active focus"
echo "    [What is being worked on right now.]"
echo ""
echo "    ## Key decisions"
echo "    [Decisions that span this project and others.]"
