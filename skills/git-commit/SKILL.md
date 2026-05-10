---
name: git-commit
description: 'Execute git commit with conventional commit message analysis, intelligent staging, and message generation. Use when user asks to commit changes, create a git commit, or mentions "/git-commit". Supports: (1) Auto-detecting type and scope from changes, (2) Generating conventional commit messages from diff, (3) Interactive commit with optional type/scope/description overrides, (4) Intelligent file staging for logical grouping'
---

# Git Commit with Conventional Commits

When the user invokes `/git-commit [language]`, analyze staged/unstaged changes and create a standardized conventional commit.

## Arguments

- `[language]` (optional): Force commit message language. Examples: `en`, `zh`, `ja`, `ko`.
  - If not provided, auto-detect from the repository's recent commit history.

## Conventional Commit Format

```
<type>[optional scope]: <subject>

[optional body]

[optional footer(s)]
```

## Commit Types

| Type       | Purpose                        |
| ---------- | ------------------------------ |
| `feat`     | New feature                    |
| `fix`      | Bug fix                        |
| `docs`     | Documentation only             |
| `style`    | Formatting/style (no logic)    |
| `refactor` | Code refactor (no feature/fix) |
| `perf`     | Performance improvement        |
| `test`     | Add/update tests               |
| `build`    | Build system/dependencies      |
| `ci`       | CI/config changes              |
| `chore`    | Maintenance/misc               |
| `revert`   | Revert commit                  |

## Workflow

### 1. Check Repository State

```bash
git status --porcelain
```

If no changes exist, inform the user and stop.

### 2. Analyze Diff

```bash
# If files are staged, use staged diff
git diff --staged

# If nothing staged, use working tree diff
git diff
```

### 3. Detect Commit Message Language

If the user provided a `[language]` argument, use that language directly.

Otherwise, detect from recent commit history:

```bash
git log --oneline -20
```

Analyze the language pattern of recent messages:

- If more than 50% of recent messages are in Chinese → generate Chinese message
- If more than 50% of recent messages are in English → generate English message
- If there is no single language over 50% (mixed or unclear) → default to English

### 4. Stage Files (if needed)

If nothing is staged, intelligently stage related files:

```bash
# Stage specific files by logical grouping
git add path/to/file1 path/to/file2
```

Rules:

- Group logically related changes together
- **NEVER** stage files that may contain secrets (.env, credentials, private keys)
- **NEVER** use `git add .` or `git add -A` blindly
- If changes span multiple logical units, suggest splitting into multiple commits

### 5. Generate Commit Message

Analyze the diff to determine:

- **Type**: What kind of change is this?
- **Scope**: What area/module is affected? (use directory or module name)
- **Subject**: One-line summary (present tense, imperative mood, <72 chars)
- **Body**: Explain "why" and "what" for non-trivial changes
- **Footer**: Breaking changes, issue references

Language rules:

- Type and scope are ALWAYS in English (e.g., `feat(auth):`)
- Subject, body and footer follow the detected/specified language

#### Format Constraints

1. **Subject**: Summarize intent in ≤ 72 chars, use imperative verbs ("add" not "added"), no trailing period.
2. **Body**: Skip a line after subject. Use bullet points (`- `) starting with imperative verbs. Explain "why/what" (max 3 points, ≤ 72 chars/line). Do NOT use colon-separated format (like ~~"Feature: desc"~~).
3. **Footer**: Skip a line after body. Use standard git trailers (e.g., `Closes #123`) or note breaking changes with `BREAKING CHANGE: <desc>` and add `!` after the commit type (e.g., `feat!:`).

#### Examples

**English:**

```text
feat(auth): add OAuth2 login support

- implement Google and GitHub third-party login
- add user authorization callback handling
- improve login state persistence logic

Closes #42
```

**Chinese:**

```text
feat(auth): 添加 OAuth2 登录支持

- 实现 Google 和 GitHub 第三方登录
- 添加用户授权回调处理
- 优化登录状态持久化逻辑

Closes #42
```

**With BREAKING CHANGE:**

```text
feat(api)!: redesign authentication API

- migrate from session-based to JWT authentication
- update all endpoint signatures
- remove deprecated login methods

BREAKING CHANGE: authentication API has been completely redesigned, all clients must update their integration
```

### 6. Confirm with User

Present the proposed commit to the user:

```
Proposed Git Commit:
Message: <type>(<scope>): <subject>
Staged files: <file list>
Language: <detected or specified language>

Proceed? [y/n]
```

Wait for explicit confirmation before executing.

### 7. Execute Commit

```bash
git commit -m "$(cat <<'EOF'
<type>[scope]: <subject>

<body>

<footer>
EOF
)"
```

### 8. Post-Commit

Show the result:

```bash
git log --oneline -1
```

## Best Practices

- One logical change per commit
- Present tense: "add" not "added"
- Imperative mood: "fix bug" not "fixes bug"
- Reference issues when applicable: `Closes #123`, `Refs #456`
- Keep subject under 72 characters
- If changes are too large or unrelated, suggest splitting

## Safety Protocol

- NEVER update git config
- NEVER run destructive commands (--force, hard reset) without explicit request
- NEVER skip hooks (--no-verify) unless user explicitly asks
- NEVER commit files that likely contain secrets
- ALWAYS confirm with user before executing the commit
