---
name: wp-block
description: Build or extend a Gutenberg block in a WordPress theme or plugin. Use when the user asks to create a custom block, add block controls, build a dynamic block, or wire editor behavior to frontend rendering.
---

Use this skill for Gutenberg block work.

Before editing:

1. Read `../../references/project-files.md`.
2. Read `../../references/standards.md`.
3. Determine whether the block belongs in the theme or plugin:
   functional blocks belong in plugins, presentational blocks may live in themes.
4. Capture the block name, purpose, attributes, editor controls, and whether it is static or dynamic.
5. If mockups or examples exist in `docs/reference/screenshots/` or `docs/reference/patterns/`, read only the relevant files.

Implementation expectations:

- Create the full block file set required by the repo's conventions.
- Use `useBlockProps()` on the outermost wrapper in edit and save.
- Keep attribute defaults aligned with rendered defaults.
- For dynamic blocks, implement the PHP render path with correct escaping and registration.
- Keep editor and frontend assets scoped to the block.

Validation:

- Run `composer phpcbf` and `composer phpcs` for any changed PHP.
- Run JS linting when the repo provides it.
- Call out block validation risks if markup and attributes must stay in lockstep.
