---
title: "AI agent coding for ESP-IDF workshop - Optional: Git workflow for agent-assisted development"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-08-28
showTableOfContents: true
showAuthor: false
---

## Git workflow for agent-assisted development

This lecture is optional. If you already use branches, review diffs, and create small commits confidently, you can skip it.

AI agents make version control more important because a single request can change several files. A simple Git workflow gives you checkpoints, makes review easier, and lets you separate agent-generated changes from unrelated work.

### Start from a known state

Before asking an agent to make a substantial change, check the working tree:

```bash
git status
git diff
```

Understand or commit existing changes first. This prevents a new task from becoming mixed with unfinished work.

### Use a branch for each feature

Create a branch before implementation:

```bash
git switch -c feat/led-blink
```

Useful branch prefixes include:

| Branch | Purpose |
|---|---|
| `feat/<name>` | New feature or component |
| `fix/<name>` | Bug fix |
| `refactor/<name>` | Code restructuring |
| `step/<n>` | One agent-driven implementation step |

Keep the default branch in a stable state. Do not ask an agent to delete branches, discard changes, rewrite history, or force-push unless you understand and explicitly approve the effect.

### Review before committing

After the agent finishes, inspect the complete change:

```bash
git status
git diff
```

Check that every changed file belongs to the task, generated files are intentional, and no credentials or build artifacts were added. Build and test the affected project before committing.

### Commit working checkpoints

Commit after each coherent, verified state instead of waiting until the end of a large task:

```bash
git add <files>
git commit -m "feat: add configurable LED blink"
```

Small commits make it easier to review the agent's work, compare behaviour between steps, and recover from a later mistake.

### Let the agent help with Git

An agent can explain a diff, select files related to the current task, and draft an accurate commit message. For example:

```text
Review the current Git diff. Identify any changes unrelated to this task,
summarise the remaining changes, and propose a concise commit message.
Do not stage or commit anything.
```

When you are ready to commit, ask explicitly and review the listed files first. The agent should not commit, push, or modify history unless you requested that action.

## Next step

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
