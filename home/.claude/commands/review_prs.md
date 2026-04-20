# Review PRs

Find and review PRs across specified GitHub organizations.

## Arguments

- `$ARGUMENTS` - Optional: GitHub org names to search (space-separated). Defaults to `AdAction AdGem` if not provided.
  - `--all` - Review all open PRs in the orgs, not just ones where you're a requested reviewer
  - `--include-drafts` - Include draft PRs in the review list
  - `--include-stale` - Include stale PRs (only relevant with `--all`)

## Instructions

1. **Find PRs awaiting review**

   Parse flags from `$ARGUMENTS`:
   - `--all` flag: search all open PRs instead of just review-requested
   - `--include-drafts` flag: include draft PRs
   - `--include-stale` flag: include stale PRs (default is to skip them when using `--all`)
   - Remaining arguments are org names (default to `AdAction` and `AdGem`)

   Search for open PRs using the `gh` CLI:
   ```bash
   # Default: PRs where user is requested reviewer
   gh search prs --review-requested=@me --state=open --owner=<ORG> --json repository,title,url,number,author,createdAt,updatedAt

   # With --all: All open PRs in the org
   gh search prs --state=open --owner=<ORG> --json repository,title,url,number,author,createdAt,updatedAt
   ```

   If `$ARGUMENTS` contains org names (excluding flags), use those. Otherwise, default to searching `AdAction` and `AdGem` orgs.

   **Filter out already-approved PRs, drafts, and stale PRs**: For each PR found, check status:
   ```bash
   gh pr view <number> --repo <owner/repo> --json reviews,isDraft --jq '{isDraft: .isDraft, approved: [.reviews[] | select(.author.login == "<username>" and .state == "APPROVED")] | length > 0}'
   ```

   Get the current user's GitHub username with:
   ```bash
   gh api user --jq '.login'
   ```

   Exclude any PRs where:
   - The user has already submitted an approval
   - The PR is a draft (unless `--include-drafts` is passed)
   - **When using `--all`**:
     - The PR was authored by the current user (can't review your own PRs)
     - The PR is stale (unless `--include-stale` is passed)

   **Staleness definition**: A PR is considered stale if:
   - It was last updated more than 14 days ago, OR
   - It has been open for more than 30 days with no reviews

   This handles the case where someone is still listed as a requested reviewer even after approving, and avoids reviewing PRs that aren't ready yet or have been abandoned.

2. **Summarize the results**

   Present the PRs in two groups:
   - **Human-authored PRs** - These are priority and should be reviewed first
   - **Bot PRs (Dependabot, etc.)** - Group these by repository and summarize

   For each human-authored PR, show:
   - PR link (repo#number)
   - Author (use first name if known)
   - Title
   - Created date

3. **Review PRs one by one**

   When the user is ready, go through each human-authored PR:

   a. Open the PR in the browser and fetch details:
      ```bash
      open <pr_url>
      gh pr view <number> --repo <owner/repo> --json title,body,author,createdAt,additions,deletions,files,reviews,comments,headRefName,baseRefName
      gh pr diff <number> --repo <owner/repo>
      ```

   b. Present a summary including:
      - Title, author, branch info
      - Change statistics (+/- lines, files changed)
      - Ticket reference (if any)
      - Existing reviews
      - Summary of changes
      - Any observations or potential issues

   c. Ask if the user wants to:
      - Draft an approval
      - Leave a comment
      - Request changes
      - Skip to the next PR

4. **Posting reviews**

   When drafting approvals or comments, match the user's communication style (see CLAUDE.md for preferences).

   Use the appropriate `gh` command:
   ```bash
   # For approvals
   gh pr review <number> --repo <owner/repo> --approve --body "<message>"

   # For comments only
   gh pr comment <number> --repo <owner/repo> --body "<message>"

   # For requesting changes
   gh pr review <number> --repo <owner/repo> --request-changes --body "<message>"
   ```

5. **Handle special cases**

   - **Draft PRs**: Filtered out by default. Only included if `--include-drafts` is passed
   - **Stale PRs**: When using `--all`, stale PRs are filtered out by default. Only included if `--include-stale` is passed. When reviewing assigned PRs (default mode), stale PRs are still shown but flagged prominently
   - **CI failures**: Check if failures are related to the PR changes
   - **Stacked PRs**: Note if a PR targets a non-main branch
   - **Your own PRs**: When using `--all`, skip PRs authored by the current user

6. **Wrap up**

   After reviewing all human-authored PRs, summarize what was done and remind the user about any remaining bot PRs.

## Review Heuristics

### Approve confidently when
- Diff is small (< 50 lines) OR docs/tests only
- CI is green
- Scope matches PR title and linked Jira ticket
- No public API changes
- Existing tests cover the change, or tests were added
- Author has recent track record in this area

Draft an `lgtm`-style approval — see `~/.claude/voice.md` → *PR-Specific Voice → Review Approvals*.

### Raise a concern or block when
- **Tag cardinality** — new Datadog tags derived from user IDs, request IDs, timestamps, or unbounded strings
- **Observability gaps** — new code paths without metrics or logs, or log levels that will spam prod
- **Migration safety** — schema changes without a backfill plan, `NOT NULL` adds on large tables, non-idempotent migrations
- **Merge commits in the branch history** — often a force-push to the feature branch is safer than preserving the merge; confirm with the author before recommending
- **Unverified capability claims** — if the PR description asserts a behavior, confirm it exists in the diff before echoing it in an approval comment

### Verify before asserting
Never describe a capability, monitor, integration, or feature as "working" or "in place" unless it's in the diff. If speculating about future behavior, phrase as a question or prefix with "assuming this is wired up". Past sessions have shipped comments describing monitors that weren't actually built — don't compound that.

## Voice

All drafted comments must match Ron's voice. The primary reference is `~/.claude/voice.md`, especially:
- *PR-Specific Voice → Review Approvals*
- *PR-Specific Voice → Feedback Style* (questions not commands)
- *Banned Phrases* — especially "solid", "clean", uppercase "LGTM", em dashes, "this isn't X. this is Y."

Before posting, re-read the drafted comment against the banned phrases list.
