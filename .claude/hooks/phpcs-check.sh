#!/usr/bin/env bash
# phpcs-check.sh — PostToolUse hook: auto-fix and lint PHP after Claude edits it.
#
# Wired up in .claude/settings.json under hooks.PostToolUse (matcher "Write|Edit").
# Receives the hook payload as JSON on stdin.
#
# WHY THIS EXISTS
#   CLAUDE.md asks the model to self-verify that "composer phpcs would pass on the
#   code as written". That is the model grading its own homework. This hook makes
#   it a fact: phpcbf fixes what is mechanically fixable, phpcs reports the rest,
#   and the remainder is fed back so the model has to deal with it.
#
# BEHAVIOUR
#   Silent no-op unless ALL of these hold: the edited file is .php, it still
#   exists, and a phpcs binary is resolvable. A project that has not run
#   `composer install` is not nagged.
#
#   phpcbf rewrites the file directly on disk, so the model's in-context copy can
#   go stale even on a clean result. The feedback message says so explicitly.
#
# EXIT CONTRACT
#   Always exits 0. Violations are reported by printing a PostToolUse decision
#   object on stdout — that feeds the reason back to the model and lets the turn
#   continue. A non-zero exit here would look like a broken hook, not a lint hit.

set -uo pipefail

payload=$(cat)

# ── Extract the edited file path ──────────────────────────────────────────────

if command -v jq >/dev/null 2>&1; then
  # stderr suppressed: malformed input must fail silently, not print a parse
  # error into the transcript on every stray payload.
  file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_response.filePath // empty' 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
  file=$(printf '%s' "$payload" | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti = d.get("tool_input") or {}
tr = d.get("tool_response") or {}
print(ti.get("file_path") or tr.get("filePath") or "")')
else
  # No JSON parser available. Staying silent is correct — a hook that cannot read
  # its input must not pretend the file is clean OR spam the transcript.
  exit 0
fi

[ -n "${file:-}" ] || exit 0
case "$file" in *.php) ;; *) exit 0 ;; esac
[ -f "$file" ] || exit 0

# ── Resolve the linter ────────────────────────────────────────────────────────
# Project-local vendor/bin wins over anything global, so the project's pinned
# WPCS version is what runs.

root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

if [ -x "$root/vendor/bin/phpcs" ]; then
  PHPCS="$root/vendor/bin/phpcs"
  PHPCBF="$root/vendor/bin/phpcbf"
elif command -v phpcs >/dev/null 2>&1; then
  PHPCS=$(command -v phpcs)
  PHPCBF=$(command -v phpcbf || true)
else
  exit 0   # No phpcs in this project — nothing to enforce.
fi

# ── Fix, then check ───────────────────────────────────────────────────────────
# phpcbf exits 1 when it fixed something and 0 when there was nothing to fix,
# so its status is not a failure signal and is deliberately discarded.

if [ -n "${PHPCBF:-}" ] && [ -x "$PHPCBF" ]; then
  "$PHPCBF" --no-colors -q "$file" >/dev/null 2>&1 || true
fi

# --report=emacs is `path:line:col: level - message`: one line per violation,
# precise enough for the model to act on and far cheaper than the full report.
report=$("$PHPCS" --no-colors -q --report=emacs "$file" 2>/dev/null)
status=$?

[ "$status" -eq 0 ] && exit 0                 # clean
[ "$status" -ge 2 ] && exit 0                 # phpcs itself errored — not a code problem
[ -n "$report" ] || exit 0

# Cap the feedback. A file with 200 violations is a signal to look at the file,
# not to paste 200 lines into the context window.
total=$(printf '%s\n' "$report" | grep -c . || true)
shown=$(printf '%s\n' "$report" | head -40)
if [ "$total" -gt 40 ]; then
  shown="$shown
… $((total - 40)) more violation(s) not shown."
fi

rel="${file#"$root"/}"

reason="phpcbf ran on $rel and $total WPCS violation(s) remain — these are not auto-fixable:

$shown

Fix them before continuing. Note that phpcbf may have already rewritten this file on disk, so re-read it before editing."

# ── Emit the PostToolUse decision ─────────────────────────────────────────────

if command -v jq >/dev/null 2>&1; then
  jq -n --arg r "$reason" --arg f "$rel" --argjson n "$total" \
    '{decision:"block", reason:$r, systemMessage:("phpcs: \($n) violation(s) in \($f)")}'
else
  python3 -c 'import json,sys
print(json.dumps({
    "decision": "block",
    "reason": sys.argv[1],
    "systemMessage": "phpcs: %s violation(s) in %s" % (sys.argv[3], sys.argv[2]),
}))' "$reason" "$rel" "$total"
fi

exit 0
