# Changelog

Per-project Claude layer template (`wp-scaffold-project`). Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## Version semantics

`bin/init.sh` **copies** this template into a project. Nothing syncs it again — a
fix made here never reaches a project that was already bootstrapped. The version
number exists to make that gap measurable, so the bump levels are defined by
**what an already-bootstrapped project has to do**, not by API surface:

| Bump | Means | Action required in existing projects |
| --- | --- | --- |
| **major** | The bootstrap contract changed — `init.sh` flags, modes, or target layout | Re-bootstrap, or migrate by hand per the entry |
| **minor** | A file was added or removed from the copied layer, or a copied file changed in a way that matters | Apply the entry to each project in `.sync-projects` |
| **patch** | New projects only — `init.sh` internals, docs, template placeholder text | None |

**Every minor entry is a propagation task.** `bin/audit-drift.sh` in
`wp-scaffold-global` reads each project's `.claude/.scaffold-version` stamp and
reports how far behind it is; this file is what tells you what that gap contains.

Sections used, in order: `Breaking Changes`, `Added`, `Changed`, `Fixed`, `Removed`.

## Releasing

1. Move everything under `## [Unreleased]` into a new dated version section.
2. Bump `VERSION` to match.
3. Commit, then `git tag vX.Y.Z`.
4. Add a fresh empty `## [Unreleased]` for the next cycle.

Released sections are immutable — never edit one after tagging.

---

## [Unreleased]

_Nothing yet._

---

## [2.1.0] — 2026-07-31

Consolidates everything committed after the `v2.0.0` tag, which ran unreleased from
2026-05-21 to 2026-07-25, plus the phpcs hook and version stamp added on 2026-07-31.

### Added

- **`.claude/hooks/phpcs-check.sh` — PostToolUse hook running phpcbf then phpcs on
  every PHP file Claude edits.** `CLAUDE.md` asks the model to self-verify that
  "`composer phpcs` would pass on the code as written," which is the model grading
  its own homework. This makes it a fact: phpcbf fixes what is mechanically fixable,
  phpcs reports the rest, and the remainder is fed back into the turn as a
  `decision: "block"` so the model has to deal with it.

  Silent no-op unless the edited file is `.php`, still exists, and a phpcs binary
  resolves — `vendor/bin/phpcs` preferred over global, so the project's pinned WPCS
  version is what runs. A project that has not run `composer install` is never
  nagged. Output capped at 40 violations. Always exits 0, so a lint hit never looks
  like a broken hook.

  Verified end-to-end: guard clauses pipe-tested against malformed, empty, non-PHP,
  and missing-file payloads; a real WPCS-dirty file confirmed phpcbf rewrites in
  place and the unescaped-output violation reaches the model.

- `.claude/.scaffold-version` — written by `bin/init.sh` at bootstrap, recording the
  template and global versions the project came from, the date, and the mode. This is
  what makes version lag measurable rather than theoretical.

- `VERSION` and this changelog.

### Changed

- `.claude/settings.json` — added the `hooks.PostToolUse` block. All existing
  permission entries preserved.

### Propagation notes for existing projects

Both `clf-rebuild` and `ubc-transit` predate the stamp and will report as
`unstamped`. To adopt this release in an existing project:

```bash
cp -r <template>/.claude/hooks <project>/.claude/
# then merge the "hooks" block from the template's .claude/settings.json
printf '{\n  "template_version": "2.1.0"\n}\n' > <project>/.claude/.scaffold-version
```

### Added — carried from the unreleased 2026-05-21 → 2026-07-25 work

- Obsidian vault integration — `CLAUDE.md` routes session start through the vault's
  workflow and topic pages; `bin/retrofit-vault.sh` for existing projects.
- Session protocol in `CLAUDE.md`: read Current Focus and Known Issues, read
  `PROJECT-SPEC.md`, read `DECISIONS.md` before any architectural decision, state
  the task in one sentence and wait for confirmation.
- Output standards — a self-verify checklist covering sanitization, escaping, nonce
  and capability checks, i18n, `$wpdb->prepare()`, and phpcs.
- WordPress decision defaults — theme vs plugin, REST vs admin-ajax, options vs
  custom tables, block vs classic PHP, hook priority, capability selection.
- Reversibility gate in `CLAUDE.md` for destructive, hard-to-reverse, and
  externally-visible actions.

### Changed

- WordPress baseline raised to 6.9; PHP 8.1+.
- `CLAUDE.md` updated for Claude 5-generation models — trimmed 1,728 to 1,642 words
  by removing generic behaviour now handled by model judgement, keeping all
  WordPress-specific and project-workflow content. The
  "— These Are Also Non-Negotiable" heading suffix was dropped as overtriggering-style
  emphasis.
- Agent settings updated.

### Fixed

- **Four dead `Write()` permission rules.** `.claude/settings.json` granted
  `Write(themes/**)`, `Write(plugins/**)`, `Write(mu-plugins/**)`, and
  `Write(tests/**)`. Claude Code matches file-write permissions on `Edit(path)`
  rules only, so all four no-oped — producing permission prompts on writes the
  developer believed were pre-approved. Because the defect lived in the template,
  every project bootstrapped via `bin/init.sh` inherited it. Claude Code emits an
  explicit stderr diagnostic naming this exact fix on every session start; it had
  been printing unread for weeks.
- Dropin mode: reference directories now created reliably, overwrite guards added
  for an existing `.claude/` and `CLAUDE.md` (the latter backed up rather than
  overwritten), settings globs corrected, project triage wired in.

---

## [2.0.0] — 2026-05-19

### Breaking Changes

- **Two-repo split.** Skills, agents, and rules moved to `wp-scaffold-global`,
  installed once per machine by symlink. This repo became the per-project Claude
  layer only. The Claude layer moved to the repo root and `bin/init.sh` became the
  bootstrap entry point, with `fresh` and `dropin` modes.

---

## [1.x]

Single-repo era, 2026-04-07 to 2026-05-19. See git history.
