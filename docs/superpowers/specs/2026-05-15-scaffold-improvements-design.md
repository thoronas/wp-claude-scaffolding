# Scaffold Improvements Design

**Date:** 2026-05-15
**Status:** Approved

## Background

During the bootstrap of a new project repo (clf8) from this scaffold, four friction points were identified:

1. The nested `project/` structure required an immediate manual restructure before any feature work could begin.
2. Reference repos dropped into `.claude/reference/` often carry `.git` folders — the scaffold gave no guidance on handling this.
3. Two `.gitignore` files with mismatched scopes left critical ignores missing at the root level before restructuring.
4. Placeholder cleanup (`your-theme`, `your-plugin`, etc.) required touching multiple files manually with no verification step.

## Decision

Split the current `scaffolding` repo into two repos and introduce `bin/init.sh` as the authoritative bootstrap mechanism. The Claude layer (CLAUDE.md, `.claude/`, config files) becomes the portable unit — it drops cleanly into any repo regardless of structure (wp-content root, single theme root, themes directory root).

## Repo Architecture

### `wp-scaffold-global`

Extracted from the current `global/` directory. Contains machine-level Claude configuration: skills, agents, rules, and `install.sh`. Content is unchanged — this is purely a structural extraction into its own repo. Clone once per machine, run `install.sh`.

### `wp-scaffold-project`

The current `scaffolding` repo restructured. The Claude layer files live at root. A `scaffolds/` directory contains WordPress-specific structure for fresh builds. Marked as a GitHub template on GitHub for convenience, but `bin/init.sh` is the authoritative bootstrap mechanism for all cases.

## `wp-scaffold-project` Structure

```
wp-scaffold-project/
├── .claude/
│   ├── settings.json
│   └── reference/
│       └── README.md          ← updated: .git stripping note added
├── bin/
│   └── init.sh                ← new: handles all bootstrap modes
├── scaffolds/
│   └── wp-content/            ← used by fresh build mode only
│       ├── .gitignore         ← comprehensive WP .gitignore + .claude/reference/**/.git rule
│       ├── .wp-env.json
│       ├── languages/
│       ├── mu-plugins/
│       ├── plugins/
│       │   └── your-plugin/   ← plugin skeleton (from current project/plugins/your-plugin/)
│       └── tests/
├── .editorconfig
├── .mcp.json
├── CLAUDE.md
├── DECISIONS.md
├── PROJECT-SPEC.md
├── composer.json
├── docs/
│   └── DEVELOPMENT-PROMPTS.md
├── phpcs.xml.dist
└── phpunit.xml.dist
```

**The Claude layer** is defined as the root-level files: `.claude/`, CLAUDE.md, PROJECT-SPEC.md, DECISIONS.md, `.editorconfig`, `.mcp.json`, `composer.json`, `phpcs.xml.dist`, `phpunit.xml.dist`, `docs/`. These are universal and work at any repo root level.

**`scaffolds/wp-content/`** contains WordPress-specific structure used only in fresh build mode. Themes are not pre-scaffolded here — the `wp-theme` skill handles theme generation.

## `bin/init.sh`

### Modes

**Drop-in mode** — for existing repos of any structure (wp-content root, theme root, themes dir root):

1. Copies the Claude layer into the target directory
2. Appends Claude-relevant `.gitignore` entries to the target's existing `.gitignore`, or creates one if absent. Entries added: `.claude/reference/**/.git`, `.claude/settings.local.json`, `.claude/reference/local/`
3. Runs placeholder substitution across all copied files (see Substitutions below)
4. Runs post-substitution grep check and warns with file paths if any placeholder strings remain

**Fresh build mode** — for new repos starting from scratch:

1. Everything drop-in mode does, plus:
2. Copies `scaffolds/wp-content/` to target: plugin skeleton, mu-plugins, languages, tests, `.wp-env.json`, `.gitignore`
3. Runs placeholder substitution across all of the above
4. Unless `--no-theme` is passed, invokes `claude` CLI at the end to kick off the `wp-theme` skill in the target directory

### Flags

All flags fall back to interactive prompts when omitted. Supplying all flags makes the script fully non-interactive.

