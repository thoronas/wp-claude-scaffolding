---
name: wp-theme
description: Generate a full WordPress theme skeleton — Full Site Editing (FSE) or hybrid. Reads .claude/reference/theme-spec.md first; only asks for what the spec doesn't cover. Use when starting a new WordPress theme from scratch or converting an existing theme.
---

## Step 1 — Read context

1. Look for `.claude/reference/theme-spec.md` in the current project. If found, read all fields.
2. Scan `.claude/reference/` for existing theme or plugin directories. Note their presence and structure.

## Step 2 — Intake

Gather the following. Skip any field already answered in the spec file — **except theme name and text domain, which must always be confirmed interactively.**

1. **Theme name** (e.g., "UBC Events Theme")
2. **Text domain** (e.g., `ubc-events-theme`) — lowercase, hyphens, matches theme folder name
3. **Theme type** — Full FSE or Hybrid?
4. **Hybrid only — which parts stay as PHP?**
   - Options: header / footer / both / other (specify)
5. **Hybrid only — which content templates stay as PHP?**
   - Present this list: home, single, page, archive, 404, search
   - User picks which are PHP; the rest become block HTML files

**Version:** Default to `1.0.0` unless spec specifies otherwise.

## Step 3 — Apply reference material

If `.claude/reference/` contains theme or plugin directories:

- If `theme-reference` is set in spec: read that directory. Apply `theme-reference-notes` as targeted extraction instructions. If no notes, extract structural conventions only (file organisation, enqueue patterns, text domain usage).
- If `plugin-reference` is set in spec: read that directory. Apply `plugin-reference-notes` as targeted extraction instructions. If no notes, extract structural conventions only.
- If no explicit reference is set but theme/plugin directories exist: auto-scan for structural conventions only.

Explicit pointer + notes takes priority over explicit pointer alone, which takes priority over auto-scan.

## Step 4 — Generate theme skeleton

Use `{theme-name}`, `{text-domain}`, and `{version}` as placeholders for the values gathered in Step 2. Theme folder slug is the text domain value.

### Common base (always generated)

**`style.css`**
```css
/*
Theme Name: {theme-name}
Theme URI:
Author:
Author URI:
Description:
Version: {version}
Requires at least: 6.5
Tested up to: 6.7
Requires PHP: 8.1
License: GPL-2.0-or-later
License URI: https://www.gnu.org/licenses/gpl-2.0.html
Text Domain: {text-domain}
*/
```

**`functions.php`**
```php
<?php
/**
 * Theme functions and definitions.
 *
 * @package {text-domain}
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

require_once get_template_directory() . '/inc/setup.php';
require_once get_template_directory() . '/inc/enqueue.php';
require_once get_template_directory() . '/inc/blocks.php';
```

For **hybrid mode**, also add after the requires:

```php
add_action( 'wp_head', 'wp_enqueue_scripts' );
```

**`inc/setup.php`**
```php
<?php
/**
 * Theme setup.
 *
 * @package {text-domain}
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

add_action( 'after_setup_theme', '{text_domain}_setup' );

/**
 * Sets up theme defaults and registers support for various WordPress features.
 */
function {text_domain}_setup(): void {
	add_theme_support( 'wp-block-styles' );
	add_theme_support( 'editor-styles' );
	add_theme_support( 'responsive-embeds' );
	add_theme_support( 'align-wide' );

	register_nav_menus(
		array(
			'primary' => esc_html__( 'Primary Navigation', '{text-domain}' ),
			'footer'  => esc_html__( 'Footer Navigation', '{text-domain}' ),
		)
	);

	add_image_size( 'theme-featured', 1200, 600, true );
}
```

Note: `{text_domain}` in function names uses underscores (e.g., `ubc_events_theme_setup`).

**`inc/enqueue.php`**
```php
<?php
/**
 * Enqueue scripts and styles.
 *
 * @package {text-domain}
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

add_action( 'wp_enqueue_scripts', '{text_domain}_enqueue_assets' );

/**
 * Enqueues theme assets.
 */
function {text_domain}_enqueue_assets(): void {
	wp_enqueue_style(
		'{text-domain}-style',
		get_stylesheet_uri(),
		array(),
		(string) filemtime( get_template_directory() . '/style.css' )
	);
}
```

