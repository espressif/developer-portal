---
title: "AI agent coding for ESP-IDF workshop - Introduction"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
showTableOfContents: true
series: ["WS003EN"]
series_order: 1
showAuthor: false
---

## AI agent coding overview

Let's start with the big picture. AI-assisted coding is changing the way developers work, and if you haven't tried it for embedded development yet, this workshop is a great place to start.

The idea is simple: instead of spending time writing boilerplate, hunting through documentation, or manually chasing build errors, you describe what you want and let an AI agent handle the routine work. That frees you to focus on design decisions, reviewing the result, and verifying that the software does what it is supposed to do.

### What is an AI coding agent?

An AI coding agent is more than a smarter autocomplete. It's a tool that combines a large language model (LLM) with access to your actual development environment: your files, your terminal, your build output, and your project context.

Instead of just suggesting code for you to copy and paste, an agent can open files, make changes, run a build, read the error output, fix the issue, and try again, all on its own. You review the result and decide whether to keep the changes.

That's a very different experience from a chatbot.

Some of the most popular AI coding agents right now include:

- [Cursor](https://www.cursor.com/): an IDE built around AI agents, with deep codebase awareness and support for custom rules and skills.
- [GitHub Copilot](https://github.com/features/copilot): available inside VS Code and other editors, with an agent mode that can make multi-file changes and run terminal commands.
- [OpenAI Codex](https://learn.chatgpt.com/docs): a coding agent from OpenAI, accessible via the CLI or IDE plugin/extension.
- [Claude](https://claude.com/solutions/agents): an AI coding agent from Anthropic, available via the terminal.

Agents can be used directly from the IDE, where they have access to your open files and project context, or from the CLI, where you can run them as part of a script or automated workflow. Both IDE and CLI modes are useful: the IDE is great for interactive development, while the CLI fits well into build pipelines and batch tasks.

### Agent vs chatbot

Both use a chat interface, so it's easy to mix them up. Here's the practical difference:

| | Chatbot | AI Coding Agent |
|---|---|---|
| **Context** | What you paste into the chat | Your entire project, open files, and terminal |
| **Actions** | Generates text suggestions | Reads, writes, and runs code |
| **Iteration** | You apply changes manually | Agent applies changes and re-checks |
| **Error handling** | You paste errors back manually | Agent reads build output and self-corrects |
| **Memory** | Stateless between chat sessions | Maintains project context across steps |

A chatbot is great for questions. An agent is great for getting things built. In this workshop, you'll be working with agents.

### Agent settings

Before starting a task, check how the agent is configured. The names vary between products, but three settings have a particularly large effect:

- **Mode:** use a planning or read-only mode when you want the agent to investigate, explain, or propose an approach without changing files. Switch to an execution or agent mode when you are ready for it to edit files and run commands.
- **Model:** switch models according to the task. A fast model is useful for small, well-defined edits, while a stronger reasoning model is better for architecture, debugging, and changes that span several files.
- **Permissions:** review which actions require approval, especially terminal commands, network access, and changes outside the project. More autonomy can speed up a well-scoped task, but you should keep sensitive or destructive actions behind explicit approval.

In this workshop, we'll use Cursor with the **GPT-5.6 Sol** model as the primary example, but the concepts apply to other agents and models too.

### Tools

Getting the most out of an AI agent isn't just about the model. Its tools determine what it can inspect and do:

- **Built-in tools:** let the agent read and edit files, search the codebase, run terminal commands, and inspect build output.
- **MCP servers:** connect the agent to external systems and live information through the Model Context Protocol. An MCP server can provide tools for searching documentation, querying a service, or retrieving data that is not in the local project.
- **Project rules:** files such as `AGENTS.md` provide standing instructions about the project, coding conventions, validation commands, and safety constraints.
- **Skills:** reusable instruction packages for specific tasks, such as reviewing code, creating a component, or running validation. In a broad sense, skills are part of the agent's toolkit, but unlike executable tools, they primarily teach the agent how to perform a workflow consistently.

Models, tools, rules, and skills complement one another. The model reasons about the task, tools let it act, rules provide persistent project context, and skills guide repeatable workflows.

## Next step

Now that you know the general concepts, set up the coding agent you'll use during the workshop.

[Assignment 1: Set up your AI coding agent](../assignment-1)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
