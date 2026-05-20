---
name: plan-new-feature
description: Plan a feature, sync the default branch, branch as victor-<slug>, implement via TDD red-green with atomic commits, lint/test, push, and open a PR.
argument-hint: "<feature description>"
allowed-tools: Bash(git *), Bash(gh *), Bash(npm *), Bash(pnpm *), Bash(yarn *), Bash(pytest *), Bash(ruff *), Bash(eslint *), Bash(make *), Bash(sed *), Read, Edit, Write, Glob, Grep, AskUserQuestion
disable-model-invocation: true
---

# Plan, implement, and PR a new feature

Developer's request: $ARGUMENTS

Run these steps **in this exact order**. Do NOT reorder, skip, or combine them.

## Pragmatic Programmer reference

Throughout this workflow, if you need a Pragmatic Programmer tip beyond what's covered in the inline checklists at Steps 2, 8, and 9, read `~/.claude/skills/pragmatic-programmer/references/tips.md` directly — it lists all 100 canonical tips. The standalone `pragmatic-programmer` skill is also available for ad-hoc review of code outside this workflow.

---

## Step 1 — Enter plan mode

Call the `EnterPlanMode` tool immediately, before any other action. All subsequent research and plan-drafting must happen inside plan mode.

## Step 2 — Research and draft the plan

While in plan mode:

- Explore the repo. Use Glob / Grep / Read directly for small scopes; launch `Explore` subagents in parallel when the scope is broad or unclear.
- Size the work using the tiers in `~/.claude/CLAUDE.md` (micro / small / medium). State the estimated file count and line count up front.
- Write the plan to the plan file the harness gives you. Include: **Context**, **Design decisions**, **Files to touch**, **Test strategy** (what the first failing test will assert), **Verification**.
- Reuse existing helpers where possible — do not propose new code when a current function fits.
- Before finalizing design decisions, walk this pragmatic checklist:
  - **Reuse** (Tip 15): is there an existing function, module, or pattern that fits?
  - **Orthogonality** (Tip 17): can this component be independent of the rest?
  - **Contracts** (Tip 37): what are the preconditions, postconditions, and invariants?
  - **Reversibility** (Tip 18): which choices are easy to undo? Prefer those.
  - **Tracer bullet** (Tip 20): smallest end-to-end skeleton that proves the architecture?
  - **Estimate** (Tip 23): rough size — files, lines, complexity?

## Step 3 — Request approval

Call `ExitPlanMode`. **Stop here until the user approves.** If the user requests changes, update the plan file and call `ExitPlanMode` again.

## Step 4 — Sync the default branch

Detect the default branch (some repos use `main`, others `master`):

```
!`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || echo mastur`
```

Then:

```
git checkout <default>
git pull --ff-only
```

## Step 5 — Handle a dirty tree or pull conflict

If `git checkout` fails because of uncommitted changes, or `git pull --ff-only` fails (non-fast-forward / conflict), use `AskUserQuestion` with these concrete options. **Do not auto-pick.**

- **Stash** — `git stash push -u -m "plan-new-feature auto-stash"`, then retry. Restore with `git stash pop` after the branch is created.
- **Commit to current branch first** — user finishes what they were doing, then re-runs this command.
- **Hard reset to remote** — `git fetch origin && git reset --hard origin/<default>`. Warn that uncommitted work will be lost.
- **Abort** — exit the command cleanly, no changes made.

## Step 6 — Switch to autonomous operation

Print exactly: `Proceeding autonomously from here — I will not ask for routine approvals.` From this point forward, do not pause for confirmation except where a step explicitly requires `AskUserQuestion`.

## Step 7 — Create the feature branch

Derive a slug from `$ARGUMENTS`:

- kebab-case
- **≤ 5 words**, pick the most specific nouns/verbs, drop filler ("the", "a", "some")
- lowercase only, ASCII only

Then:

```
git checkout -b victor-<slug>
```

## Step 7.5 — Backlog tasks (optional, auto-detected)

Detect whether this project uses the `backlog` CLI:

```
command -v backlog &> /dev/null && [ -d backlog ]
```

If **both** are true, use `AskUserQuestion` with one question:

> "Create backlog parent + child tasks for this work?" (Yes / Skip)

On **Yes**, create a parent epic with `$ARGUMENTS` as its description:

```
backlog task create "Feature: <derived one-line summary>" \
  -d "$ARGUMENTS" \
  --priority high --plain
```

