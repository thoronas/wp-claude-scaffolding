#!/bin/bash
# init.sh — Bootstrap a new project from wp-scaffold-project.
#
# Modes:
#   dropin  — copy the Claude layer into an existing repo of any structure
#   fresh   — copy Claude layer + wp-content scaffold, then invoke wp-theme
#
# Usage (fully non-interactive):
#   bin/init.sh --mode dropin --target /path/to/repo --theme my-theme \
#               --plugin my-plugin --vendor acme --namespace AcmeCorp
#
# Usage (interactive prompts for missing values):
#   bin/init.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# ── Defaults ──────────────────────────────────────────────────────────────────

MODE=""
TARGET=""
THEME_SLUG=""
PLUGIN_SLUG=""
VENDOR=""
NAMESPACE=""
NO_THEME=false
VAULT_PATH=""

# ── Arg parsing ───────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case $1 in
    --mode)        MODE="$2";        shift 2 ;;
    --target)      TARGET="$2";      shift 2 ;;
    --theme)       THEME_SLUG="$2";  shift 2 ;;
    --plugin)      PLUGIN_SLUG="$2"; shift 2 ;;
    --vendor)      VENDOR="$2";      shift 2 ;;
    --namespace)   NAMESPACE="$2";   shift 2 ;;
    --no-theme)    NO_THEME=true;    shift   ;;
    --vault-path)  VAULT_PATH="$2";  shift 2 ;;
    *)
      echo "Unknown flag: $1"
      echo "Usage: $0 [--mode dropin|fresh] [--target PATH] [--theme SLUG]"
      echo "          [--plugin SLUG] [--vendor NAME] [--namespace NAME] [--no-theme]"
      echo "          [--vault-path PATH]"
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

# Mode selection
if [[ -z "$MODE" ]]; then
  echo ""
  echo "What type of bootstrap?"
  echo "  [1] Drop into existing repo (Claude layer only)"
  echo "  [2] Fresh build (Claude layer + WordPress structure + theme skeleton)"
  read -rp "Choice [1/2]: " _mode_choice
  case "$_mode_choice" in
    1) MODE="dropin" ;;
    2) MODE="fresh"  ;;
    *) echo "Invalid choice. Expected 1 or 2."; exit 1 ;;
  esac
fi

if [[ "$MODE" != "dropin" && "$MODE" != "fresh" ]]; then
  echo "Invalid --mode value '$MODE'. Must be 'dropin' or 'fresh'."
  exit 1
fi

prompt_value TARGET      "Target directory (absolute path):"
prompt_value THEME_SLUG  "Theme slug (e.g. clf8):"
prompt_value PLUGIN_SLUG "Plugin slug (e.g. clf8-plugin):"
prompt_value VENDOR      "Composer vendor name (e.g. acme):"
prompt_value NAMESPACE   "PHP namespace prefix (e.g. AcmeCorp):"

# Vault path is fully optional — prompt only if flag was not passed
if [[ -z "$VAULT_PATH" ]]; then
  read -rp "Obsidian vault path (leave blank to skip): " _vault_input
  VAULT_PATH="$_vault_input"
fi

# Expand ~ in TARGET and VAULT_PATH
TARGET="${TARGET/#\~/$HOME}"
VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

# Ask about theme generation only in fresh mode when not already suppressed
if [[ "$MODE" == "fresh" && "$NO_THEME" == false ]]; then
  read -rp "Generate theme skeleton via wp-theme skill? [Y/n]: " _gen_theme
  if [[ "$_gen_theme" =~ ^[Nn]$ ]]; then
    NO_THEME=true
  fi
fi

# ── Validation ─────────────────────────────────────────────────────────────────

if [[ -z "$TARGET" ]]; then
  echo "Error: target directory is required."
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Error: target directory '$TARGET' does not exist."
  echo "Create it first: mkdir -p '$TARGET'"
  exit 1
fi

