#!/usr/bin/env bash
#
# Install the pre-push hook shipped in `.githooks/`.
#
# `core.hooksPath` is a *local* git config — it is NOT inherited by fresh
# clones, and crucially it is NOT inherited by `git worktree add` either.
# Without this, format/analyzer issues only surface in CI instead of locally.
#
# Usage (from the repo root):
#   ./bin/install-hooks.sh
#
# Verify afterwards:
#   git config --get core.hooksPath     # should print: .githooks
#   cat .git/hooks/pre-push             # should exist and be executable
#
# To uninstall:
#   git config --unset core.hooksPath
#
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$REPO_ROOT" ]; then
  echo "✖ Not inside a git repository." >&2
  exit 1
fi

HOOKS_DIR="$REPO_ROOT/.githooks"
if [ ! -d "$HOOKS_DIR" ]; then
  echo "✖ No .githooks/ directory in $REPO_ROOT." >&2
  echo "  This script is intended for projects scaffolded from flutter-starter-template." >&2
  exit 1
fi

PRE_PUSH="$HOOKS_DIR/pre-push"
if [ ! -f "$PRE_PUSH" ]; then
  echo "✖ $PRE_PUSH not found." >&2
  exit 1
fi

# .githooks/pre-push ships executable, but a clone on Windows or via a zip
# download can drop the bit. Restore it just in case.
chmod +x "$PRE_PUSH"

# `git config --local` so the setting stays scoped to this clone. Using
# `--local` (the default for `git config`) means a different clone in a
# sibling directory is not affected.
git config core.hooksPath .githooks

# A worktree that already exists won't pick up the change retroactively, so
# remind the user to re-run after creating new worktrees. We don't try to
# reconfigure existing worktrees automatically — that would touch state the
# user might not want changed. (POSIX-portable `git worktree list` parsing —
# awk on macOS BSD rejects unescaped $ in regexes.)
SELF_PATH="$REPO_ROOT"
WORKTREES=$(git worktree list --porcelain 2>/dev/null | awk -v self="$SELF_PATH" 'index($0, "worktree ") == 1 && $2 != self { print $2 }')
if [ -n "$WORKTREES" ]; then
  echo "ℹ  Existing worktrees will not pick up the new hook automatically."
  echo "   Re-run this script from inside each worktree, or run:"
  echo "   git -C <worktree-path> config core.hooksPath \"$(git -C "$REPO_ROOT" rev-parse --show-toplevel)/.githooks\""
fi

echo "✓ Installed pre-push hook from .githooks/."
echo "  core.hooksPath → $(git config --get core.hooksPath)"
echo ""
echo "Next push will run: build_runner + dart format + flutter analyze"
echo "Bypass in an emergency with:  git push --no-verify"
