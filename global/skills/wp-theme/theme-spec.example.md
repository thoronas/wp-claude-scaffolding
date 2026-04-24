# Theme Spec
#
# Copy this file to .claude/reference/theme-spec.md in your project.
# All fields are optional except theme-name and text-domain,
# which are always confirmed interactively even if present here.

## Identity
theme-name: My Theme
text-domain: my-theme
version: 1.0.0

## Mode
# Options: fse | hybrid
type: hybrid

## Hybrid Options
# Which parts stay as PHP files (header.php, footer.php)?
php-parts: header, footer

# Which content templates stay as PHP files?
# Options: home, single, page, archive, 404, search
php-templates: single, archive

## Templates
# Omit this section to use the default set: home, single, page, archive, 404, search
# templates: home, single, page, archive, 404, search

## Typography
# Omit to use UBCDS defaults (ubcds-0 through ubcds-11)
# font-sizes:
#   - slug: custom-sm
#     size: 14px
#     name: Small

## Colors
# Omit to leave color palette empty (recommended — add directly in theme.json once confirmed)
# primary: "#000000"
# secondary: "#ffffff"
# accent: "#0055B3"

## Spacing
# Omit to use UBCDS defaults (spacer-01 through spacer-04)
# spacers:
#   - slug: spacer-05
#     size: 128px
#     name: Spacer 05

## Layout
# Omit to leave blank (set once design specs are confirmed)
# content-size: "860px"
# wide-size: "1200px"

## Reference
# Point at directories inside .claude/reference/ that the skill should read.
# Without notes, the skill extracts structural conventions only.
# With notes, it follows your targeted extraction instructions.

# theme-reference: classic-theme-2023/
# theme-reference-notes: |
#   Pull the custom nav walker from inc/nav-walker.php.
#   Ignore enqueue patterns — we're replacing those entirely.

# plugin-reference: events-plugin/
# plugin-reference-notes: |
#   We need the custom post type registration from includes/cpt-events.php
#   and the taxonomy setup from includes/tax-event-category.php.
#   Do not carry forward any shortcode logic.

## WooCommerce
# woocommerce: false

## Notes
# Free-form notes the skill should factor in during generation.
# Example: "This theme targets WordPress 6.6+ only — use block bindings where appropriate."
