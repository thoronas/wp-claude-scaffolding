---
name: wp-debug
description: Investigate and fix WordPress bugs. Use when the user reports a WordPress error, regression, broken hook flow, REST issue, admin bug, or unexpected frontend behavior.
---

Use this skill when the task is primarily debugging.

Debugging sequence:

1. Read `../../references/project-files.md`.
2. Identify the expected behavior, actual behavior, reproduction steps, and affected package.
3. Trace the entry point and call chain before proposing a fix.
4. Check recent changes, load order, auth context, caching, autosaves, revisions, and database errors when relevant.
5. Pin the failure to a specific line or decision point and explain the mechanism.

Fix and validation expectations:

- Do not jump to code changes before identifying root cause.
- Keep the fix as narrow as the cause allows.
- Run `composer phpcbf` and `composer phpcs` on changed PHP when available.
- Add or propose a regression test when the project has a working test harness.
- Explain why the bug escaped earlier checks and what would catch it next time.
