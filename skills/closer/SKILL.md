---
name: closer
description: Before leaving a long conversation, sweep it for loose ends (recommendations never acted on, bugs found but not fixed, lessons not recorded, open questions) and persist each one to the right place (task, memory, project notes) so nothing is lost.
argument-hint: "[optional focus, e.g. 'only tasks' or 'skip memory']"
allowed-tools: Bash(git *), Bash(gh *), Bash(backlog *), Bash(ls *), Bash(grep *), Bash(date *), Read, Edit, Write, Glob, Grep, AskUserQuestion
disable-model-invocation: true
---

# Closer: leave nothing behind

Extra instructions from the user: $ARGUMENTS

The user is about to leave a long conversation. Some things surfaced mid-conversation, got buried under later messages, and were never addressed. Your job is to find them, check they are not already saved, and persist each one in the right place. **Do not fix or implement anything.** Only capture.

Run these steps in order.

## Step 1 — Sweep the whole conversation

Re-read the conversation from the first message, not just the recent part. The items that matter most are usually early and buried. Collect every item that fits one of these kinds:

| Kind | What it looks like |
|---|---|
| **Recommendation** | You suggested a feature, refactor, follow-up, tool, or config change, and the user never said yes or no. |
| **Loose end** | A bug, warning, flaky test, smell, or risk was noticed and nobody fixed it or explicitly dropped it. Includes "out of scope, noting as TODO" from Rule 7. |
| **Deferred** | Someone said "later", "next time", "after this", "for now", "we'll revisit". |
| **Lesson** | Something learned that would save time next time: a gotcha, a non-obvious command, an environment quirk, a decision and its reason. |
| **Mistake** | Something you got wrong and had to retract or redo. |
| **Open question** | A question either side asked that never got an answer. |

Skip anything that was resolved: implemented, explicitly rejected, or answered. Skip things that only mattered for this conversation.

## Step 2 — Check what is already saved

For each item, check if it is already recorded before you propose saving it. Look in:

- The auto-memory dir for this project (the path is in the system prompt's Memory section) and its `MEMORY.md`.
- `~/memories/*.md`
- The project's `CLAUDE.md` and the project note in `~/projects/<project>.md` if one exists.
- `~/todos/`
- The project's `backlog/` (run `backlog task list --plain` if that dir exists) and open GitHub issues (`gh issue list --limit 50`) if the repo has a GitHub remote.
- `git log --oneline -30` for things already committed.

Drop items that are already saved. If something is saved but now outdated, mark it **update** instead of new.

## Step 3 — Pick a destination for each item

Use this routing. When an item fits more than one row, or none, mark it **ask**.

| Item | Default destination |
|---|---|
| Task for the current repo, repo has `backlog/` | `backlog task create` (follow the `backlog-manager` skill) |
| Task for the current repo, no backlog | The "Open items" section of `~/projects/<project>.md` (create the section if missing) |
| Task that should be a GitHub issue | Only if the user picks it. Opening an issue is outward-facing. |
| Task not tied to one repo (system, personal, cross-project) | `~/todos/YYYY-MM-DD-closer.md` (today's date) |
| Lesson or fact about this project | Auto-memory, type `project` or `reference` |
| Lesson that applies to all projects | `~/memories/project-conventions.md` or `~/memories/system-notes.md` |
| Preference or correction about how Claude should work | Auto-memory, type `feedback` (with **Why:** and **How to apply:**) |
| Fact about the user | Auto-memory, type `user` |
| Claude mistake | Append to `~/memories/llm-mistakes-log.md` |
| Architecture decision and its reason | `~/memories/architecture-decisions.md` |
| Open question | Ask now in Step 4. If the user can't answer yet, save it as a task. |

Never write to a repo's tracked files (like its `CLAUDE.md` or README) without the user picking that option. That changes the repo.

## Step 4 — Show the list and confirm

The user is a bit dyslexic. Keep it short and scannable: one line per item, plain words, no long paragraphs.

Show a numbered table:

```
#  Kind            Item (one line)                              Where it goes
1  Loose end       Flaky test in test_sync.py, never fixed      backlog task
2  Lesson          F43 needs --system-site-packages for venv    auto-memory (project)
3  Recommendation  Add retry to S3 upload                        ask
```

If you found nothing, say so in one line and stop.

Then use `AskUserQuestion`:

- One question, `multiSelect: true`, listing items to **save as proposed** (all selected by default in your wording; the user unticks what to drop).
- One question per **ask** item (up to the tool's limit of 4 questions per call; make more calls if needed), with 2-4 concrete destination options plus "Drop it".

If the user drops an item, do not save it anywhere.

## Step 5 — Write

For each approved item:

- Write one self-contained entry. Someone reading it in 3 weeks with no context must understand it. Include: what, why it matters, and where it came from (file path, command, error text). Use absolute dates (today is from `date +%F`), never "today" or "yesterday".
- For auto-memory: one fact per file with the frontmatter format from the system prompt, then add the one-line pointer to `MEMORY.md`. Update an existing file instead of making a duplicate.
- For markdown files: append, never rewrite existing content.
- For backlog: `backlog task create "<title>" -d "<description>"`.
- For GitHub issues: `gh issue create`, only when the user chose it.

## Step 6 — Report

End with a short list: each saved item and the exact path or task/issue ID where it went. Then list anything dropped, so the user sees the full picture. Do not commit changes in other repos unless the user asks.
