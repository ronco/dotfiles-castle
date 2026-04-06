#!/usr/bin/env bash
# Auto-rename unnamed sessions on exit using claude -p with haiku.
# Backgrounds the LLM call so the hook returns immediately and avoids
# being cancelled during SessionEnd teardown.
set -uo pipefail

# Read hook stdin (contains session_id, transcript_path, reason, etc.)
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)
REASON=$(echo "$INPUT" | jq -r '.reason // empty' 2>/dev/null)

# Only rename interactive sessions that exited normally (skip claude -p sessions etc.)
if [ "$REASON" != "prompt_input_exit" ]; then
  exit 0
fi

if [ -z "$SESSION_ID" ] || [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

# Skip if already named
if grep -q '"custom-title"\|"agent-name"' "$TRANSCRIPT" 2>/dev/null; then
  exit 0
fi

# Background the expensive work (claude -p call) so the hook exits immediately
(
  FIRST_PROMPT=$(jq -r 'select(.type == "user" and .toolUseResult == null and (.message.content | type == "string")) | .message.content' "$TRANSCRIPT" 2>/dev/null \
    | head -1 \
    | head -c 300)

  [ -z "$FIRST_PROMPT" ] && exit 0

  RAW=$(printf 'Reply with ONLY a kebab-case name. 3-6 lowercase words joined by hyphens. Nothing else.\n\nExamples of good names:\nfix-auth-redirect-bug\nsetup-ci-pipeline\nreview-team-prs\nadd-user-search-api\n\nName this session:\n%s' "$FIRST_PROMPT" \
    | claude -p --model haiku 2>/dev/null)

  NAME=$(echo "$RAW" | head -1 | tr -d '\n\r' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g; s/^-//; s/-$//')

  # Validate: must be 5-60 chars and contain at least one hyphen
  if [ ${#NAME} -lt 5 ] || [ ${#NAME} -gt 60 ] || ! echo "$NAME" | grep -q '-'; then
    exit 0
  fi

  printf '{"type":"custom-title","customTitle":"%s","sessionId":"%s"}\n' "$NAME" "$SESSION_ID" >> "$TRANSCRIPT"
  printf '{"type":"agent-name","agentName":"%s","sessionId":"%s"}\n' "$NAME" "$SESSION_ID" >> "$TRANSCRIPT"
) &
disown

exit 0