echo ""
echo "Bootstrap summary:"
echo "  Mode:      $MODE"
echo "  Target:    $TARGET"
echo "  Theme:     $THEME_SLUG"
echo "  Plugin:    $PLUGIN_SLUG"
echo "  Vendor:    $VENDOR"
echo "  Namespace: $NAMESPACE"
echo "  wp-theme:  $( [[ "$MODE" == "fresh" && "$NO_THEME" == false ]] && echo "yes" || echo "no" )"
echo ""
read -rp "Proceed? [Y/n]: " _confirm
if [[ "$_confirm" =~ ^[Nn]$ ]]; then
  echo "Aborted."
  exit 0
fi

echo ""
echo "Starting bootstrap..."

# ── Copy Claude layer ──────────────────────────────────────────────────────────

CLAUDE_LAYER=(
  ".claude"
  ".editorconfig"
  ".mcp.json"
  "CLAUDE.md"
  "DECISIONS.md"
  "PROJECT-SPEC.md"
  "composer.json"
  "phpcs.xml.dist"
  "phpunit.xml.dist"
)

# In dropin mode, warn if .claude already exists to prevent silent overwrites
if [[ "$MODE" == "dropin" && -d "$TARGET/.claude" ]]; then
    echo ""
    echo "WARNING: $TARGET/.claude already exists."
    echo "Existing files will be overwritten. Your customisations in"
    echo "settings.json or commands/ may be lost."
    echo ""
    read -rp "Continue and overwrite? [y/N]: " _overwrite
    if [[ ! "$_overwrite" =~ ^[Yy]$ ]]; then
        echo "Aborted. Back up $TARGET/.claude first, then re-run."
        exit 1
    fi
fi

# In dropin mode, back up an existing CLAUDE.md rather than silently overwriting
if [[ "$MODE" == "dropin" && -f "$TARGET/CLAUDE.md" ]]; then
    BACKUP="$TARGET/CLAUDE.md.bak-$(date +%Y%m%d%H%M%S)"
    cp "$TARGET/CLAUDE.md" "$BACKUP"
    echo ""
    echo "NOTE: Existing CLAUDE.md backed up to $(basename "$BACKUP")"
    echo "      Review it after bootstrap to merge any project-specific content."
    echo ""
fi

echo "Copying Claude layer..."
for item in "${CLAUDE_LAYER[@]}"; do
  cp -r "$REPO_ROOT/$item" "$TARGET/"
  echo "  ✓ $item"
done

# Ensure .claude subdirectories exist regardless of scaffold source state.
# Git does not track empty directories — these must be created explicitly.
mkdir -p "$TARGET/.claude/reference"
mkdir -p "$TARGET/.claude/commands"

# Copy reference README if it exists in source
if [[ -f "$REPO_ROOT/.claude/reference/README.md" ]]; then
    cp "$REPO_ROOT/.claude/reference/README.md" "$TARGET/.claude/reference/"
    echo " ✓ .claude/reference/ (with README)"
else
    echo " ✓ .claude/reference/ (created, empty — add inspiration code here)"
fi

# Copy any committed custom commands
if [[ -d "$REPO_ROOT/.claude/commands" ]] && \
   [[ -n "$(ls -A "$REPO_ROOT/.claude/commands" 2>/dev/null)" ]]; then
    cp "$REPO_ROOT/.claude/commands/"* "$TARGET/.claude/commands/" 2>/dev/null || true
    echo " ✓ .claude/commands/ (with scaffold commands)"
else
    echo " ✓ .claude/commands/ (created, empty — add custom slash commands here)"
fi

# ── Version stamp ─────────────────────────────────────────────────────────────
# The Claude layer is COPIED, so template fixes never reach a project that was
# already bootstrapped. This records what the project came from, which is what
# makes that gap measurable: bin/audit-drift.sh in wp-scaffold-global compares
# this stamp against the template's current VERSION and reports the lag.
#
# Kept out of CLAUDE_LAYER deliberately — it is generated per project, not copied.

TEMPLATE_VERSION="unknown"
[[ -f "$REPO_ROOT/VERSION" ]] && TEMPLATE_VERSION="$(tr -d '[:space:]' < "$REPO_ROOT/VERSION")"

