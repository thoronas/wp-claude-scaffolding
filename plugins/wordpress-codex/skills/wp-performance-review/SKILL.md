---
name: wp-performance-review
description: Review WordPress code for performance issues. Use when the user asks to profile code, find slow queries, reduce unnecessary asset loading, audit caching, or improve WordPress runtime efficiency.
---

Use this skill for performance-focused review or optimization work.

Before reviewing:

1. Read `../../references/project-files.md`.
2. Read `../../references/standards.md`.
3. Identify the request path, affected package, and whether the concern is frontend time, database load, admin latency, or memory use.

Review sequence:

1. Run `python3 ../../scripts/performance_scan.py --project-root <project-root> [paths...]`
   to collect deterministic performance signals before the deeper review.
2. Look for WordPress-specific performance traps:
   queries inside loops, expensive meta queries, missing cache layers, global asset loading, unnecessary full-object fetches, and remote calls without caching.
3. Check whether a problem is on the hot path or incidental.
4. Explain the mechanism of slowness, not just the symptom.
5. When proposing a fix, preserve behavior and keep the result WPCS-compliant.

Output expectations:

- Findings ordered by likely impact.
- File and line references.
- Why the code is slow.
- Expected impact: page load, database load, memory, or admin responsiveness.
- Concrete remediation.

Validation:

- If you change PHP, run `composer phpcbf` and `composer phpcs` when available.
- If the repo has a repeatable benchmark or test path, say what should be measured before and after.
