---
name: audit-skill
description: Audit a skill for quality, conciseness, and effectiveness. Add success criteria if missing.
---

# Audit Skill

Audit the specified skill for quality and suggest improvements.

**Skill to audit:** $ARGUMENTS

If no skill name is provided, list available skills and ask which one to audit.

## Success Criteria

Before presenting output, verify:

1. Audit includes specific, line-level suggestions (not just "looks good")
2. Proposed changes preserve clarity and functionality
3. The user is given a clear yes/no choice for each proposed change

## Workflow

### Step 1: Read the Skill

Read the skill's `.md` file from `~/.claude/commands/` (or the dotfiles source if symlinked).

### Step 2: Success Criteria Check

If the skill does NOT already have success criteria:

- Propose success criteria appropriate to what the skill does
- Propose adding a verification instruction (e.g., "Before presenting output, verify the success criteria are met")

Don't force success criteria onto simple skills where they'd be overhead.

### Step 3: Conciseness Review

Check for token-saving opportunities:

- Redundant instructions
- Overlapping sections
- Verbose phrasing that can be tightened

Do NOT degrade clarity or functionality.

### Step 4: Effectiveness Review

If the skill was used earlier in this session, evaluate how it performed:

- Did it produce the expected output?
- Were there gaps or failure modes?
- Propose fixes for any issues observed

If the skill wasn't used this session, skip this step.

### Step 5: Present Changes

Present all proposed changes to the user as a numbered list. For each change, show the before/after or describe the addition. Apply only what the user approves.
