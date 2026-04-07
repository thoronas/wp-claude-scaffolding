---
name: wp-debug
description: Investigate and fix WordPress bugs. Use when the user reports a bug, error, or unexpected behavior in WordPress PHP or JavaScript code.
context: fork
agent: Explore
---

Investigate this bug systematically. Do NOT propose a fix until you have identified the root cause.

**Phase 1 — Understand the symptom**
- What is the expected behavior?
- What is the actual behavior?
- What error messages, if any, appear (PHP errors, JS console, REST responses)?
- Which package is affected (theme or plugin)?

**Phase 2 — Trace the execution path**
- Identify the entry point (hook, REST route, AJAX handler, template)
- Follow the call chain step by step, across theme/plugin boundaries if needed
- Check: what changed recently? (recent commits, plugin updates, WordPress core update)

**Phase 3 — Identify root cause**
- Pin the failure to a specific line and explain the mechanism
- Check for common WordPress gotchas:
  - Hook running before dependency is loaded (priority issue)
  - `wp_get_current_user()` called before `init`
  - REST endpoint missing auth context on frontend calls
  - Caching returning stale data (object cache, transients, page cache)
  - `save_post` hook triggering on autosave or revision
  - `$wpdb->last_error` / `$wpdb->last_query` revealing SQL issues
  - Theme/plugin load order conflicts

**Phase 4 — Fix and verify**
- Provide the complete fixed file
- Run `composer phpcbf` then `composer phpcs` on all modified PHP files — the fix must not introduce any WPCS violations
- List edge cases the fix must handle
- Provide a regression test
- Explain why this wasn't caught and what would catch it next time
