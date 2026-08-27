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

The idea is simple: instead of spending time writing boilerplate, hunting through documentation, or manually chasing build errors, you describe what you want and let an AI agent do the heavy lifting. That frees you up to focus on the things that actually need your attention, like design decisions, hardware validation, and making sure the firmware does what it's supposed to do.

For ESP-IDF development specifically, this works really well. The project structure is consistent, the APIs are documented, and the build system gives clear feedback. All of that gives an AI agent enough context to be genuinely useful.

### What is an AI coding agent?

An AI coding agent is more than a smarter autocomplete. It's a tool that combines a large language model (LLM) with access to your actual development environment: your files, your terminal, your build output, and your project context.

Instead of just suggesting code for you to copy and paste, an agent can open files, make changes, run a build, read the error output, fix the issue, and try again, all on its own. You review the result and decide whether to keep the changes.

That's a very different experience from a chatbot.

Some of the most popular AI coding agents right now include:

- [Cursor](https://www.cursor.com/): an IDE built around AI agents, with deep codebase awareness and support for custom rules and skills.
- [GitHub Copilot](https://github.com/features/copilot): available inside VS Code and other editors, with an agent mode that can make multi-file changes and run terminal commands.
- [OpenAI Codex](https://platform.openai.com/docs/guides/codex): a coding agent from OpenAI, accessible via the CLI or IDE plugin/extension.

Agents can be used directly from the IDE, where they have access to your open files and project context, or from the CLI, where you can run them as part of a script or automated workflow. Both IDE and CLI modes are useful: the IDE is great for interactive development, while the CLI fits well into build pipelines and batch tasks.

In this workshop, we'll use Cursor with the **GPT-5.6 Sol** model as the primary example, but the concepts apply to other agents and models too.

### Agent vs chatbot

Both use a chat interface, so it's easy to mix them up. Here's the practical difference:

| | Chatbot | AI Coding Agent |
|---|---|---|
| **Context** | What you paste into the chat | Your entire project, open files, and terminal |
| **Actions** | Generates text suggestions | Reads, writes, and runs code |
| **Iteration** | You apply changes manually | Agent applies changes and re-checks |
| **Error handling** | You paste errors back manually | Agent reads build output and self-corrects |
| **Memory** | Stateless between chat sessions | Maintains project context across steps |

For Espressif-specific questions, try the free [Espressif ChatBot](https://chat.espressif.com/). Its main advantage is access to the latest information from across Espressif's documentation and platforms.

A chatbot is great for questions. An agent is great for getting things built. In this workshop, you'll be working with agents.

### AI agents and ESP-IDF

Here are some of the things you can ask an AI agent to do in an ESP-IDF project:

- **Create a project scaffold:** generate the full directory structure, `CMakeLists.txt`, `Kconfig`, and the app entry point.
- **Write a function:** describe the behaviour you need and let the agent pick the right ESP-IDF APIs and wire everything up.
- **Create a component:** get a complete component with public header, source file, and build config in one shot.
- **Review a code:** ask the agent to check for missing error handling, incorrect API usage, or anything that doesn't follow the project conventions.
- **Refactor a code:** break up a monolithic `app_main`, extract reusable functions, or reorganise a component without changing behaviour.
- **Port a code from other platforms:** bring in Arduino code and have the agent rewrite it using ESP-IDF APIs.
- **Migrate a code from older ESP-IDF versions:** find deprecated APIs and update them to the current equivalents.
- **Generate a documentation:** add Doxygen comments, write a README, or produce usage examples straight from the source code.

You'll get hands-on practice with most of these during the assignments.

### Tools

Getting the most out of an AI agent isn't just about the model. The tools and context you give it make a big difference. Here are the most important ones for ESP-IDF work:

- **MCP Servers:** these connect the agent to live external sources. The [Espressif Documentation MCP Server](https://mcp.espressif.com/#espressif-documentation) gives it access to up-to-date ESP-IDF API docs, and the [ESP Component Registry MCP Server](https://mcp.espressif.com/#esp-component-registry) lets it search for and fetch components directly.

Together, these tools make the agent much more reliable, especially for a fast-moving ecosystem like ESP-IDF where training data can go stale quickly.

### Workflow for embedded development

The classic embedded dev loop goes like this:

> Every step is manual. Errors mean going back to the start, and it's easy to spend more time on the loop than on the actual problem.

With an AI agent in the mix, it looks more like this:

> The agent takes care of the mechanical parts. You focus on describing the intent, reviewing the output, and verifying the result on hardware. The number of back-and-forth cycles drops a lot, especially for tasks with a clear structure.

We'll look at this in more detail in Lecture 1.

### Spec-driven development

Here's something that will save you a lot of time: write a clear spec before you prompt the agent.

A vague prompt like this:

> *"Write me a temperature sensor driver."*

...gives the agent very little to work with. When a prompt is too vague, the agent will either make assumptions that don't match your expectations or start asking a lot of clarifying questions before writing a single line of code. Both situations slow you down. The more context you give upfront, the less back-and-forth you'll have.

A spec-driven prompt like this gives the agent a real contract to implement:

> *"Create a component called `temperature_sensor` for ESP32-C5 using ESP-IDF v6.0.2. The public API should be: `esp_err_t temperature_sensor_init(void)`, `esp_err_t temperature_sensor_read(float *out_celsius)`, `esp_err_t temperature_sensor_deinit(void)`. Use `CONFIG_TEMPERATURE_SENSOR_SAMPLE_PERIOD_MS` (Kconfig, default 1000 ms) for the sampling interval. Use the ESP-IDF internal temperature sensor driver. Follow the project rules in AGENTS.md."*

The output will be predictable, easier to review, and much closer to what you actually wanted on the first try.

Taking this further, instead of writing the spec directly in the chat, you can write it as Markdown files committed to your project. Three files are particularly useful:

- **`ARCHITECTURE.md`:** how the system is structured. Components, their responsibilities, and how they interact. Recommended location: `docs/ARCHITECTURE.md`.
- **`PLAN.md`:** what you want to build and why. High-level goals, constraints, and open questions. Recommended location: `docs/PLAN.md`.
- **`STEP.md`:** the current task. A single, focused description of what the agent should do next. Recommended location: `docs/STEP.md`.

Once these files are in place, you can open the agent and say:

> *"Read docs/PLAN.md, docs/ARCHITECTURE.md, and docs/STEP.md, then implement accordingly."*

The agent has full context, and you can update `docs/STEP.md` for each new task without repeating yourself.

Taking a few minutes to plan before prompting is not extra work. It's the fastest way to get a good result. We'll go deeper on this in Lecture 3.

## Next step

Now that you know the basic concepts, let's get your hands dirty. First, you'll set up the environment.

[Assignment 1: Set up your AI agent coding environment](../assignment-1)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
