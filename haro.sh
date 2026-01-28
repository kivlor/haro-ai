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

echo "Fetching unassigned open issues from GitHub..."

# Fetch open issues that are unassigned
ISSUES_JSON=$(gh issue list --state open --assignee none --json number,title,body,labels,url --limit 100)

if [ "$ISSUES_JSON" = "[]" ] || [ -z "$ISSUES_JSON" ]; then
  echo "No unassigned open issues found in the current repository."
  exit 0
fi

echo "Found $(echo "$ISSUES_JSON" | jq length) unassigned issue(s)"
echo ""

PROMPT="
## Your Task

You are working on open GitHub issues in this repository.

Follow this workflow exactly:

1. Fetch the list of unassigned open issues (already provided below)
2. Read 'AGENTS.md' (if it exists) for codebase patterns
3. Identify the NEXT issue to work on:
   - Choose the lowest-numbered unassigned issue from the list provided
   - **FIRST ACTION: Assign yourself to the issue with: gh issue edit [number] --add-assignee @me**
   - This prevents other processes from working on the same issue
4. Create or switch to a feature branch (e.g., 'issue-123-brief-description')
5. Implement a solution for that ONE issue only
6. Run code checks/tests/lint relevant to the change
7. Update 'AGENTS.md' with any reusable patterns discovered (see below)
8. Commit with message format:
   - '[feat|fix]: [Issue Title] (#[issue-number])'
9. Create a pull request for review:
   - Push the branch: 'git push -u origin HEAD'
   - Create PR with: gh pr create --title \"[Issue Title]\" --body \"Closes #[issue-number]\n\n[Description of changes]\"
   - The PR body should include 'Closes #[issue-number]' to auto-link the issue
10. Do NOT close issues directly - they will be closed when the PR is merged

---

## Unassigned Open Issues

The following issues are currently unassigned and available to work on:

\`\`\`json
$ISSUES_JSON
\`\`\`

---

## AGENTS.md – Codebase Patterns

If you discover reusable, cross-cutting patterns, add them to 'AGENTS.md'.

Rules:
- Append patterns to the TOP of the file under a section titled:

## Codebase Patterns

- Patterns must be generic and reusable
- Do NOT duplicate issue-specific notes here
- Examples:
  - Migrations: Use IF NOT EXISTS
  - React: useRef<Timeout | null>(null)
  - APIs: Always return 404 for unauthorized resource access

If 'AGENTS.md' does not exist:
- Create it
- Add the '## Codebase Patterns' section at the top

---

## Stop Condition

If there are NO unassigned issues remaining:

1. Ensure all changes are committed and pushed
2. Reply:
   <promise>COMPLETE</promise>

Otherwise end normally after completing one issue and creating its PR.
"

echo "Starting Agent Loop"
echo "Iterations: $ITERATIONS"
echo ""

for i in $(seq 1 "$ITERATIONS"); do
  echo "Iteration $i"

  OUTPUT=$(echo "$PROMPT" \
    | codex exec --dangerously-bypass-approvals-and-sandbox 2>&1 \
    | tee /dev/stderr) || true

  if echo "$OUTPUT" | tail -n 10 | grep -q "<promise>COMPLETE</promise>"; then
    echo "All issues completed!"
    exit 0
  fi

  # Refresh unassigned issues list for next iteration
  ISSUES_JSON=$(gh issue list --state open --assignee none --json number,title,body,labels,url --limit 100)

  if [ "$ISSUES_JSON" = "[]" ] || [ -z "$ISSUES_JSON" ]; then
    echo "No more unassigned issues!"
    exit 0
  fi

  sleep 2
done

echo "Max iterations reached"
exit 1
