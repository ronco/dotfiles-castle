# Review PRs

Find and review all PRs where I'm a requested reviewer.

## Arguments

- `$ARGUMENTS` - Optional: GitHub org names to search (space-separated). If not provided, will prompt for orgs.
  - Add `--include-drafts` to include draft PRs in the review list.

## Instructions

1. **Find PRs awaiting review**

   Search for open PRs where the user is a requested reviewer using the `gh` CLI:
   ```bash
   gh search prs --review-requested=@me --state=open --owner=<ORG> --json repository,title,url,number,author,createdAt
   ```

   If `$ARGUMENTS` contains org names, use those. Otherwise, ask the user which orgs to search.

   **Filter out already-approved PRs and drafts**: For each PR found, check if the user has already approved it or if it's a draft:
   ```bash
   gh pr view <number> --repo <owner/repo> --json reviews,isDraft --jq '{isDraft: .isDraft, approved: [.reviews[] | select(.author.login == "<username>" and .state == "APPROVED")] | length > 0}'
   ```

   Get the current user's GitHub username with:
   ```bash
   gh api user --jq '.login'
   ```

   Exclude any PRs where:
   - The user has already submitted an approval
   - The PR is a draft (unless the user explicitly asks to include drafts)

   This handles the case where someone is still listed as a requested reviewer even after approving, and avoids reviewing PRs that aren't ready yet.

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

   a. Fetch PR details and diff:
      ```bash
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
   - **Stale PRs**: Note if a PR has been open for a long time
   - **CI failures**: Check if failures are related to the PR changes
   - **Stacked PRs**: Note if a PR targets a non-main branch

6. **Wrap up**

   After reviewing all human-authored PRs, summarize what was done and remind the user about any remaining bot PRs.
