#!/usr/bin/env bash
# On session start, sync custom-title from transcript to PID session file
set -uo pipefail

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)

if [ -z "$SESSION_ID" ]; then
  exit 0
fi

# Find the session PID file
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

# Skip if PID file already has a name
EXISTING=$(jq -r '.name // empty' "$SESSION_FILE" 2>/dev/null)
if [ -n "$EXISTING" ]; then
  exit 0
fi

# Find the transcript
CWD=$(jq -r '.cwd // empty' "$SESSION_FILE" 2>/dev/null)
if [ -z "$CWD" ]; then
  exit 0
fi

PROJECT_DIR="$HOME/.claude/projects/$(echo "$CWD" | sed 's|/|-|g')"
TRANSCRIPT="$PROJECT_DIR/$SESSION_ID.jsonl"

if [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

# Read custom-title from transcript (take the last one if multiple)
TITLE=$(grep '"custom-title"' "$TRANSCRIPT" 2>/dev/null | tail -1 | jq -r '.customTitle // empty' 2>/dev/null)

if [ -z "$TITLE" ]; then
  exit 0
fi

# Write name to session PID file
TMP=$(mktemp)
jq --arg name "$TITLE" '.name = $name' "$SESSION_FILE" > "$TMP" && mv "$TMP" "$SESSION_FILE"

exit 0
