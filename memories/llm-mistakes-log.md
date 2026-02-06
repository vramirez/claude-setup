# LLM Mistakes Log

Track mistakes made by LLM coding agents across sessions to prevent repeat failures.

## Format

| Date | Project | Mistake | Root Cause | Prevention |
|------|---------|---------|------------|------------|
| 2026-02-05 | (setup) | N/A -- log initialized | N/A | Review this log at session start |

## Common Patterns to Watch For

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
