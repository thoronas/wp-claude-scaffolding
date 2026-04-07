---
name: wp-feature
description: Build a new WordPress feature with full security, hook registration, and WordPress Coding Standards compliance. Use when the user asks to add a feature, create a settings page, register a post type, build a REST endpoint, or implement any new functionality.
---

Before writing any code, determine:

1. **Which package owns this feature** — theme (`themes/[name]/`) or plugin (`plugins/[name]/`)? Follow the boundary rules: themes own presentation, plugins own data and logic. Check PROJECT-SPEC.md if a theme/plugin boundary table exists.
2. **What** the feature does (one sentence)
3. **Where** it lives — admin, frontend, REST, CLI, or block
4. **Who** uses it — which WordPress capability/role
5. **Which hooks** it attaches to
6. **What data** it reads or writes — options, meta, custom tables, transients

If reference material exists in `.claude/reference/` that is relevant to this feature,
read it first and apply its patterns where appropriate.

Then produce, in order:

1. **Package and file placement** — which theme or plugin directory this goes into, following the conventions in CLAUDE.md
2. **Hook registration map** — every `add_action` / `add_filter` with priority and justification
3. **Data flow** — user action → hook → service → repository → database → response
4. **Security checklist** — nonce verification, capability check, sanitization functions, escaping functions, `$wpdb->prepare()` usage
5. **Complete implementation** — WordPress Coding Standards compliant, no stubs
6. **Enqueue calls** — `wp_enqueue_script` / `wp_enqueue_style` with correct dependencies, conditional loading, and correct text domain for the owning package
7. **Edge cases** — what happens on multisite, when options don't exist, when the user lacks permissions, when expected data is missing
8. **Uninstall cleanup** — what gets removed via `register_deactivation_hook` or `uninstall.php`

**WPCS enforcement (mandatory):**
Run `composer phpcbf` on every PHP file you create to auto-fix standards violations,
then run `composer phpcs` to verify zero remaining violations. If any manual fixes are
needed, apply them and re-run until clean. For large features with multiple PHP files,
delegate final validation to the `wpcs-enforcer` subagent.

After delivering, tell the user to check:
- All input sanitized, all output escaped
- Nonces on every form and AJAX/REST handler
- Capability checks use the correct capability for the role
- Text strings use the correct text domain for the package (theme vs plugin)
- Feature is in the correct package (presentation in theme, logic in plugin)
