# Reference Material

This directory holds inspiration code, examples, and reference material that Claude
reads during development but that never ships with the project.

## How to Use

Everything in `.claude/reference/` is accessible to Claude Code during your session.
Claude does NOT auto-load this directory. It only reads files here when you reference
them or ask it to explore the reference material.

```
"Look at .claude/reference/plugins/acf-settings-page.php for how ACF
handles settings registration. Use that pattern for our settings page."
```

```
"Review the API response samples in .claude/reference/api-examples/
and build our data models to match that structure."
```

```
"The design is in .claude/reference/screenshots/settings-mockup.png.
Build the admin page to match this layout."
```

## Directory Structure

```
reference/
├── plugins/          Code from other plugins worth emulating
├── themes/           Theme patterns, theme.json configs, template examples
├── patterns/         Reusable code patterns and snippets
├── api-examples/     API request/response samples from third-party services
├── screenshots/      Design mockups, UI references, layout inspiration
└── local/            Personal references (gitignored)
```

## Naming Conventions

```
plugins/acf-settings-page.php           ✓ Clear
plugins/file3.php                        ✗ Meaningless
api-examples/crm-contacts-response.json ✓ Clear
screenshots/settings-page-mockup.png    ✓ Clear
```

## Git Behavior

- `reference/` is committed (shared with team)
- `reference/local/` is gitignored (personal scratchpad)