**`inc/blocks.php`**
```php
<?php
/**
 * Block registration.
 *
 * @package {text-domain}
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

add_action( 'init', '{text_domain}_register_blocks' );

/**
 * Registers custom blocks.
 */
function {text_domain}_register_blocks(): void {
	register_block_type( __DIR__ . '/../blocks/example-block' );
}
```

**`blocks/example-block/block.json`**
```json
{
	"$schema": "https://schemas.wp.org/trunk/block.json",
	"apiVersion": 3,
	"name": "{text-domain}/example-block",
	"version": "1.0.0",
	"title": "Example Block",
	"category": "theme",
	"description": "A starter block — rename and extend.",
	"supports": {
		"html": false,
		"color": {
			"background": true,
			"text": true
		},
		"spacing": {
			"padding": true,
			"margin": true
		}
	},
	"textdomain": "{text-domain}",
	"editorScript": "file:./index.js",
	"style": "file:./style.scss",
	"editorStyle": "file:./editor.scss"
}
```

**`blocks/example-block/edit.js`**
```js
import { useBlockProps } from '@wordpress/block-editor';

export default function Edit() {
	const blockProps = useBlockProps();
	return (
		<p { ...blockProps }>
			Example block — edit view.
		</p>
	);
}
```

**`blocks/example-block/save.js`**
```js
import { useBlockProps } from '@wordpress/block-editor';

export default function Save() {
	const blockProps = useBlockProps.save();
	return (
		<p { ...blockProps }>
			Example block.
		</p>
	);
}
```

**`blocks/example-block/index.js`**
```js
import { registerBlockType } from '@wordpress/blocks';
import Edit from './edit';
import Save from './save';
import metadata from './block.json';

registerBlockType( metadata.name, { edit: Edit, save: Save } );
```

**`blocks/example-block/style.scss`**
```scss
// Frontend styles for example-block
.wp-block-{text-domain-underscored}-example-block {
}
```

**`blocks/example-block/editor.scss`**
```scss
// Editor-only styles for example-block
.wp-block-{text-domain-underscored}-example-block {
}
```

Note: `{text-domain-underscored}` replaces hyphens with underscores in the CSS class (e.g., `ubc_events_theme`).

Create empty directories with `.gitkeep`:
- `patterns/.gitkeep`
- `assets/css/.gitkeep`
- `assets/js/.gitkeep`
- `assets/images/.gitkeep`

### Full FSE additions

**`templates/home.html`**
```html
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->
<!-- wp:group {"tagName":"main","layout":{"type":"constrained"}} -->
<main class="wp-block-group">
	<!-- wp:query {"queryId":0,"query":{"perPage":10,"pages":0,"offset":0,"postType":"post","order":"desc","orderBy":"date","author":"","search":"","exclude":[],"sticky":"","inherit":true}} -->
	<div class="wp-block-query">
		<!-- wp:post-template -->
			<!-- wp:post-title {"isLink":true} /-->
			<!-- wp:post-excerpt /-->
		<!-- /wp:post-template -->
		<!-- wp:query-pagination /-->
	</div>
	<!-- /wp:query -->
</main>
<!-- /wp:group -->
<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
```

**`templates/single.html`**
```html
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->
<!-- wp:group {"tagName":"main","layout":{"type":"constrained"}} -->
<main class="wp-block-group">
	<!-- wp:post-title /-->
	<!-- wp:post-featured-image /-->
	<!-- wp:post-content /-->
	<!-- wp:post-tags /-->
</main>
<!-- /wp:group -->
<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
```

**`templates/page.html`**
```html
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->
<!-- wp:group {"tagName":"main","layout":{"type":"constrained"}} -->
<main class="wp-block-group">
	<!-- wp:post-title /-->
	<!-- wp:post-content /-->
</main>
<!-- /wp:group -->
<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
```

