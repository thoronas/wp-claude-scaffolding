---
name: wp-migrate
description: Assist with WordPress migrations and upgrades — PHP version bumps, WordPress major version updates, moving from Classic to Gutenberg, replacing deprecated APIs, or swapping dependencies. Use when the user mentions upgrade, migrate, deprecation, or version bump.
---

Before making any changes, produce:

1. **Migration analysis**
   - What must change across all packages (themes and plugins) in this repo
   - What can stay as-is
   - What's at risk (behavioral changes that aren't errors but produce different results)

2. **Breaking change inventory**
   - Every deprecated/removed API found in the codebase with its replacement
   - Organized by package (theme vs plugin)
   - Source: WordPress core changelogs, PHP migration guides, plugin changelogs

3. **Migration sequence**
   - Ordered steps, each deployable independently
   - No step leaves the codebase in a broken state
   - Each step specifies which package it affects
   - Each step includes a verification method

4. **Compatibility layer** (if old and new must coexist)
   - Version-checking wrappers
   - `function_exists()` / `class_exists()` guards
   - Graceful degradation paths

5. **Implementation of step one only**
   - Complete files, not fragments
   - Run `composer phpcbf` then `composer phpcs` on all modified PHP files — zero violations required
   - Migrated code must maintain full WPCS compliance; do not introduce standards regressions
   - Verify all escaping, sanitization, and nonce patterns still function correctly after migration

Tell the user: "Step one is ready. Deploy and verify it, then ask me for step two."
