# wp-scaffold-project

A per-project starter template for WordPress development with Claude Code.
Drop the Claude layer into any WordPress repo structure, or use fresh build mode
to scaffold a full project in one command.

For the machine-level Claude configuration (skills, agents, rules), see
[wp-scaffold-global](https://github.com/thoronas/wp-scaffold-global).

---

## Two repos, two jobs

| Repo | What it does | When you need it |
| ---- | ------------ | ---------------- |
| **wp-scaffold-global** | Skills, agents, rules, `install.sh` | Once per developer machine |
| **wp-scaffold-project** | Claude layer template + `bin/init.sh` | Once per new project |

---

## Step 1 — Global install (once per machine)

Clone [wp-scaffold-global](https://github.com/thoronas/wp-scaffold-global) and run:

```bash
./install.sh
```

This symlinks skills, agents, and rules into `~/.claude/` so they are available
in every project automatically.

Verify:

```bash
ls ~/.claude/skills/
# should show: wp-block  wp-debug  wp-feature  wp-migrate  wp-review  wp-theme
```

---

## Step 2 — Bootstrap a project

Clone this repo, then run `bin/init.sh`. It handles everything: copying the
Claude layer, .gitignore setup, placeholder substitution, and optionally
generating a full theme skeleton.

```bash
git clone https://github.com/your-org/wp-scaffold-project.git
cd wp-scaffold-project
bin/init.sh
```

The script will prompt for any values not supplied as flags:

```text
What type of bootstrap?
  [1] Drop into existing repo (Claude layer only)
  [2] Fresh build (Claude layer + WordPress structure + theme skeleton)
Choice [1/2]:
```

### Drop-in mode

Use when adding Claude Code to an existing repo, regardless of whether
the root is a wp-content directory, a single theme directory, or a themes
directory:

```bash
bin/init.sh \
  --mode dropin \
  --target /path/to/existing-project \
  --theme my-theme \
  --plugin my-plugin \
  --vendor acme \
  --namespace AcmeCorp
```

Copies: `.claude/`, `CLAUDE.md`, `PROJECT-SPEC.md`, `DECISIONS.md`,
`.editorconfig`, `.mcp.json`, `composer.json`, `phpcs.xml.dist`,
`phpunit.xml.dist`, `docs/DEVELOPMENT-PROMPTS.md`

Appends Claude-relevant entries to the target's existing `.gitignore`
(or creates one).

### Fresh build mode

Use when starting a new project from scratch:

```bash
bin/init.sh \
  --mode fresh \
  --target /path/to/new-project \
  --theme my-theme \
  --plugin my-plugin \
  --vendor acme \
  --namespace AcmeCorp
```

Copies the Claude layer + WordPress scaffold (plugins skeleton, mu-plugins,
languages, tests, `.wp-env.json`, `.gitignore`), runs all placeholder
substitutions, then launches Claude Code to generate the theme skeleton via
the `wp-theme` skill.

Pass `--no-theme` to skip theme generation and run it manually later.

### All flags

| Flag | Prompt fallback | Description |
| ---- | --------------- | ----------- |
| `--mode dropin\|fresh` | Interactive menu | Bootstrap mode |
| `--target PATH` | Prompt | Where to bootstrap |
| `--theme SLUG` | Prompt | Theme slug (e.g. `my-theme`) |
| `--plugin SLUG` | Prompt | Plugin slug (e.g. `my-plugin`) |
| `--vendor NAME` | Prompt | Composer vendor (e.g. `acme`) |
| `--namespace NAME` | Prompt | PHP namespace prefix (e.g. `AcmeCorp`) |
| `--no-theme` | Interactive Y/n | Skip wp-theme in fresh build |

---

## Reference: what .claude/reference/ is for

`.claude/reference/` holds inspiration code, mockups, and API samples that
Claude reads during development. See `.claude/reference/README.md` for usage.

**Note on nested .git folders:** Reference repos dropped here often carry
`.git` folders. Strip them before committing:

```bash
rm -rf .claude/reference/your-repo/.git
```

The `.gitignore` blocks nested `.git` dirs as a safety net, but the strip
step is required for a clean clone by teammates.

---

## Skills reference

All skills are installed globally via wp-scaffold-global and work in every project.

| Skill | When to use |
| ----- | ----------- |
| `/wp-feature` | Add a feature, settings page, post type, REST endpoint, or new functionality |
| `/wp-block` | Create a Gutenberg block from scratch |
| `/wp-debug` | Investigate a bug or unexpected behavior |
| `/wp-migrate` | Handle a WordPress upgrade, PHP version bump, or API deprecation |
| `/wp-review` | Security and WPCS code review before merging |
| `/wp-theme` | Generate a full theme skeleton — FSE or hybrid — from scratch |