**`templates/archive.html`**
```html
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->
<!-- wp:group {"tagName":"main","layout":{"type":"constrained"}} -->
<main class="wp-block-group">
	<!-- wp:query-title /-->
	<!-- wp:query {"queryId":0,"query":{"perPage":10,"pages":0,"offset":0,"postType":"post","order":"desc","orderBy":"date","author":"","search":"","exclude":[],"sticky":"","inherit":true}} -->
	<div class="wp-block-query">
		<!-- wp:post-template -->
			<!-- wp:post-title {"isLink":true} /-->
			<!-- wp:post-excerpt /-->
		<!-- /wp:post-template -->
		<!-- wp:query-pagination /-->
	</div>
	<!-- /wp:query -->
</main>
<!-- /wp:group -->
<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
```

**`templates/404.html`**
```html
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->
<!-- wp:group {"tagName":"main","layout":{"type":"constrained"}} -->
<main class="wp-block-group">
	<!-- wp:heading -->
	<h1 class="wp-block-heading">Page Not Found</h1>
	<!-- /wp:heading -->
	<!-- wp:paragraph -->
	<p>The page you&#8217;re looking for doesn&#8217;t exist.</p>
	<!-- /wp:paragraph -->
</main>
<!-- /wp:group -->
<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
```

**`templates/search.html`**
```html
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->
<!-- wp:group {"tagName":"main","layout":{"type":"constrained"}} -->
<main class="wp-block-group">
	<!-- wp:query-title /-->
	<!-- wp:search /-->
	<!-- wp:query {"queryId":0,"query":{"perPage":10,"pages":0,"offset":0,"postType":"post","order":"desc","orderBy":"date","author":"","search":"","exclude":[],"sticky":"","inherit":true}} -->
	<div class="wp-block-query">
		<!-- wp:post-template -->
			<!-- wp:post-title {"isLink":true} /-->
			<!-- wp:post-excerpt /-->
		<!-- /wp:post-template -->
		<!-- wp:query-pagination /-->
	</div>
	<!-- /wp:query -->
</main>
<!-- /wp:group -->
<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
```

**`parts/header.html`**
```html
<!-- wp:group {"tagName":"header","className":"site-header","layout":{"type":"flex","justifyContent":"space-between"}} -->
<header class="wp-block-group site-header">
	<!-- wp:site-title /-->
	<!-- wp:navigation /-->
</header>
<!-- /wp:group -->
```

**`parts/footer.html`**
```html
<!-- wp:group {"tagName":"footer","className":"site-footer","layout":{"type":"constrained"}} -->
<footer class="wp-block-group site-footer">
	<!-- wp:paragraph {"align":"center"} -->
	<p class="has-text-align-center">&#169; <!-- wp:site-title /--></p>
	<!-- /wp:paragraph -->
</footer>
<!-- /wp:group -->
```

### Hybrid additions

Generate PHP files only for parts/templates the user designated as PHP. Generate block HTML files for the rest using the FSE templates above (omitting `wp:template-part` references for header/footer if those are PHP).

**`header.php`** (if header designated as PHP)
```php
<?php
/**
 * The header template.
 *
 * @package {text-domain}
 */

?><!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
	<meta charset="<?php bloginfo( 'charset' ); ?>">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
<?php wp_body_open(); ?>
<header class="site-header">
	<a href="<?php echo esc_url( home_url( '/' ) ); ?>"><?php bloginfo( 'name' ); ?></a>
	<?php
	wp_nav_menu(
		array(
			'theme_location' => 'primary',
			'container'      => 'nav',
		)
	);
	?>
</header>
```

**`footer.php`** (if footer designated as PHP)
```php
<?php
/**
 * The footer template.
 *
 * @package {text-domain}
 */

?>
<footer class="site-footer">
	<p>&copy; <?php echo esc_html( get_bloginfo( 'name' ) ); ?></p>
</footer>
<?php wp_footer(); ?>
</body>
</html>
```

For each PHP content template (e.g., `single.php`):
```php
<?php
/**
 * The {template-name} template.
 *
 * @package {text-domain}
 */

get_header();
?>
<main class="site-main">
	<?php
	while ( have_posts() ) :
		the_post();
		// Template-appropriate tags here (the_title, the_content, etc.)
	endwhile;
	?>
</main>
<?php
get_footer();
```

