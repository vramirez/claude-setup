# claude-setup

Version-controlled configuration for Claude Code. This repo is the single source of truth -- files are symlinked from their expected locations back to this repo.

## Symlink Map

| Repo path | Symlinked from | Purpose |
|-----------|---------------|---------|
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | Global Claude Code instructions (rules, preferences, workflow) |
| `settings.local.json` | `~/.claude/settings.local.json` | Extra permission rules |
| `notification_sound.txt` | `~/.claude/notification_sound.txt` | Notification sound file path |
| `hooks/git-rules.sh` | `~/.claude/hooks/git-rules.sh` | PreToolUse hook: prints commit rules before `git`/`gh` commands |
| `projects/CLAUDE.md` | `~/projects/CLAUDE.md` | Projects folder instructions |
| `agents/code-reviewer.md` | `~/.claude/agents/code-reviewer.md` | Agent that reviews diffs for LLM anti-patterns |
| `agents/backend-architect.md` | `~/.claude/agents/backend-architect.md` | Backend, API design and AWS architecture agent |
| `agents/ml-engineer.md` | `~/.claude/agents/ml-engineer.md` | ML lifecycle agent: features, training, deployment |
| `agents/pragmatic-programmer.md` | `~/.claude/agents/pragmatic-programmer.md` | Design, build and review with Pragmatic Programmer principles |
| `agents/requirements-analyst.md` | `~/.claude/agents/requirements-analyst.md` | Turns informal requests into formal requirements |
| `agents/technical-plan-reviewer.md` | `~/.claude/agents/technical-plan-reviewer.md` | Reviews plans and breaks them into backlog tasks |
| `memories/architecture-decisions.md` | `~/memories/architecture-decisions.md` | Architecture Decision Records |
| `memories/workflow-templates.md` | `~/memories/workflow-templates.md` | Declarative prompt templates (bug fix, feature, refactor, pipeline) |
| `scripts/pre-commit-quality-gate.sh` | `~/code/claude-scripts/pre-commit-quality-gate.sh` | Generic pre-commit hook for any project |
| `skills/aws-infrastructure/` | `~/.claude/skills/aws-infrastructure` | AWS resources, CDK, SageMaker training, S3 |
| `skills/aws-ml-deployment/` | `~/.claude/skills/aws-ml-deployment` | SageMaker endpoints and Bedrock |
| `skills/backlog-manager/` | `~/.claude/skills/backlog-manager` | Tasks and epics with the backlog CLI |
| `skills/docker-manager/` | `~/.claude/skills/docker-manager` | Docker images and containers |
| `skills/feature-engineering/` | `~/.claude/skills/feature-engineering` | Feature engineering for ML pipelines |
| `skills/model-training/` | `~/.claude/skills/model-training` | Model training, tuning, experiment tracking |
| `skills/closer/` | `~/.claude/skills/closer` | `/closer`: save a long conversation's loose ends before leaving |
| `skills/plan-new-feature/` | `~/.claude/skills/plan-new-feature` | `/plan-new-feature`: plan, TDD, and PR a feature |
| `skills/pragmatic-programmer/` | `~/.claude/skills/pragmatic-programmer` | Pragmatic Programmer principles and the 100-tip list |

## Setup on a new machine

Clone and run symlinks:

