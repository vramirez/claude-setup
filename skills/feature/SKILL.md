---
name: feature
description: Planning or bootstrapping a new coding feature — branch, backlog parent+tasks, and plan with TDD
allowed-tools: Read, Grep, Glob
argument-hint: "<detailed feature description>"
disable-model-invocation: true
---

# New Feature

Developer's description: $ARGUMENTS

You are setting up a new coding feature. Follow these steps in order. Do NOT skip ahead.

## Step 0 — Understand the feature
Read the developer's description above carefully. From it, derive:
- A short kebab-case branch suffix (e.g., "login-page-jwt") — use only the core nouns/verbs
- A one-line summary for the parent task title
- The logical sub-steps needed to implement this feature

## Step 1 — Create the feature branch
Run:
  git checkout -b victor-<derived-branch-suffix>

## Step 2 — Create the backlog parent task (epic equivalent)
Use the developer's full description as the task description:
  backlog task create "Feature: <one-line summary>" \
    -d "$ARGUMENTS" \
    --priority high \
    --plain

Note the task ID returned (e.g., TASK-12). Use it as `<epic-id>` in Step 3.

## Step 3 — Break the feature into child tasks
For EACH implementation sub-step, create a child task with full context:
  backlog task create "<specific task title>" \
    --parent <epic-id> \
    -d "<what this task does and why — enough context to work on it independently>" \
    --ac "<acceptance criterion 1>" \
    --ac "<acceptance criterion 2>" \
    --plan "<high-level implementation approach for this task>" \
    --priority high \
    --plain

Rules for child tasks:
- Each task = one TDD red/green cycle
- Description must be self-contained — a developer should not need to read other tasks to understand it
- At least 1 acceptance criterion per task
- If a task depends on another, add: --depends-on <task-id>
- If there is a relevant doc or file to reference, add: --ref <path-or-url>

## Step 4 — Enter plan mode
After the branch and backlog are set up, enter plan mode and produce a detailed implementation plan.

The plan MUST include, for each sub-step:

### TDD cycle (red → green → commit):
  1. Red — write failing test first → commit: `test: <what it tests>`
  2. Green — write minimum code to pass → commit: `feat: <what it implements>`
  3. Refactor if needed → commit: `refactor: <what changed>`

### Backlog updates as work progresses:
  - Start a task: `backlog task edit <id> -s "in progress"`
  - Complete a task: `backlog task edit <id> -s "done"`

---
Start by running Step 1 (branch), then Step 2–3 (backlog), then ask me to approve the plan.
