# Scaffold Improvements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split the scaffold into two repos (`wp-scaffold-global` and `wp-scaffold-project`), restructure `wp-scaffold-project` so the Claude layer lives at root and WordPress structure lives in `scaffolds/wp-content/`, and ship `bin/init.sh` as the authoritative bootstrap mechanism for both drop-in and fresh build workflows.

**Architecture:** The current `scaffolding` repo is restructured in-place to become `wp-scaffold-project`. The `global/` directory is extracted into a new sibling repo (`wp-scaffold-global`). The Claude layer files (CLAUDE.md, `.claude/`, config files) become the portable unit at the repo root — they drop into any repo structure regardless of whether it is a wp-content root, theme root, or themes directory. WordPress scaffolding (plugins skeleton, mu-plugins, etc.) lives in `scaffolds/wp-content/` and is only used in fresh build mode. The `wp-theme` skill handles theme generation after init.

**Tech Stack:** Bash (init.sh), Git, Claude Code CLI (invoked by init.sh for wp-theme in fresh build mode)

---

## File Map

**New files:**
- `bin/init.sh` — bootstrap script, drop-in and fresh build modes
- `scaffolds/wp-content/.gitignore` — comprehensive WP gitignore (from `project/.gitignore` + nested .git rule)
- `scaffolds/wp-content/.wp-env.json` — moved from `project/`
- `scaffolds/wp-content/languages/.gitkeep`
- `scaffolds/wp-content/mu-plugins/.gitkeep`
- `scaffolds/wp-content/plugins/your-plugin/` — full plugin skeleton (moved from `project/plugins/your-plugin/`)
- `scaffolds/wp-content/tests/Unit/.gitkeep`
- `scaffolds/wp-content/tests/Integration/.gitkeep`
- `~/Sites/wp-scaffold-global/` — new separate repo (extracted from `global/`)

**Moved to root (from `project/`):**
- `project/CLAUDE.md` → `CLAUDE.md`
- `project/DECISIONS.md` → `DECISIONS.md`
- `project/PROJECT-SPEC.md` → `PROJECT-SPEC.md`
- `project/.claude/` → `.claude/`
- `project/.editorconfig` → `.editorconfig`
- `project/.mcp.json` → `.mcp.json`
- `project/composer.json` → `composer.json`
- `project/phpcs.xml.dist` → `phpcs.xml.dist`
- `project/phpunit.xml.dist` → `phpunit.xml.dist`
- `project/docs/DEVELOPMENT-PROMPTS.md` → `docs/DEVELOPMENT-PROMPTS.md`

**Modified:**
- `.claude/reference/README.md` — add .git stripping note
- `README.md` — full rewrite for two-repo structure

**Deleted from this repo:**
- `project/` directory (all contents moved above)
- `global/` directory (extracted to wp-scaffold-global)

---

## Task 1: Create wp-scaffold-global repo

**Files:**
- Create: `~/Sites/wp-scaffold-global/` (new git repo)

- [ ] **Step 1: Create the new repo directory and initialize git**

```bash
mkdir ~/Sites/wp-scaffold-global
cd ~/Sites/wp-scaffold-global
git init
```

Expected: `Initialized empty Git repository in ~/Sites/wp-scaffold-global/.git/`

- [ ] **Step 2: Copy global/ contents into the new repo**

Run from the `scaffolding` repo root:

```bash
cp -r ~/Sites/scaffolding/global/skills ~/Sites/wp-scaffold-global/
cp -r ~/Sites/scaffolding/global/agents ~/Sites/wp-scaffold-global/
cp -r ~/Sites/scaffolding/global/rules ~/Sites/wp-scaffold-global/
cp ~/Sites/scaffolding/global/install.sh ~/Sites/wp-scaffold-global/
```

- [ ] **Step 3: Add a minimal .gitignore**

```bash
cat > ~/Sites/wp-scaffold-global/.gitignore << 'EOF'
.DS_Store
Thumbs.db
.idea/
.vscode/
*.swp
*.swo
EOF
```

- [ ] **Step 4: Verify the structure**

```bash
find ~/Sites/wp-scaffold-global -not -path '*/.git/*' | sort
```

