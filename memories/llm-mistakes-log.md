# LLM Mistakes Log

Track mistakes made by LLM coding agents across sessions to prevent repeat failures.

## Format

| Date | Project | Mistake | Root Cause | Prevention |
|------|---------|---------|------------|------------|
| 2026-02-05 | (setup) | N/A -- log initialized | N/A | Review this log at session start |
| 2026-08-03 | (setup) | Commit broke this repo's own git hook: 54-char subject + Co-Authored-By trailers | Piped `git commit` through `tail -8`, which cut off the hook's warning | Never filter tool output past where warnings appear; read commit/hook output in full |
| 2026-08-03 | (setup) | All 12 runs of an A/B test answered a one-word prompt; whole run void | `xargs` + `eval` re-split the quoted prompt down to its first word | Pass long prompts via files, not shell args; validate one run before spending N |

## Common Patterns to Watch For

(Full catalogue, incl. failure modes that read as competence: ~/memories/operating-standard.md)

- Assuming API shapes without reading source code
- Over-engineering simple requests
- Silently choosing one interpretation of ambiguous requirements
- Modifying code outside the task scope
- Leaving dead code after refactors
- Creating abstractions before they're needed

## Instructions

Append a row after any session where the LLM:
1. Made an incorrect assumption that caused rework
2. Over-complicated a solution that needed simplification
3. Broke existing functionality
4. Modified code outside the task scope
5. Left dead code or commented-out blocks
