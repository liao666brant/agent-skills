# Agent Tools

个人 Claude Code 插件市场，包含多个独立插件。

## 安装

```bash
# 添加为插件市场源
claude plugin marketplace add liao666brant/agent-tools

# 安装主插件（技能集合）
claude plugin install agent-tools

# 安装 type-inject 插件
claude plugin install type-inject
```

## 插件列表

| 插件        | 说明                                     |
| ----------- | ---------------------------------------- |
| agent-tools | 个人技能集合（git-commit、title-rename） |
| type-inject | TypeScript 类型自动注入                  |

## agent-tools

通用技能集合，包含日常开发辅助技能。

### 技能

| 技能         | 说明                                                          |
| ------------ | ------------------------------------------------------------- |
| git-commit   | 智能 Git 提交：conventional commits、自动语言检测、可指定语言 |
| title-rename | 根据对话内容智能重命名会话标题                                |

### Hooks

| 事件 | 说明                     |
| ---- | ------------------------ |
| Stop | 会话结束时自动重命名标题 |

## type-inject

封装 [nick-vi/type-inject](https://github.com/nick-vi/type-inject)，免去手动配置 MCP 和 hooks。

### 功能

- 读取 `.ts`/`.svelte` 文件时自动注入解析后的类型签名
- 写入/编辑后立即报告类型错误
- 提供 `lookup_type`、`list_types`、`type_check` MCP 工具
- 提供 `/type-check` 技能

### Hooks

| 事件        | Matcher | 说明           |
| ----------- | ------- | -------------- |
| PostToolUse | Read    | 注入类型上下文 |
| PostToolUse | Write   | 报告类型错误   |
| PostToolUse | Edit    | 报告类型错误   |

## 目录结构

```
agent-tools/
├── .claude-plugin/
│   ├── plugin.json          # agent-tools 主插件
│   └── marketplace.json     # 插件市场注册表
├── skills/                  # agent-tools 技能
│   ├── git-commit/
│   └── title-rename/
├── hooks/                   # agent-tools hooks
├── plugins/
│   └── type-inject/         # 独立插件
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
└── package.json
```

## 添加新插件

1. 在 `plugins/` 下创建目录，包含 `.claude-plugin/plugin.json`
2. 在根 `marketplace.json` 的 `plugins` 数组中注册，指定 `source` 路径
