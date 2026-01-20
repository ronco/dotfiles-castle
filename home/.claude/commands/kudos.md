---
description: Generate a kudos shout-out for a teammate based on their recent activity
allowed-tools: Bash(gh *), mcp__atlassian__lookupJiraAccountId, mcp__atlassian__searchJiraIssuesUsingJql, mcp__slack__slack_get_users
---

Generate a kudos shout-out for a teammate based on their recent GitHub, Jira, and Slack activity.

**Teammate:** $ARGUMENTS

## Instructions

1. **Look up the teammate's GitHub username** from the team table in CLAUDE.md:

   | Name | GitHub |
   |------|--------|
   | Benjamin / Ben | @BenGiese22 |
   | Corbin | @cmckeonaa |
   | Dakota | @dakotawashok |
   | Daniel | @danielsballes |
   | Dylan | @dkreth |
   | Eduardo | @egonzalezfsl |
   | Emma | @EmmaWorthington235 |
   | Fabian | @cfabianleon |
   | Francisco | @paco22dt |
   | Lenin | @pylenin |
   | Luiz | @abbluiz |
   | Maria | @Alex23013 |
   | Micah | @micahwierenga |
   | Mitch | @mitchcarter21 |
   | Nick | @nhaynes |
   | Paul | @Exaper |
   | Quintin | @QSoto |
   | Simuel / Sim | @G00SE-EGG |
   | Stenyo | @stenyof |
   | Steven | @ambitionphp |
   | Tawni | @tawnimyers |
   | Yury | @yurykorzun |

   If no match found, ask for the GitHub username.

2. **Gather GitHub activity** (past 30 days) in parallel:
   ```bash
   gh search prs --author=<github_username> --created=">=$(date -v-1m +%Y-%m-%d)" --limit=20 --json title,url,createdAt,repository,state
   ```

3. **Gather Jira activity** (past 30 days):
   - Look up their Jira account ID using `lookupJiraAccountId` with cloudId `d3313118-d3da-4712-bbac-77c0c26c7053`
   - Search with JQL: `assignee = "<account_id>" AND updated >= -30d ORDER BY updated DESC`

4. **Synthesize a 3-sentence kudos** that:
   - Opens with enthusiasm and names them
   - Highlights specific contributions with concrete examples
   - Closes with the impact on the team

5. **Present results:**

   ```
   **Activity Summary:**
   - GitHub: X PRs (themes...)
   - Jira: Y tickets completed (themes...)

   **Kudos:**
   > [3-sentence kudos here]

   Want me to adjust the tone or emphasize any particular aspect?
   ```
