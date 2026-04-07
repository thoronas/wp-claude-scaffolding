# WordPress Claude Code Scaffold

A shared scaffold for WordPress development with Claude Code. Contains global Claude configuration (skills, agents, rules) and a per-project starter template.

## Structure

```text
wp-scaffold/
├── global/          ← Install once per developer machine
│   ├── skills/      → wp-feature, wp-block, wp-debug, wp-migrate, wp-review
│   ├── agents/      → wpcs-enforcer, security-auditor, performance-profiler
│   ├── rules/       → php-standards, js-standards, template-standards, test-standards
│   └── install.sh   → symlinks everything above to ~/.claude/
└── project/         ← Copy into each new WordPress project repo
    ├── CLAUDE.md
    ├── PROJECT-SPEC.md
    ├── DECISIONS.md
    ├── .claude/
    │   ├── settings.json
    │   └── reference/
    ├── themes/your-theme/
    ├── plugins/your-plugin/
    ├── composer.json
    └── ...
```

---

## Setup

### Step 1 — Global install (once per machine)

Clone this repo, then run:

```bash
./global/install.sh
```

This symlinks the skills, agents, and rules from `global/` into `~/.claude/`, making them available in every project automatically. You only need to re-run this if you add new files to `global/` (edits to existing files are picked up instantly via symlinks).

Verify it worked:

```bash
ls ~/.claude/skills/
# should show: wp-block  wp-debug  wp-feature  wp-migrate  wp-review
```

### Step 2 — New project setup (per project)

Copy the `project/` directory into your new repo:

```bash
cp -r project/. /path/to/your/new-project
```

Then complete the rename checklist:

- [ ] Rename `themes/your-theme/` to your actual theme slug
- [ ] Rename `plugins/your-plugin/` to your actual plugin slug
- [ ] `CLAUDE.md` — fill in project name, packages, text domains, Current Focus
- [ ] `composer.json` — update vendor name and PSR-4 namespace
- [ ] `phpcs.xml.dist` — update text domain values
- [ ] `themes/[name]/style.css` — update theme header
- [ ] `plugins/[name]/[name].php` — update plugin header and constants
- [ ] `PROJECT-SPEC.md` — fill in packages table and first feature
- [ ] `.wp-env.json` — update theme and plugin directory names
- [ ] Run `composer install`
- [ ] Open Claude Code in the project directory

---

## Skills Reference

Skills are invoked by typing the skill name when working with Claude Code. All skills enforce WPCS compliance — they run `composer phpcbf` → `composer phpcs` before delivering PHP code.

| Skill | When to use |
|-------|-------------|
| `/wp-feature` | Add a feature, settings page, post type, REST endpoint, or any new functionality |
| `/wp-block` | Create a Gutenberg block from scratch |
| `/wp-debug` | Investigate a bug or unexpected behavior |
| `/wp-migrate` | Handle a WordPress upgrade, PHP version bump, or API deprecation |
| `/wp-review` | Security and WPCS code review before merging |

## Agents Reference

Agents are specialized subprocesses Claude can delegate to.

| Agent | When to use |
|-------|-------------|
| `wpcs-enforcer` | "Run a full WPCS audit" — finds and fixes all standards violations |
| `security-auditor` | "Audit this for security issues" — cross-references WPCS with manual checks |
| `performance-profiler` | "Profile this for performance issues" — N+1 queries, cache misses, etc. |

---

## Contributing

Skills, agents, and rules live in `global/`. Edit them here — symlinks mean `~/.claude/` picks up changes immediately without re-running `install.sh`.

To add a new skill:
1. Create `global/skills/[name]/SKILL.md`
2. Run `./global/install.sh` once to create the new symlink
3. The skill is immediately available across all projects

To update an existing skill, agent, or rule: edit the file directly and commit. Teammates pull the change and their symlinks pick it up automatically.
