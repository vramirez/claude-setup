#!/usr/bin/env bash
# pre-commit-quality-gate.sh
# Generic pre-commit hook that catches common LLM anti-patterns.
# Symlink this into any project: ln -sf ~/code/claude-scripts/pre-commit-quality-gate.sh .git/hooks/pre-commit
#
# Checks:
#   1. Diff size warning (> 500 lines added)
#   2. Scope review (list changed files)
#   3. Dead code check for Python (ruff F401, F841)
#   4. Commented-out code detection

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

WARNINGS=0
FAILURES=0

warn() {
    echo -e "${YELLOW}WARNING:${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

fail() {
    echo -e "${RED}FAIL:${NC} $1"
    FAILURES=$((FAILURES + 1))
}

pass() {
    echo -e "${GREEN}PASS:${NC} $1"
}

echo -e "${BOLD}=== Pre-commit Quality Gate ===${NC}"
echo ""

# --------------------------------------------------------------------------
# 1. Diff size warning
# --------------------------------------------------------------------------
LINES_ADDED=$(git diff --cached --numstat | awk '{ added += $1 } END { print added+0 }')
LINES_REMOVED=$(git diff --cached --numstat | awk '{ removed += $2 } END { print removed+0 }')

if [ "$LINES_ADDED" -gt 500 ]; then
    warn "Large commit: +${LINES_ADDED} / -${LINES_REMOVED} lines. Consider splitting into smaller commits."
else
    pass "Diff size: +${LINES_ADDED} / -${LINES_REMOVED} lines"
fi

# --------------------------------------------------------------------------
# 2. Scope review -- list changed files for human verification
# --------------------------------------------------------------------------
echo ""
echo -e "${BOLD}Files in this commit:${NC}"
git diff --cached --name-status | while IFS=$'\t' read -r status file; do
    case "$status" in
        A) echo -e "  ${GREEN}+${NC} $file (new)" ;;
        M) echo -e "  ${YELLOW}~${NC} $file (modified)" ;;
        D) echo -e "  ${RED}-${NC} $file (deleted)" ;;
        R*) echo -e "  ${YELLOW}>${NC} $file (renamed)" ;;
        *) echo "  ? $file ($status)" ;;
    esac
done
echo ""

# --------------------------------------------------------------------------
# 3. Dead code check -- Python only (ruff F401 unused imports, F841 unused variables)
# --------------------------------------------------------------------------
STAGED_PY_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$' || true)

if [ -n "$STAGED_PY_FILES" ]; then
    if command -v ruff &>/dev/null; then
        RUFF_OUTPUT=$(echo "$STAGED_PY_FILES" | xargs ruff check --select F401,F841 --no-fix 2>/dev/null || true)
        if [ -n "$RUFF_OUTPUT" ]; then
            fail "Dead code detected in Python files:"
            echo "$RUFF_OUTPUT" | sed 's/^/  /'
        else
            pass "No unused imports or variables in Python files"
        fi
    else
        warn "ruff not found -- skipping Python dead code check. Install: pip install ruff"
    fi
else
    pass "No Python files staged -- skipping dead code check"
fi

# --------------------------------------------------------------------------
# 4. Commented-out code detection
# --------------------------------------------------------------------------
COMMENTED_CODE=$(git diff --cached -U0 | grep '^+' | grep -v '^+++' | \
    grep -E '^\+\s*#\s*(def |class |import |from .+ import|if |for |while |return |elif |else:)' || true)

if [ -n "$COMMENTED_CODE" ]; then
    warn "Possible commented-out code detected:"
    echo "$COMMENTED_CODE" | head -10 | sed 's/^/  /'
    TOTAL=$(echo "$COMMENTED_CODE" | wc -l)
    if [ "$TOTAL" -gt 10 ]; then
        echo "  ... and $((TOTAL - 10)) more lines"
    fi
else
    pass "No commented-out code detected"
fi

# --------------------------------------------------------------------------
# Summary
# --------------------------------------------------------------------------
echo ""
echo -e "${BOLD}=== Summary ===${NC}"
if [ "$FAILURES" -gt 0 ]; then
    echo -e "${RED}${FAILURES} failure(s), ${WARNINGS} warning(s). Fix failures before committing.${NC}"
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    echo -e "${YELLOW}${WARNINGS} warning(s). Proceeding with commit -- review warnings above.${NC}"
    exit 0
else
    echo -e "${GREEN}All checks passed.${NC}"
    exit 0
fi