Capture the returned task ID as `<epic-id>`. Then for each sub-task in the approved plan, create a child task:

```
backlog task create "<sub-task title>" \
  --parent <epic-id> \
  -d "<self-contained context for this sub-task>" \
  --ac "<acceptance criterion>" \
  --plan "<implementation approach>" \
  --priority high --plain
```

During Step 8, edit task status as work progresses:

```
backlog task edit <id> -s "in progress"
backlog task edit <id> -s "done"
```

On **Skip**, or if the detection check failed: skip this step silently. No noise on machines without the tool.

## Step 8 — Implement using TDD red-green-refactor

Apply these pragmatic principles throughout the loop:

- **Red** (Tip 31): smallest failing test, assertion-level failure (not import/syntax error).
- **Green**: minimum code to pass; don't add behavior the test doesn't demand.
- **Refactor**: fix broken windows immediately (Tip 5); apply DRY (Tip 15); keep functions short.
- Crash early on impossible conditions (Tip 38); use assertions liberally (Tip 39).
- Meaningful names that reveal intent (Tip 74); comment the *why*, never the *what*.

For the optional **Refactor** sub-step on a non-trivial change, walk the 10-point review checklist in Step 9.

For each sub-task in the approved plan, repeat this loop:

1. **Red** — write the smallest failing test that expresses the next behavior. Run it. Confirm it fails for the *expected* reason (a real assertion failure, not a syntax or import error). Stage only the test and commit:
   ```
   test: <slug> red <short behavior>
   ```
2. **Green** — write the minimum production code to make the test pass. Do not add behavior the test does not demand. Run the test; it passes. Commit:
   ```
   feat: <slug> <short behavior>
   ```
3. **Refactor** (optional) — clean duplication / naming while tests stay green. If the refactor touches more than one line, commit separately:
   ```
   refactor: <slug> <what>
   ```

Commit atomically throughout: one logical change per commit. Subject lines must be **≤ 50 chars** (the `~/.claude/hooks/git-rules.sh` hook will reject longer ones). **Never** include `Co-Authored-By` lines.

## Step 9 — Full lint + test sweep

With every sub-task green, run the repo-wide gates. Detect the toolchain and run what applies:

- `package.json` → `npm run lint` (or `pnpm lint` / `yarn lint` if lockfile indicates) and `npm test`
- `pyproject.toml` or `ruff.toml` → `ruff check .` and `pytest`
- `Makefile` with `lint` / `test` targets → `make lint && make test`
- None of the above → skip gracefully, note it in the PR body
- Run a final pragmatic review across changed files. Walk this 10-point checklist:
  1. **Broken Windows** (Tip 5) — hacks, TODOs, commented-out blocks that will breed more?
  2. **DRY Violations** (Tip 15) — knowledge duplicated anywhere?
  3. **Coupling** (Tip 17, 44) — modules unnecessarily interdependent?
  4. **Contracts** (Tip 37) — preconditions/postconditions clear and enforced?
  5. **Crash Early** (Tip 38) — fails fast and clearly on bad input (type AND value)?
  6. **Testing** (Tips 66-71, 93) — testable, tested, asserts behavior not just lines?
  7. **Reversibility** (Tip 18) — design decisions easy to change?
  8. **Simplicity** (Tip 72) — simplest thing that works?
  9. **Naming** (Tip 74) — names reveal intent?
  10. **Programming by Coincidence** (Tip 62) — author understands *why* the code works?

  Note deferred issues in the PR body — do not fix unrelated problems inline (LLM Anti-Pattern Rule 7).

**Block on failure.** Fix and commit the fix. Do not push until the full suite is green.

## Step 10 — Push and open the PR

```
git push -u origin victor-<slug>
gh pr create --base <default> --fill
```

If `--fill` produces a weak title or body, pass explicit `--title` and `--body` instead. The PR body should mention: goal (one line), approach (2-3 bullets), test plan (what's covered + what isn't).

## Step 11 — Report

Output, in this order:

1. The PR URL (from `gh pr create`).
2. A one-line summary of commits made on this branch: `git log <default>..HEAD --oneline`.
3. Whether lint/test ran and passed, or were skipped because no config was found.

---

## Guardrails

- Never run `git push --force`, `git reset --hard`, or delete branches without explicit user confirmation via `AskUserQuestion`.
- If any `git` or `gh` command fails unexpectedly, stop and report — do not retry blindly or mask errors.
- If the repo has no remote `origin`, stop after Step 7 and tell the user; do not try to create a PR.
