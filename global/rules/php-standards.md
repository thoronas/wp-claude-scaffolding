---
paths:
  - "plugins/**/*.php"
  - "mu-plugins/**/*.php"
  - "themes/**/inc/**/*.php"
  - "themes/**/src/**/*.php"
  - "themes/**/functions.php"
---

When writing or editing PHP files in this project:

- Follow WordPress-Extra PHPCS ruleset strictly
- Use Yoda conditions: `if ( 'value' === $var )`
- Space inside parentheses: `if ( $condition )` not `if ($condition)`
- Use `wp_safe_redirect()` not `wp_redirect()`
- Short array syntax `[]` is permitted (PHP 8.1+ project)
- Type declarations on all function parameters and return types
- PHPDoc blocks on all public methods with `@since`, `@param`, `@return`
- All class files: one class per file, filename matches class name
- Use the correct text domain based on which package the file belongs to
- Run `composer phpcs` before finalizing any PHP file
