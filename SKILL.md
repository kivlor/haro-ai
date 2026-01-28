---
name: create-haro-issue
description: Use when the user wants to create a well-defined GitHub issue with structured acceptance criteria. Guides the user interactively through defining the issue.
metadata:
  short-description: Create GitHub issues with well-defined acceptance criteria
---

## Goal

Interactively guide the user to create a well-structured GitHub issue with clear, testable acceptance criteria. The agent generates acceptance criteria from the title and description, then allows the user to refine before creating.

---

## Prerequisites

The agent MUST verify GitHub CLI access by running:

```bash
gh repo view
```

If this command fails:
- Inform the user that GitHub CLI access is not working
- Ask them to:
  1. Ensure they're logged in: `gh auth login`
  2. Verify they're in a Git repository by running: `gh repo view`
  3. If `gh repo view` works in their terminal but fails in Codex, restart Codex with the `--yolo` flag to bypass sandbox restrictions

Do NOT proceed until `gh repo view` succeeds

---

## Interaction flow (STRICT)

The agent MUST follow this flow exactly.

### Step 1: Get the issue title

Ask the user: **"What issue would you like to create? Please provide a clear, concise title."**

Once provided, proceed immediately to Step 2.

---

### Step 2: Get the description

Ask the user: **"Describe the issue or feature request. What needs to be done and why?"**

Guidelines for description:
- Should explain the problem or feature clearly
- Include relevant context (e.g., current behavior vs. desired behavior)
- Mention affected components or areas if applicable

Once provided, proceed immediately to Step 3.

---

### Step 3: Generate acceptance criteria

Based on the title and description provided, the agent MUST automatically generate 3–7 testable acceptance criteria.

Guidelines for acceptance criteria:
- Each criterion MUST be testable and objective
- Use clear, actionable language (e.g., "User can...", "System returns...", "Error message displays...")
- Include edge cases and error handling where relevant
- For admin/privileged features, explicitly state permission requirements
- For destructive actions, include confirmation steps
- Use checkbox format: `- [ ] [criterion text]`

**Do NOT ask the user to build criteria one by one.** Generate them intelligently from the context provided.

Proceed immediately to Step 4.

---

### Step 4: Preview and confirm

Present a formatted preview:

```
Title: [issue title]

Description:
[description]

Acceptance Criteria:
- [ ] [criterion 1]
- [ ] [criterion 2]
- [ ] [criterion 3]
...
```

Ask: **"Create this issue or edit? (create/edit)"**

- If **create**: proceed to Step 5
- If **edit**: proceed to Step 4a

---

### Step 4a: Handle edits

Ask: **"What would you like to change?"**

The user can say things like:
- "Change the title to..."
- "Add an acceptance criterion about..."
- "Remove the third criterion"
- "Update the description to include..."
- "The second criterion should say..."

Interpret the user's request and update the appropriate section(s).

After making the change, return to Step 4 (show preview again).

---

### Step 5: Create the GitHub issue

Construct the issue body in Markdown format:

```markdown
## Description

[user's description]

## Acceptance Criteria

- [ ] [criterion 1]
- [ ] [criterion 2]
- [ ] [criterion 3]
...
```

Create the issue using:
```bash
gh issue create --title "[title]" --body "[formatted body]"
```

---

### Step 6: Confirm success

Once created:
- Display: **"✅ Issue #[number] created: [URL]"**

Do NOT print the entire issue body again.

---

## Acceptance criteria generation rules

When generating acceptance criteria, consider:

### For features:
- User capabilities ("User can...")
- UI/UX elements ("Button displays...", "Form validates...")
- Data persistence ("Data is saved...", "State persists...")
- Permissions ("Admin users can...", "Non-admin users cannot...")
- Edge cases ("Empty state shows...", "Error message appears when...")

### For bugs:
- Current broken behavior is fixed
- Related edge cases are addressed
- Error handling is improved
- Regression prevention ("Bug does not reappear when...")

### For refactoring:
- Functionality remains unchanged
- Tests continue to pass
- Performance is maintained or improved
- Code quality metrics (if applicable)

### Quality criteria examples:

**Good:**
- `- [ ] User can submit the form with all required fields populated`
- `- [ ] System returns a 400 error when email format is invalid`
- `- [ ] Admin users see the "Delete" button; non-admin users do not`
- `- [ ] Confirmation dialog appears before permanently deleting data`
- `- [ ] Loading spinner displays while data is fetching`

**Bad:**
- `- [ ] Form should work` (not testable)
- `- [ ] Better error handling` (not specific)
- `- [ ] Fix the bug` (not descriptive)
- `- [ ] Make it faster` (not measurable)

---

## Best practices

- **Be specific**: Each criterion should test one clear thing
- **Be testable**: Use objective, verifiable language
- **Be complete**: Cover happy path, edge cases, and error states
- **Be user-focused**: Frame from user or system perspective
- **Be realistic**: Don't generate criteria for features not mentioned in the description

---

## Error handling

If `gh repo view` fails during prerequisites:
- Show the error message
- Ask the user to:
  - Run `gh auth login` to authenticate
  - Verify `gh repo view` works in their terminal
  - If it works in terminal but not in Codex, restart Codex with: `codex --yolo`

If `gh issue create` fails:
- Display the error message
- Suggest verifying authentication and trying `codex --yolo` if needed
- Do NOT retry automatically - let the user address the issue

---

## Final behavior

- Keep the flow conversational but efficient
- Only ask three questions: title, description, create/edit
- Generate acceptance criteria intelligently - don't burden the user
- Allow flexible editing via natural language
- The primary outcome is a created GitHub issue
- Show the issue URL as the final confirmation