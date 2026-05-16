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

# ── Arg parsing ───────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case $1 in
    --mode)      MODE="$2";        shift 2 ;;
    --target)    TARGET="$2";      shift 2 ;;
    --theme)     THEME_SLUG="$2";  shift 2 ;;
    --plugin)    PLUGIN_SLUG="$2"; shift 2 ;;
    --vendor)    VENDOR="$2";      shift 2 ;;
    --namespace) NAMESPACE="$2";   shift 2 ;;
    --no-theme)  NO_THEME=true;    shift   ;;
    *)
      echo "Unknown flag: $1"
      echo "Usage: $0 [--mode dropin|fresh] [--target PATH] [--theme SLUG]"
      echo "          [--plugin SLUG] [--vendor NAME] [--namespace NAME] [--no-theme]"
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

# Expand ~ in TARGET
TARGET="${TARGET/#\~/$HOME}"

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

echo "Copying Claude layer..."
for item in "${CLAUDE_LAYER[@]}"; do
  cp -r "$REPO_ROOT/$item" "$TARGET/"
  echo "  ✓ $item"
done

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
else
  echo "  1. Review and fill in CLAUDE.md (project name, focus, known issues)"
  echo "  2. Review and fill in PROJECT-SPEC.md"
  echo "  3. Run composer install"
  echo "  4. Run: npx wp-env start"
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
