---
name: title-rename
description: Intelligently rename the current session based on conversation content. Detects user language and generates a concise, descriptive title.
---

# /title-rename

When the user invokes `/title-rename`, generate a smart title for the current session based on conversation content.

## Workflow

1. Run the rename script via Bash tool with a **timeout of 120 seconds** (the inner claude process needs time to initialize):

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/title-rename/scripts/rename.sh" "$CLAUDE_TRANSCRIPT_PATH"
```

2. Report the result to the user.

## Rules

- The generated title MUST match the primary language of the user's messages (Chinese input → Chinese title, English input → English title, etc.)
- Title should be 3-8 words, concise and descriptive
- Focus on the main topic/intent, not implementation details
- If the script exits non-zero, report the error verbatim