Expected output:
```
/Users/[you]/Sites/wp-scaffold-global
/Users/[you]/Sites/wp-scaffold-global/.gitignore
/Users/[you]/Sites/wp-scaffold-global/agents
/Users/[you]/Sites/wp-scaffold-global/agents/performance-profiler.md
/Users/[you]/Sites/wp-scaffold-global/agents/security-auditor.md
/Users/[you]/Sites/wp-scaffold-global/agents/wpcs-enforcer.md
/Users/[you]/Sites/wp-scaffold-global/install.sh
/Users/[you]/Sites/wp-scaffold-global/rules
/Users/[you]/Sites/wp-scaffold-global/rules/js-standards.md
/Users/[you]/Sites/wp-scaffold-global/rules/php-standards.md
/Users/[you]/Sites/wp-scaffold-global/rules/template-standards.md
/Users/[you]/Sites/wp-scaffold-global/rules/test-standards.md
/Users/[you]/Sites/wp-scaffold-global/skills
/Users/[you]/Sites/wp-scaffold-global/skills/wp-block
/Users/[you]/Sites/wp-scaffold-global/skills/wp-debug
/Users/[you]/Sites/wp-scaffold-global/skills/wp-feature
/Users/[you]/Sites/wp-scaffold-global/skills/wp-migrate
/Users/[you]/Sites/wp-scaffold-global/skills/wp-review
/Users/[you]/Sites/wp-scaffold-global/skills/wp-theme
```

- [ ] **Step 5: Initial commit**

```bash
cd ~/Sites/wp-scaffold-global
git add -A
git commit -m "feat: initial wp-scaffold-global repo — extracted from wp-scaffold-project"
```

---

## Task 2: Move Claude layer files from project/ to root

Run all commands from the `scaffolding` repo root.

**Files:**
- Modify: repo root (git mv operations)

- [ ] **Step 1: Move the Claude layer files**

```bash
git mv project/CLAUDE.md CLAUDE.md
git mv project/DECISIONS.md DECISIONS.md
git mv project/PROJECT-SPEC.md PROJECT-SPEC.md
git mv project/.editorconfig .editorconfig
git mv project/.mcp.json .mcp.json
git mv project/composer.json composer.json
git mv project/phpcs.xml.dist phpcs.xml.dist
git mv project/phpunit.xml.dist phpunit.xml.dist
git mv project/.claude .claude
```

- [ ] **Step 2: Move the docs file (docs/ already exists at root)**

```bash
git mv project/docs/DEVELOPMENT-PROMPTS.md docs/DEVELOPMENT-PROMPTS.md
```

- [ ] **Step 3: Verify the root now has the Claude layer**

```bash
ls -la
```

Expected to see at root: `.claude/`, `.editorconfig`, `.mcp.json`, `CLAUDE.md`, `DECISIONS.md`, `PROJECT-SPEC.md`, `composer.json`, `docs/`, `phpcs.xml.dist`, `phpunit.xml.dist`

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor: move Claude layer from project/ to repo root"
```

---

## Task 3: Create scaffolds/wp-content/ from project/ WordPress assets

**Files:**
- Create: `scaffolds/wp-content/` tree (see file map)

- [ ] **Step 1: Create the scaffolds directory structure**

```bash
mkdir -p scaffolds/wp-content
```

- [ ] **Step 2: Move the plugin skeleton**

```bash
git mv project/plugins scaffolds/wp-content/plugins
```

- [ ] **Step 3: Move mu-plugins, languages, tests**

```bash
git mv project/mu-plugins scaffolds/wp-content/mu-plugins
git mv project/languages scaffolds/wp-content/languages
git mv project/tests scaffolds/wp-content/tests
```

- [ ] **Step 4: Move .wp-env.json**

```bash
git mv project/.wp-env.json scaffolds/wp-content/.wp-env.json
```

- [ ] **Step 5: Copy and update .gitignore to scaffolds/wp-content/**

Copy the project-level gitignore (which has all WordPress-appropriate ignores) and add the nested .git rule:

```bash
cp project/.gitignore scaffolds/wp-content/.gitignore
```

Open `scaffolds/wp-content/.gitignore` and append at the end:

```
# Reference repos — strip .git before committing
.claude/reference/**/.git
```

The full `scaffolds/wp-content/.gitignore` should read:

```gitignore
# Dependencies
vendor/
node_modules/

# Build output
build/
dist/

# WordPress core and third-party
wp-content/uploads/
wp-content/upgrade/

# OS files
.DS_Store
Thumbs.db

# IDE
.idea/
.vscode/
*.swp
*.swo

