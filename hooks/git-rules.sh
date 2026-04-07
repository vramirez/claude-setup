#!/bin/bash
cmd=$(python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))")

# --- Add rule blocks below as needed ---

if echo "$cmd" | grep -q "git commit"; then
  echo "COMMIT RULES:"
  echo "- Subject line must be ≤50 chars"
  echo "- Do NOT include Co-Authored-By lines"
fi
