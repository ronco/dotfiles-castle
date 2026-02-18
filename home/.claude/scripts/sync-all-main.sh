#!/bin/bash
# Sync local main with origin/main for all repos registered with git maintenance.
# Runs via launchd on a schedule, after git maintenance prefetch has fetched objects.

REPOS=$(git config --global --get-all maintenance.repo 2>/dev/null)

for repo in $REPOS; do
  [ -d "$repo/.git" ] || continue
  # fetch origin main:main does a fast-forward update of local main directly.
  # Falls back to branch -f if we're currently on main or it has diverged.
  git -C "$repo" fetch origin main:main 2>/dev/null \
    || git -C "$repo" branch -f main origin/main 2>/dev/null
done
