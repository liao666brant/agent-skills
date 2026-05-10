# Agent Skills

个人 Claude Code 技能集合。

## 安装

```bash
# 通过 skills.sh
npx skills add liao666brant/agent-skills

# 通过 Claude Code 插件
claude plugin add https://github.com/liao666brant/agent-skills
```

## 添加新技能

在 `skills/` 下创建子目录，包含 `SKILL.md` 文件：

```
skills/
└── my-skill/
    └── SKILL.md
```

`SKILL.md` frontmatter 格式：

```yaml
---
name: my-skill
description: 技能描述
---
```

然后在 `plugin.json` 的 `skills` 数组中注册。

## 技能列表

| 技能 | 说明 |
|------|------|
| title-rename | 根据对话内容智能重命名会话标题 |
| example | 技能模板示例 |
