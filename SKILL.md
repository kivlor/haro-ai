---
name: create-haro-issue
description: Use when the user wants to create a well-defined GitHub issue with structured acceptance criteria. Guides the user interactively through defining the issue.
metadata:
  short-description: Create GitHub issues with well-defined acceptance criteria
---

## Goal

Interactively guide the user to create a well-structured GitHub issue with clear, testable acceptance criteria. The agent MUST use a conversational, step-by-step approach rather than gathering all information at once.

---

## Prerequisites

The agent MUST verify:

1) GitHub CLI (`gh`) is installed and authenticated
   - If not: instruct the user to run `gh auth login`

2) The current directory is inside a Git repository
   - If not: ask the user to navigate to their project

---

## Interaction flow (STRICT, ITERATIVE)

The agent MUST follow this flow exactly.

### Step 1: Establish the issue title

Ask the user: **"What issue would you like to create? Please provide a clear, concise title."**

Once provided:
- Confirm the title in a single sentence
- Proceed to Step 2

---

### Step 2: Capture the issue description

Ask the user: **"Describe the issue or feature request. What needs to be done and why?"**

Guidelines for description:
- Should explain the problem or feature clearly
- Include relevant context (e.g., current behavior vs. desired behavior)
- Mention affected components or areas if applicable

Once provided:
- Summarize the description briefly
- Proceed to Step 3

---

### Step 3: Define acceptance criteria iteratively

The agent MUST build acceptance criteria one at a time.

For each criterion:

1) Ask: **"What's one specific, testable condition that must be met to consider this issue complete?"**

2) If the criterion is vague, ask **at most one** clarifying question to make it concrete and testable

3) Present the refined criterion and confirm with the user

4) Ask: **"Add another acceptance criterion? (yes/no)"**
   - If **yes**: repeat for the next criterion
   - If **no**: proceed to Step 4

Guidelines for acceptance criteria:
- Each criterion MUST be testable and objective
- Use clear, actionable language (e.g., "User can...", "System returns...", "Error message displays...")
- Include edge cases and error handling where relevant
- For admin/privileged features, explicitly state permission requirements
- For destructive actions, include confirmation steps
- Aim for 3–7 criteria per issue

---

### Step 4: Assign labels (optional)

Ask: **"Would you like to add any labels to this issue? (e.g., bug, enhancement, documentation)"**

- If the user provides labels, store them as a comma-separated list
- If no labels, proceed to Step 5

---

### Step 5: Assign priority/milestone (optional)

Ask: **"Should this issue be assigned to a milestone or given a priority label? (optional)"**

- If provided, note it for inclusion in the issue body
- If not, proceed to Step 6

---

### Step 6: Review and create

Present a formatted summary:

```
Title: [issue title]

Description:
[description]

Acceptance Criteria:
- [ ] [criterion 1]
- [ ] [criterion 2]
- [ ] [criterion 3]
...

Labels: [labels if any]
Milestone: [milestone if any]
```

Ask: **"Does this look correct? Should I create this issue? (yes/no/edit)"**

- If **yes**: proceed to Step 7
- If **no**: abort and exit
- If **edit**: ask what needs to change, make the edit, and re-present

---

### Step 7: Create the GitHub issue

Construct the issue body in Markdown format:

```markdown
## Description

[user's description]

## Acceptance Criteria

- [ ] [criterion 1]
- [ ] [criterion 2]
- [ ] [criterion 3]
...

[If milestone/priority was mentioned, include it here as a note]
```

Create the issue using:
```bash
gh issue create --title "[title]" --body "[formatted body]" [--label "label1,label2"] [--milestone "milestone-name"]
```

---

### Step 8: Confirm success

Once created:
- Display the issue number and URL
- Respond with: **"Issue #[number] created successfully: [URL]"**

Do NOT print the entire issue body again unless explicitly asked.

---

## Acceptance criteria formatting rules

- Use checkbox format: `- [ ] [criterion text]`
- Each criterion on its own line
- Clear, action-oriented language
- Testable and objective
- No vague terms like "should work well" or "must be good"

### Good examples:
- `- [ ] User can submit the form with all required fields populated`
- `- [ ] System returns a 400 error when email format is invalid`
- `- [ ] Admin users see the "Delete" button; non-admin users do not`
- `- [ ] Confirmation dialog appears before permanently deleting data`

### Bad examples:
- `- [ ] Form should work` (not testable)
- `- [ ] Better error handling` (not specific)
- `- [ ] Fix the bug` (not descriptive)

---

## Issue design best practices

- **Be specific**: Avoid broad, multi-faceted issues. If the scope grows, suggest splitting into multiple issues.
- **Be testable**: Every acceptance criterion should be verifiable with a clear pass/fail outcome.
- **Be complete**: Include edge cases, error states, and permission checks where relevant.
- **Be user-focused**: Frame criteria from the perspective of what the user experiences or what the system does.

---

## Error handling

If `gh issue create` fails:
- Display the error message
- Suggest common fixes:
  - Re-authenticate: `gh auth login`
  - Verify repository: `gh repo view`
  - Check network connectivity

Do NOT retry automatically. Let the user address the issue.

---

## Final behavior

- The primary outcome is a created GitHub issue
- Keep responses concise and focused
- Only ask one question at a time during the interactive flow
- Do NOT dump all questions at once
- Guide the user through a conversational process