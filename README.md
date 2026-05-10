# Agent Skills

Personal skills collection for Claude Code.

## Install

```bash
# via skills.sh
npx skills add liao666brant/agent-skills

# via Claude Code plugin
claude plugin add https://github.com/liao666brant/agent-skills
```

## Adding a New Skill

Create a subdirectory under `skills/` with a `SKILL.md`:

```
skills/
└── my-skill/
    └── SKILL.md
```

`SKILL.md` frontmatter:

```yaml
---
name: my-skill
description: What this skill does
---
```

Then register it in `plugin.json` under the `skills` array.

## Skills

| Skill | Description |
|-------|-------------|
| title-rename | Intelligently rename session based on conversation content |
| example | A template skill demonstrating the correct structure |
