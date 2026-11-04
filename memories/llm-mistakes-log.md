# LLM Mistakes Log

Track mistakes made by LLM coding agents across sessions to prevent repeat failures.

## 2026-10-20 navigate-app (TASK-135.5)
- Re-extracted past articles on the real clock: played matches became past_result, wasted an eval round. Freeze the clock to the article processing time.
- A prompt "revert" edit dropped a newline and glued two prompt bullets; caught only by review. Diff prompt edits as text before measuring.
- Split commit: git mv staged a rename but the dependency edit was not re-added; pushed a migration still depending on 0074. Check git status after every commit.

## Format

| Date | Project | Mistake | Root Cause | Prevention |
|------|---------|---------|------------|------------|
| 2026-02-05 | (setup) | N/A -- log initialized | N/A | Review this log at session start |
| 2026-08-03 | (setup) | Commit broke this repo's own git hook: 54-char subject + Co-Authored-By trailers | Piped `git commit` through `tail -8`, which cut off the hook's warning | Never filter tool output past where warnings appear; read commit/hook output in full |
| 2026-08-03 | (setup) | All 12 runs of an A/B test answered a one-word prompt; whole run void | `xargs` + `eval` re-split the quoted prompt down to its first word | Pass long prompts via files, not shell args; validate one run before spending N |

## Common Patterns to Watch For

- Assuming API shapes without reading source code
- Over-engineering simple requests
- Silently choosing one interpretation of ambiguous requirements
- Modifying code outside the task scope
- Leaving dead code after refactors
- Creating abstractions before they're needed
- Fluent recall passed off as analysis
- Listing possible causes instead of naming one
- Symmetric hedging that pushes the decision back to me
- Running a check that could not have failed
- Confidence earned by effort rather than evidence
- Plausible file/flag/error details that can't be sourced
- Stopping at the first coherent story
- Apologizing where a one-line correction was the job
- Dropping a measured result on mere assertion
- Delivering the tractable 80% and reporting done

## Instructions

Append a row after any session where the LLM:
1. Made an incorrect assumption that caused rework
2. Over-complicated a solution that needed simplification
3. Broke existing functionality
4. Modified code outside the task scope
5. Left dead code or commented-out blocks

