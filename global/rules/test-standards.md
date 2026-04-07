---
paths:
  - "tests/**/*.php"
---

When writing or editing test files:

- Extend `WP_UnitTestCase` (not raw PHPUnit TestCase) for integration tests
- Use WordPress factory methods: `$this->factory()->post->create()`, `$this->factory()->user->create()`
- Test method naming: `test_[method]_[scenario]_[expected]` (e.g., `test_save_settings_with_invalid_nonce_returns_error`)
- Each test: arrange, act, assert — clearly separated
- Assert on specific values, not just truthiness
- Mock external HTTP with `pre_http_request` filter, not actual network calls
- Clean up after tests that create options or transients
- Test files must also pass `composer phpcs` — WPCS applies to tests too
- When testing features that span theme and plugin, test from the consumer's perspective
