#!/usr/bin/env bash
# Append a 3-bullet summary of each interactive session to ~/.claude/session-log.md.
# Backgrounds the LLM call so the hook returns immediately and avoids being
# cancelled during SessionEnd teardown. Mirrors auto-rename-session.sh.
set -uo pipefail

INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)
REASON=$(echo "$INPUT" | jq -r '.reason // empty' 2>/dev/null)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)

# Only log interactive sessions that exited normally
if [ "$REASON" != "prompt_input_exit" ]; then
  exit 0
fi

if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

LOG_FILE="$HOME/.claude/session-log.md"

(
  # Pull user prompts (skip tool results) — cap at 8KB so haiku stays fast and cheap
  PROMPTS=$(jq -r 'select(.type == "user" and .toolUseResult == null and (.message.content | type == "string")) | .message.content' "$TRANSCRIPT" 2>/dev/null | head -c 8000)

  [ -z "$PROMPTS" ] && exit 0

  # Prefer the kebab-case title set by auto-rename-session.sh if present
  TITLE=$(grep -o '"customTitle":"[^"]*"' "$TRANSCRIPT" 2>/dev/null | tail -1 | sed 's/.*"customTitle":"\([^"]*\)".*/\1/')
  [ -z "$TITLE" ] && TITLE="(untitled)"

  DATE=$(date +%Y-%m-%d)

  SUMMARY=$(printf 'Summarize this Claude Code session in EXACTLY 3 bullets. Each bullet one line, under 80 chars. Format:\n- <what got done>\n- <key decision or finding>\n- <next step or open item>\n\nReturn ONLY the 3 bullets. No preamble, no trailing prose.\n\nSession user prompts:\n%s' "$PROMPTS" \
    | claude -p --model haiku 2>/dev/null)

  # Require 3 bullet lines
  BULLET_COUNT=$(printf '%s\n' "$SUMMARY" | grep -c '^- ')
  if [ "$BULLET_COUNT" -lt 3 ]; then
    exit 0
  fi

  # Initialize log with header if new
  if [ ! -f "$LOG_FILE" ]; then
    printf '# Session Log\n\nAuto-generated 3-bullet summaries of each interactive Claude Code session.\n' > "$LOG_FILE"
  fi

  {
    printf '\n## %s — %s\n' "$DATE" "$TITLE"
    printf '**Project:** %s  \n' "$CWD"
    printf '**Session:** %s\n\n' "$SESSION_ID"
    printf '%s\n' "$SUMMARY"
  } >> "$LOG_FILE"
) &
disown

exit 0