GLOBAL_VERSION="unknown"
for _g in "${WP_SCAFFOLD_GLOBAL:-}" "$HOME/Sites/wp-scaffold-global"; do
  [[ -n "$_g" && -f "$_g/VERSION" ]] && { GLOBAL_VERSION="$(tr -d '[:space:]' < "$_g/VERSION")"; break; }
done

cat > "$TARGET/.claude/.scaffold-version" <<EOF
{
  "template_version": "$TEMPLATE_VERSION",
  "global_version_at_bootstrap": "$GLOBAL_VERSION",
  "bootstrapped": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "mode": "$MODE"
}
EOF
echo "  ✓ .claude/.scaffold-version (template $TEMPLATE_VERSION)"

# docs/ — copy only the project-facing file, not scaffold dev artifacts
mkdir -p "$TARGET/docs"
cp "$REPO_ROOT/docs/DEVELOPMENT-PROMPTS.md" "$TARGET/docs/"
echo "  ✓ docs/DEVELOPMENT-PROMPTS.md"

# ── .gitignore handling ────────────────────────────────────────────────────────

CLAUDE_GITIGNORE_BLOCK=$'\n# Claude Code — project-level config\n.claude/reference/**/.git\n.claude/settings.local.json\n.claude/reference/local/\n'

if [[ "$MODE" == "fresh" ]]; then
  cp "$REPO_ROOT/scaffolds/wp-content/.gitignore" "$TARGET/.gitignore"
  echo "  ✓ .gitignore (full WP gitignore)"
else
  if [[ -f "$TARGET/.gitignore" ]]; then
    printf '%s' "$CLAUDE_GITIGNORE_BLOCK" >> "$TARGET/.gitignore"
    echo "  ✓ .gitignore (appended Claude entries)"
  else
    printf '%s' "$CLAUDE_GITIGNORE_BLOCK" > "$TARGET/.gitignore"
    echo "  ✓ .gitignore (created with Claude entries)"
  fi
fi

# ── Cross-platform sed helper ──────────────────────────────────────────────────

