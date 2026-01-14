---
description: Initialize CLAUDE.md and create PR for a repository
allowed-tools: Bash(git *)
---

Initialize a CLAUDE.md file for a repository and create a PR. Follow these steps:

1. First, determine the main branch by running:
   ```
   git remote show origin | grep 'HEAD branch' | cut -d' ' -f5
   ```

2. Fetch latest and create a new branch from the main branch:
   ```
   git fetch origin
   git checkout origin/<main-branch> -b docs/add-claude-md
   ```

3. Run the /init command to analyze the codebase and generate CLAUDE.md

4. After CLAUDE.md is created, stage and commit it:
   ```
   git add CLAUDE.md
   git commit -m "docs: add CLAUDE.md for Claude Code guidance

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
   ```

5. Run the /pr command to create a pull request
