---
description: Find a past Claude Code session by keyword with a fallback chain
allowed-tools: Agent, Bash, Grep, Read
---

# Find Session

Locate a past Claude Code session matching a keyword. Tries multiple sources so a single failed tool doesn't derail the lookup.

## Arguments

- `$ARGUMENTS` — keywords or topic describing the session (e.g., "postback monitoring", "S3 audit")

## Fallback Chain

Try each source in order. Track which succeeded and which failed so tool breakage is visible.

### 1. Episodic-memory agent (primary)

Dispatch the `episodic-memory:search-conversations` agent with the keywords. This is the richest source — semantic search over indexed conversation history.

If the agent returns matches, present them. If it fails (agent unavailable, plugin error, empty results), mark as failed and continue.

### 2. Transcript grep

Grep the raw JSONL conversation transcripts:

```bash
grep -l -r -i "<keywords>" ~/.claude/projects/*/*.jsonl 2>/dev/null | head -20
```

For each matching file, extract context with `jq`:

```bash
# First user prompt
jq -r 'select(.type == "user" and .toolUseResult == null and (.message.content | type == "string")) | .message.content' <file> 2>/dev/null | head -1

# Custom title if set by auto-rename hook
grep -o '"customTitle":"[^"]*"' <file> | tail -1
```

### 3. Research notes

Significant research is saved to `~/dev/notes/<topic>.md` (per `~/.claude/CLAUDE.md` guidance):

```bash
grep -l -r -i "<keywords>" ~/dev/notes/ 2>/dev/null
```

### 4. Session log

The auto-generated 3-bullet summary log at `~/.claude/session-log.md`:

```bash
grep -B 2 -A 5 -i "<keywords>" ~/.claude/session-log.md 2>/dev/null
```

## Output

Group results by source. For each hit, show:
- Date
- Session ID or file path
- One-line summary or first user prompt (truncated to 120 chars)

End with a diagnostic line showing which sources worked:

```
Sources checked: ✅ episodic-memory (3 hits) · ⚠️ transcripts (grep ok, 2 hits) · ✅ notes (1 hit) · ✅ session-log (0 hits)
```

Mark a source with ❌ if it errored outright — that's the signal to investigate tooling breakage rather than silently retry.

## When all sources fail

Print which sources were checked and what each returned. Do not silently grep-flail. A clean "no results from any of the 4 sources" is more useful than an endless bash loop.
