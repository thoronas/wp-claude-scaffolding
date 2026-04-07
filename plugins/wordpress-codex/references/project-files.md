# Project Files

Read only the files that matter to the task at hand.

## Canonical context

- `AGENTS.md`: The root instruction file for Codex in a downstream project. Use it first for package layout, commands, and non-negotiable conventions.
- `PROJECT-SPEC.md`: Product requirements, ownership boundaries, user roles, data model, and acceptance criteria.
- `DECISIONS.md`: Architecture decisions that should not be undone casually.
- `docs/reference/`: Shared implementation examples, API payloads, UI mockups, theme patterns, and other reusable source material.

## Common supporting files

- `composer.json`: PHP tooling, autoloading, and project scripts.
- `phpcs.xml.dist`: WPCS configuration and text domains.
- `phpunit.xml.dist`: Test suite layout.
- `.mcp.json`: Optional MCP server configuration for project-specific systems.
- Theme and plugin bootstrap files: use the package boundaries in `AGENTS.md` and `PROJECT-SPEC.md` before adding new files.

## Reading strategy

- Start with `AGENTS.md`.
- Read `PROJECT-SPEC.md` before implementing features or migrations.
- Read `DECISIONS.md` before refactors or architectural changes.
- Open only the relevant file or folder under `docs/reference/`; do not bulk-load the whole directory unless the user explicitly asks for a broad review.
