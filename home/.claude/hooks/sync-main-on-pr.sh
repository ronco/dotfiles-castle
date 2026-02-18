#!/bin/bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only sync when running gh pr commands
if echo "$COMMAND" | grep -qE "^gh pr "; then
  git fetch origin main:main 2>/dev/null || git branch -f main origin/main 2>/dev/null
fi

exit 0
