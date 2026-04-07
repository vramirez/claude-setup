---
name: backlog-manager
description: Manage development tasks, epics, user stories, and agile workflows using backlog CLI. Use when planning features, creating tasks, managing sprints, tracking acceptance criteria, or organizing project work.
allowed-tools: Bash, BashOutput, Read, Glob, Grep, TodoWrite
---

# Backlog Manager

Expert task and project management skill using the backlog CLI tool. Provides git-native, markdown-based task tracking for agile development workflows.

## When to Activate This Skill

Activate this skill when:
- User mentions agile terminology: epic, task, user story, sprint, acceptance criteria, feature, bug, subtask
- Planning development work: features, refactoring, bug fixes
- Starting new development tasks
- Organizing project work and tracking progress

**Important**: Only activate when in a git repository. Backlog requires git to function.

## CRITICAL: Always Use Timeout

The backlog binary has a known issue where it doesn't properly exit after completing commands (it gets stuck in an epoll event loop). **ALWAYS wrap backlog commands with `timeout`** to prevent zombie shell processes:

```bash
# CORRECT - with timeout (30 seconds is usually enough)
timeout 30s backlog task list
timeout 30s backlog task 15
timeout 30s backlog task create "Title" --desc "Description"

# WRONG - will leave zombie processes
backlog task list
```

**All examples in this document should be prefixed with `timeout 30s`**. Use longer timeouts (60s) for operations that might take longer like `backlog board` or complex searches.

## Integration with TodoWrite

This skill works **alongside** TodoWrite, not as a replacement:

- **Backlog CLI**: Use for project-level, persistent tasks that need to be tracked across sessions
  - Features, bugs, epics, user stories
  - Tasks that will result in git commits
  - Work that needs acceptance criteria and implementation plans
  - Tasks with dependencies and assignments

- **TodoWrite**: Use for session-level, ephemeral implementation steps
  - Immediate next steps during implementation
  - Breaking down current work into smaller pieces
  - Temporary tracking during a single coding session

**Workflow**: Create backlog task → Use TodoWrite for implementation steps → Update backlog task status

## Core Workflows

execute this commands from the projects root directory

### 1. Search-First Approach (CRITICAL)

**ALWAYS search before creating tasks** to avoid duplicates:

```bash
# Search for existing tasks
backlog search "<feature/bug description>"

# Search with filters
backlog search "authentication" --status "To Do"
backlog search "user profile" --priority high
```

**Decision tree**:
1. Search for related tasks first
2. If similar task exists → Update it or create subtask
3. If no match → Create new task

### 2. Feature Branch Workflow

**Standard workflow for features and bugs**:

#### Step 1: Create backlog task
```bash
# Search first
backlog search "feature name"

# Create task with full details
backlog task create "Add user authentication" \
  --desc "Implement JWT-based authentication system" \
  --priority high \
  --labels feature,security \
  --ac "User can login with email/password" \
  --ac "Token expires after 24 hours" \
  --ac "Refresh token implemented" \
  --plan "1. Setup JWT library
2. Create auth middleware
3. Add login/logout endpoints
4. Implement token refresh"
```

#### Step 2: Create feature branch
```bash
# Get task ID from previous command (e.g., task-15)
git checkout -b tasks/task-15-user-authentication
```

#### Step 3: Update task status
```bash
backlog task edit 15 --status "In Progress" --assignee victor
```

#### Step 4: Implement (use TodoWrite for steps)
```bash
# Use TodoWrite for implementation steps
# Make commits as you progress
git commit -m "TASK-15 - Setup JWT library"
git commit -m "TASK-15 - Add auth middleware"
```

#### Step 5: Mark acceptance criteria complete
```bash
# As you complete each AC
backlog task edit 15 --check-ac 1
backlog task edit 15 --check-ac 2
backlog task edit 15 --check-ac 3
```

#### Step 6: Add progress notes
```bash
backlog task edit 15 --append-notes "JWT implementation complete. All tests passing."
```

#### Step 7: Complete task
```bash
# Run tests first
# Run linter/type checker
# Only then mark complete
backlog task edit 15 --status "Done"
```

## Common Commands

### Task Creation

**Basic task**:
```bash
backlog task create "Task title" \
  --desc "Detailed description" \
  --priority high \
  --labels feature,backend
```

**Task with acceptance criteria**:
```bash
backlog task create "Feature name" \
  --ac "First acceptance criteria" \
  --ac "Second acceptance criteria" \
  --ac "Third acceptance criteria"
```

**Task with dependencies**:
```bash
backlog task create "Frontend integration" \
  --dep task-10,task-11 \
  --desc "This task depends on backend API completion"
```

**Subtask creation**:
```bash
backlog task create "Implement specific endpoint" \
  -p task-10 \
  --desc "This is a subtask of the larger feature"
```

### Task Management

**List tasks**:
```bash
backlog task list                     # All tasks
backlog task list -s "In Progress"    # Filter by status
backlog task list -a victor           # My tasks
backlog task list -p task-10          # Subtasks
```

**View task details**:
```bash
backlog task 15                       # View full task details
```

**Edit task**:
```bash
# Update status
backlog task edit 15 --status "In Progress"

# Change priority
backlog task edit 15 --priority high

# Update assignee
backlog task edit 15 --assignee victor

# Add labels
backlog task edit 15 --labels bug,urgent

# Add notes
backlog task edit 15 --append-notes "Making good progress. 80% complete."

# Mark AC complete
backlog task edit 15 --check-ac 1
backlog task edit 15 --check-ac 2
```

