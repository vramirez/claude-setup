---
name: closer
description: Before leaving a long conversation, sweep it for loose ends (recommendations never acted on, bugs found but not fixed, lessons not recorded, open questions) and persist each one to the right place (task, memory, project notes) so nothing is lost.
argument-hint: "[optional focus, e.g. 'only tasks' or 'skip memory']"
allowed-tools: Bash(git log *), Bash(backlog *), Bash(timeout 30s backlog *), Bash(ls *), Bash(date *), Read, Edit, Write, Glob, Grep, AskUserQuestion
disable-model-invocation: true
---

# Closer: leave nothing behind

Extra instructions from the user: $ARGUMENTS

The user is about to leave a long conversation. Some things surfaced mid-conversation, got buried under later messages, and were never addressed. Your job is to find them, check they are not already saved, and persist each one in the right place. **Do not fix or implement anything.** Only capture.

**Local only.** Write only to local files and to local tools the repo already uses for notes or tasks (for example `backlog`, when the repo has a `backlog/` dir or its `CLAUDE.md` names it). Never read from or write to an external system (GitHub issues, Jira, Linear, Slack, Google Docs, etc.) unless a `CLAUDE.md`, `AGENTS.md` or similar instruction file (user, folder or repo level) explicitly says to use it for tasks or notes. Asking the user does not replace that rule: if no instruction file names the system, do not offer it.

Run these steps in order.

## Step 1 — Sweep the whole conversation

Re-read the conversation from the first message, not just the recent part. The items that matter most are usually early and buried. If the conversation was compacted (you see a summary instead of the first messages), the early part is gone from context: Grep the full transcript at `~/.claude/projects/<key>/${CLAUDE_SESSION_ID}.jsonl` instead (`<key>` is the working directory with every `/` and `.` turned into `-`; if the id is not filled in, use the newest `.jsonl` there). Collect every item that fits one of these kinds:

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
- The project's `CLAUDE.md` and its project note in `~/projects/` if one exists. Notes are named by topic, not always by repo (for example `pstack-claude-fork.md`), so list `~/projects/*.md` and grep them for the repo name.
- `~/todos/`
- The project's `backlog/`: for each item run `timeout 30s backlog search '<keywords>' --plain` (it searches descriptions and notes, not only titles). Or whatever local task/notes tool the repo's instruction files name.
- An external tracker only if an instruction file explicitly names it (see **Local only**).
- `git log --oneline -30` for things already committed.

Drop items that are already saved. If something is saved but now outdated, mark it **update** instead of new.

## Step 3 — Pick a destination for each item

Use this routing. When an item fits more than one row, or none, mark it **ask**.

| Item | Default destination |
|---|---|
| Task for the current repo, repo has `backlog/` or its instruction files name a task/notes tool | That tool (for backlog: `backlog task create`, following the `backlog-manager` skill) |
| Task for the current repo, no task tool | The "Open items" section of the project note from Step 2 (create the section, or the note as `~/projects/<repo name>.md`, if missing) |
| Task not tied to one repo (system, personal, cross-project) | `~/todos/YYYY-MM-DD-closer.md` (today's date) |
| Lesson, fact, or Claude-behavior correction specific to this project | Auto-memory, type `project`, `reference` or `feedback` (feedback gets **Why:** and **How to apply:**) |
| User-level: a lesson for all projects, a preference or correction about how Claude should work everywhere, a fact about the user | Global `~/.claude/CLAUDE.md`, as a short rule under the section it belongs to |
| Claude mistake | Append to `~/memories/llm-mistakes-log.md` |
| Architecture decision and its reason | `~/memories/architecture-decisions.md` |
| Open question | Ask now in Step 4. If the user answers, save the answer with the row that fits it (lesson, decision, task). If they can't answer yet, save the question as a task. |

Never write to a repo's tracked files (like its `CLAUDE.md` or README) without the user picking that option. That changes the repo. The global `~/.claude/CLAUDE.md` is the one exception: it is the default for user-level items, and Step 4 already confirms each one.

## Step 4 — Show the list and confirm

Keep it short and scannable: one line per item, plain words, no long paragraphs.

Show a numbered table:

```
#  Kind            Item (one line)                              Where it goes
1  Loose end       Flaky test in test_sync.py, never fixed      backlog task
2  Lesson          F43 needs --system-site-packages for venv    auto-memory (project)
3  Recommendation  Add retry to S3 upload                        ask
```

If you found nothing, say so in one line and stop.

Then use `AskUserQuestion`:

- Items to **save as proposed**: `multiSelect: true` questions with up to 4 items each (the tool allows 2-4 options per question and pre-selects nothing). Say in the question that ticked items are saved and unticked ones are dropped. A single item gets a plain question with "Save" and "Drop it".
- One question per **ask** item, with 2-3 concrete destination options plus "Drop it" (4 options max).
- The tool takes up to 4 questions per call; make more calls if needed.

If the user drops an item, do not save it anywhere.

## Step 5 — Write

For each approved item:

- Write one self-contained entry. Someone reading it in 3 weeks with no context must understand it. Include: what, why it matters, and where it came from (file path, command, error text). Use absolute dates (today is from `date +%F`), never "today" or "yesterday".
- For auto-memory: one fact per file with the frontmatter format from the system prompt, then add the one-line pointer to `MEMORY.md`. Update an existing file instead of making a duplicate.
- For markdown files: add the entry under the heading it belongs to (end of file when there is none); never delete or reword other entries.
- For an **update**: change the outdated entry in place (auto-memory file, markdown line, or `timeout 30s backlog task edit <id> --append-notes '<text>'`) instead of adding a second one.
- For backlog: `timeout 30s backlog task create '<title>' -d '<description>'`. Use single quotes: descriptions carry commands and error text, and backticks or `$` inside double quotes run as shell code. Write a `'` inside the text as `'\''`.
- For an external system: only when an instruction file explicitly names it (see **Local only**).

## Step 6 — Report

End with a short list: each saved item and the exact path or task/issue ID where it went. Then list anything dropped, so the user sees the full picture. Last, name each git repo you left with uncommitted changes (the current repo after a backlog task; `~/projects/claude-setup` when a `~/memories/` file you wrote is a symlink into it). Do not commit changes in other repos unless the user asks.
