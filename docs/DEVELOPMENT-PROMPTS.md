# Development Prompt Library

> **Stack context:** WordPress / PHP / JavaScript / Frontend Frameworks
> **Audience:** Senior and intermediate developers using AI-assisted development workflows
> **Usage:** Copy the relevant prompt, fill in every bracketed field, and paste into your AI tool. Do not skip fields — empty context produces generic output.

---

## How to Use These Prompts

Each prompt follows a three-phase pattern:

1. **Context in** — Fill every field. If you don't have the information, say so explicitly rather than leaving it blank. "I don't have profiling data yet" is more useful than silence.
2. **Output out** — The model produces structured deliverables listed under each prompt.
3. **Iterate** — Every prompt ends with guidance on what to check first and how to feed corrections back in. AI output is a first draft, not a final artifact.

**When output exceeds a single response:** If the implementation is too large for one pass, tell the model: "Produce the full implementation plan with file-by-file specifications first. Then implement the highest-priority file. I will ask for subsequent files one at a time."

---

## 1. WordPress Feature Builder

Use when adding a new feature to an existing WordPress plugin or theme. This is the everyday workhorse prompt.

**Feature:** [One clear sentence — e.g., "Add a settings page that lets admins configure API credentials and sync frequency for the CRM integration"]
**Plugin or theme:** [Name, current version, brief description of what it does]
**Users:** [Who interacts with this feature — e.g., "site admins only, via wp-admin"]
**WordPress context:**
- Admin or frontend: [Where does this feature live?]
- Gutenberg block, classic editor, or neither: [Specify]
- Hooks involved: [Any known actions/filters this must attach to — e.g., `admin_menu`, `rest_api_init`, `save_post`]
- Multisite considerations: [Network-activated? Per-site settings? Not applicable?]
- Existing plugin architecture: [How the plugin is currently structured — OOP with autoloader? Procedural? Namespace conventions?]

**Dependencies:** [Required WordPress APIs — Settings API, REST API, Transients, WP_Query, etc.]
**PHP version floor:** [e.g., 8.0]
**WordPress version floor:** [e.g., 6.4]
**Constraints:** [Performance targets, no new composer dependencies, must pass PHPCS with WordPress-Extra ruleset, etc.]
**Acceptance criteria:** [What does "done" look like? Be specific — "settings save and persist across page loads" not "settings work"]

### Required output:

1. **Architecture overview** — components involved (classes, hooks, templates, REST endpoints, blocks) and how they interact
2. **File structure** — where new files go within the existing plugin/theme structure, following its established conventions
3. **Hook registration map** — every `add_action` and `add_filter` with priority and justification for priority choice
4. **Data flow** — from user action through WordPress hooks to database and back
5. **Security implementation** — nonce verification, capability checks, data sanitization (`sanitize_*`), escaping (`esc_*`), and prepared SQL where applicable
6. **Complete implementation** — runnable code, WordPress Coding Standards compliant, no placeholder stubs
7. **Enqueueing** — all `wp_enqueue_script` / `wp_enqueue_style` calls with correct dependencies and conditional loading
8. **Edge cases** — explicit list of what happens when: the feature is activated on multisite, options don't exist yet, the user lacks permissions, expected data is missing
9. **Error handling** — `WP_Error` usage, admin notices for failures, logging via `error_log` or custom logger
10. **Uninstall / deactivation** — what gets cleaned up and how (`uninstall.php` or `register_deactivation_hook`)

### After receiving output — check these first:

- [ ] All user input is sanitized on the way in and escaped on the way out
- [ ] Nonces are present on every form and AJAX/REST request
- [ ] Capability checks use the correct capability (not just `manage_options` by default)
- [ ] Hooks use appropriate priority (not all defaulting to 10)
- [ ] Text strings are translatable via `__()` / `esc_html__()` with correct text domain
- [ ] Direct database queries use `$wpdb->prepare()`

### To iterate:

Paste the output back with: "Here is your implementation. [Specific issue — e.g., 'The settings page doesn't register the menu item correctly because the parent slug is wrong. The parent should be `tools.php`, not `options-general.php`.']. Revise only the affected code and explain what changed."