# Environment and secrets
.env
.env.*
wp-config.php

# Claude Code — project-level config
# .claude/settings.json is committed (shared permissions)
# .claude/reference/ is committed (shared reference material)
# skills/, agents/, rules/ are NOT present here — they live in ~/.claude/ (see wp-scaffold-global)
.claude/reference/local/
.claude/settings.local.json

# Reference repos — strip .git before committing
.claude/reference/**/.git

# Logs
*.log
debug.log
```

- [ ] **Step 6: Verify the scaffolds structure**

```bash
find scaffolds -not -path '*/.git/*' | sort
```

Expected:
```
scaffolds
scaffolds/wp-content
scaffolds/wp-content/.gitignore
scaffolds/wp-content/.wp-env.json
scaffolds/wp-content/languages
scaffolds/wp-content/languages/.gitkeep
scaffolds/wp-content/mu-plugins
scaffolds/wp-content/mu-plugins/.gitkeep
scaffolds/wp-content/plugins
scaffolds/wp-content/plugins/your-plugin
scaffolds/wp-content/plugins/your-plugin/assets
...
scaffolds/wp-content/tests
scaffolds/wp-content/tests/Integration
scaffolds/wp-content/tests/Unit
```

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "refactor: create scaffolds/wp-content/ from project/ WordPress assets"
```

---

## Task 4: Remove project/ and global/ from this repo

**Files:**
- Delete: `project/` (themes/ remains — remove it; project/ dir should now be empty or contain only themes/)
- Delete: `global/`

