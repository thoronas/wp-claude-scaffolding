---
name: wp-wpcs-fix
description: Enforce and fix WordPress Coding Standards in a WordPress codebase. Use when the user asks to run WPCS, clean up PHPCS violations, auto-fix standards issues, or make PHP files compliant without changing behavior.
---

Use this skill for standards-enforcement work.

Process:

1. Read `../../references/project-files.md`.
2. Read `../../references/standards.md`.
3. Use `python3 ../../scripts/wpcs_scope.py --project-root <project-root> [paths...]`
   for validation, and add `--fix` when it is safe to run `phpcbf`.
4. Separate auto-fixable issues from manual fixes.
5. Apply manual fixes only where standards cannot be resolved automatically.
6. Run validation again and repeat until clean or until you hit a blocker that would change behavior.

Guardrails:

- Do not change behavior, architecture, or ownership boundaries just to satisfy style.
- If a standards fix would materially change behavior, stop and report it instead of sneaking it in.
- Use the correct escaping, sanitization, text domain, naming, spacing, and PHPDoc rules for WordPress.

Output expectations:

- Total violations found before fixes.
- What was auto-fixed versus manually fixed.
- Remaining blockers, if any.
- Final validation status.
- File and line references for manual fixes that matter to reviewers.
