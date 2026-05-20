# [Project Name] — Product Specification

Last updated: [Date]

## Overview

[2-3 paragraph description of the product, the problem it solves,
who uses it, and where it runs (self-hosted WordPress).]

## Packages in This Repo

| Package | Type | Directory | Text Domain | Description |
|---------|------|-----------|-------------|-------------|
| [Theme Name] | Theme | `themes/[slug]/` | `[theme-textdomain]` | [Brief description] |
| [Plugin Name] | Plugin | `plugins/[slug]/` | `[plugin-textdomain]` | [Brief description] |

## User Roles

| Role | WordPress Capability | What They Do |
|------|---------------------|--------------|
| Site Admin | `manage_options` | Configures plugin settings, manages all data |
| Editor | `edit_others_posts` | [Role-specific actions] |
| Subscriber | `read` | [Role-specific actions] |

## Features

### Feature 1: [Name]

**Package:** [Which theme or plugin owns this feature]
**Status:** [Planned | In Progress | Complete | Blocked]

**Description:** [What it does, in one paragraph]

**User story:** As a [role], I want to [action] so that [outcome].

**Acceptance criteria:**
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]

**Technical notes:**
- WordPress APIs involved: [Settings API, REST API, WP_Query, etc.]
- Database: [Custom table? Post meta? Options? Transients?]
- Hooks: [Key actions/filters this feature registers or uses]
- UI location: [Settings page? Metabox? Block? Template? Front page?]

### Feature 2: [Name]

[Same structure as above]

## Data Model

### Custom Post Types

| Post Type | Slug | Registered By | Supports | Public | Has Archive |
|-----------|------|--------------|----------|--------|-------------|
| [Name] | `cpt_slug` | `plugins/[slug]` | title, editor, thumbnail | No | No |

### Custom Taxonomies

| Taxonomy | Slug | Registered By | Attached To | Hierarchical |
|----------|------|--------------|-------------|-------------|
| [Name] | `tax_slug` | `plugins/[slug]` | `cpt_slug` | Yes |

### Custom Tables (if any)

```sql
-- Only use custom tables when post types/meta are genuinely insufficient.
-- Document WHY a custom table was chosen over WordPress native storage.
CREATE TABLE {$wpdb->prefix}plugin_records (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    -- ...
) $charset_collate;
```

### Options

| Option Name | Autoload | Type | Owned By | Purpose |
|-------------|----------|------|----------|---------|
| `plugin_settings` | yes | array | `plugins/[slug]` | Main settings (serialized) |
| `plugin_version` | yes | string | `plugins/[slug]` | Installed version for migrations |

## REST API Endpoints

| Method | Route | Auth | Permission | Provided By | Purpose |
|--------|-------|------|------------|-------------|---------|
| GET | `/plugin/v1/items` | Cookie + Nonce | `edit_posts` | `plugins/[slug]` | List items |

## WP-CLI Commands (if any)

| Command | Description | Provided By | Flags |
|---------|-------------|-------------|-------|
| `wp plugin-name sync` | Sync external data | `plugins/[slug]` | `--dry-run`, `--force` |

## Theme / Plugin Boundary

> Document which responsibilities belong to the theme vs. the plugin(s).
> This prevents feature duplication and unclear ownership.

| Responsibility | Owner | Rationale |
|---------------|-------|-----------|
| Visual layout and templates | Theme | Presentation layer |
| Custom post type registration | Plugin | Data persists if theme changes |
| Block styles and variations | Theme | Visual concern |
| Block registration (functional) | Plugin | Logic persists if theme changes |
| Settings pages | Plugin | Configuration is not theme-dependent |
| Frontend enqueueing of CSS | Theme | Styles are presentation |

## Out of Scope

[Explicitly list what this project does NOT do.]

## Open Questions

[Unresolved decisions that need human input before implementation.]
