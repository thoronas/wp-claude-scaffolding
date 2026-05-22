# [Project Name]

[One sentence: what this project is and who it's for.]

## Project Type

This repo is a **wp-content** directory containing custom theme(s) and plugin(s)
for a self-hosted WordPress site. Only project-specific code is versioned here —
WordPress core, third-party plugins, and uploads are excluded.

## Stack

- PHP 8.1+ / WordPress 6.6+
- Block theme with `theme.json` + classic PHP fallbacks where needed
- Custom plugin(s) with Composer PSR-4 autoloading
- [Any additional: REST API, WP-CLI commands, custom tables, etc.]

## What's in This Repo

### Theme: `themes/[your-theme]/`
- Block theme using `theme.json` for global styles and settings
- `templates/` — block template files (HTML)
- `parts/` — block template parts (header, footer, sidebar)
- `patterns/` — block patterns
- `styles/` — style variations
- `inc/` — procedural PHP (hooks, filters, template tags, customizer)
- `src/` — OOP PHP classes (autoloaded if Composer is used in the theme)
- `assets/` — JS, CSS, images (compiled or source depending on build setup)
- `blocks/` — theme-specific custom blocks
- `functions.php` — bootstrap file, keep it lean (autoload + hooks only)

### Plugin: `plugins/[your-plugin]/`
- `[your-plugin].php` — plugin bootstrap file (header comment + autoload + hooks)
- `src/` — PHP source (PSR-4 autoloaded via Composer)
  - `Admin/` — wp-admin screens, settings pages, metaboxes
  - `Frontend/` — public-facing output, shortcodes, template tags
  - `REST/` — REST API endpoints (namespace: `[your-plugin]/v1`)
  - `Blocks/` — block registration and server-side render callbacks
  - `CLI/` — WP-CLI commands
  - `Services/` — business logic (no direct DB or WordPress API calls)
  - `Repositories/` — data access layer ($wpdb, WP_Query, options, meta)
- `assets/` — JS/CSS source files
- `blocks/` — Gutenberg block source (each block in its own directory)
- `templates/` — PHP template files (all output escaped)
- `languages/` — translation files

### mu-plugins/ (if used)
- Must-use plugins for site-critical functionality that cannot be deactivated

## Build & Test Commands

- `composer install` — install PHP dependencies
- `composer phpcs` — lint all PHP (WordPress-Extra ruleset)
- `composer phpcbf` — auto-fix PHP standards violations
- `composer test` — run PHPUnit tests
- `npm install && npm run build` — build theme/block assets (if applicable)
- `npm run start` — watch mode for development
- `npx wp-env start` — spin up local WordPress environment

## Session Protocol

At the start of every session, before any work:

1. Read "Current Focus" and "Known Issues / Gotchas" in this file.
2. Read `PROJECT-SPEC.md` for the relevant feature or task if one is active.
3. Before any architectural decision, read `DECISIONS.md` — do not re-litigate settled decisions.
4. State your understanding of the active task in one sentence. Wait for confirmation before writing any code.

If the task matches a category in `docs/DEVELOPMENT-PROMPTS.md` (feature build, bug investigation, code review, performance work, migration, block build, etc.), apply the required output structure from that prompt even if the developer has not used the full template.

## Conventions — These Are Non-Negotiable

- WordPress Coding Standards (WordPress-Extra ruleset) — no exceptions
- All user input: sanitize on input (`sanitize_*`, `absint`, `wp_kses`), escape on output (`esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`)
- Every form and AJAX handler: nonce verification + capability check
- All text strings translatable: `__()`, `esc_html__()`, `_e()` with correct text domain per package
- Database queries: always `$wpdb->prepare()` — no raw interpolation
- Hook priorities: document why when not using default (10)
- No `query_posts()`. Use `WP_Query` or `get_posts()`.
- No direct `$_GET`/`$_POST`/`$_REQUEST` access without sanitization
- REST endpoints: always define `permission_callback` (never `__return_true`)
- Enqueue scripts/styles conditionally — only on pages that need them
- Autoloaded options: only for data needed on every page load
- Theme templates: escape everything, no exceptions
- Plugin code: service layer pattern — controllers are thin, logic is in services

## Code Behaviour — These Are Also Non-Negotiable

**Think before coding.**
- State assumptions explicitly before implementing. If uncertain, ask.
- If a requirement has multiple valid WordPress approaches, name them and recommend one — don't pick silently.
- If the task touches the theme/plugin boundary, state explicitly which side owns it and why before proceeding.
- Push back when a simpler approach exists.

**Simplicity within the established architecture.**
- No abstractions beyond what the service/repository/controller pattern already in this project requires.
- No features beyond what was asked.
- No speculative error handling, flexibility, or configurability that wasn't requested.
- If you write 200 lines and it could be 50, rewrite it.

**Surgical changes only.**
- Every changed line must trace directly to the request.
- Do not improve adjacent code, hooks, filters, comments, or formatting.
- Do not refactor code that isn't broken.
- Match existing style, even if you would do it differently.
- If you notice unrelated dead code or a security issue outside scope: name it explicitly and ask whether to address it now or log it to Known Issues. Do not silently fix or silently ignore it.
- Remove only imports, variables, or functions that your changes made unused.

**Define success criteria before coding.**
- For any non-trivial task, state what done looks like before writing a line.
- Transform tasks into verifiable goals: "Add validation" → "tests for invalid inputs pass, phpcs clean, nonce and capability verified."
- For multi-step tasks, produce a numbered plan with a verification step per stage before implementing anything. Implement one step at a time.

**Architectural decisions must be visible.**
- When making a structural choice (which layer handles this, why this hook, why this data store), state the decision and the reason before writing the code.
- After any session where a new architectural decision was made, append it to `DECISIONS.md` with a one-sentence rationale. Do not wait to be asked.

---

## Output Standards

**Always produce complete files, not diffs or fragments.**
When modifying an existing file, show the complete modified file. Mark added sections with an inline comment. Never show partial files with "rest of file unchanged."

**Self-verify before presenting any WordPress implementation.**
Before presenting output, confirm:
- [ ] All user input is sanitized on input (`sanitize_*`, `absint`, `wp_kses`)
- [ ] All output is escaped (`esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`)
- [ ] Every form and AJAX/REST handler has nonce verification and a capability check
- [ ] All text strings are translatable with the correct text domain
- [ ] Any direct database query uses `$wpdb->prepare()`
- [ ] `composer phpcs` would pass on the code as written
- [ ] No `query_posts()`, no unguarded `$_GET`/`$_POST`, no `__return_true` in permission callbacks

If any item would fail, fix it before presenting. Do not present code that would not pass this list.

**For debugging tasks:**
Before investigating, ask: "What changed recently — deployments, config changes, plugin or WordPress updates, server changes?" If nothing changed, say so. This field is required before root cause analysis.

**For performance tasks:**
If no profiling data has been provided, the first output must be a measurement plan — what to measure, which tools to use, how to capture a baseline. Do not propose optimizations without measurements.

---

## WordPress Decision Defaults

When the right approach is not obvious from the request or existing codebase patterns, use these defaults:

- **Theme vs plugin:** Default to plugin unless the code is purely presentational output. Custom post types, taxonomies, REST endpoints, and business logic belong in plugins regardless of what a theme requires.
- **REST vs admin-ajax:** Prefer REST endpoints with proper `permission_callback` for all new work. Use admin-ajax only when maintaining existing patterns.
- **Options vs custom tables:** Use options unless querying, filtering, or joining is required. Autoloaded options only for data needed on every page load.
- **Block vs classic PHP template:** Prefer blocks for new template output. Use classic PHP for data-heavy logic, WP-CLI commands, and anything that runs outside a browser request.
- **Hook priority:** Use default (10) unless there is a documented reason. When using a non-default priority, add an inline comment explaining why.
- **Capability checks:** Use the most specific capability that applies. Do not default to `manage_options` for everything — check the WordPress capability reference for the right fit.

## Current Focus

[Update this section when starting a new phase of work. 1-2 sentences.]

Example: "Building the settings page for the CRM plugin. Admin-only,
uses the Settings API, stores options in a single serialized array."

## Known Issues / Gotchas

- [List specific things Claude should watch for in this project]

## Reference

- See `PROJECT-SPEC.md` for full feature spec and requirements
- See `DECISIONS.md` for architectural decision log — read before any architectural work; update after any architectural decision
- See `docs/DEVELOPMENT-PROMPTS.md` for structured prompt templates covering features, bugs, reviews, performance, migrations, blocks, and more — apply the required output structure from the matching prompt type even on ad-hoc requests
- See `.claude/reference/` for inspiration code and examples