- [ ] **Step 1: Check what remains in project/**

```bash
find project -not -path '*/.git/*' | sort
```

Expected: only `project/themes/` and `project/.gitignore` remain (everything else was moved).

- [ ] **Step 2: Remove project/themes/ (no pre-scaffolded theme — wp-theme skill handles this)**

```bash
git rm -r project/themes
git rm project/.gitignore
```

- [ ] **Step 3: Remove the now-empty project/ directory**

```bash
rmdir project
```

- [ ] **Step 4: Remove global/ from this repo (contents now live in wp-scaffold-global)**

```bash
git rm -r global
```

- [ ] **Step 5: Verify project/ and global/ are gone**

```bash
ls
```

Expected at root: `.claude/`, `.editorconfig`, `.gitignore`, `.mcp.json`, `CLAUDE.md`, `DECISIONS.md`, `PROJECT-SPEC.md`, `README.md`, `composer.json`, `docs/`, `phpcs.xml.dist`, `phpunit.xml.dist`, `scaffolds/`

No `project/` or `global/`.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "refactor: remove project/ and global/ from wp-scaffold-project"
```

---

## Task 5: Update .claude/reference/README.md

**Files:**
- Modify: `.claude/reference/README.md`

- [ ] **Step 1: Add the .git stripping note to the Git Behavior section**

Open `.claude/reference/README.md`. The current "Git Behavior" section reads:

```markdown
## Git Behavior

- `reference/` is committed (shared with team)
- `reference/local/` is gitignored (personal scratchpad)
```

Replace it with:

```markdown
## Git Behavior

- `reference/` is committed (shared with team)
- `reference/local/` is gitignored (personal scratchpad)
- Reference repos dropped here often carry `.git` folders — strip them before
  committing: `rm -rf .claude/reference/your-repo/.git`. If you need the
  reference to stay updatable, use a git submodule instead. The `.gitignore`
  blocks nested `.git` dirs as a safety net, but the strip step is still
  required for a clean clone.
```

- [ ] **Step 2: Verify the file looks correct**

```bash
cat .claude/reference/README.md
```

Confirm the Git Behavior section has all three bullet points.

- [ ] **Step 3: Commit**

```bash
git add .claude/reference/README.md
git commit -m "docs: add .git stripping guidance to reference README"
```

---

## Task 6: Write bin/init.sh — skeleton, arg parsing, and validation

**Files:**
- Create: `bin/init.sh`

- [ ] **Step 1: Create the bin/ directory and script file**

```bash
mkdir -p bin
touch bin/init.sh
chmod +x bin/init.sh
```

- [ ] **Step 2: Write the script skeleton with arg parsing and interactive prompts**

Write `bin/init.sh`:

```bash
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
    --mode)      MODE="$2";       shift 2 ;;
    --target)    TARGET="$2";     shift 2 ;;
    --theme)     THEME_SLUG="$2"; shift 2 ;;
    --plugin)    PLUGIN_SLUG="$2";shift 2 ;;
    --vendor)    VENDOR="$2";     shift 2 ;;
    --namespace) NAMESPACE="$2";  shift 2 ;;
    --no-theme)  NO_THEME=true;   shift   ;;
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
  local -n _ref=$1
  local _prompt="$2"
  if [[ -z "$_ref" ]]; then
    read -rp "$_prompt " _ref
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

prompt_value TARGET     "Target directory (absolute path):"
prompt_value THEME_SLUG "Theme slug (e.g. clf8):"
prompt_value PLUGIN_SLUG "Plugin slug (e.g. clf8-plugin):"
prompt_value VENDOR     "Composer vendor name (e.g. acme):"
prompt_value NAMESPACE  "PHP namespace prefix (e.g. AcmeCorp):"

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
```

- [ ] **Step 3: Verify the script runs and handles flags correctly**

```bash
# Test: all flags supplied — should print summary and prompt for confirm
./bin/init.sh --mode dropin --target /tmp --theme my-theme \
  --plugin my-plugin --vendor acme --namespace AcmeCorp
# At the "Proceed?" prompt, type n to abort
```

Expected: summary printed, then "Aborted."

```bash
# Test: unknown flag — should print usage
./bin/init.sh --invalid-flag 2>&1 || true
```

Expected: "Unknown flag: --invalid-flag" and usage line.

```bash
# Test: bad mode value — should exit with error
./bin/init.sh --mode bad --target /tmp --theme a --plugin b --vendor c --namespace D 2>&1 || true
```

Expected: "Invalid --mode value 'bad'."

```bash
# Test: nonexistent target — should exit with error
./bin/init.sh --mode dropin --target /nonexistent --theme a --plugin b --vendor c --namespace D 2>&1 || true
```

Expected: "Error: target directory '/nonexistent' does not exist."

- [ ] **Step 4: Commit**

```bash
git add bin/init.sh
git commit -m "feat: add bin/init.sh skeleton with arg parsing and validation"
```

---

## Task 7: bin/init.sh — Claude layer copy and .gitignore handling

**Files:**
- Modify: `bin/init.sh`

- [ ] **Step 1: Add the copy_claude_layer function after the "Starting bootstrap..." echo**

Append to `bin/init.sh` after the `echo "Starting bootstrap..."` line:

```bash
# ── Copy Claude layer ──────────────────────────────────────────────────────────

CLAUDE_LAYER=(
  ".claude"
  ".editorconfig"
  ".mcp.json"
  "CLAUDE.md"
  "DECISIONS.md"
  "PROJECT-SPEC.md"
  "composer.json"
  "docs"
  "phpcs.xml.dist"
  "phpunit.xml.dist"
)

echo "Copying Claude layer..."
for item in "${CLAUDE_LAYER[@]}"; do
  cp -r "$REPO_ROOT/$item" "$TARGET/"
  echo "  ✓ $item"
done
```

- [ ] **Step 2: Add .gitignore handling after the Claude layer copy**

Append:

```bash
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
```

- [ ] **Step 3: Verify drop-in mode copies files and appends .gitignore correctly**

```bash
TEST_DIR=$(mktemp -d)
# Pre-create a .gitignore so we test the append path
echo "# existing ignores" > "$TEST_DIR/.gitignore"

printf 'Y\n' | ./bin/init.sh \
  --mode dropin \
  --target "$TEST_DIR" \
  --theme mytest \
  --plugin myplugin \
  --vendor acme \
  --namespace AcmeCorp

# Check files were copied
ls "$TEST_DIR"
```

Expected: `.claude/`, `.editorconfig`, `.mcp.json`, `CLAUDE.md`, `DECISIONS.md`, `PROJECT-SPEC.md`, `composer.json`, `docs/`, `phpcs.xml.dist`, `phpunit.xml.dist`, `.gitignore`

```bash
# Check .gitignore has both original content and Claude entries
cat "$TEST_DIR/.gitignore"
```

Expected: "# existing ignores" followed by the Claude gitignore block.

```bash
rm -rf "$TEST_DIR"
```

- [ ] **Step 4: Verify fresh mode copies the full .gitignore**

```bash
TEST_DIR=$(mktemp -d)

printf 'Y\n' | ./bin/init.sh \
  --mode fresh \
  --target "$TEST_DIR" \
  --theme mytest \
  --plugin myplugin \
  --vendor acme \
  --namespace AcmeCorp \
  --no-theme

cat "$TEST_DIR/.gitignore"
```

Expected: full WP gitignore content including `.claude/reference/**/.git` line.

```bash
rm -rf "$TEST_DIR"
```

- [ ] **Step 5: Commit**

```bash
git add bin/init.sh
git commit -m "feat: bin/init.sh — Claude layer copy and .gitignore handling"
```

---

## Task 8: bin/init.sh — fresh build scaffold copy and substitutions

**Files:**
- Modify: `bin/init.sh`

- [ ] **Step 1: Add cross-platform sed helper and fresh mode scaffold copy**

Append to `bin/init.sh`:

```bash
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

  cp -r "$SCAFFOLD/languages"  "$TARGET/"
  cp -r "$SCAFFOLD/mu-plugins" "$TARGET/"
  cp -r "$SCAFFOLD/plugins"    "$TARGET/"
  cp -r "$SCAFFOLD/tests"      "$TARGET/"
  cp    "$SCAFFOLD/.wp-env.json" "$TARGET/"

  echo "  ✓ languages, mu-plugins, plugins, tests, .wp-env.json"

  # Rename plugin directory and bootstrap file
  mv "$TARGET/plugins/your-plugin"          "$TARGET/plugins/$PLUGIN_SLUG"
  mv "$TARGET/plugins/$PLUGIN_SLUG/your-plugin.php" \
     "$TARGET/plugins/$PLUGIN_SLUG/$PLUGIN_SLUG.php"

  echo "  ✓ plugins/your-plugin → plugins/$PLUGIN_SLUG"
