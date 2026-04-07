---
name: wp-migrate
description: Plan and execute WordPress or PHP migrations. Use when the user asks about major WordPress upgrades, PHP version bumps, deprecations, replacing legacy APIs, or staged compatibility work.
---

Use this skill for staged migration work.

Before editing:

1. Read `../../references/project-files.md`.
2. Read `../../references/standards.md`.
3. Inventory the affected packages, entry points, APIs, and compatibility risks.
4. Use authoritative changelogs or official docs when the migration depends on current platform behavior.

Deliver migration work in this order:

1. Migration analysis
2. Breaking-change inventory
3. Ordered rollout sequence with verification per step
4. Compatibility layer, if old and new behavior must coexist
5. Implementation of the first safe step only unless the user asks for more

Validation:

- Keep the codebase deployable after each step.
- Run project validation tools when available.
- Flag behavioral changes that should not be slipped in silently.
