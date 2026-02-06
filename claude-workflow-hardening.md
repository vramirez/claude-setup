# Claude Workflow Hardening

Targeted countermeasures against known LLM coding-agent failure modes (based on Karpathy's Dec 2025 analysis). User-level improvements only -- no project-specific changes.

## Status

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | CLAUDE.md rules + code-reviewer agent | Done |
| 2 | Persistent memory seed files + declarative templates | Done |
| 3 | Generic pre-commit hook | Done |

## Karpathy's 9 Weaknesses -> Countermeasures

| # | Weakness | Countermeasure | Where |
|---|----------|---------------|-------|
| 1 | Wrong assumptions, runs with them | Force explicit assumption-stating before code | CLAUDE.md Rule 1 |
| 2 | Doesn't seek clarifications | STOP + ask when ambiguous | CLAUDE.md Rule 2 |
| 3 | Doesn't present tradeoffs | Mandatory tradeoff table for multi-approach decisions | CLAUDE.md Rule 3 |
| 4 | Too sycophantic, no pushback | Explicit permission to disagree | CLAUDE.md Rule 4 |
| 5 | Overcomplicates code | Simplicity-first, line budgeting | CLAUDE.md Rule 5 |
| 6 | Doesn't clean up dead code | Post-change dead code sweep | CLAUDE.md Rule 6 + pre-commit hook |
| 7 | Bloated implementations | Proportionality check before writing | CLAUDE.md Rule 8 |
| 8 | Side effects on unrelated code | Strict scope discipline | CLAUDE.md Rule 7 + code-reviewer agent |
| 9 | Plan mode too heavy for small changes | Tiered plan mode (micro/small/large) | CLAUDE.md Plan Mode Tiers |

## What Was Implemented

### Phase 1 -- CLAUDE.md Rules + Agent

**`~/.claude/CLAUDE.md`** -- Added:
- "LLM Anti-Pattern Rules" section (9 rules, one per Karpathy weakness)
- "Plan Mode Tiers" replacing the blanket "always plan mode" rule
- "Memory Protocol" section linking to ~/memories/ files

**`~/.claude/agents/code-reviewer.md`** -- New agent that reviews diffs for:
- Bloat (functions > 30 lines, files grew > 50%)
- Dead code (unused imports, commented-out code, orphaned functions)
- Scope creep (changes outside task description)
- Over-abstraction (ABCs with < 3 implementations, unnecessary factories)
- Assumptions (hardcoded values, missing error handling)
- Side effects (unrelated modifications)

### Phase 2 -- Memory + Templates

**`~/memories/llm-mistakes-log.md`** -- Running log of LLM mistakes with date, project, mistake, root cause, prevention. Append after sessions with errors.

**`~/memories/project-conventions.md`** -- Per-project facts template. Fill in as you work on each project so the LLM stops forgetting stack details.

**`~/memories/architecture-decisions.md`** -- ADR table. Check before proposing tech changes.

**`~/memories/workflow-templates.md`** -- Declarative prompt templates for Bug Fix, Feature, Refactor, Data Pipeline. Includes anti-pattern examples (bad imperative vs good declarative prompting).

### Phase 3 -- Pre-commit Hook

**`~/code/claude-scripts/pre-commit-quality-gate.sh`** -- Generic hook, symlink into any project:
```bash
ln -sf ~/code/claude-scripts/pre-commit-quality-gate.sh .git/hooks/pre-commit
```

4 checks:
1. Diff size warning (> 500 lines added)
2. Scope review (list changed files)
3. Dead code (ruff F401, F841 on staged .py files)
4. Commented-out code detection

## Pragmatic Programmer Tips Applied

- **Tip 34**: Don't Assume It, Prove It -> Rule 1, Rule 9
- **Tip 5**: Don't Live with Broken Windows -> Rule 6, pre-commit hook
- **Tip 42**: Take Small Steps, Always -> Tiered plan mode
- **Tip 72**: Keep It Simple -> Rule 5
- **Tip 17**: Eliminate Effects Between Unrelated Things -> Rule 7
- **Tip 62**: Don't Program by Coincidence -> Rule 1, memory system
- **Tip 76**: Programmers Help People Understand What They Want -> Rule 2
- **Tip 31**: Failing Test Before Fixing Code -> Bug fix template
- **Tip 66-67**: Testing Is Not About Finding Bugs -> Feature template

## Verification Checklist

- [ ] Start new session, give ambiguous task -> verify it asks clarifying questions
- [ ] Give task that could be over-engineered -> verify it proposes simple version first
- [ ] Start session -> verify it checks ~/memories/
- [ ] Make a deliberate mistake -> verify it gets logged to llm-mistakes-log.md
- [ ] Commit with unused import -> verify pre-commit hook catches it
- [ ] Make large commit (500+ lines) -> verify size warning fires

## Not In Scope

- MCP browser automation (separate project)
- IDE integration (terminal-primary workflow)
- Project-specific hooks (add per-project as needed)
- Agent swarms (premature per Karpathy)
