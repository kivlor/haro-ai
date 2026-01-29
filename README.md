# Haro

AI-powered automation loop script for GitHub issue completion.

## Overview

Haro automatically works through your GitHub issues by:
- Fetching unassigned open issues
- Assigning itself to an issue
- Implementing the solution
- Creating a pull request for review
- Moving to the next issue

## Prerequisites

Before installing, ensure you have:

1. **GitHub CLI** - [Installation guide](https://cli.github.com/)
2. **jq** - JSON processor
   - Ubuntu/Debian: `sudo apt install jq`
   - macOS: `brew install jq`
   - Fedora: `sudo dnf install jq`
3. **Codex CLI** - For AI code execution

## Installation

Install the Haro script to your local bin directory:

```bash
curl -o ~/.local/bin/haro https://raw.githubusercontent.com/kivlor/haro/main/haro.sh
chmod +x ~/.local/bin/haro
```

> **Note:** Make sure `~/.local/bin` is in your PATH. Add this to your `.bashrc` or `.zshrc` if needed:
> ```bash
> export PATH="$HOME/.local/bin:$PATH"
> ```

## Setup

1. **Authenticate with GitHub:**
   ```bash
   gh auth login
   ```

2. **Navigate to your project:**
   ```bash
   cd /path/to/your/project
   ```

3. **Run Haro:**
   ```bash
   haro
   ```

## Usage

```bash
haro [iterations]
```

### Parameters

- `iterations` (optional) - Maximum number of issues to process. Default: 10

### Examples

Process up to 10 issues (default):
```bash
haro
```

Process up to 5 issues:
```bash
haro 5
```

Process up to 20 issues:
```bash
haro 20
```

## Optional: Codex Skill for Issue Creation

For a streamlined workflow, install the included `$create-haro-issue` Codex skill to create well-defined issues that Haro can work on.

### Install the Skill

```bash
# Clone to your Codex user skills directory
mkdir -p ~/.codex/skills
git clone https://github.com/kivlor/haro-ai.git ~/.codex/skills/haro-ai

# Or install at repo-level (from your project root)
mkdir -p .codex/skills
git clone https://github.com/kivlor/haro-ai.git .codex/skills/haro-ai
```

After installation, restart Codex to pick up the new skill.

### Use the Skill

Invoke the skill in Codex:
```bash
$create-haro-issue
```

The skill will interactively guide you through:
1. Defining a clear issue title
2. Writing a detailed description
3. Creating testable acceptance criteria (one at a time)
4. Adding labels and milestones (optional)
5. Creating the GitHub issue with structured formatting

This creates issues that are perfectly formatted for Haro to process automatically.

## How It Works

1. **Fetches unassigned issues** from the current repository
2. **Selects lowest-numbered issue** to maintain priority
3. **Assigns itself** to the issue (`gh issue edit [number] --add-assignee @me`)
4. **Implements the solution** using AI
5. **Creates a feature branch** (e.g., `issue-123-description`)
6. **Runs tests/checks** to verify the solution
7. **Commits changes** with format: `[feat|fix]: [Issue Title] (#123)`
8. **Creates a pull request** that references the issue
9. **Repeats** for the next unassigned issue

The script stops when:
- All unassigned issues are processed
- Maximum iterations are reached
- No unassigned issues remain

## Codebase Patterns

The agent learns and documents reusable patterns in `AGENTS.md` at the root of your project. This file helps maintain consistency across implementations.

Example patterns:
- Database migrations best practices
- API error handling conventions
- React component patterns
- Testing strategies

## Benefits

- **Autonomous issue resolution** - Handles routine issues automatically
- **Human oversight** - All changes go through PR review
- **Prevents conflicts** - Self-assignment prevents duplicate work
- **Maintains context** - Learns patterns in `AGENTS.md`
- **Priority-based** - Works on lowest-numbered (typically highest priority) issues first

## Notes

- Issues are **not closed automatically** - they close when you merge the PR
- All work is done in **feature branches** for safe review
- The agent will **not** work on assigned issues (respects human ownership)
- Each run is independent - you can safely stop and restart
