#!/bin/bash
set -e

ITERATIONS="${1:-10}"

# Check if gh is installed
if ! command -v gh &> /dev/null; then
  echo "Error: GitHub CLI (gh) is not installed."
  echo "Install it from: https://cli.github.com/"
  exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed."
  echo "Install it with your package manager (e.g., apt install jq, brew install jq)"
  exit 1
fi

# Check if gh is authenticated
if ! gh auth status &> /dev/null; then
  echo "Error: GitHub CLI is not authenticated."
  echo "Run: gh auth login"
  exit 1
fi

echo "Starting Agent Loop"
echo "Max Iterations: $ITERATIONS"
echo ""

for i in $(seq 1 "$ITERATIONS"); do
  echo "Iteration $i"

  # Fetch one unassigned open issue
  ISSUE_JSON=$(gh issue list --state open --json number,title,body,labels,url,assignees --limit 100 \
    | jq '[.[] | select(.assignees | length == 0)] | first // empty')

  if [ -z "$ISSUE_JSON" ]; then
    echo "No unassigned open issues found. All done!"
    exit 0
  fi

  ISSUE_NUMBER=$(echo "$ISSUE_JSON" | jq -r '.number')
  ISSUE_TITLE=$(echo "$ISSUE_JSON" | jq -r '.title')
  echo "Working on issue #$ISSUE_NUMBER: $ISSUE_TITLE"
  echo ""

  PROMPT="
## Your Task

Complete the GitHub issue below.

### Workflow

1. Read 'AGENTS.md' (if it exists) for codebase patterns
2. **FIRST: Assign yourself to the issue with: gh issue edit $ISSUE_NUMBER --add-assignee @me**
3. Create or switch to a feature branch (e.g., 'issue-$ISSUE_NUMBER-brief-description')
4. Implement a solution for this issue
5. Run code checks/tests/lint relevant to the change
6. Update 'AGENTS.md' with any reusable patterns discovered (see below)
7. Commit with message format: '[feat|fix]: $ISSUE_TITLE (#$ISSUE_NUMBER)'
8. Push and create a pull request:
   - Push: git push -u origin HEAD
   - Create PR: gh pr create --title \"$ISSUE_TITLE\" --body \"Closes #$ISSUE_NUMBER\n\n[Description of changes]\"
9. Do NOT close issues directly - they will be closed when the PR is merged

---

## Issue

\`\`\`json
$ISSUE_JSON
\`\`\`

---

## AGENTS.md – Codebase Patterns

If you discover reusable, cross-cutting patterns, add them to 'AGENTS.md'.

Rules:
- Append patterns to the TOP of the file under a section titled: ## Codebase Patterns
- Patterns must be generic and reusable
- Do NOT duplicate issue-specific notes here
- Examples:
  - Migrations: Use IF NOT EXISTS
  - React: useRef<Timeout | null>(null)
  - APIs: Always return 404 for unauthorized resource access

If 'AGENTS.md' does not exist, create it with the '## Codebase Patterns' section.
"

  echo "$PROMPT" | codex exec --dangerously-bypass-approvals-and-sandbox 2>&1 | tee /dev/stderr || true

  echo ""
  sleep 2
done

echo "Max iterations reached"
exit 0
