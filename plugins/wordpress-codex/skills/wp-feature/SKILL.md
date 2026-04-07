---
name: wp-feature
description: Build or extend a WordPress feature in an existing theme or plugin. Use when the user asks to add a settings page, REST endpoint, post type, admin workflow, frontend behavior, data flow, or other WordPress functionality.
---

Use this skill for implementation work inside a WordPress codebase.

Before editing:

1. Read `../../references/project-files.md` and follow the relevant project files.
2. Read `../../references/standards.md`.
3. Identify the owning package:
   theme for presentation, plugin for data and business logic.
4. Capture the user, surface area, hooks, data storage, and acceptance criteria before changing code.
5. If the repo includes `docs/reference/` material that matches the task, inspect only the relevant files.

Implementation expectations:

- State file placement and hook registration before or while making the change.
- Keep controllers and bootstrap files thin; move logic into package-specific files or classes.
- Sanitize on input, escape on output, and add nonce plus capability checks anywhere state changes.
- Define real REST `permission_callback` functions.
- Use `$wpdb->prepare()` for SQL with variable data.
- Implement complete files, not stubs.

Validation:

- Run `composer phpcbf` on changed PHP files when available and appropriate, then run `composer phpcs`.
- Run tests when the project has a working harness and the change adds or alters behavior.
- If validation tools are missing, note that clearly.

Final output should call out:

- Package placement
- Hook map
- Data flow
- Edge cases
- Validation status
