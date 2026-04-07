# WordPress Codex Scaffold

A Codex-first scaffold for WordPress development. It packages reusable WordPress
skills as a local Codex plugin and ships a per-project template with vendor-neutral
AI context files.

Legacy Claude assets are still present during the migration, but new work should
target the Codex-native layer first.

## Structure

```text
wp-scaffold/
├── AGENTS.md                         ← repo instructions for Codex maintainers
├── .agents/plugins/marketplace.json ← exposes the local Codex plugin
├── plugins/wordpress-codex/         ← Codex plugin with WordPress skills
│   ├── .codex-plugin/plugin.json
│   ├── references/
│   └── skills/
├── project/                         ← copy into each new WordPress project repo
│   ├── AGENTS.md
│   ├── PROJECT-SPEC.md
│   ├── DECISIONS.md
│   ├── docs/reference/
│   ├── themes/your-theme/
│   ├── plugins/your-plugin/
│   └── ...
└── global/                          ← legacy Claude migration layer
```

## Setup

### Step 1 — Enable the Codex plugin

This repository now ships a local Codex plugin at `plugins/wordpress-codex/`.
The repo-local marketplace entry lives at `.agents/plugins/marketplace.json`.

If you are working inside this repository, use Codex from the repo root so it can
see the local plugin layout. If you want the plugin available elsewhere, copy
`plugins/wordpress-codex/` into your Codex plugin location and add an entry to your
own marketplace file using the same shape as `.agents/plugins/marketplace.json`.

### Step 2 — Project setup

There are two paths depending on whether you're starting fresh or dropping into an
existing repo.

#### New project

Copy the `project/` directory into your new repo:

```bash
cp -r project/. /path/to/your/new-project
```

Then complete the rename checklist:

- [ ] Rename `themes/your-theme/` to your actual theme slug
- [ ] Rename `plugins/your-plugin/` to your actual plugin slug
- [ ] `AGENTS.md` — fill in project name, packages, text domains, and Current Focus
- [ ] `composer.json` — update vendor name and PSR-4 namespace
- [ ] `phpcs.xml.dist` — update text domain values
- [ ] `themes/[name]/style.css` — update theme header
- [ ] `plugins/[name]/[name].php` — update plugin header and constants
- [ ] `PROJECT-SPEC.md` — fill in packages table and first feature
- [ ] `docs/reference/` — add any design mockups, API samples, or code references
- [ ] `.wp-env.json` — update theme and plugin directory names
- [ ] Run `composer install`
- [ ] Open Codex in the project directory

#### Existing project

Drop in only the AI context layer:

| File | What it does | Commit it? |
| --- | --- | --- |
| `AGENTS.md` | Root instruction file for Codex and other AI agents | Yes |
| `PROJECT-SPEC.md` | Feature specs and data model | Yes |
| `DECISIONS.md` | Architecture decision log | Yes |
| `docs/reference/` | Shared examples, mockups, and API samples | Yes (except `docs/reference/local/`) |
| `.mcp.json` | Optional project MCP configuration | Yes, if used |

**Minimum viable drop-in**:

```bash
cp project/AGENTS.md /path/to/existing-project/
cp project/PROJECT-SPEC.md /path/to/existing-project/
cp project/DECISIONS.md /path/to/existing-project/
mkdir -p /path/to/existing-project/docs
cp -r project/docs/reference /path/to/existing-project/docs/
```

Then update `AGENTS.md` to match the real structure, commands, and conventions in
that repo. The Codex plugin remains shared; the project files hold the project-specific
context.

## Skills Reference

The local Codex plugin ships these skills:

| Skill | When to use |
|-------|-------------|
| `$wp-feature` | Add a feature, settings page, post type, REST endpoint, or other functionality |
| `$wp-block` | Create or extend a Gutenberg block |
| `$wp-debug` | Investigate a bug or unexpected behavior |
| `$wp-migrate` | Handle a WordPress upgrade, PHP version bump, or API deprecation |
| `$wp-review` | Review WordPress code for security, correctness, and maintainability |
| `$wp-security-audit` | Run a security-only review of WordPress code |
| `$wp-performance-review` | Audit WordPress code for performance issues |
| `$wp-wpcs-fix` | Run and fix WordPress Coding Standards violations |

## Install Workflow

Home-local install with live updates from this repo:

```bash
python3 plugins/wordpress-codex/scripts/install_plugin.py --target-root ~ --method symlink
```

Validate the installed plugin:

```bash
python3 plugins/wordpress-codex/scripts/validate_plugin.py \
  --plugin-root ~/plugins/wordpress-codex \
  --marketplace ~/.agents/plugins/marketplace.json
```

Run an end-to-end smoke test without touching home directories:

```bash
python3 plugins/wordpress-codex/scripts/smoke_test_install.py
```

## Migration Status

Codex-first assets added in this branch:

- Repo-level `AGENTS.md`
- Local Codex plugin package and marketplace entry
- Project-level `AGENTS.md`
- Vendor-neutral `project/docs/reference/`
- Focused Codex audit skills replacing the old Claude agent workflows

Still legacy for now:

- `global/` Claude skills, agents, and rules
- `project/CLAUDE.md`
- `project/.claude/`

## Contributing

- Update Codex skills in `plugins/wordpress-codex/`.
- Keep `project/AGENTS.md`, `PROJECT-SPEC.md`, `DECISIONS.md`, and `docs/reference/` vendor-neutral.
- Treat legacy Claude files as compatibility shims until the migration is complete.