sedi() {
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

# ── Fresh mode: copy wp-content scaffold ──────────────────────────────────────

if [[ "$MODE" == "fresh" ]]; then
  echo "Copying WordPress scaffold..."
  SCAFFOLD="$REPO_ROOT/scaffolds/wp-content"

  cp -r "$SCAFFOLD/languages"    "$TARGET/"
  cp -r "$SCAFFOLD/mu-plugins"   "$TARGET/"
  cp -r "$SCAFFOLD/plugins"      "$TARGET/"
  cp -r "$SCAFFOLD/tests"        "$TARGET/"
  cp    "$SCAFFOLD/.wp-env.json" "$TARGET/"

  echo "  ✓ languages, mu-plugins, plugins, tests, .wp-env.json"

  # Rename plugin directory and bootstrap file
  mv "$TARGET/plugins/your-plugin" "$TARGET/plugins/$PLUGIN_SLUG"
  mv "$TARGET/plugins/$PLUGIN_SLUG/your-plugin.php" \
     "$TARGET/plugins/$PLUGIN_SLUG/$PLUGIN_SLUG.php"

  echo "  ✓ plugins/your-plugin → plugins/$PLUGIN_SLUG"
fi

# ── Substitutions ─────────────────────────────────────────────────────────────

echo "Running substitutions..."

# Derive UPPER_PLUGIN for PHP constant prefix (e.g. clf8-plugin → CLF8_PLUGIN)
UPPER_PLUGIN="$(echo "$PLUGIN_SLUG" | tr '[:lower:]-' '[:upper:]_')"

# Files that always get substitutions (Claude layer)
SUBST_FILES=(
  "$TARGET/CLAUDE.md"
  "$TARGET/composer.json"
  "$TARGET/phpcs.xml.dist"
)

# Files that only exist in fresh mode (WordPress scaffold)
if [[ "$MODE" == "fresh" ]]; then
  SUBST_FILES+=(
    "$TARGET/plugins/$PLUGIN_SLUG/$PLUGIN_SLUG.php"
    "$TARGET/.wp-env.json"
  )
fi

for f in "${SUBST_FILES[@]}"; do
  [[ -f "$f" ]] || continue

  # Bracketed placeholder form used in CLAUDE.md (e.g. [your-theme])
  sedi "s/\[your-theme\]/$THEME_SLUG/g"   "$f"
  sedi "s/\[your-plugin\]/$PLUGIN_SLUG/g" "$f"

  # Plain slug substitutions
  sedi "s/your-theme/$THEME_SLUG/g"    "$f"
  sedi "s/your-project/$PLUGIN_SLUG/g" "$f"
  sedi "s/your-plugin/$PLUGIN_SLUG/g"  "$f"
  sedi "s/your-vendor/$VENDOR/g"       "$f"

  # Namespace and constant prefix
  sedi "s/YourPlugin/$NAMESPACE/g"     "$f"
  sedi "s/YOUR_PLUGIN/$UPPER_PLUGIN/g" "$f"

  echo "  ✓ $(basename "$f")"
done

# Patch settings.json permission globs with actual theme and plugin slugs
SETTINGS="$TARGET/.claude/settings.json"
if [[ -f "$SETTINGS" ]]; then
    sedi "s|themes/your-theme|themes/$THEME_SLUG|g" "$SETTINGS"
    sedi "s|plugins/your-plugin|plugins/$PLUGIN_SLUG|g" "$SETTINGS"
    echo "  ✓ .claude/settings.json (permission globs updated)"
fi

# ── Post-substitution verification ────────────────────────────────────────────

echo ""
echo "Checking for remaining placeholders..."

REMAINING=$(grep -rl \
  "your-theme\|your-plugin\|your-project\|your-vendor\|YourPlugin\|YOUR_PLUGIN\|Your Plugin\|Your Name\|example\.com" \
  "$TARGET" \
  --exclude-dir=.git \
  --exclude-dir=vendor \
  --exclude-dir=node_modules \
  2>/dev/null || true)

if [[ -n "$REMAINING" ]]; then
  echo ""
  echo "WARNING: Placeholder strings still found in the following files."
  echo "Review them manually and update any missed values:"
  echo ""
  echo "$REMAINING" | sed 's/^/  /'
  echo ""
else
  echo "  ✓ No remaining placeholders found."
fi

# ── Optional vault integration ────────────────────────────────────────────────

VAULT_WIRED=false

if [[ -n "$VAULT_PATH" ]]; then
  if [[ ! -d "$VAULT_PATH" ]]; then
    echo ""
    echo "WARNING: Vault path '$VAULT_PATH' not found — skipping vault integration."
    echo "         Run bin/retrofit-vault.sh once the vault is accessible."
  else
    VAULT_RESOLVED="$(cd "$VAULT_PATH" && pwd)"
    VAULT_BRIEF_PATH="$VAULT_RESOLVED/wiki/synthesis/$PLUGIN_SLUG-brief.md"

    POINTER_FILE="$TARGET/.claude/reference/vault-brief-pointer.md"
    cat > "$POINTER_FILE" <<EOF
# Vault Brief Pointer

Project slug: $PLUGIN_SLUG
Vault brief: $VAULT_BRIEF_PATH

## Session start instruction

At the start of every session, before writing any code, read the vault brief at:

  $VAULT_BRIEF_PATH

This file contains cross-project context, active initiatives, and decisions that span
multiple repositories. Copy or open the path above in Obsidian to view or edit it.
EOF
    echo "  ✓ .claude/reference/vault-brief-pointer.md"

    CLAUDE_MD="$TARGET/CLAUDE.md"
    SECTION_HEADER="## Cross-Project Context"
    if ! grep -qF "$SECTION_HEADER" "$CLAUDE_MD" 2>/dev/null; then
      printf '\n%s\n\nSee `.claude/reference/vault-brief-pointer.md` for the Obsidian vault brief\npath and session-start instruction.\n' \
        "$SECTION_HEADER" >> "$CLAUDE_MD"
      echo "  ✓ CLAUDE.md (appended Cross-Project Context section)"
    fi

    GITIGNORE="$TARGET/.gitignore"
    POINTER_ENTRY=".claude/reference/vault-brief-pointer.md"
    if ! grep -qF "$POINTER_ENTRY" "$GITIGNORE" 2>/dev/null; then
      printf '\n# Obsidian vault pointer — machine-local, not committed\n%s\n' \
        "$POINTER_ENTRY" >> "$GITIGNORE"
      echo "  ✓ .gitignore (added vault-brief-pointer.md entry)"
    fi

    VAULT_WIRED=true
  fi
fi

# ── Completion summary ─────────────────────────────────────────────────────────

echo ""
echo "Bootstrap complete."
echo ""
echo "Next steps:"

if [[ "$MODE" == "dropin" ]]; then
  echo "  1. Review and fill in CLAUDE.md (project name, focus, known issues)"
  echo "  2. Review and fill in PROJECT-SPEC.md"
  echo "  3. Review .claude/settings.json — update permission globs to match your repo structure"
  echo "  4. Run composer install"
  echo "  5. Open DECISIONS.md and document the key architectural decisions already"
  echo "     present in this project (data layer, auth approach, hook patterns, etc.)"
  echo "     Claude will read this file — a blank file means no historical context."
  if [[ "$VAULT_WIRED" == true ]]; then
    echo "  6. Create the vault brief in Obsidian at:"
    echo "     $VAULT_BRIEF_PATH"
  fi
else
  echo "  1. Review and fill in CLAUDE.md (project name, focus, known issues)"
  echo "  2. Review and fill in PROJECT-SPEC.md"
  echo "  3. Run composer install"
  echo "  4. Run: npx wp-env start"
  if [[ "$VAULT_WIRED" == true ]]; then
    echo "  5. Create the vault brief in Obsidian at:"
    echo "     $VAULT_BRIEF_PATH"
  fi
fi

# ── Optional triage (dropin mode only) ────────────────────────────────────────
if [[ "$MODE" == "dropin" ]]; then
    echo ""
    echo "Project triage (recommended for existing projects):"
    echo "  The wp-project-triage skill inspects your codebase and produces a"
    echo "  diagnostic report. Claude can use this to pre-fill your CLAUDE.md"
    echo "  and identify gaps before you start development work."
    echo ""
    read -rp "Run wp-project-triage now to analyse the existing project? [Y/n]: " _run_triage

    if [[ ! "$_run_triage" =~ ^[Nn]$ ]]; then
        echo ""
        echo "Launching Claude Code to triage the existing project..."
        echo "(Running: claude in $TARGET)"
        echo ""
        cd "$TARGET"
        claude --dangerously-skip-permissions \
            "Run the wp-project-triage skill on this repository. \
            After the triage report is complete: \
            1. Use the findings to fill in the project name, description, \
               and 'What's in This Repo' section of CLAUDE.md. \
            2. Document any architectural patterns you observe \
               (data layer approach, hook conventions, namespace structure, \
               theme/plugin boundary decisions) in DECISIONS.md. \
            3. List any gaps, inconsistencies, or risks you find in the \
               'Known Issues / Gotchas' section of CLAUDE.md. \
            4. Report what you filled in and what still needs manual input."
    else
        echo ""
        echo "Skipped. To run triage later, open Claude Code in $TARGET and run /wp-project-triage"
    fi
fi

# ── wp-theme invocation (fresh mode only) ─────────────────────────────────────

if [[ "$MODE" == "fresh" && "$NO_THEME" == false ]]; then
  echo ""
  echo "Launching Claude Code to generate the theme skeleton..."
  echo "(Running: claude --dangerously-skip-permissions in $TARGET)"
  echo ""
  cd "$TARGET"
  claude --dangerously-skip-permissions \
    "Generate a full WordPress theme skeleton using the wp-theme skill. \
Theme slug: $THEME_SLUG. \
Plugin slug: $PLUGIN_SLUG. \
Vendor: $VENDOR. \
Namespace: $NAMESPACE."
elif [[ "$MODE" == "fresh" && "$NO_THEME" == true ]]; then
  echo ""
  echo "Theme skeleton skipped (--no-theme). When ready, open Claude Code in"
  echo "$TARGET and run /wp-theme."
fi
