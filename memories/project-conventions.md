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
