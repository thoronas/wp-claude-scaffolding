# WordPress Codex Plugin

This plugin packages Codex-native WordPress skills for implementation, review,
debugging, migration, security auditing, performance review, and WPCS cleanup.

## Skills

- `wp-feature`
- `wp-block`
- `wp-debug`
- `wp-migrate`
- `wp-review`
- `wp-security-audit`
- `wp-performance-review`
- `wp-wpcs-fix`

## Scripts

- `scripts/install_plugin.py`
  - installs this plugin into a Codex plugin root and updates `marketplace.json`
- `scripts/validate_plugin.py`
  - validates the plugin manifest, marketplace entry, and skill metadata
- `scripts/smoke_test_install.py`
  - runs an install plus validation flow against a temporary target root
- `scripts/wpcs_scope.py`
  - runs `composer phpcs` and optional `phpcbf` for a scoped WordPress project
- `scripts/security_scan.py`
  - collects deterministic security review signals for manual follow-up
- `scripts/performance_scan.py`
  - collects deterministic performance review signals for manual follow-up

## Install

Home-local install:

```bash
python3 plugins/wordpress-codex/scripts/install_plugin.py --target-root ~ --method symlink
```

Validation:

```bash
python3 plugins/wordpress-codex/scripts/validate_plugin.py \
  --plugin-root ~/plugins/wordpress-codex \
  --marketplace ~/.agents/plugins/marketplace.json
```

Smoke test without touching home directories:

```bash
python3 plugins/wordpress-codex/scripts/smoke_test_install.py
```