---

## 2. Production Feature Builder (General)

Use for non-WordPress features — standalone JS applications, Node services, frontend components in frameworks outside WordPress.

**Feature:** [One clear sentence]
**Users:** [Who uses this, how, and at what scale]
**Tech stack:** [Framework, language, runtime, database — be exact with versions]
**Existing codebase context:** [Key patterns, file organization conventions, state management approach, naming conventions]
**Constraints:** [Performance targets, bundle size limits, SSR requirements, browser support floor, no new dependencies, etc.]
**Acceptance criteria:** [Specific, testable statements of what "done" means]

### Required output:

1. **Architecture overview** — components involved and interaction pattern
2. **File structure** — where new files live, following existing codebase conventions
3. **Data flow** — user action → state change → persistence → UI update
4. **Security considerations** — auth, input validation, XSS vectors, data exposure
5. **Complete implementation** — runnable code, no stubs; if too large for one response, produce file-by-file spec first, then implement the critical path file
6. **Edge case inventory** — explicit list with handling strategy for each
7. **Error handling** — user-facing messages, logging, failure recovery
8. **Tests** — critical path and each edge case above
9. **Performance notes** — tradeoffs made and why

### After receiving output — check these first:

- [ ] No hardcoded values that should be configurable
- [ ] Error states have user-facing messages, not silent failures
- [ ] The code follows existing codebase patterns, not the model's preferred patterns

### To iterate:

"The implementation of [specific component] doesn't account for [specific scenario]. Here is the relevant existing code it needs to integrate with: [paste]. Revise that component only."

---

## 3. Existing Codebase Feature Integration

Use when you have existing code and need to wire a new feature into it. This is the most common real-world task — not greenfield, not a refactor, just "add this thing to what already exists."

**Existing code:**

```text
[Paste the relevant existing files — focus on the files the new feature will touch or depend on]
```

**Feature to add:** [What it does, in one paragraph]
**Integration points:** [Where in the existing code does this feature attach? Which functions, hooks, classes, or routes does it modify or extend?]
**What must not change:** [Existing behavior that must be preserved — specific functions, API contracts, database schemas]
**New dependencies:** [Any new packages, APIs, or services required — or "none"]
**Conventions to follow:** [Point to patterns already visible in the pasted code — "follow the same service class pattern used in `UserService`", "register hooks the same way `init.php` does"]

### Required output:

1. **Integration analysis** — how the new feature connects to existing code, which files are modified vs. created
2. **Modified files** — show the complete modified file, not diffs; clearly mark what was added with inline comments
3. **New files** — complete implementation following existing conventions
4. **Data flow** — trace a request through both existing and new code
5. **Regression risks** — what existing behavior could break and how to verify it doesn't
6. **Migration needs** — database changes, option additions, config updates, one-time scripts

### After receiving output — check these first:

- [ ] The existing code's public API / function signatures are unchanged unless explicitly required
- [ ] No existing tests should break (if you have tests, run them)
- [ ] New code follows the same patterns as the code it's being added to

### To iterate:

"The new feature conflicts with [specific existing behavior]. Here is what happens when I [specific reproduction step]. The existing code at [location] does [X] but your new code assumes [Y]. Fix the integration point without changing the existing behavior."

---

## 4. Full Application MVP

Use sparingly — only for genuine greenfield projects. Not for adding to existing systems.

