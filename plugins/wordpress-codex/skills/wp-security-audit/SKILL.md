---
name: wp-security-audit
description: Audit WordPress code for security vulnerabilities. Use when the user asks for a security review, vulnerability audit, pre-merge security check, or targeted validation of sanitization, escaping, auth, nonces, SQL safety, or REST permissions.
---

Use this skill for security-only audit work.

Before reviewing:

1. Read `../../references/project-files.md`.
2. Read `../../references/standards.md`.
3. Confirm the review scope: changed files, package, entry point, and data flow.

Audit sequence:

1. Run `python3 ../../scripts/security_scan.py --project-root <project-root> [paths...]`
   to collect deterministic review signals before manual analysis.
2. Run `composer phpcs` on the relevant PHP files when the project has it installed.
3. Record security-relevant WPCS findings:
   `WordPress.Security.*`, `WordPress.DB.PreparedSQL`, and related auth or escaping issues.
4. Perform a manual audit for issues static checks may miss:
   SQL injection, XSS, CSRF, broken access control, unsafe file handling, unsafe redirects, object injection, information disclosure, and REST routes with weak permissions.
5. Trace the vulnerable code path instead of reporting a vague suspicion.

Output expectations:

- Report only security findings, ordered by severity.
- Include file and line references.
- State whether WPCS flagged the issue.
- Show the exploit path or failure mechanism in plain language.
- Provide the concrete fix or corrected pattern.
- If no issues are found, say so explicitly and note any residual blind spots.

Validation:

- If you modify PHP while fixing a finding, run `composer phpcbf` and `composer phpcs`.
- Do not dilute the output with style or architecture feedback unless it directly affects security.
