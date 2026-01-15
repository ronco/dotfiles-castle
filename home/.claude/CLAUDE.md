# Personal Information

## User Details
- **Name:** Ron White
- **GitHub:** ronco

## Documentation Preferences
When drafting Architecture Decision Records (ADRs) or other documentation:
- Use "Ron White" as the "Original Author" field
- GitHub username: ronco

# Memory and Configuration Management

## Remember Requests
**IMPORTANT**: When I ask you to "remember" something, "save this", or similar requests, you should:
1. Update this global CLAUDE.md file (`~/.claude/CLAUDE.md`) with the information
2. Place the information in the appropriate section (create new sections if needed)
3. Format it clearly so future Claude sessions can understand the preference
4. For project-specific preferences, update the project's CLAUDE.md instead
5. For secrets/credentials, use `~/.claude/.env` instead
6. Confirm what you've added after updating the file

# Git Workflow Preferences

## Branch Creation
**IMPORTANT**: Always create new branches from `origin/main` unless explicitly specified otherwise.
- Use: `git checkout origin/main -b <branch-name>` or `git fetch origin && git checkout -b <branch-name> origin/main`
- This ensures a clean starting point and avoids accidentally including commits from the current branch
- We practice trunk-based development, so all branches should start from main

## Branch Naming
- Always prefix branch names with `ronco/` (e.g., `ronco/feature-name`, `ronco/fix-bug`)

## Commit Messages
Always use Conventional Commits syntax for all commit messages:
- Format: `<type>(<scope>): <description>`
- Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert
- Scope is optional but recommended when applicable
- Example: `feat(auth): add OAuth2 login support`
- Keep subject line under 50 characters
- Use imperative mood ("add" not "added")
- Body and footer are optional but encouraged for complex changes

## Pull Request Creation
**IMPORTANT**: Always use the `/pr` command when creating pull requests.
- The `/pr` command ensures that a gif is included in the PR description
- This follows our team's convention of making PRs more engaging
- The command will prompt for a gif URL before creating the PR

## Communication Style for PR Comments and Descriptions

When drafting PR descriptions or comments, match this style:

**PR Description Structure:**
- Always include a relevant GIF (often humorous or pop culture reference, especially Simpsons)
- Use clear sections: Summary → Changes → Test plan → GIF
- Use checkboxes (- [ ] or - [x]) for test plans and action items
- Concise bullet points with technical precision
- Include specific file paths and technical details (e.g., `dbt/dbt-adaction/models/tune_ho/turbo_goals.sql:1`)
- Use ✅ checkmarks for completed items
- Professional but friendly tone

**PR Review Approvals:**
When approving PRs, use Ron's natural voice - casual and concise:
- "lgtm" (most common - lowercase, no punctuation)
- "lgtm!" (with enthusiasm)
- "Looks good." (simple, with period)
- "Looks good to me."
- "Looks really good." (when genuinely impressed)
- "Couple questions, but i think it's good." (when approving with minor questions)

**AVOID** formal/stiff phrasing like:
- "Test coverage is appropriate" ❌
- "The fix correctly preserves..." ❌
- "LGTM" (all caps) ❌
- Any overly technical summaries in approvals ❌

**PR Comments/Reviews:**
- Keep comments short and direct ("I'll address this", "What do you think?")
- Frame concerns as questions, not demands: "Will we need to back populate this stat?", "What if the data for a goal id is changed?"
- Use casual capitalization - lowercase "i" is fine ("i think", "i'm not sure")
- Use self-deprecating humor: "D'oh! I should've got that right", "I'm not the sharpest tool in the SQL shed"
- Friendly @mentions: "Hey @username!"
- Playful when appropriate: "Love that `failure_dag` some genius must've written that one."
- Lead with questions before approval: "One question before you merge.", "Pretty tricky. I think it's all correct, but I left a few questions for clarification."
- Ask about impact/edge cases: "What will the impact of adding a new grouping column have on the existing data?"
- Collaborative approach - ask questions rather than dictate solutions
- Not confrontational - diplomatic when identifying issues
- Use markdown code blocks for technical examples

**Emoji Usage:**
- Use ✅ for completed items
- Use checkboxes for action items
- Use → in bullet points for technical specs
- Generally minimal emoji usage, let GIFs do the talking

# Infrastructure-as-Code Standards

## AWS CDK
- **Directory Naming:** Always use `provision/` for CDK infrastructure code (NOT `infrastructure/`, `cdk/`, or `infra/`)
- **Language:** TypeScript is preferred for CDK stacks

# Python Development Preferences

## Testing
- **Framework:** Always use PyTest over UnitTest for all Python testing
- Use pytest fixtures, parametrize, and other pytest-specific features when appropriate

# Environment and Secrets Management

## Environmental Secrets
**IMPORTANT**: Always load environmental secrets and credentials from `~/.claude/.env` unless explicitly specified otherwise.
- Default location: `~/.claude/.env`
- Use `python-dotenv` or similar to load credentials in scripts
- Example: `load_dotenv(Path.home() / '.claude' / '.env')`
- This keeps secrets out of project repositories and centralized for all projects

# Team Members

Use this table to look up GitHub usernames when adding PR reviewers by first name.

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