fi
```

- [ ] **Step 2: Add substitutions**

Append:

```bash
# ── Substitutions ─────────────────────────────────────────────────────────────

echo "Running substitutions..."

# Derive UPPER_PLUGIN for PHP constant prefix (e.g. clf8-plugin → CLF8_PLUGIN)
UPPER_PLUGIN="${PLUGIN_SLUG^^}"
UPPER_PLUGIN="${UPPER_PLUGIN//-/_}"

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
```

- [ ] **Step 3: Verify substitutions in fresh mode**

```bash
TEST_DIR=$(mktemp -d)

printf 'Y\n' | ./bin/init.sh \
  --mode fresh \
  --target "$TEST_DIR" \
  --theme clf8 \
  --plugin clf8-plugin \
  --vendor clarifyfirst \
  --namespace ClarifyFirst \
  --no-theme

# Check plugin directory renamed
ls "$TEST_DIR/plugins/"
```

Expected: `clf8-plugin/` directory.

```bash
# Check plugin PHP file — slug-based fields substituted, display fields left for manual completion
cat "$TEST_DIR/plugins/clf8-plugin/clf8-plugin.php"
```

Expected substituted: `Text Domain: clf8-plugin`, `CLF8_PLUGIN_VERSION`, `CLF8_PLUGIN_FILE`, `CLF8_PLUGIN_DIR`, `CLF8_PLUGIN_URL`, `@package ClarifyFirst`

NOT substituted (require manual completion): `Plugin Name: Your Plugin`, `Author: Your Name`, `Plugin URI: https://example.com`, `Author URI: https://example.com`. These are flagged by the post-substitution verification step (Task 9).

```bash
# Check composer.json substituted
cat "$TEST_DIR/composer.json"
```

Expected: `"name": "clarifyfirst/clf8-plugin"`, `"ClarifyFirst\\": "plugins/clf8-plugin/src/"`

```bash
# Check phpcs.xml.dist substituted
grep "element value" "$TEST_DIR/phpcs.xml.dist"
```

Expected: `<element value="clf8"/>` and `<element value="clf8-plugin"/>`

```bash
# Check .wp-env.json substituted
cat "$TEST_DIR/.wp-env.json"
```

Expected: `"./themes/clf8"` and `"./plugins/clf8-plugin"`

```bash
rm -rf "$TEST_DIR"
```

- [ ] **Step 4: Verify substitutions in drop-in mode**

```bash
TEST_DIR=$(mktemp -d)

printf 'Y\n' | ./bin/init.sh \
  --mode dropin \
  --target "$TEST_DIR" \
  --theme clf8 \
  --plugin clf8-plugin \
  --vendor clarifyfirst \
  --namespace ClarifyFirst

grep "clf8" "$TEST_DIR/CLAUDE.md" | head -5
grep "clarifyfirst" "$TEST_DIR/composer.json"
```

