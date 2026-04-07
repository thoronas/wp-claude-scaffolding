---
paths:
  - "themes/**/templates/**/*.html"
  - "themes/**/parts/**/*.html"
  - "themes/**/patterns/**/*.php"
  - "plugins/**/templates/**/*.php"
---

Template files have the highest escaping risk. Apply these rules without exception:

For PHP templates (plugin templates, theme pattern files):
- Every `echo` statement must use an escaping function
- `esc_html()` for text content
- `esc_attr()` for HTML attributes
- `esc_url()` for URLs (href, src, action)
- `wp_kses_post()` for rich HTML content from trusted sources
- `wp_kses()` with explicit allowed tags for untrusted HTML
- Never use `<?= $var ?>` — always `<?php echo esc_html( $var ); ?>`
- Translation functions in templates: use `esc_html_e()` not `echo __()`
- Run `composer phpcs` on template files — escaping violations are WPCS errors

For block templates (HTML files in themes/*/templates/ and themes/*/parts/):
- Use only valid block markup (<!-- wp:block-name {attributes} --> content <!-- /wp:block-name -->)
- Do not mix PHP into HTML block templates
- Keep block templates minimal — complex logic belongs in render callbacks