## 2026-08-31 (navigate-app, TASK-119/120 session)
- Committed a backlog chore commit on local dev, then branched WITHOUT pushing dev first: the chore commit rode into the feature PR's squash unannounced. Push dev (or branch from origin/dev) before cutting a feature branch.
- Tried to prevent a deploy-vs-nightly-pipeline race by disabling the deploy workflow AFTER checking CI state that was already stale; the deploy had finished 5 min earlier and the "protection" was a no-op. Check `gh run list` timestamps (and actual step durations, not last release's) before acting on a projected race.

## 2026-09-02 (fedora-hyprland, research + Phase 1 session)
- Wrote a `set -euo pipefail` script where `grep` inside a command substitution had an expected no-match case (package absent from Fedora); the script exited silently after 7 of 12 rows. Wrap expected-miss greps in `{ grep ... || true; }` and run the script on the full input before calling it done.

## 2026-09-02 (whatsdesk launch-error triage)
- Used `pkill -f '<pattern>'` inside a Bash tool command whose own command line contained the pattern; pkill killed the shell running it and the rest of the output was lost (twice). Kill by saved PID or `pkill -x <name>`, never `pkill -f` with a string that appears in the invoking command.

## 2026-09-03 navigate-app (TASK-125 / 117 / 122 session)
- Ran `git stash` + `git stash pop` in the main checkout to get a ruff baseline while a background pytest sweep was using the docker bind mount. The sweep died silently (empty output). Lesson: never rewrite the working tree while background tests or coding subagents run on it; use a worktree or `git show origin/dev:<path>` for baselines.
- Committed backlog task notes to dev through a scratch worktree while the feature branch was editing the same task .md. The PR squash-merge then conflicted on the markdown and needed a merge commit on the branch. Lesson: notes for files a branch touches ride with that branch's PR.
- A sonnet coding subagent sat idle ~8h on a blocked permission prompt (pip install inside the container for a temporary ruff) with no signal to the coordinator. Lesson: pre-install or pre-authorize tooling the agent will need, and check `ListAgents` + file mtimes when a report is overdue.

## 2026-09-15 navigate-app TASK-135.1 (feed quality spike)
- Estimated the benefit of two dedup-key extensions from a cause breakdown of missed pairs ("about 3% duplicates left") instead of running them; the measured result was 7-8%. Lesson: when the data and helpers are already in hand, simulate before quoting a number, an inference is not a measurement.
- A coding subagent's local smoke run wrote to the wrapper's default output path, which was the same date-stamped file as the prod snapshot, and silently overwrote it (2 min prod re-run). Lesson: give tools distinct default filenames per environment before a subagent runs them, and copy irreplaceable measurement dumps aside before delegating.
- The same subagent did `git checkout <older commit>` + `commit --amend` to reword a subject, leaving HEAD detached and about to rebase; caught by a stale-file symptom, not by the agent. Lesson: subagent prompts must forbid checkout/amend/rebase explicitly, not just push/reset/stash; watch the branch pointer, not only the commit stream.

## 2026-09-16 navigate-app TASK-135.2 (PR #243)
- Coding subagents backgrounded their full pytest sweep twice and stopped on "waiting", despite the brief saying foreground; each needed a SendMessage nudge. Say "never run_in_background" explicitly, not just "foreground".
- I ran the full backend suite while a subagent was still running its own sweep against the same Docker test database: 11 spurious failures (taxonomy, transaction-lock tests). Check for a running pytest process in the container before starting a suite run, or wait for the subagent to finish.
- Plan claimed the SystemConfiguration admin "picks fields up automatically"; the admin uses explicit fieldsets, so the new knob was invisible until review caught it. Verify admin registration, not just the model, when adding a config field.

## 2026-10-11 (ThinkPad battery thresholds + hibernate)
- Labeled the whole swap directory with SELinux `semanage fcontext -a -t swapfile_t '/var/swap(/.*)?'` (a common recipe). logind was denied `search` on the directory and `CanHibernate` stayed `na`. Label only the swapfile itself; check `ausearch -m avc -ts recent` right after any new fcontext.
- Told the user I couldn't run sudo and handed them the commands; `sudo -n true` worked. Check `sudo -n true` before claiming sudo is unavailable.

## 2026-10-20 navigate-app (release, publish-date fix, squash policy)
- Quoted Bedrock reprocess cost from the Espiga runs ($1.50); measured was $2.70 (Haiku 4.5 with cache writes). Measure cost from BedrockUsage on a small run before quoting a number.
- Wrote a workflow-logic test whose "hotfix" case used a tree from dev's own history, so the case could not fail. Make each negative test case provably absent from the data it runs against.

## 2026-10-22 navigate-app (TASK-176 deploy re-exec, TASK-167 epic close, TASK-186 e2e paths)
- Reported PR #307 "all green" from `gh pr checks` right after a push; the list still showed the previous commit's runs and E2E on the new head failed (flake). Before saying green, confirm every check run on the PR's current headRefOid is completed (`gh api .../commits/<sha>/check-runs`).
- Delegate's TDD "red" run failed for the wrong reason (hardcoded REPO_DIR), not the bug. Re-run red with only the fix removed to prove the test catches the actual defect.

## 2026-10-25 navigate-app (TASK-193 Actions minutes)
- Optimized CI minutes through several rounds of path maps and job stacking before converting the bill to dollars. October was ~$12, about the free allowance's value; the real blocker was the $0 budget. Price the problem (and the simplest fix, e.g. pay) before designing levers.
- Claimed unknown-path rules "never skip a check" without the case where a known folder gains a new dependency. State the failure mode of a rule, not only its safe case.
- Delegate's release gate waited only on runs at the exact head SHA, and its gh stub ignored the head_sha filter, so the test could not catch it. Make test doubles honor every filter the code relies on, then prove red on the old code.
- Said "add the card" was enough; a card alone does not raise a $0 Actions budget. Check the limit too.

## 2026-10-26 navigate-app (TASK-195 hide/date lock, TASK-196 REVIEW.md -> guards + pstack Review playbook)
- Called pstack "upstream, generic, edits lost on update" from the plugin cache path alone; it is Victor's own fork (vramirez/claude-skills). Check a plugin's marketplace repo owner before calling it third-party.
- Said a plugin refresh would pick up the merged playbook; the cache kept 1.0.0 because the version was not bumped. Bump the plugin version in the same PR as the change.

## 2026-10-27 navigate-app (TASK-197/198 Haiku 5.5 switch, TASK-201 CRLF prompt, TASK-204)
- Ran `migrate` on the shared dev DB as part of a check while an unreleased migration (0084 column drop) was on disk; it dropped dev columns and had to be reversed. Never migrate the shared dev DB to verify something; use a throwaway navigate_eval_* DB (TASK-202).
- Told Victor dev had prompt v2 "by the release" without checking; dev kept v1 because migration 0080 seeds a prompt once per DB. Read the stored value before claiming two environments match.

## 2026-10-28 NaviGate release waiter hung 7 hours
- What: a background until-loop waited for >= 4 check runs on the release head; the head was a backlog-only commit, Tests skips doc-only changes (paths-ignore), so only 1 check ever ran and the loop never ended. No notification, no timeout, release missed the 09:00 UTC crawl window.
- Why: the wait condition came from an assumption (4 checks) instead of the checks that actually exist for that commit; I even read the paths-ignore comment in deploy.yml after starting the loop and did not revisit it.
- Rule: every wait loop gets a timeout and exits on any terminal state; derive what to wait for from the real check runs (gh pr checks --watch) and re-check the condition when new facts arrive.

## 2026-10-29 NaviGate: false test failures from shared test DB, backlog edit in a busy checkout
- What: I ran the recommendations suite while a subagent's background `pytest --create-db` was still running in the same container; 1 failure + 16 errors, all false. Later I ran `backlog task edit` in the main checkout while a subagent was committing there (reverted before it got swept into its commit).
- Why: I treated the subagent's "done" report as "no processes left", and forgot the main checkout was the subagent's workspace.
- Rule: before a suite, check /proc for a running `bin/pytest`; give parallel runs their own DATABASE_URL. Never edit files in a checkout a subagent is working in; put backlog edits on the branch after it finishes.

## 2026-11-04 claude-setup: /closer PR commits broke git-rules.sh
- What: the first two PR 4 commits had subjects over 50 chars and Co-Authored-By lines, both banned by hooks/git-rules.sh.
- Why: I followed the harness attribution reminder and did not read the commit rules the hook prints; user rules override that reminder.
- Rule: before the first commit in a repo session, read hooks/git-rules.sh output; subject <=50 chars, no Co-Authored-By.
