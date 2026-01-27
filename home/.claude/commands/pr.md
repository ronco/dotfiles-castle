---
description: Create a pull request with a GIF
allowed-tools: Bash(git *), Bash(gh *), mcp__atlassian__getTransitionsForJiraIssue, mcp__atlassian__transitionJiraIssue
---

Create a pull request for the current branch. Follow these steps:

1. First, ask me for a GIF URL to include in the PR description using the AskUserQuestion tool
2. Run these commands in parallel to understand the full context:
   - `git status` to see current state
   - `git diff --staged` to see staged changes
   - `git diff` to see unstaged changes
   - `git log main..HEAD` to see all commits since branching from main
   - `git diff main...HEAD` to see all changes since diverging from main
3. Analyze ALL commits that will be included in the PR (not just the latest)
4. Push to remote with `-u` flag if needed
5. Create the PR using `gh pr create` with this format:

```
gh pr create --title "the pr title" --body "$(cat <<'EOF'
## Summary
<bullet points of changes>

## Test plan
[Bulleted markdown checklist for testing]

![Demo](GIF_URL_HERE)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Replace GIF_URL_HERE with the URL I provide.

6. After creating the PR, check if the branch name or PR title contains a Jira ticket ID (pattern like `AGPI-1234`, `AG-123`, `AI-456`, etc.)
7. If a Jira ticket is found, transition it to "Code Review" status:
   - Use cloudId: `d3313118-d3da-4712-bbac-77c0c26c7053`
   - First call `mcp__atlassian__getTransitionsForJiraIssue` to get available transitions
   - Find the transition where the name contains "code review" (case-insensitive)
   - Call `mcp__atlassian__transitionJiraIssue` with the found transition ID
   - Report success or failure of the transition to the user
