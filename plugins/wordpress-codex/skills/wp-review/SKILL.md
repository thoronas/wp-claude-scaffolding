---
name: wp-review
description: Review WordPress code for security, correctness, performance, and maintainability. Use when the user asks for a review, audit, pre-merge check, or targeted validation of WordPress PHP or JavaScript.
---

Use this skill for review and audit work.

For narrower audits, prefer the focused skills:

- `wp-security-audit` for security-only review
- `wp-performance-review` for performance-only review
- `wp-wpcs-fix` for standards enforcement and cleanup

Review order:

1. Read `../../references/project-files.md`.
2. Read `../../references/standards.md`.
3. Review for security first:
   sanitization, escaping, nonces, capability checks, prepared SQL, REST permissions, file handling.
4. Review for correctness:
   hook timing, data flow, logic errors, type or signature mismatches, and unintended package-boundary violations.
5. Review for performance and maintainability:
   query patterns, unnecessary global asset loading, naming clarity, duplication, and missing tests.

Output expectations:

- Findings first, ordered by severity
- File and line references for each issue
- WPCS violations called out separately when tool output is available
- Brief note on what is well done
- Clear verdict: approve, request changes, or block

Validation:

- Run `composer phpcs` on relevant PHP files when the repo has it installed.
- If tooling is unavailable, provide a manual review and say what could not be validated automatically.
