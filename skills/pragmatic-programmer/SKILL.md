---
name: pragmatic-programmer
description: Apply Pragmatic Programmer principles when designing, implementing, refactoring, or reviewing code. Use during planning to check DRY, Orthogonality, Reversibility, and Design by Contract; during implementation to fight broken windows and program deliberately; during review to evaluate against pragmatic criteria. Load references/tips.md for the full 100-tip list.
allowed-tools: Read, Grep, Glob
---

# Pragmatic Programmer

Apply the timeless principles from "The Pragmatic Programmer" (Andy Hunt and Dave Thomas) to every design, implementation, refactor, and review.

## Core philosophy

- Software entropy ("broken windows") must be fought constantly — one bad decision breeds more.
- Good Enough Software means knowing when to stop and ship, not writing perfect code.
- You own your code and its quality. Provide options, not lame excuses (Tip 4).
- Programming is about managing complexity and change. Prefer reversible decisions (Tip 18).
- Never run on autopilot — think about your work (Tip 2).

## Fundamental principles to apply

- **DRY — Don't Repeat Yourself** (Tip 15): every piece of knowledge has a single, unambiguous, authoritative representation. Hunt duplication in code, docs, and data.
- **Orthogonality** (Tip 17): independent, decoupled components. Changes to one shouldn't ripple to others. Minimize coupling, maximize cohesion.
- **Reversibility** (Tip 18): no decision cast in stone. Use abstractions and loose coupling to make pivots cheap.
- **Tracer Bullets** (Tip 20): build end-to-end skeletons first to verify architecture, then flesh out.
- **Prototype to Learn** (Tip 21): prototypes are for learning and are thrown away — distinct from tracer bullets.
- **Design by Contract** (Tip 37): explicit preconditions, postconditions, and invariants. Document assumptions.
- **Crash Early** (Tip 38): fail fast and clearly. Don't hide errors or program by coincidence.
- **Assertive Programming** (Tip 39): use assertions to catch "impossible" cases — they happen.
- **Decoupled Code Is Easier to Change** (Tip 44), **Tell, Don't Ask** (Tip 45), **Avoid Global Data** (Tip 47).
- **Refactor Early, Refactor Often** (Tip 65): leave code cleaner than you found it.
- **Don't Program by Coincidence** (Tip 62): understand *why* your code works, not just *that* it works.
- **Take Small Steps — Always** (Tip 42): deliberate, incremental progress beats heroic leaps.

## When to use this skill

### 1. Designing (e.g., `plan-new-feature` Step 2)

Before finalizing design decisions, walk this checklist:

- **Reuse**: is there an existing function, module, or pattern that fits? (DRY — Tip 15, Make It Easy to Reuse — Tip 16)
- **Orthogonality**: can this component be independent of the rest of the system? (Tip 17)
- **Contracts**: what are the preconditions, postconditions, and invariants? (Tip 37)
- **Reversibility**: which choices here are easy to undo, which are not? Prefer the easy-to-undo path (Tip 18).
- **Tracer bullet first**: what's the smallest end-to-end skeleton that proves the architecture? (Tip 20)
- **Estimate**: what's the rough size — files, lines, complexity? (Tip 23)

### 2. Implementing (e.g., `plan-new-feature` Step 8 — TDD red/green/refactor)

While writing code:

- **Red**: write the failing test first (Tip 31 — Failing Test Before Fixing Code). The test is the first user of your code (Tip 67).
- **Green**: minimum code to pass. Don't add behavior the test doesn't demand.
- **Refactor**: fix broken windows immediately (Tip 5). Apply DRY. Keep functions short and focused.
- Use meaningful names that reveal intent. Rename when names stop fitting (Tip 74).
- Crash early on impossible conditions (Tip 38). Use assertions liberally (Tip 39).
- Comment the *why*, never the *what*. Skip comments whose removal wouldn't confuse a future reader.

### 3. Reviewing (e.g., `plan-new-feature` Step 9 — final sweep)

Evaluate changed files against this 10-point review checklist:

1. **Broken Windows** (Tip 5): any quick hacks, TODOs, or commented-out blocks that will breed more?
2. **DRY Violations** (Tip 15): is knowledge duplicated anywhere?
3. **Coupling** (Tip 17, 44): are modules unnecessarily interdependent?
4. **Contracts** (Tip 37): are preconditions and postconditions clear and enforced?
5. **Crash Early** (Tip 38): does code fail fast and clearly on bad input?
6. **Testing** (Tips 66-71, 90, 91, 93): is it testable, tested, and does the test suite assert behavior — not just exercise lines?
7. **Reversibility** (Tip 18): can design decisions be changed without rewrites?
8. **Simplicity** (Tip 72): is this the simplest thing that works?
9. **Naming** (Tip 74): do names reveal intent?
10. **Programming by Coincidence** (Tip 62): does the author understand *why* the code works?

Note deferred issues in the PR body — do not fix unrelated problems inline (LLM Anti-Pattern Rule 7).

## Loading the full tips list

If you need a specific numbered tip, or want to scan the entire 100-tip canon, read `references/tips.md`. **Do not load it by default** — load only when:

- A user or step references a specific tip number ("apply tip 34").
- A design decision needs grounding in a tip that isn't in the curated list above.
- You're doing the final review sweep and want to scan for tips you haven't applied.

Source of truth: https://pragprog.com/tips/

## Communication style

- Give clear reasoning for every design decision.
- Surface trade-offs explicitly when multiple approaches exist (LLM Anti-Pattern Rule 3).
- Push back on tech debt; don't be sycophantic (LLM Anti-Pattern Rule 4).
- Cite specific tip numbers when they apply — they're the shared vocabulary.

Avoid:

- Vague generalities without specific application.
- Over-engineering for hypothetical futures.
- Perfectionism that blocks shipping.
- Making excuses instead of providing options (Tip 4).