```bash
git clone git@github.com:vramirez/claude-setup.git ~/projects/claude-setup
cd ~/projects/claude-setup

# Create target directories if they don't exist
mkdir -p ~/.claude/agents ~/.claude/skills ~/.claude/hooks ~/memories ~/code/claude-scripts

# A plain file or folder already at a target must be diffed against the repo and
# removed first (settings.json is handled in Local-only files below):
# ln -sf overwrites a plain file, and ln -sfn puts the link INSIDE a plain folder.
# This lists plain items in the target folders; only unmanaged ones should show up:
find ~/.claude/skills ~/.claude/agents ~/.claude/hooks ~/memories ~/code/claude-scripts -mindepth 1 -maxdepth 1 ! -type l

# Symlink everything
ln -sf ~/projects/claude-setup/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/projects/claude-setup/settings.local.json ~/.claude/settings.local.json
ln -sf ~/projects/claude-setup/notification_sound.txt ~/.claude/notification_sound.txt
ln -sf ~/projects/claude-setup/hooks/git-rules.sh ~/.claude/hooks/git-rules.sh
ln -sf ~/projects/claude-setup/projects/CLAUDE.md ~/projects/CLAUDE.md
ln -sf ~/projects/claude-setup/agents/code-reviewer.md ~/.claude/agents/code-reviewer.md
ln -sf ~/projects/claude-setup/agents/backend-architect.md ~/.claude/agents/backend-architect.md
ln -sf ~/projects/claude-setup/agents/ml-engineer.md ~/.claude/agents/ml-engineer.md
ln -sf ~/projects/claude-setup/agents/pragmatic-programmer.md ~/.claude/agents/pragmatic-programmer.md
ln -sf ~/projects/claude-setup/agents/requirements-analyst.md ~/.claude/agents/requirements-analyst.md
ln -sf ~/projects/claude-setup/agents/technical-plan-reviewer.md ~/.claude/agents/technical-plan-reviewer.md
ln -sf ~/projects/claude-setup/memories/architecture-decisions.md ~/memories/architecture-decisions.md
ln -sf ~/projects/claude-setup/memories/workflow-templates.md ~/memories/workflow-templates.md
ln -sf ~/projects/claude-setup/scripts/pre-commit-quality-gate.sh ~/code/claude-scripts/pre-commit-quality-gate.sh
ln -sfn ~/projects/claude-setup/skills/aws-infrastructure ~/.claude/skills/aws-infrastructure
ln -sfn ~/projects/claude-setup/skills/aws-ml-deployment ~/.claude/skills/aws-ml-deployment
ln -sfn ~/projects/claude-setup/skills/backlog-manager ~/.claude/skills/backlog-manager
ln -sfn ~/projects/claude-setup/skills/docker-manager ~/.claude/skills/docker-manager
ln -sfn ~/projects/claude-setup/skills/feature-engineering ~/.claude/skills/feature-engineering
ln -sfn ~/projects/claude-setup/skills/model-training ~/.claude/skills/model-training
ln -sfn ~/projects/claude-setup/skills/closer ~/.claude/skills/closer
ln -sfn ~/projects/claude-setup/skills/plan-new-feature ~/.claude/skills/plan-new-feature
ln -sfn ~/projects/claude-setup/skills/pragmatic-programmer ~/.claude/skills/pragmatic-programmer
```

## Local-only files

Some files hold machine details (hostname, users, security setup) that must not be in this public repo. They follow the same symlink pattern but are listed in `.gitignore`, so they are never committed. That also means they are not backed up anywhere, and `git clean -x` or `git clean -X` deletes them: never run those here.

| Repo path | Symlinked from | Purpose |
|-----------|---------------|---------|
| `memories/system-notes.md` | `~/memories/system-notes.md` | Notes about this machine: fixes, quirks, setup facts |
| `memories/llm-mistakes-log.md` | `~/memories/llm-mistakes-log.md` | Running log of LLM mistakes (names private projects) |
| `memories/project-conventions.md` | `~/memories/project-conventions.md` | Per-project facts (stack, buckets, constraints) |
| `CLAUDE.personal.md` | `~/.claude/CLAUDE.personal.md` | Personal details, imported by `CLAUDE.md` via `@~/.claude/CLAUDE.personal.md` |
| `settings.json` | `~/.claude/settings.json` | Global settings: permissions, hooks, plugins (holds host-specific rules and paths) |

Create it on a new machine (starts empty, fill it in as you go). The `[ -e ]` guard keeps a re-run from wiping existing notes:

```bash
[ -e ~/projects/claude-setup/memories/system-notes.md ] || printf '# System Notes\n' > ~/projects/claude-setup/memories/system-notes.md
ln -sf ~/projects/claude-setup/memories/system-notes.md ~/memories/system-notes.md
for f in memories/llm-mistakes-log.md memories/project-conventions.md CLAUDE.personal.md; do
  [ -e ~/projects/claude-setup/$f ] || printf '# %s\n' "$f" > ~/projects/claude-setup/$f
done
ln -sf ~/projects/claude-setup/memories/llm-mistakes-log.md ~/memories/llm-mistakes-log.md
ln -sf ~/projects/claude-setup/memories/project-conventions.md ~/memories/project-conventions.md
ln -sf ~/projects/claude-setup/CLAUDE.personal.md ~/.claude/CLAUDE.personal.md
# settings.json: if Claude Code already made ~/.claude/settings.json, move it into the repo first
[ -e ~/projects/claude-setup/settings.json ] || { [ -f ~/.claude/settings.json ] && mv ~/.claude/settings.json ~/projects/claude-setup/settings.json || printf '{}\n' > ~/projects/claude-setup/settings.json; }
ln -sf ~/projects/claude-setup/settings.json ~/.claude/settings.json
```

## Using the pre-commit hook

Symlink into any git project:

```bash
ln -sf ~/code/claude-scripts/pre-commit-quality-gate.sh /path/to/project/.git/hooks/pre-commit
```

It runs 4 checks on every commit: diff size warning, scope review, Python dead code (ruff), and commented-out code detection.

## Adding new files

1. Create the file inside this repo under the appropriate directory
2. Symlink it from the expected location (`ln -sf` for files, `ln -sfn` for folders)
3. Add it to the Symlink Map and to the setup commands in this README
4. Commit all of it together

Repo-only rules for Claude (symlinks, public repo) are in `.claude/CLAUDE.md`. The root `CLAUDE.md` is the global instructions file.
