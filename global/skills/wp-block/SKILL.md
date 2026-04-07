---
name: wp-block
description: Build a Gutenberg block from scratch with block.json, edit component, save function, and optional PHP render callback. Use when the user asks to create a block, build a Gutenberg component, or add an editor block.
---

Gather from the user:

1. **Block name** (namespace/slug format, e.g., `your-plugin/testimonial`)
2. **Purpose** — what it displays and how editors interact with it
3. **Dynamic or static** — PHP `render_callback` or saved HTML
4. **Which package owns it** — theme block (`themes/[name]/blocks/`) or plugin block (`plugins/[name]/blocks/`)? Functional blocks go in plugins; purely decorative/layout blocks may go in themes.
5. **Attributes** — each with type, default, and editor control
6. **Inner blocks** — does it contain other blocks? Which are allowed?
7. **Editor UX** — InspectorControls, BlockControls, placeholder states

If design mockups exist in `.claude/reference/screenshots/`, review them first.
If similar block patterns exist in `.claude/reference/patterns/`, follow their conventions.

Produce these files in the correct package directory:

1. `block.json` — complete with attributes, supports, category, icon
2. `edit.js` — full editor component using `useBlockProps`, `InspectorControls`, `BlockControls`, and a meaningful placeholder state
3. `save.js` — save function (or return `null` if dynamic)
4. `render.php` — server-side render callback (if dynamic), with full escaping
5. `index.js` — block registration via `registerBlockType`
6. `style.scss` + `editor.scss` — separated frontend and editor styles
7. Registration PHP — `register_block_type()` with asset enqueueing, placed in the correct package
8. **Transforms** — `from` / `to` transforms for related block types
9. **Deprecations** — if replacing an existing block, include deprecation handler

**WPCS enforcement (mandatory before presenting final code):**
- Run `composer phpcbf` then `composer phpcs` on all PHP files. Fix all violations until zero remain.
- Verify all output in `render.php` uses appropriate escaping.
- Verify translatable strings use the correct text domain for the owning package.
- If `npm run lint` is available, run it against JS files.

After delivering, warn the user about common block validation errors:
- `save` output must exactly match `edit` output structure (for static blocks)
- `useBlockProps()` must wrap the outermost element in both edit and save
- Attribute defaults in `block.json` must match what the editor renders with no user input
