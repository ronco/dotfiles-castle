#!/usr/bin/env bash
# Stop hook: extract the last ```draft ... ``` fence from the most recent
# assistant message and copy it to the macOS clipboard with both HTML and
# plain-text formats (via NSPasteboard). Silent no-op when no draft fence
# is present. Falls back to plain pbcopy if the Swift markdown→HTML path
# fails for any reason.
set -uo pipefail

LOG="$HOME/.claude/auto-pbcopy.log"
log() { printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$*" >> "$LOG" 2>/dev/null; }

INPUT=$(cat)

TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)

if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  log "skip: no transcript_path or file missing (got '$TRANSCRIPT')"
  exit 0
fi

# Extract the text content from the most recent assistant message.
# Assistant content can be a string or an array of content blocks — join all text blocks.
LAST_ASSISTANT=$(jq -s -r '
  [.[] | select(.type == "assistant")] | last |
  if . == null then empty
  else
    .message.content as $c |
    if ($c | type) == "string" then $c
    else ($c | map(select(.type == "text") | .text) | join("\n"))
    end
  end
' "$TRANSCRIPT" 2>/dev/null)

if [ -z "$LAST_ASSISTANT" ]; then
  log "skip: empty last-assistant text (transcript=$TRANSCRIPT)"
  exit 0
fi

# Pull the last ```draft ... ``` fence from the message.
DRAFT=$(printf '%s' "$LAST_ASSISTANT" | awk '
  /^```draft[[:space:]]*$/ { in_draft=1; content=""; next }
  /^```[[:space:]]*$/ && in_draft { last_draft=content; in_draft=0; next }
  in_draft { content = content $0 ORS }
  END { printf "%s", last_draft }
')

if [ -z "$DRAFT" ]; then
  log "skip: no draft fence (last_assistant_len=${#LAST_ASSISTANT})"
  exit 0
fi

# Run swift synchronously; fall back to plain pbcopy on failure.
# Removed prior backgrounding — process-group cleanup by the harness was
# (suspected of) killing the backgrounded swift before it could write.
SWIFT_SCRIPT="$HOME/.claude/hooks/clipboard-write.swift"
if printf '%s' "$DRAFT" | /usr/bin/swift "$SWIFT_SCRIPT" 2>/dev/null; then
  log "ok: swift wrote clipboard (draft_len=${#DRAFT})"
else
  printf '%s' "$DRAFT" | /usr/bin/pbcopy
  log "ok: fallback pbcopy wrote clipboard (draft_len=${#DRAFT}, swift failed)"
fi

exit 0
