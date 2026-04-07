# WordPress Standards

These are the baseline rules the WordPress Codex skills enforce.

## PHP and WordPress

- Follow WordPress-Extra PHPCS rules.
- Sanitize on input and escape on output.
- Use nonce verification and capability checks on every state-changing handler.
- Use `$wpdb->prepare()` for variable SQL.
- Keep bootstrap files thin and move real logic into package-specific files or classes.
- Use the correct text domain for the owning theme or plugin.
- Prefer plugins for data and business logic; themes own presentation.

## Blocks and JavaScript

- Use `@wordpress/*` packages for blocks instead of `wp.*` globals.
- `useBlockProps()` belongs on the outermost element in both edit and save components.
- Avoid jQuery unless the task is integrating with legacy admin code.
- Run linting when the project provides it.

## Templates

- Escape all PHP template output in the correct context.
- Keep block-template HTML valid and free of PHP.
- Push non-trivial logic out of templates and into callbacks or services.

## Validation

- When Composer tooling is installed, run `composer phpcbf` on changed PHP files when appropriate, then `composer phpcs`.
- Run tests when the repo has a working test harness and the change warrants it.
- If validation tooling is unavailable, say so explicitly in the final response.
