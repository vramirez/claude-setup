# Project Conventions

Facts and preferences the LLM should remember across sessions. Check this before making assumptions about a project.

## General Preferences

- Functions over classes (unless state management requires it)
- Explicit over implicit
- Flat over nested
- Small PRs over large PRs
- stdlib over third-party when possible
- Concrete over abstract (no ABCs unless 3+ implementations exist)
- Tests before commits, always

## Per-Project Sections

Add a section per project as you work on them. Format:

```
## <project-name>

- **Stack**: [languages, frameworks, databases]
- **Linting**: [tool and config]
- **Testing**: [tool and config]
- **Branch workflow**: [branching strategy]
- **Build/Run**: [how to build and run]
- **Key constraints**: [anything unusual the LLM keeps forgetting]
```

## backlog-mcp

- **Stack**: Python >=3.12, mcp==2.0.0 (SDK v2, MCPServer), uvicorn, uv + hatchling
- **Linting**: uvx ruff check (no config committed)
- **Testing**: uv run pytest; integration tests marked `integration`, need backlog CLI + git
- **Branch workflow**: feature branches, TDD red-green commit pairs
- **Build/Run**: uv run backlog-mcp --port 8765 --allowed-dirs <roots>; endpoint at /mcp
- **Key constraints**: backlog `board export` resolves even absolute paths against the project root; `overview`/`board view` are TUI-only (never subprocess them); backlog binary lives in ~/.nvm so BACKLOG_MCP_BIN may be needed off-shell
