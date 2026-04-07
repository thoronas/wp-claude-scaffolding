# [Project Name]

This file is the primary instruction file for Codex and other agentic coding tools.

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
  - `Repositories/` — data access layer (`$wpdb`, `WP_Query`, options, meta)
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

## Current Focus

[Update this section when starting a new phase of work. 1-2 sentences.]

Example: "Building the settings page for the CRM plugin. Admin-only,
uses the Settings API, stores options in a single serialized array."

## Known Issues / Gotchas

- [List specific things an AI coding agent should watch for in this project]

## Reference

- See `PROJECT-SPEC.md` for full feature spec and requirements
- See `DECISIONS.md` for architectural decision log
- See `docs/reference/` for inspiration code, API examples, and mockups
