# Declarative Workflow Templates

Use these templates instead of step-by-step imperative instructions. Define WHAT success looks like, not HOW to get there.

---

## Bug Fix Template

```
Bug: [one-sentence description]
Expected behavior: [what should happen]
Actual behavior: [what happens instead]
Reproduction: [steps or command to reproduce]

Success criteria:
- [ ] Bug reproduces before fix (verified)
- [ ] Root cause identified and documented
- [ ] Fix is under 50 lines of changed code
- [ ] New test added that catches this specific bug
- [ ] All existing tests pass without modification
- [ ] No unrelated code was changed
- [ ] No dead code left behind
```

---

## Feature Template

```
Feature: [one-sentence description]
User story: As a [role], I want [action] so that [benefit]

Success criteria:
- [ ] Naive correct version works end-to-end
- [ ] Tests written BEFORE implementation (test-first)
- [ ] Handles empty/null/edge-case inputs gracefully
- [ ] No new dependencies unless justified
- [ ] Implementation is proportional to the ask (not gold-plated)
- [ ] Only optimize if measured performance is insufficient

Scope boundary:
- Files to touch: [list]
- Files NOT to touch: [list]
```

---

## Refactor Template

```
Refactor: [what is being refactored]
Why: [specific problem with current code -- not "it could be better"]

Success criteria:
- [ ] All existing tests pass WITHOUT modification
- [ ] Fewer total lines of code (or same, never more)
- [ ] No dead code, unused imports, or commented-out blocks
- [ ] No behavior change (pure structural improvement)
- [ ] No new abstractions unless they eliminate duplication in 3+ places

Scope boundary:
- Files to touch: [list]
- Files NOT to touch: [list]
```

---

## Data Pipeline Template

```
Pipeline: [one-sentence description]
Input: [format, source, expected volume]
Output: [format, destination, expected volume]

Success criteria:
- [ ] Handles empty input without error
- [ ] Handles malformed/missing fields in records
- [ ] Idempotent (safe to re-run)
- [ ] No hardcoded file paths, URLs, or credentials
- [ ] Logging at key checkpoints (input count, output count, error count)
- [ ] Tested with sample data before production run
- [ ] Resource usage is proportional to input size (no memory blowup)
```

---

## Anti-Pattern Examples

### BAD: Imperative prompting (tells the LLM HOW)
```
1. First read the file users.py
2. Find the function get_user_by_id
3. Add a try-except block around the database call
4. Log the error if it fails
5. Return None on failure
6. Add a test for the error case
7. Run the tests
```

Problems: Over-specified, doesn't explain WHY, no success criteria, LLM may follow steps blindly even if they don't make sense.

### GOOD: Declarative prompting (tells the LLM WHAT)
```
Bug: get_user_by_id crashes with unhandled DatabaseError when the connection pool is exhausted.

Success criteria:
- Function returns None instead of crashing on database errors
- Error is logged with enough context to debug (user_id, error type)
- Existing callers already handle None returns (verify this)
- New test simulates database failure and verifies graceful handling
- No changes to any other function
```

Why this works: Explains the problem, defines success, sets scope boundaries, lets the LLM choose the implementation.

---

### BAD: Vague feature request
```
Add caching to the API
```

### GOOD: Declarative feature request
```
Feature: Cache the /api/businesses/ list endpoint to reduce database load.

Success criteria:
- Response is cached for 5 minutes (configurable)
- Cache invalidates when a business is created, updated, or deleted
- Cache key includes query parameters (so filtered results are cached separately)
- No new dependencies (use Django's built-in cache framework + Redis already in stack)
- Measured: endpoint responds in < 50ms on cache hit (vs current ~200ms)

Scope: Only the businesses list endpoint. Do not add caching to other endpoints.
```
