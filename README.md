# Agent Tools

个人 Claude Code 技能集合。

## 安装

```bash
# 添加为插件市场源
claude plugin marketplace add liao666brant/agent-tools

# 安装插件
claude plugin install agent-tools

# 或通过 skills.sh
npx skills add liao666brant/agent-tools
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
| git-commit | 智能 Git 提交：conventional commits、自动语言检测、可指定语言 |
| title-rename | 根据对话内容智能重命名会话标题 |
