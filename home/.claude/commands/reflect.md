---
name: reflect
description: Review the current chat session for mistakes, friction, and improvements. Suggest new skills for repeated patterns.
---

# Reflect

Perform a structured retrospective on the current chat session.

## Success Criteria

Before presenting output, verify all of the following are met:

1. Session review covers all major interactions, not just the most recent
2. Each identified issue is specific and actionable (not vague)
3. Proposed improvements are concrete and scoped (not generic advice)
4. The user is given a clear yes/no choice for each proposed change

## Workflow

### Step 1: Session Review

Review the full conversation and produce a concise summary:

- What was accomplished
- What went well
- What required corrections, clarifications, or retries

### Step 2: Identify Issues

List specific instances of:

- **Mistakes** -- incorrect output, wrong assumptions, bad code
- **Friction** -- unnecessary back-and-forth, unclear questions, slow approaches
- **Unclear outputs** -- responses that needed follow-up to understand

Format each as: `[category] brief description -> what happened -> what would have been better`

### Step 3: Propose Improvements

Based on the issues, propose a numbered list of concrete improvements. These can be:

- New instructions to add to CLAUDE.md
- Workflow changes
- New skills to create
- Existing skill modifications

### Step 4: Ask What to Remember

Present the improvements and ask the user which ones to save. Improvements can go to:

- **CLAUDE.md** -- for standalone preferences or instructions
- **A new or existing skill** -- when improvements form a cohesive technique or workflow

Apply only what the user approves.

### Step 5: Repeated Pattern Detection

Scan the session for tasks the user asked for more than once or similar manual steps that were repeated. If found:

- Suggest creating a reusable skill
- Describe what the skill would do
- Ask for confirmation before creating it

### Step 6: Skill Usage Check

If any skills (slash commands) were used during the session, note which ones and flag any that performed poorly. If a skill needs improvement, suggest the user run `/audit-skill <name>` on it.

## Proactive Trigger

When NOT running as an invoked skill: if the user has corrected you on the same type of issue twice in a session, suggest they run `/reflect` to capture improvements.