**Archive completed tasks**:
```bash
backlog task archive 15              # Archive single task
backlog cleanup                      # Archive all completed tasks
```

### Visualization

**Terminal Kanban board**:
```bash
backlog board                        # Interactive board
```

**Project overview**:
```bash
backlog overview                     # Statistics and metrics
```

**Export board**:
```bash
backlog board export                 # Export to markdown
backlog board export --readme        # Update README.md
```

## Checking Backlog Availability

Before using backlog commands, check if backlog is initialized:

```bash
# Check if backlog directory exists
if [ -d "backlog" ]; then
  # Use backlog commands
  backlog task create "..."
else
  # Inform user backlog is not initialized
  # Offer to initialize: backlog init
fi
```

**Initialize backlog in new project**:
```bash
backlog init                         # Interactive setup
```

## Task File Format (Manual Creation)

**CRITICAL**: When creating or editing task files manually, follow this exact format:

```markdown
---
id: task-X
title: Brief descriptive title
status: To Do
priority: high
assignee: "@claude"
created: 2025-11-08
milestone: ML Enhancement
parent: task-Y  # Optional: for subtasks/epics
labels:
  - label1
  - label2
estimated_hours: 8
---

## Description

Clear description of what needs to be done and why. The backlog CLI looks for this exact heading "## Description" - do NOT use "## Overview" or other variations.

## Implementation Plan

1. Step one
2. Step two
3. Step three

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Progress Log

### YYYY-MM-DD
- Initial notes and progress updates
```

**IMPORTANT**:
- The heading MUST be `## Description` (not "Overview", "Details", etc.)
- The backlog CLI parser specifically looks for this heading
- Without it, the task will show "No description provided"

## Task Properties Reference

### Status Values
- To Do (default)
- In Progress
- Done
- Blocked
- (Custom statuses via config)

### Priority Levels
- high
- medium
- low

### Common Labels
- feature
- bug
- refactor
- documentation
- testing
- security
- performance
- tech-debt

## Best Practices

### Task Creation
1. **Search first** - Always check for existing tasks
2. **Be specific** - Clear, actionable task titles
3. **Add acceptance criteria** - Define "done" upfront
4. **Set priority** - Help with prioritization
5. **Add labels** - Make tasks findable
6. **Link dependencies** - Show relationships

### Task Management
1. **Update status** - Keep task status current
2. **Add notes** - Document progress and blockers
3. **Check ACs** - Mark criteria as you complete them
4. **Clean up** - Archive completed tasks periodically

### Git Integration
1. **Branch naming**: `tasks/task-<id>-<short-name>`
2. **Commit format**: `TASK-<id> - <description>`
3. **Run tests** before marking tasks complete
4. **Run linter** before marking tasks complete

### Code Quality
1. **Run tests**: Ensure all tests pass
2. **Type check**: `bunx tsc --noEmit` or equivalent
3. **Lint**: Run project linter
4. **Simplify**: Review code for simplification opportunities

## Configuration

View and modify backlog settings:

```bash
# View all config
backlog config list

# Set default status
backlog config set defaultStatus "To Do"

# Set default assignee
backlog config set defaultAssignee victor

# Configure statuses
backlog config set statuses "To Do,In Progress,Review,Done"

# Auto-commit changes
backlog config set autoCommit true
```

## Typical Usage Scenarios

### Scenario 1: User describes a feature to implement
```
User: "I need to add user profile editing functionality"

Actions:
1. Search: backlog search "user profile"
2. If no match, create task with ACs
3. Create feature branch: tasks/task-N-user-profile
4. Update status to "In Progress"
5. Use TodoWrite for implementation steps
6. Update task as work progresses
```

### Scenario 2: User mentions a bug
```
User: "There's a bug in the login form validation"

Actions:
1. Search: backlog search "login validation"
2. Create task with --labels bug,urgent
3. Add AC: "Login form validates correctly"
4. Follow feature branch workflow
```

### Scenario 3: Planning a large feature (epic)
```
User: "Let's build a notification system"

Actions:
1. Create parent task: "Build notification system"
2. Create subtasks:
   - "Email notifications" (-p task-N)
   - "In-app notifications" (-p task-N)
   - "Push notifications" (-p task-N)
3. Set dependencies where needed
4. Prioritize and sequence work
```

## Error Handling

### Backlog not initialized
```bash
# Error: backlog/ directory not found
# Solution: Offer to initialize
backlog init
```

### Not in git repository
```bash
# Error: git repository required
# Solution: Initialize git or move to git repo
git init
```

### Task not found
```bash
# Error: Task task-15 not found
# Solution: List tasks or search
backlog task list
backlog search "task description"
```

## Integration Points

### With Git
- Branch naming convention
- Commit message format
- Pre-commit hooks (tests, linters)

### With CI/CD
- Task IDs in commit messages
- Automated status updates
- Test requirements before completion

### With TodoWrite
- Backlog for persistent project tasks
- TodoWrite for session implementation steps
- Complementary, not competitive

## Remember

1. **Search before creating** - Avoid duplicate tasks
2. **Feature branch workflow** - tasks/task-N-name
3. **Update as you go** - Keep task status current
4. **Run quality checks** - Tests and linters before done
5. **Use with TodoWrite** - Both tools serve different purposes
6. **Git integration** - Backlog is git-native, use it

Use this skill for all agile project management, task tracking, and development planning activities.
