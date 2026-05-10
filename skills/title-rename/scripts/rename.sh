#!/usr/bin/env bash
set -euo pipefail

TRANSCRIPT="${1:?Usage: rename.sh <transcript_path>}"

if [[ ! -f "$TRANSCRIPT" ]]; then
  echo "Error: transcript not found at $TRANSCRIPT" >&2
  exit 1
fi

SESSION_ID=$(basename "$(dirname "$TRANSCRIPT")")

# Extract user messages (last 2000 lines max for context)
CONTEXT=$(tail -n 2000 "$TRANSCRIPT" | head -c 8000)

PROMPT="Based on the following conversation transcript, generate a concise session title (3-8 words).

Rules:
- Match the language of the user's messages (if user writes Chinese, title in Chinese; English input, English title, etc.)
- Focus on the main topic or intent
- No quotes, no punctuation at the end
- Output ONLY the title, nothing else

Transcript:
$CONTEXT"

TITLE=$(echo "$PROMPT" | claude -p --model haiku 2>/dev/null)

if [[ -z "$TITLE" ]]; then
  echo "Error: failed to generate title" >&2
  exit 1
fi

# Clean up: remove quotes and trailing punctuation
TITLE=$(echo "$TITLE" | sed 's/^["'"'"']//;s/["'"'"']$//;s/[.。]$//')

claude session rename "$SESSION_ID" "$TITLE" 2>/dev/null

echo "Session renamed: $TITLE"
