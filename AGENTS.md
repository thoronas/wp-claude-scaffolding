# Repository Instructions

This repository is a scaffold, not a live WordPress site.

## Layout

- `plugins/wordpress-codex/` contains the Codex plugin package and skills.
- `.agents/plugins/marketplace.json` exposes the local plugin to Codex.
- `project/` is the downstream WordPress project template.
- `global/` and `project/.claude/` are legacy Claude migration artifacts. Prefer Codex-native files for new work.

## Working Rules

- Keep Codex assets repo-local and machine-independent. Do not introduce new `~/.claude` or `~/.codex` dependencies into the scaffold.
- Treat `project/AGENTS.md`, `project/PROJECT-SPEC.md`, `project/DECISIONS.md`, and `project/docs/reference/` as the canonical project context for downstream repos.
- Keep skills concise. Move reusable guidance into nearby `references/` files instead of expanding `SKILL.md` unnecessarily.
- When editing both Codex and legacy Claude files, keep behavior aligned but make Codex the source of truth.
