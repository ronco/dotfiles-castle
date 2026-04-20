#!/usr/bin/env bash
# Stop hook: extract the last ```draft ... ``` fence from the most recent
# assistant message and copy it to the macOS clipboard with both HTML and
# plain-text formats (via NSPasteboard). Silent no-op when no draft fence
# is present. Falls back to plain pbcopy if the Swift markdown→HTML path
# fails for any reason.
set -uo pipefail

INPUT=$(cat)

TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)

if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
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

[ -z "$LAST_ASSISTANT" ] && exit 0

# Pull the last ```draft ... ``` fence from the message.
DRAFT=$(printf '%s' "$LAST_ASSISTANT" | awk '
  /^```draft[[:space:]]*$/ { in_draft=1; content=""; next }
  /^```[[:space:]]*$/ && in_draft { last_draft=content; in_draft=0; next }
  in_draft { content = content $0 ORS }
  END { printf "%s", last_draft }
')

[ -z "$DRAFT" ] && exit 0

# Try the rich path first: NSAttributedString(markdown:) → HTML + plain text on NSPasteboard.
# Background it so the hook returns fast.
SWIFT_SCRIPT="$HOME/.claude/hooks/clipboard-write.swift"
(
  if ! printf '%s' "$DRAFT" | /usr/bin/swift "$SWIFT_SCRIPT" 2>/dev/null; then
    # Fallback: plain pbcopy if Swift path failed
    printf '%s' "$DRAFT" | /usr/bin/pbcopy
  fi
) &
disown

exit 0