| Flag | Interactive prompt | Purpose |
|---|---|---|
| `--mode [dropin\|fresh]` | "Mode? [1] Drop into existing repo [2] Fresh build:" | Selects bootstrap mode |
| `--target <path>` | "Target directory:" | Where to bootstrap |
| `--theme <slug>` | "Theme slug (e.g. clf8):" | Replaces `your-theme` |
| `--plugin <slug>` | "Plugin slug (e.g. clf8-plugin):" | Replaces `your-plugin` |
| `--vendor <name>` | "Composer vendor name (e.g. acme):" | Replaces `your-vendor` |
| `--namespace <Name>` | "PHP namespace prefix (e.g. AcmeCorp):" | Replaces `YourPlugin` |
| `--no-theme` | "Generate theme skeleton? [Y/n]:" | Skips `wp-theme` invocation in fresh build mode |

### Substitutions

The script runs substitutions across all files it copies. Theme files are not included — the `wp-theme` skill generates them with the correct slug after init.sh completes. Files affected:

| File | What changes |
|---|---|
| `plugins/your-plugin/your-plugin.php` | Plugin header, constants (`YOUR_PLUGIN_*`), `@package` docblock |
| `plugins/your-plugin/` directory | Directory renamed to plugin slug |
| `plugins/your-plugin/your-plugin.php` | File renamed to plugin slug |
| `composer.json` | `name` field (`your-vendor/your-project`), PSR-4 namespace key (`YourPlugin\\`) |
| `phpcs.xml.dist` | Both `<element value>` text domain entries (theme and plugin) |
| `.wp-env.json` | Theme path and plugin path (theme path updated so wp-env finds the generated theme correctly) |
| `CLAUDE.md` | Placeholder theme/plugin slug references |

### Post-substitution Verification

After all substitutions, the script greps for remaining placeholder strings (`your-theme`, `your-plugin`, `your-vendor`, `YourPlugin`) across all copied files and prints a warning with file paths for any matches found. This surfaces files that were added to the scaffold without being added to the substitution list.

### Evolution Path

A future `--theme-spec <file>` flag (Option C) will pass a pre-filled theme spec to Claude non-interactively instead of launching the interactive `wp-theme` flow. The answers already collected by init.sh (theme slug, vendor, namespace) can seed that spec file automatically — making the upgrade path straightforward.

## `.gitignore` Changes

The `.gitignore` in `scaffolds/wp-content/` is the current `project/.gitignore` content with one addition:

```
# Reference repos — strip .git before committing
.claude/reference/**/.git
```

In drop-in mode, init.sh appends only the Claude-specific entries to the target's existing `.gitignore` rather than overwriting it:

```gitignore
# Claude Code — project-level config
.claude/reference/**/.git
.claude/settings.local.json
.claude/reference/local/
```

The scaffold root (this repo) retains a minimal `.gitignore` covering OS/IDE only — correct for a tools repo, not a WordPress project.

## `.claude/reference/README.md` Update

One addition to the existing "Git Behavior" section:

> Reference repos dropped here often carry `.git` folders — strip them before committing: `rm -rf .claude/reference/your-repo/.git`. If you need the reference to stay updatable, use a git submodule instead. The `.gitignore` blocks nested `.git` dirs as a safety net, but the strip step is still required for a clean clone.

## Migration Path

The current `scaffolding` repo becomes `wp-scaffold-project`:

1. Extract `global/` contents into a new `wp-scaffold-global` repo
2. Delete `global/` from the current repo
3. Move `project/` contents to the repo root
4. Add `scaffolds/wp-content/` with content from current `project/plugins/`, `project/mu-plugins/`, `project/languages/`, `project/tests/`, `project/.wp-env.json`, `project/.gitignore`
5. Remove `themes/` from root (no pre-scaffolded theme — `wp-theme` skill handles this)
6. Add `bin/init.sh`
7. Update `.claude/reference/README.md`
8. Mark repo as GitHub template on GitHub
9. Update README to reflect new two-repo structure and `bin/init.sh` as primary bootstrap

## What This Does Not Change

- Content of skills, agents, and rules in `global/` — unchanged, just moved to a new repo
- The `wp-theme` skill workflow — init.sh invokes it, the skill itself is unmodified
- `.claude/settings.json` permission structure — unchanged
- CLAUDE.md, PROJECT-SPEC.md, DECISIONS.md templates — unchanged in content