**App idea:** [One paragraph — what it does, the core problem it solves]
**Core features:** [Numbered list — maximum 5 for an MVP. If you have more, you're not building an MVP.]
**Users:** [Who, how many at launch, growth expectation]
**Tech stack:** [Be explicit. If WordPress: theme or plugin? Headless with REST/GraphQL? If JS: which framework, which meta-framework, which hosting target?]
**Out of scope:** [What this MVP deliberately does not include — be specific]

### Required output:

1. **Architectural decisions log** — every structural choice (state management, routing, auth, data layer) with a one-sentence justification. This is non-negotiable — the team needs to understand why, not just what.
2. **Database schema** — tables, relationships, indexes, constraints. WordPress: which are custom tables vs. post types vs. options vs. meta?
3. **API contract** — routes, methods, request/response shapes, auth requirements
4. **UI structure** — page and component hierarchy with state ownership marked
5. **Auth and permissions** — who can do what, enforced where
6. **Error strategy** — how failures surface to users and to operators
7. **Implementation** — complete, working code for the critical path (not every feature); remaining features get file-by-file specs
8. **What to build next** — single highest-value addition after MVP ships

### After receiving output:

Review the architectural decisions log first. If any decision is wrong for your context, correct it before asking for code revisions. Bad architecture is expensive to fix later.

---

## 5. Codebase Audit + Targeted Refactor

**Codebase:**

```text
[Paste code — if too large, paste the entry point and the most problematic area, and describe the rest]
```

**Primary concern:** [What triggered this — performance, bugs, developer confusion, scaling limits, inherited code nobody understands?]
**Risk tolerance:** [Must behavior be identical? Can edge case behavior shift? Can the public API change?]
**Team context:** [Team size, familiarity with this code, whether the refactor is solo or reviewed]
**Deployment constraints:** [Can this be deployed incrementally, or is it all-or-nothing?]

### Required output:

1. **Architecture map** — how the system is structured today, in plain English
2. **Data flow trace** — follow one representative request from entry to response
3. **Problem inventory** — ranked by severity, with evidence from the code (line references), not assumptions
4. **Refactor plan** — ordered by priority, with explicit tradeoffs per change; each change should be deployable independently where possible
5. **Refactored code** — only the files that change; complete files, not fragments
6. **Verification approach** — how to confirm behavior is preserved; if no tests exist, provide the tests to write before refactoring

### After receiving output — check these first:

- [ ] The problem inventory matches your intuition. If the model found issues you didn't expect, investigate those before proceeding.
- [ ] Each refactor step is independently deployable. If not, ask the model to break it down further.

---

## 6. Production Bug Investigation

**Code:**

```text
[Paste the relevant code — include the function/class where the bug manifests and its callers]
```

**Expected behavior:** [What should happen — be precise]
**Actual behavior:** [What happens instead — include exact error messages, incorrect values, or observed symptoms]
**Environment:** [PHP version, WordPress version, Node version, browser, OS, hosting environment]
**Reproduction steps:** [Minimal steps to trigger the bug]
**What changed recently:** [Deployments in the last 48 hours, config changes, dependency updates, WordPress or plugin updates, server migrations — anything. If nothing changed, say so.]
**What has been investigated:** [What you looked at and what you observed — not conclusions, but raw findings. "I added logging to `process_order()` and the `$user_id` parameter is null when called from the cron job" is better than "I ruled out the user service."]

### Required output:

1. **Code behavior summary** — what this code does, step by step
2. **Root cause analysis** — the exact location and mechanism of failure
3. **Why it wasn't caught** — missing test, type gap, validation hole, untested code path
4. **Timeline hypothesis** — if something changed recently, how that change connects to the bug
5. **Fixed code** — complete file, not a diff
6. **Edge cases the fix must handle** — and confirmation each is addressed
7. **Regression test** — a test that would have caught this bug before it shipped

### After receiving output:

Apply the fix in isolation and verify against your reproduction steps before addressing the edge cases. If the fix doesn't resolve the reproduction case, paste the still-failing behavior back and say: "The proposed fix did not resolve the issue. Here is what still happens: [symptoms]. What else could cause this?"

---

## 7. System Design + Scoped Implementation

**Product:** [What it does and who it's for]
**Scale tier:**
- [ ] **Small** — Hundreds of users, single server, low concurrency
- [ ] **Medium** — Thousands of users, needs caching and possibly horizontal scaling
- [ ] **Large** — Tens of thousands+, distributed, high availability required

*If you have specific numbers (concurrent users, requests/second, data volume), include them. If not, the tier above is sufficient.*

**SLA requirements:** [Uptime target, acceptable latency, data loss tolerance — or "best effort for MVP"]
**Tech stack:** [What's mandated or already in use]
**Constraints:** [Budget, team size, hosting environment, compliance requirements]

### Required output:

1. **System architecture** — components, boundaries, data ownership, described in structured text
2. **Component breakdown** — each service/module with its single responsibility
3. **Data flow** — write path and read path separately
4. **API contract** — external-facing interface
5. **Database schema and access patterns** — optimized for stated scale tier
6. **Caching strategy** — what's cached, where, TTL, invalidation; for WordPress: transients vs. object cache vs. CDN
7. **Deep implementation** — one complete, production-quality component (the most critical one)
8. **Scaling plan** — what breaks first at each tier boundary, and what to change when it does

### After receiving output:

Validate the architecture against your actual infrastructure. If the model assumes services you don't have (Redis, a queue system, a CDN), flag it: "We don't have [X] in our infrastructure. Redesign the caching/queue/CDN layer using only [what you actually have]."

---

## 8. Performance Investigation + Optimization

**Code:**

```text
[Paste code here — if the slow area is unknown, paste the entry point of the slow operation]
```

**Symptoms:** [What "slow" looks like — page load time, specific AJAX call taking Xs, admin dashboard timing out, cron job exceeding execution limit]
**Current measurements:** [If you have profiling data — Query Monitor output, New Relic traces, `SAVEQUERIES` output, browser DevTools network waterfall, `time` output — paste it. If you don't have measurements, say "no profiling yet."]
**Performance target:** [What "fast enough" looks like — specific numbers. "Under 2 seconds for initial page load" or "API response under 200ms at p95"]
**Environment:** [Server specs, PHP version, MySQL version, object cache availability, CDN, hosting provider]

### Required output:

**If no profiling data was provided**, start with:
1. **Measurement plan** — what to measure, which tools to use (Query Monitor, `SAVEQUERIES`, Xdebug profiler, browser DevTools), and how to capture a baseline before changing anything

**Then (or if profiling data was provided):**
2. **Bottleneck identification** — ranked by impact, with evidence
3. **Root cause per bottleneck** — why it's slow (N+1 queries, missing index, unoptimized `WP_Query` args, render-blocking scripts, no caching, autoloaded options bloat, etc.)
4. **Optimization strategy** — priority order with expected impact per change
5. **Optimized code** — complete implementation of the highest-impact changes
6. **Tradeoffs** — what was sacrificed and why it's acceptable
7. **Verification steps** — the exact measurements to repeat to confirm improvement

### After receiving output:

Implement and measure one optimization at a time. Do not batch all changes — you need to know which change produced which improvement. Paste measurement results back to inform the next round.

---

## 9. Architectural Restructure

**Code:**

```text
[Paste code — focus on the structural entry points, not every file]
```

**Target architecture:** [Specify concretely — e.g., "service classes with dependency injection," "vertical feature folders," "WordPress plugin with PSR-4 autoloading and namespaced classes separated by domain." Not just "clean architecture."]
**Why this structure:** [What current problem does this solve — "new developers can't find where things are," "everything is in one god class," "adding a new post type requires editing 6 files"]
**Team context:** [Who works in this code and how familiar they are with the target pattern]
**Behavior contract:** [Do tests exist? If not, the first output must define the contract before any code moves.]
**Deployment strategy:** [Can this be merged incrementally (feature branch per module) or must it land all at once?]

### Required output:

1. **Current structure diagnosis** — what pattern exists today, even if accidental
2. **Target structure** — what it means concretely for this codebase, not in the abstract
3. **Migration sequence** — ordered steps, each independently deployable and mergeable; no step should leave the codebase in a broken state
4. **New file structure** — with rationale for each boundary
5. **Refactored code** — complete files for the first migration step only (the model should tell you what subsequent steps contain but implement only step one)
6. **Example of change under new structure** — show what adding a new feature looks like after the restructure

### After receiving output:

Execute step one, deploy it, verify nothing broke. Then ask: "Step one is deployed and verified. Implement step two of the migration sequence." Do not ask for all steps at once.

---

## 10. Multi-Perspective Engineering Review

**Code or design under review:**

```text
[Paste code, architecture doc, or technical spec]
```

**Context:** [What this is for, who uses it, what success looks like, what stage it's at (prototype / pre-production / production)]

Review from four perspectives in sequence. Each perspective must challenge the assumptions of the previous one.

**Perspective 1 — Architect:** Structural design, coupling, abstraction boundaries, and whether they hold under future requirements changes.

**Perspective 2 — Implementer:** Correctness, edge cases, error handling, gaps between intended architecture and actual code.

**Perspective 3 — Security:** Trust boundaries, input validation, auth enforcement, data exposure. For WordPress: nonce verification, capability checks, SQL injection via `$wpdb`, XSS in template output, CSRF on AJAX handlers.

**Perspective 4 — Operator:** What breaks silently? What's unobservable? What does the on-call see at 2am? For WordPress: what happens when a plugin conflict occurs, when WP_DEBUG is off, when the site is behind a reverse proxy, when object cache fails?

### Required output:

1. **Each perspective's findings** — specific issues with code references
2. **Conflict log** — where perspectives disagree (architect says "abstract this" but implementer says "the abstraction adds complexity for no current benefit")
3. **Severity-ranked issue list** — all findings, merged and deduplicated
4. **Revised implementation** — incorporating fixes for the top five issues

---

## 11. Production UI Component

**Component:** [What it does, where it appears in the product]
**Framework:** [React / Vue / Alpine.js / vanilla JS + version; if WordPress: is this a Gutenberg block, a block editor sidebar plugin, a classic metabox, or a frontend component?]
**Design system:** [Existing component library, CSS framework, token system, or WordPress admin styles]
**Existing patterns:** [How similar components are structured in this codebase — paste an example if possible]
**Browser support:** [Minimum targets — include mobile if relevant]
**Accessibility:** [WCAG level, specific requirements — keyboard navigation, screen reader announcements, focus management]

### Required output:

1. **Component contract** — props/attributes, events, slots/children, types
2. **Composition** — how this fits into the surrounding UI and data flow
3. **State model** — what state lives where (component local, store, URL, server) and why
4. **Complete implementation** — no TODOs, no placeholder handlers
5. **States handled explicitly** — loading, empty, error, partial data, permission denied
6. **Accessibility** — ARIA roles, keyboard interaction map, focus management, announced state changes
7. **Usage examples** — three representative scenarios
8. **Tests** — interaction tests for critical user paths

### WordPress Gutenberg-specific additions (if applicable):

9. **Block registration** — `registerBlockType` with complete `block.json`
10. **Editor vs. frontend rendering** — `edit` and `save` (or dynamic render via PHP `render_callback`)
11. **Block attributes and InspectorControls** — settings panel implementation
12. **Enqueue strategy** — editor-only vs. frontend-only vs. both

---

## 12. Production API Endpoint

**Endpoint purpose:** [What action it performs and who calls it]
**Tech stack:** [PHP/WordPress REST API, Node/Express, etc. — with versions]
**Auth model:** [WordPress nonce + cookie, JWT, API key, application password, OAuth]
**Existing conventions:** [How routes, validation, and errors are structured in this codebase — paste an example endpoint if possible]
**Rate limiting and abuse concerns:** [Expected call volume, known abuse vectors]

### Required output:

1. **Route design** — method, path, namespace (for WP REST: `/wp-json/your-namespace/v1/resource`), and reasoning
2. **Request validation** — schema with all constraints; for WP REST: `args` array with `validate_callback` and `sanitize_callback`
3. **Auth and authorization** — authentication check and permission enforcement via `permission_callback`; never return `true` unconditionally
4. **Controller logic** — separated from transport; for WordPress: thin controller in the REST route callback, business logic in a service class
5. **Error responses** — consistent `WP_Error` / error shape, appropriate HTTP status codes, no internal detail leakage (no stack traces, no SQL, no file paths)
6. **Logging and observability** — what is logged, at what level, what is never logged (PII, passwords, tokens)
7. **Complete implementation** — runnable code
8. **Integration tests** — happy path, auth failure, validation failure, and one domain-specific edge case

---

## 13. Code Review (PR/Diff Review)

Use when you have a diff or set of changes and want a structured review before merging.

**Diff or changed code:**

```text
[Paste the diff, or paste the changed files with changes marked]
```

**What this change does:** [One paragraph — the PR description]
**What it's supposed to fix or add:** [Link to ticket/issue or describe the requirement]
**Existing code context:** [Paste any unchanged files that the diff depends on, if not obvious from the diff itself]
**Areas of concern:** [Anything you're specifically uncertain about — "I'm not sure the caching invalidation is correct," "I don't know if this is accessible"]

### Required output:

1. **Change summary** — what the diff actually does, in the reviewer's words (catch mismatches between intent and implementation)
2. **Correctness issues** — bugs, logic errors, race conditions, unhandled states
3. **Security issues** — for WordPress: unsanitized input, missing nonces, missing capability checks, unescaped output, raw SQL
4. **Performance concerns** — N+1 queries, unnecessary re-renders, missing caching opportunities, autoloaded options
5. **Maintainability notes** — naming, structure, unnecessary complexity, missing documentation
6. **What's good** — explicitly call out well-done parts (code review isn't only about problems)
7. **Verdict** — approve, request changes (with ranked list), or block (with explanation)

---

## 14. Documentation Generator

Use when you need to produce or update documentation from existing code.

**Code to document:**

```text
[Paste the code — a plugin, a module, an API, a component library]
```

**Documentation type:**
- [ ] README / project overview
- [ ] API reference
- [ ] Developer onboarding guide ("how to work in this codebase")
- [ ] Inline code documentation (PHPDoc / JSDoc)
- [ ] End-user documentation (how to use the plugin/feature)
- [ ] Architecture decision records (ADRs)

**Audience:** [Who reads this — new developer on the team, external API consumer, site administrator, open-source contributor?]
**Existing documentation:** [Is there any? Paste what exists so the model can update rather than rewrite from scratch.]
**Conventions:** [Documentation format — Markdown, PHPDoc, JSDoc, WordPress readme.txt format, etc.]

### Required output:

1. **Documentation** — complete, in the specified format, written for the specified audience
2. **Gaps identified** — areas where the code's behavior is ambiguous and the documentation had to make assumptions (flag these so a human can verify)
3. **Maintenance notes** — which sections will go stale fastest and what triggers an update

### After receiving output:

Read it as if you're the target audience encountering this codebase for the first time. If any section confuses you, paste it back: "This section is unclear to someone who doesn't already understand [concept]. Rewrite it assuming the reader knows [X] but not [Y]."

---

## 15. Migration + Upgrade

Use for framework upgrades, dependency replacements, PHP version bumps, WordPress major version migrations, or moving from one service/library to another.

**What's being migrated:** [e.g., "PHP 7.4 to 8.2," "WordPress Classic Editor to Gutenberg blocks," "jQuery AJAX to WordPress REST API + fetch," "MySQL to MariaDB," "custom auth to WordPress application passwords"]
**Current state:**

```text
[Paste representative code showing current patterns — not everything, just the patterns that will change]
```

**Target state:** [What the code should look like after migration — link to docs, paste examples, or describe the target pattern]
**Scope:** [How much code is affected? Rough file/function count. Is this the whole codebase or one module?]
**Breaking changes known:** [Deprecated functions, removed APIs, changed behavior — paste from upgrade guides if available]
**Rollback plan:** [Can this be feature-flagged? Blue-green deployed? Or is it all-or-nothing?]
**Test coverage:** [Do tests exist for the code being migrated?]

### Required output:

1. **Migration analysis** — what must change, what can stay, what's at risk
2. **Breaking change inventory** — every deprecated/removed API used in the current code, with its replacement
3. **Migration sequence** — ordered steps, each deployable independently. No step should leave the codebase broken.
4. **Compatibility layer** (if applicable) — shims or wrappers that let old and new coexist during migration
5. **Migrated code** — complete files for the first migration step
6. **Verification plan** — how to confirm each step worked before proceeding to the next
7. **Rollback procedure** — how to undo each step if something goes wrong

### After receiving output:

Execute one step at a time. Verify. Then: "Step [N] is complete and verified. Here are the results: [any issues or observations]. Proceed with step [N+1]."

---

## 16. WordPress-Specific: Custom Block Builder

Use when building a Gutenberg block from scratch.

**Block name:** [e.g., `your-plugin/testimonial-card`]
**Block purpose:** [What it displays and how editors interact with it]
**Block category:** [text, media, design, widgets, embed, or custom]
**Dynamic or static:** [Does it render via PHP `render_callback` (dynamic) or save HTML to the database (static)?]
**Attributes:** [List each attribute with its type, default, and what controls it in the editor — e.g., "heading: string, default empty, controlled by RichText"]
**Inner blocks:** [Does this block contain other blocks? If so, which are allowed?]
**Variations:** [Does this block have variations — e.g., a "card" block with "horizontal" and "vertical" variations?]
**Editor experience:** [Describe the editing UX — sidebar controls, inline editing, placeholder states, toolbar controls]
**Frontend rendering:** [How it looks on the site — responsive behavior, animation, interaction]

### Required output:

1. **`block.json`** — complete with attributes, supports, and metadata
2. **`edit.js`** — full editor component with InspectorControls, BlockControls, and placeholder state
3. **`save.js`** — save function (or null if dynamic)
4. **`render.php`** — server-side render callback (if dynamic)
5. **`index.js`** — block registration
6. **`style.scss` / `editor.scss`** — frontend and editor styles, separated appropriately
7. **`index.php`** — block registration via `register_block_type` with asset enqueueing
8. **Transforms** — `from` and `to` transforms for related block types where sensible
9. **Deprecations** — if this replaces an existing block, include a deprecation handler for the old markup

### After receiving output:

Register the block and test in the editor. Common issues to check: attribute defaults not matching, `save` output not matching `edit` output (causes block validation errors), missing `useBlockProps` causing wrapper element issues.

---

## 17. WordPress-Specific: WP-CLI Command

Use when building a custom WP-CLI command for administrative automation.

**Command:** [e.g., `wp yourplugin sync --force`]
**Purpose:** [What it does — e.g., "syncs CRM contacts with WordPress users, creating or updating as needed"]
**Arguments and flags:** [List each with type, required/optional, default, and description]
**Data involved:** [What data is read, written, or deleted — be specific about tables/post types/options]
**Expected runtime:** [Seconds for small site, minutes for large site, or unknown]
**Safety concerns:** [Does this modify or delete data? Is it idempotent? Can it be run twice safely?]

### Required output:

1. **Command registration** — `WP_CLI::add_command` with complete synopsis
2. **Implementation** — full command class extending `WP_CLI_Command`
3. **Progress reporting** — `WP_CLI::log`, progress bars for batch operations, summary stats at completion
4. **Error handling** — `WP_CLI::warning` for recoverable issues, `WP_CLI::error` for fatal ones
5. **Dry-run mode** — `--dry-run` flag that reports what would happen without making changes
6. **Batch processing** — if operating on many records, process in chunks to avoid memory exhaustion
7. **Documentation** — inline help text that appears with `wp help yourplugin sync`

---

## Appendix: Iteration Patterns

These patterns work across all prompts above.

**When the output is mostly right but has specific issues:**
"Your implementation of [specific part] has this problem: [describe]. The rest is correct. Revise only [specific part] and explain what changed."

**When the output misunderstands the codebase context:**
"You assumed [X] about the existing code, but actually [Y]. Here is the relevant existing code: [paste]. Revise your implementation to work with this constraint."

**When you need the model to continue a large implementation:**
"The implementation plan is approved. Implement [next file from the plan] following the same conventions as the [previous file] you already produced."

**When the output is wrong in a way you can't diagnose:**
"Your implementation doesn't work. Here is what happens when I run it: [exact error or behavior]. Here is the environment: [versions, config]. Diagnose the failure and provide a corrected implementation."

**When you want to explore an alternative approach:**
"Before I commit to this implementation, propose an alternative architecture for [specific part] that prioritizes [different tradeoff — e.g., simplicity over flexibility, performance over readability]. Compare the two approaches."