Use template-appropriate WordPress template tags for each file:
- `single.php` — `the_title()`, `the_content()`, `the_tags()`
- `archive.php` — `the_archive_title()`, loop with `the_title()`, `the_excerpt()`
- `home.php` — loop with `the_title()`, `the_excerpt()`
- `page.php` — `the_title()`, `the_content()`
- `404.php` — static heading and paragraph, no loop
- `search.php` — `get_search_form()`, loop with `the_title()`, `the_excerpt()`

## Step 5 — `theme.json`

Generate with UBCDS defaults. If the spec provides overrides, merge them in place of the relevant section.

```json
{
	"$schema": "https://schemas.wp.org/trunk/theme.json",
	"version": 3,
	"settings": {
		"appearanceTools": true,
		"useRootPaddingAwareAlignments": true,
		"typography": {
			"fontSizes": [
				{ "slug": "ubcds-0",  "size": "16px",  "name": "UBCDS 0" },
				{ "slug": "ubcds-1",  "size": "20px",  "name": "UBCDS 1" },
				{ "slug": "ubcds-2",  "size": "24px",  "name": "UBCDS 2" },
				{ "slug": "ubcds-3",  "size": "28px",  "name": "UBCDS 3" },
				{ "slug": "ubcds-4",  "size": "32px",  "name": "UBCDS 4" },
				{ "slug": "ubcds-5",  "size": "40px",  "name": "UBCDS 5" },
				{ "slug": "ubcds-6",  "size": "48px",  "name": "UBCDS 6" },
				{ "slug": "ubcds-7",  "size": "56px",  "name": "UBCDS 7" },
				{ "slug": "ubcds-8",  "size": "68px",  "name": "UBCDS 8" },
				{ "slug": "ubcds-9",  "size": "84px",  "name": "UBCDS 9" },
				{ "slug": "ubcds-10", "size": "100px", "name": "UBCDS 10" },
				{ "slug": "ubcds-11", "size": "120px", "name": "UBCDS 11" }
			],
			"customFontSize": false
		},
		"custom": {
			"font-weight": {
				"regular":   400,
				"semi-bold": 600,
				"bold":      700
			},
			"line-height": {
				"01": "150%",
				"02": "160%"
			},
			"spacer": {
				"01": "8px",
				"02": "16px",
				"03": "32px",
				"04": "64px"
			}
		},
		"spacing": {
			"spacingSizes": [
				{ "slug": "spacer-01", "size": "8px",  "name": "Spacer 01" },
				{ "slug": "spacer-02", "size": "16px", "name": "Spacer 02" },
				{ "slug": "spacer-03", "size": "32px", "name": "Spacer 03" },
				{ "slug": "spacer-04", "size": "64px", "name": "Spacer 04" }
			]
		},
		"color": {
			"palette": []
		},
		"layout": {
			"contentSize": "",
			"wideSize": ""
		}
	},
	"styles": {}
}
```

If spec provides colors, populate `color.palette`:
```json
{ "slug": "primary", "color": "#000000", "name": "Primary" }
```

If spec provides `contentSize` / `wideSize`, populate `layout` accordingly.

## Step 6 — WPCS enforcement

Run on all generated PHP files before presenting output. Do not present files until `phpcs` reports zero violations.

1. `composer phpcbf` to auto-fix
2. `composer phpcs` to verify zero remaining violations
3. Verify all output uses correct escaping: `esc_html()`, `esc_attr()`, `esc_url()`, `wp_kses_post()`
4. Verify all translatable strings use `{text-domain}` as text domain
5. Hybrid only: verify PHP templates call `get_header()` and `get_footer()`

## Step 7 — Present output

List every generated file. Then remind the user:

- `theme.json` `layout.contentSize` and `layout.wideSize` are intentionally blank — set once design specs are known
- Color palette is empty — add brand colors to `theme-spec.md` or directly in `theme.json`
- Rename `blocks/example-block/` to a real block name before building on it
- Hybrid mode: PHP header/footer require `wp_head()` and `wp_footer()` — verify these are present before testing
