# Reference Material

This directory holds inspiration code, examples, API payloads, and reference material
that AI coding tools can inspect during development but that never ships with the project.

## How to Use

`docs/reference/` is not meant to be bulk-loaded. Point the agent at the specific file
or directory that matches the task.

```text
"Look at docs/reference/plugins/acf-settings-page.php for how ACF
handles settings registration. Use that pattern for our settings page."
```

```text
"Review the API response samples in docs/reference/api-examples/
and build our data models to match that structure."
```

```text
"The design is in docs/reference/screenshots/settings-mockup.png.
Build the admin page to match this layout."
```

## Directory Structure

```text
reference/
├── plugins/          Code from other plugins worth emulating
├── themes/           Theme patterns, theme.json configs, template examples
├── patterns/         Reusable code patterns and snippets
├── api-examples/     API request/response samples from third-party services
├── screenshots/      Design mockups, UI references, layout inspiration
└── local/            Personal references (gitignored)
```

## Naming Conventions

```text
plugins/acf-settings-page.php           ✓ Clear
plugins/file3.php                       ✗ Meaningless
api-examples/crm-contacts-response.json ✓ Clear
screenshots/settings-page-mockup.png    ✓ Clear
```

## Git Behavior

- `docs/reference/` is committed (shared with team)
- `docs/reference/local/` is gitignored (personal scratchpad)
