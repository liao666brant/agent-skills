---
name: type-check
description: |
  Run TypeScript type checking on the current project or a specific file.
  Use when asked to "check types", "run tsc", "type check", "find type errors",
  or when the user mentions TypeScript compilation issues.
---

# Type Check

Run TypeScript type checking using the type-inject MCP tool.

## Usage

When the user asks to check types, use the `mcp__type-inject__type_check` tool:

- To check the entire project: call with no arguments
- To check a specific file: call with the `file` argument set to the file path

## Output

Report diagnostics clearly:
- Group errors by file
- Show the line number and error message
- Suggest fixes when the error is straightforward