Expected: theme and plugin slug appear in CLAUDE.md, vendor appears in composer.json.

```bash
rm -rf "$TEST_DIR"
```

- [ ] **Step 5: Commit**

```bash
git add bin/init.sh
git commit -m "feat: bin/init.sh — fresh build scaffold copy and substitutions"
```

---

## Task 9: bin/init.sh — post-substitution verification

**Files:**
- Modify: `bin/init.sh`

- [ ] **Step 1: Add the verification grep after the substitutions block**

Append to `bin/init.sh`:

```bash
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
```

- [ ] **Step 2: Verify the warning triggers when a placeholder remains**

```bash
TEST_DIR=$(mktemp -d)

printf 'Y\n' | ./bin/init.sh \
  --mode dropin \
  --target "$TEST_DIR" \
  --theme clf8 \
  --plugin clf8-plugin \
  --vendor clarifyfirst \
  --namespace ClarifyFirst

# Manually introduce a placeholder into a copied file
echo "# your-plugin was here" >> "$TEST_DIR/CLAUDE.md"

# Run grep manually (simulating the verification step)
grep -rl "your-plugin" "$TEST_DIR" --exclude-dir=.git 2>/dev/null || true
```

Expected: `CLAUDE.md` path printed.

```bash
rm -rf "$TEST_DIR"
```

- [ ] **Step 3: Verify the post-substitution check runs as part of the script**

Note: In fresh mode the grep will flag `Your Plugin`, `Your Name`, and `example.com` in the plugin PHP file — this is expected and intentional. Those fields require manual completion. The warning surfaces them so the developer knows what still needs updating.

```bash
TEST_DIR=$(mktemp -d)

printf 'Y\n' | ./bin/init.sh \
  --mode dropin \
  --target "$TEST_DIR" \
  --theme clf8 \
  --plugin clf8-plugin \
  --vendor clarifyfirst \
  --namespace ClarifyFirst
```

Expected final lines include: `✓ No remaining placeholders found.` (drop-in mode has no plugin PHP, so no manual fields to flag)

```bash
rm -rf "$TEST_DIR"
```

- [ ] **Step 4: Commit**

```bash
git add bin/init.sh
git commit -m "feat: bin/init.sh — post-substitution placeholder verification"
```

---

## Task 10: bin/init.sh — wp-theme invocation and completion summary

**Files:**
- Modify: `bin/init.sh`

- [ ] **Step 1: Add completion summary and wp-theme invocation**

Append to `bin/init.sh`:

```bash
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
```

- [ ] **Step 2: Verify --no-theme skips the claude invocation**

```bash
TEST_DIR=$(mktemp -d)

printf 'Y\n' | ./bin/init.sh \
  --mode fresh \
  --target "$TEST_DIR" \
  --theme clf8 \
  --plugin clf8-plugin \
  --vendor clarifyfirst \
  --namespace ClarifyFirst \
  --no-theme
```

Expected final output includes: "Theme skeleton skipped (--no-theme). When ready, open Claude Code in..."

Does NOT include: "Launching Claude Code"

```bash
rm -rf "$TEST_DIR"
```

- [ ] **Step 3: Verify drop-in completion message is correct**

```bash
TEST_DIR=$(mktemp -d)

printf 'Y\n' | ./bin/init.sh \
  --mode dropin \
  --target "$TEST_DIR" \
  --theme clf8 \
  --plugin clf8-plugin \
  --vendor clarifyfirst \
  --namespace ClarifyFirst
```

Expected: completion summary includes "Review .claude/settings.json" step. Does NOT mention wp-env.

```bash
rm -rf "$TEST_DIR"
```

- [ ] **Step 4: Commit**

```bash
git add bin/init.sh
git commit -m "feat: bin/init.sh — completion summary and wp-theme invocation"
```

---

## Task 11: Update README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Rewrite README.md for the two-repo structure**

Replace the entire contents of `README.md` with:

```markdown
# wp-scaffold-project

A per-project starter template for WordPress development with Claude Code.
Drop the Claude layer into any WordPress repo structure, or use fresh build mode
to scaffold a full project in one command.

For the machine-level Claude configuration (skills, agents, rules), see
[wp-scaffold-global](https://github.com/your-org/wp-scaffold-global).

---

## Two repos, two jobs

| Repo | What it does | When you need it |
|------|-------------|-----------------|
| **wp-scaffold-global** | Skills, agents, rules, `install.sh` | Once per developer machine |
| **wp-scaffold-project** | Claude layer template + `bin/init.sh` | Once per new project |

---

## Step 1 — Global install (once per machine)

Clone [wp-scaffold-global](https://github.com/your-org/wp-scaffold-global) and run:

```bash
./install.sh
```

This symlinks skills, agents, and rules into `~/.claude/` so they are available
in every project automatically.

Verify:

```bash
ls ~/.claude/skills/
# should show: wp-block  wp-debug  wp-feature  wp-migrate  wp-review  wp-theme
```

---

## Step 2 — Bootstrap a project

Clone this repo, then run `bin/init.sh`. It handles everything: copying the
Claude layer, .gitignore setup, placeholder substitution, and optionally
generating a full theme skeleton.

```bash
git clone https://github.com/your-org/wp-scaffold-project.git
cd wp-scaffold-project
bin/init.sh
```

The script will prompt for any values not supplied as flags:

```
What type of bootstrap?
  [1] Drop into existing repo (Claude layer only)
  [2] Fresh build (Claude layer + WordPress structure + theme skeleton)
Choice [1/2]:
```

### Drop-in mode

Use when adding Claude Code to an existing repo, regardless of whether
the root is a wp-content directory, a single theme directory, or a themes
directory:

```bash
bin/init.sh \
  --mode dropin \
  --target /path/to/existing-project \
  --theme my-theme \
  --plugin my-plugin \
  --vendor acme \
  --namespace AcmeCorp
```

Copies: `.claude/`, `CLAUDE.md`, `PROJECT-SPEC.md`, `DECISIONS.md`,
`.editorconfig`, `.mcp.json`, `composer.json`, `phpcs.xml.dist`,
`phpunit.xml.dist`, `docs/`

Appends Claude-relevant entries to the target's existing `.gitignore`
(or creates one).

### Fresh build mode

Use when starting a new project from scratch:

```bash
bin/init.sh \
  --mode fresh \
  --target /path/to/new-project \
  --theme my-theme \
  --plugin my-plugin \
  --vendor acme \
  --namespace AcmeCorp
```

Copies the Claude layer + WordPress scaffold (plugins skeleton, mu-plugins,
languages, tests, `.wp-env.json`, `.gitignore`), runs all placeholder
substitutions, then launches Claude Code to generate the theme skeleton via
the `wp-theme` skill.

Pass `--no-theme` to skip theme generation and run it manually later.

### All flags

| Flag | Prompt fallback | Description |
|------|----------------|-------------|
| `--mode dropin\|fresh` | Interactive menu | Bootstrap mode |
| `--target PATH` | Prompt | Where to bootstrap |
| `--theme SLUG` | Prompt | Theme slug (e.g. `my-theme`) |
| `--plugin SLUG` | Prompt | Plugin slug (e.g. `my-plugin`) |
| `--vendor NAME` | Prompt | Composer vendor (e.g. `acme`) |
| `--namespace NAME` | Prompt | PHP namespace prefix (e.g. `AcmeCorp`) |
| `--no-theme` | Interactive Y/n | Skip wp-theme in fresh build |

---

## Reference: what .claude/reference/ is for

`.claude/reference/` holds inspiration code, mockups, and API samples that
Claude reads during development. See `.claude/reference/README.md` for usage.

**Note on nested .git folders:** Reference repos dropped here often carry
`.git` folders. Strip them before committing:

```bash
rm -rf .claude/reference/your-repo/.git
```

The `.gitignore` blocks nested `.git` dirs as a safety net, but the strip
step is required for a clean clone by teammates.

---

## Skills reference

All skills are installed globally via wp-scaffold-global and work in every project.

| Skill | When to use |
|-------|-------------|
| `/wp-feature` | Add a feature, settings page, post type, REST endpoint, or new functionality |
| `/wp-block` | Create a Gutenberg block from scratch |
| `/wp-debug` | Investigate a bug or unexpected behavior |
| `/wp-migrate` | Handle a WordPress upgrade, PHP version bump, or API deprecation |
| `/wp-review` | Security and WPCS code review before merging |
| `/wp-theme` | Generate a full theme skeleton — FSE or hybrid — from scratch |
```

- [ ] **Step 2: Verify README renders correctly (spot check)**

