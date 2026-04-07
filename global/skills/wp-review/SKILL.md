---
name: wp-review
description: Security-focused code review for WordPress PHP and JavaScript with WPCS validation. Use when the user asks to review code, check a PR, audit security, or validate a file before merge.
---

Review the provided code from five lenses, in order:

**1. Security (highest priority)**
- Unsanitized `$_GET`, `$_POST`, `$_REQUEST` access
- Missing `wp_verify_nonce()` on form handlers and AJAX callbacks
- Missing `current_user_can()` checks
- Unescaped output in templates (`echo $var` without `esc_html()` etc.)
- Raw SQL without `$wpdb->prepare()`
- `__return_true` in REST `permission_callback`
- File path manipulation without `sanitize_file_name()` or `realpath()` validation

**2. WordPress Coding Standards compliance**
- Run `composer phpcs` against all PHP files under review
- Report every violation with file, line, sniff name, and severity
- Distinguish auto-fixable violations (can run `composer phpcbf`) from manual-fix-required
- Check: Yoda conditions, spacing, naming conventions, PHPDoc blocks, translatable strings with correct text domain per package

**3. Correctness**
- Logic errors, wrong hook priorities, incorrect function signatures
- Race conditions in AJAX handlers
- Missing return types, incorrect type coercion
- `WP_Query` args that don't do what the developer intended

**4. Performance**
- Queries inside loops (N+1)
- Missing object caching / transient usage for expensive operations
- Autoloaded options that shouldn't be
- Scripts/styles enqueued globally instead of conditionally
- `get_posts()` without `'no_found_rows' => true` when pagination isn't needed

**5. Maintainability**
- Naming clarity, function length, single responsibility
- Missing PHPDoc blocks
- Hardcoded values that should be constants or options
- Theme/plugin boundary violations (logic in theme, presentation in plugin)

Output format:
- Severity-ranked issue list (critical / warning / suggestion)
- WPCS violations listed separately with sniff names for reference
- For each issue: file, line reference, what's wrong, and the fix
- Explicit callout of what's well-done
- Verdict: approve, request changes, or block
