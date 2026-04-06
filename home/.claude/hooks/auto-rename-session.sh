#!/usr/bin/env bash
# Auto-rename unnamed sessions on exit using claude -p with haiku
set -uo pipefail

# Read hook stdin (contains session_id)
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)

if [ -z "$SESSION_ID" ]; then
  exit 0
fi

# Find the session file by matching sessionId to get CWD
SESSION_FILE=""
for f in ~/.claude/sessions/*.json; do
  [ -f "$f" ] || continue
  SID=$(jq -r '.sessionId // empty' "$f" 2>/dev/null)
  if [ "$SID" = "$SESSION_ID" ]; then
    SESSION_FILE="$f"
    break
  fi
done

if [ -z "$SESSION_FILE" ]; then
  exit 0
fi

# Get the CWD from session to find the transcript
CWD=$(jq -r '.cwd // empty' "$SESSION_FILE" 2>/dev/null)
if [ -z "$CWD" ]; then
  exit 0
fi

# Find the transcript file
PROJECT_DIR="$HOME/.claude/projects/$(echo "$CWD" | sed 's|/|-|g')"
TRANSCRIPT="$PROJECT_DIR/$SESSION_ID.jsonl"

if [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

# Skip if already named (custom-title or agent-name entry exists in transcript)
if grep -q '"custom-title"\|"agent-name"' "$TRANSCRIPT" 2>/dev/null; then
  exit 0
fi

# Extract ONLY the first user message (the initial prompt that defines the session)
FIRST_PROMPT=$(jq -r 'select(.type == "user") | .message.content | if type == "string" then . elif type == "array" then map(if type == "string" then . elif .text? then .text else empty end) | join(" ") else empty end' "$TRANSCRIPT" 2>/dev/null \
  | head -1 \
  | head -c 300)

if [ -z "$FIRST_PROMPT" ]; then
  exit 0
fi

# Generate a name using claude in non-interactive mode
RAW=$(printf 'Reply with ONLY a kebab-case name. 3-6 lowercase words joined by hyphens. Nothing else.\n\nExamples of good names:\nfix-auth-redirect-bug\nsetup-ci-pipeline\nreview-team-prs\nadd-user-search-api\n\nName this session:\n%s' "$FIRST_PROMPT" \
  | claude -p --model haiku 2>/dev/null)

# Take first line, keep only kebab-case chars
NAME=$(echo "$RAW" | head -1 | tr -d '\n\r' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g; s/^-//; s/-$//')

# Validate: must be 5-60 chars and contain at least one hyphen
if [ ${#NAME} -lt 5 ] || [ ${#NAME} -gt 60 ] || ! echo "$NAME" | grep -q '-'; then
  exit 0
fi

# Write both custom-title and agent-name entries to the transcript (same as /rename)
printf '{"type":"custom-title","customTitle":"%s","sessionId":"%s"}\n' "$NAME" "$SESSION_ID" >> "$TRANSCRIPT"
printf '{"type":"agent-name","agentName":"%s","sessionId":"%s"}\n' "$NAME" "$SESSION_ID" >> "$TRANSCRIPT"

# Also update the session PID file if it still exists
if [ -f "$SESSION_FILE" ]; then
  TMP=$(mktemp)
  jq --arg name "$NAME" '.name = $name' "$SESSION_FILE" > "$TMP" && mv "$TMP" "$SESSION_FILE"
fi

exit 0
