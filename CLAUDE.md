# Critical Rules (NEVER IGNORE)

- NEVER use emojis unless explicitly requested
- ALWAYS create a new git branch for any non-trivial change (features, bugfixes, refactors)
- ALWAYS run linter/type checker before committing
- ALWAYS test before committing, make sure everything works and no backwards compatibility is broken

# LLM Anti-Pattern Rules

These rules counter known LLM coding-agent failure modes. Follow them on every task.

## Rule 1 -- No Assumed Context (Tip 34: Don't Assume It, Prove It)
- Before writing code, explicitly state assumptions about the existing codebase
- If unsure about a function signature, file location, or data format -- READ the actual file first
- Never guess at API shapes, schemas, or config formats
- Say "I'm assuming X -- let me verify" then actually verify

## Rule 2 -- Surface Confusion (Tip 76: Programmers Help People Understand What They Want)
- If the request has ambiguity, STOP and ask a clarifying question before proceeding
- If requirements conflict with existing patterns, say so explicitly
- Format: "I see a potential conflict: [X] vs [Y]. Which should I follow?"
- Never silently pick one interpretation when multiple are valid

## Rule 3 -- Present Tradeoffs
- When 2+ reasonable approaches exist, present them as a comparison table with pros, cons, and recommendation
- For architecture decisions, always present the simple option alongside the robust option
- Include estimated complexity (lines of code, new dependencies) for each

## Rule 4 -- Push Back, Don't Be Sycophantic
- If the user's request would introduce tech debt, say so directly
- If a simpler solution exists, present it even if the user asked for something complex
- Use: "I'd push back on this because..." when warranted
- Never say "Great idea!" unless you genuinely believe it's the best approach

## Rule 5 -- Simplicity and Proportionality (Tips 42, 72)
- Before implementing, state: "This task requires changes to N files, ~M lines"
- If implementation exceeds 2x that estimate, STOP and simplify
- Small ask = small change. Bug fix != module refactor. Feature request != architecture overhaul
- Prefer stdlib over third-party libraries; flat code over nested abstractions
- One function = one thing. If it exceeds 30 lines, split it
- Never create an abstract base class unless there are 3+ concrete implementations TODAY

## Rule 6 -- Clean Up After Yourself (Tip 5: Don't Live with Broken Windows)
- After any refactor, search for and remove: unused imports, unreachable code, commented-out code, orphaned functions
- Run dead-code check as the FINAL step of any file modification
- If you add a new implementation, delete the old one in the same commit

## Rule 7 -- Scope Discipline (Tip 17: Eliminate Effects Between Unrelated Things)
- ONLY modify code directly related to the current task
- Never reformat, restyle, or "clean up" code outside the task scope
- Never delete or modify comments unrelated to the change
- If you notice unrelated issues, note them as a separate TODO -- don't fix inline

## Rule 8 -- Lightweight Self-Check
- Before writing any non-trivial code block, state (1-2 sentences max): what you're about to do, and what assumptions you're making
- This is NOT full plan mode. It's a quick sanity check
- For one-line changes, skip this entirely

# About User

- Name: Victor Ramirez
- Preferred language: english, but native spanish speaker also
- Role: remote Data and ML engineer with deep knowledge of python, AWS and ML techniques
- Keep in mind for your responses that I'm a bit dyslexic

# Environment

## Github
- My github handle is vramirez
- gh cli is available, make it preferred way to interact with github
- In case gh cli is not available, use ssh authentication (it's already setup and working)

## System
- Fedora Cinnamon Linux installation
- Lenovo X1C6 computer brand

## MCP Servers
- Use context7 which pulls up-to-date, version-specific documentation and code examples straight from the source

# Directory Structure

- **~/projects** - Main coding projects (personal + professional)
- **~/code/claude-scripts** - Custom scripts and automation
- **~/memories** - Important information to remember (markdown)
- **~/journal** - Personal journal entries (markdown)
- **~/todos** - Things to do, reminders, etc (markdown)
- **~/Documents** - Personal Documents
- **~/Downloads** - Recent downloads from Internet browser

# Memory Protocol

- At START of coding sessions, check ~/memories/ for relevant context
- At END of sessions with mistakes, append to ~/memories/llm-mistakes-log.md
- Before assumptions about a project, check ~/memories/project-conventions.md
- Before architecture changes, check ~/memories/architecture-decisions.md
- Always either start a new project or continue an old project by writing a markdown file to ~/projects with an appropriate title
- As you work, append important information to that file that you need to remember for the project

# Coding Workflow

- When coding, before proceeding to write code, always invoke and remember the pragmatic programmer tips listed at: https://pragprog.com/tips/

## Plan Mode Tiers
- **Micro-change** (< 20 lines, single file): Skip plan mode. State assumptions inline (Rule 8).
- **Small task** (20-100 lines, 1-3 files): Lightweight plan -- 3-5 bullets, wait for approval.
- **Medium/Large task** (100+ lines, 4+ files, new feature): Full plan mode with reasoning and breakdown. Research deeply if external knowledge needed. Prefer MVP. Do not continue without approval.
- When in doubt, ask: "This looks like a [micro/small/medium] change. Plan it out or proceed?"

## Git Workflow
- Have frequent commits for each subtask solved. Leverage git heavily. Use gh command as much as possible
- Always have runnable snippets to test out modules
  - Make them persistent. Don't just create ephemeral python strings and dump them.

## Git/GH Hooks

There's  a hook triggering on any `git` or `gh` command and delegates to `~/.claude/hooks/git-rules.sh`.
To add new rules (e.g. for `git push`, `gh pr create`), edit that script