```bash
head -60 README.md
```

Confirm: title is `# wp-scaffold-project`, two-repo table is present, `bin/init.sh` usage is documented.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README for two-repo structure and bin/init.sh bootstrap"
```

---

## Task 12: Final verification

- [ ] **Step 1: Verify the final repo structure**

```bash
find . -not -path '*/.git/*' -not -path '*/vendor/*' -not -path '*/node_modules/*' | sort
```

Expected root-level items: `.claude/`, `.editorconfig`, `.gitignore`, `.mcp.json`, `CLAUDE.md`, `DECISIONS.md`, `PROJECT-SPEC.md`, `README.md`, `bin/`, `composer.json`, `docs/`, `phpcs.xml.dist`, `phpunit.xml.dist`, `scaffolds/`

No `global/`, no `project/`.

- [ ] **Step 2: Confirm bin/init.sh is executable**

```bash
ls -la bin/init.sh
```

Expected: `-rwxr-xr-x`

- [ ] **Step 3: Run a full fresh build integration test**

```bash
TEST_DIR=$(mktemp -d)

printf 'Y\n' | ./bin/init.sh \
  --mode fresh \
  --target "$TEST_DIR" \
  --theme clf8 \
  --plugin clf8-plugin \
  --vendor clarifyfirst \
  --namespace ClarifyFirst \
  --no-theme

echo "--- Root contents ---"
ls "$TEST_DIR"

echo "--- Plugin contents ---"
ls "$TEST_DIR/plugins/clf8-plugin/"

echo "--- composer.json ---"
cat "$TEST_DIR/composer.json"

echo "--- .gitignore first 10 lines ---"
head -10 "$TEST_DIR/.gitignore"

echo "--- phpcs.xml.dist text domains ---"
grep "element value" "$TEST_DIR/phpcs.xml.dist"

rm -rf "$TEST_DIR"
```

Expected: plugin directory `clf8-plugin/` present, `composer.json` shows `clarifyfirst/clf8-plugin` and `ClarifyFirst\\`, phpcs shows both text domains substituted.

- [ ] **Step 4: Run a full drop-in integration test**

```bash
TEST_DIR=$(mktemp -d)
echo "# existing content" > "$TEST_DIR/.gitignore"
mkdir -p "$TEST_DIR/themes/clf8" "$TEST_DIR/plugins"

printf 'Y\n' | ./bin/init.sh \
  --mode dropin \
  --target "$TEST_DIR" \
  --theme clf8 \
  --plugin clf8-plugin \
  --vendor clarifyfirst \
  --namespace ClarifyFirst

echo "--- .gitignore ---"
cat "$TEST_DIR/.gitignore"

echo "--- CLAUDE.md slug check ---"
grep "clf8" "$TEST_DIR/CLAUDE.md" | head -3

rm -rf "$TEST_DIR"
```

Expected: `.gitignore` has original content + Claude block appended, CLAUDE.md references clf8.

- [ ] **Step 5: Confirm wp-scaffold-global is intact**

```bash
ls ~/Sites/wp-scaffold-global/
```

Expected: `agents/`, `install.sh`, `rules/`, `skills/`

- [ ] **Step 6: Tag the restructure complete**

```bash
git log --oneline | head -15
```

Review the commit history — confirm all restructure commits are present.

```bash
git tag v2.0.0 -m "v2.0.0: two-repo split, Claude layer as portable unit, bin/init.sh"
```

---

## Notes for implementer

- **`--dangerously-skip-permissions` in fresh mode:** The `claude` CLI invocation in Task 10 uses this flag so Claude can write the theme skeleton without prompting. Only safe because it runs in the freshly created target directory, not in the scaffold source. If this feels too permissive, remove the flag and Claude will prompt for each write.

- **GitHub template:** After pushing `wp-scaffold-project` to GitHub, mark it as a template repo: Settings → check "Template repository". This lets collaborators click "Use this template" as an alternative to cloning + running `bin/init.sh`.

- **wp-scaffold-global GitHub remote:** After Task 1, create the GitHub repo at `github.com/your-org/wp-scaffold-global` and push: `git remote add origin <url> && git push -u origin main`.

- **Re-running install.sh after the split:** Any developer who previously ran `global/install.sh` from the old `scaffolding` repo will have symlinks pointing to the old path. They need to clone `wp-scaffold-global` and run `install.sh` from there to update the symlinks.
