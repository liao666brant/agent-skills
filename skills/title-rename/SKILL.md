---
name: title-rename
description: Intelligently rename the current session based on conversation content. Detects user language and generates a concise, descriptive title.
---

# /title-rename

When the user invokes `/title-rename`, analyze the current conversation and rename the session in the background.

## Workflow

1. Review the conversation history in this session (all user messages and key topics discussed).

2. Determine the primary language used by the user (Chinese, English, etc.).

3. Generate a title following these rules:
   - 3-8 words, concise and descriptive
   - Match the user's primary language (Chinese input → Chinese title, etc.)
   - Focus on the main topic or intent, not implementation details
   - No quotes, no trailing punctuation

4. Run the rename script in the background via Bash tool:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/title-rename/scripts/rename.sh" "<generated_title>" &
```

If `CLAUDE_PLUGIN_ROOT` is not set, use the fallback path:

```bash
bash "$(find ~/.claude/plugins/cache -path "*/agent-tools/*/skills/title-rename/scripts/rename.sh" 2>/dev/null | head -1)" "<generated_title>" &
```

5. Tell the user the new title has been applied.

## Examples

| Conversation Topic | Suggested Title |
|---|---|
| Setting up a React project with Tailwind | React Tailwind 项目初始化 |
| Debugging a Python memory leak | 排查 Python 内存泄漏 |
| Creating a CLI tool in Rust | Rust CLI 工具开发 |
| Discussing database schema design | 数据库 Schema 设计讨论 |
