# claude-setup

Version-controlled configuration for Claude Code. This repo is the single source of truth -- files are symlinked from their expected locations back to this repo.

## Symlink Map

| Repo path | Symlinked from | Purpose |
|-----------|---------------|---------|
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | Global Claude Code instructions (rules, preferences, workflow) |
| `projects/CLAUDE.md` | `~/projects/CLAUDE.md` | Projects folder instructions |
| `agents/code-reviewer.md` | `~/.claude/agents/code-reviewer.md` | Agent that reviews diffs for LLM anti-patterns |
| `memories/llm-mistakes-log.md` | `~/memories/llm-mistakes-log.md` | Running log of LLM mistakes to prevent repeats |
| `memories/project-conventions.md` | `~/memories/project-conventions.md` | Per-project facts template (stack, tooling, constraints) |
| `memories/architecture-decisions.md` | `~/memories/architecture-decisions.md` | Architecture Decision Records |
| `memories/workflow-templates.md` | `~/memories/workflow-templates.md` | Declarative prompt templates (bug fix, feature, refactor, pipeline) |
| `scripts/pre-commit-quality-gate.sh` | `~/code/claude-scripts/pre-commit-quality-gate.sh` | Generic pre-commit hook for any project |

## Setup on a new machine

Clone and run symlinks:

```bash
git clone git@github.com:vramirez/claude-setup.git ~/projects/claude-setup
cd ~/projects/claude-setup

# Create target directories if they don't exist
mkdir -p ~/.claude/agents ~/memories ~/code/claude-scripts

# Symlink everything
ln -sf ~/projects/claude-setup/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/projects/claude-setup/projects/CLAUDE.md ~/projects/CLAUDE.md
ln -sf ~/projects/claude-setup/agents/code-reviewer.md ~/.claude/agents/code-reviewer.md
ln -sf ~/projects/claude-setup/memories/llm-mistakes-log.md ~/memories/llm-mistakes-log.md
ln -sf ~/projects/claude-setup/memories/project-conventions.md ~/memories/project-conventions.md
ln -sf ~/projects/claude-setup/memories/architecture-decisions.md ~/memories/architecture-decisions.md
ln -sf ~/projects/claude-setup/memories/workflow-templates.md ~/memories/workflow-templates.md
ln -sf ~/projects/claude-setup/scripts/pre-commit-quality-gate.sh ~/code/claude-scripts/pre-commit-quality-gate.sh
```

## Using the pre-commit hook

Symlink into any git project:

```bash
ln -sf ~/code/claude-scripts/pre-commit-quality-gate.sh /path/to/project/.git/hooks/pre-commit
```

It runs 4 checks on every commit: diff size warning, scope review, Python dead code (ruff), and commented-out code detection.

## Adding new files

1. Create the file inside this repo under the appropriate directory
2. Symlink it from the expected location
3. Add the mapping to this README
4. Commit
