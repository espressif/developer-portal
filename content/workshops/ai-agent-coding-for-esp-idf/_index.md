---
title: "AI agent coding for ESP-IDF workshop"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
tags: ["Workshop", "ESP-IDF", "AI", "Agents", "Cursor", "Coding Assistant"]
summary: "A hands-on workshop that teaches developers how to use AI coding agents to accelerate ESP-IDF firmware development, from environment setup and project scaffolding to component creation, debugging, and refactoring."

---

Welcome to the AI Agent Coding for ESP-IDF workshop!

## About this workshop

This hands-on workshop teaches you how to use AI coding agents throughout the ESP-IDF development workflow. You will set up ESP-IDF with EIM, configure an agent in Cursor or VS Code, connect it to Espressif documentation through MCP, and give it persistent project instructions and reusable skills.

You will learn the ESP-IDF concepts needed to guide an agent effectively, including the project build system and `CMakeLists.txt` files, components, BSPs, Kconfig, `sdkconfig`, `idf.py`, `esptool`, error handling, and logging. You will then apply a spec-driven workflow to create a project, build a reusable component, and validate the generated firmware through build, flash, monitor, debugging, and refactoring cycles.

## Prerequisites

To follow this workshop, you will need both hardware and software.

Required hardware:

- Computer running Linux, Windows, or macOS
- An ESP32 series development board (e.g. ESP32-C5-DevKitC, ESP32-H2-DevKitM, or similar)
- USB cable that supports power and data and is compatible with the development kit above

Required software:

- [Visual Studio Code](https://code.visualstudio.com/download) or [Cursor IDE](https://www.cursor.com/)
- [ESP-IDF plugin for VS Code](https://github.com/espressif/vscode-esp-idf-extension?tab=readme-ov-file#how-to-use)
- [ESP-IDF](https://github.com/espressif/esp-idf) v6.0.2 or later
- An account on an AI coding platform (e.g. [Cursor](https://www.cursor.com/), [GitHub Copilot](https://github.com/features/copilot), [OpenAI Codex](https://platform.openai.com/), or similar)

## Agenda

If you have met the [prerequisites](#prerequisites), you can start with the individual chapters:

- [Introduction: AI agent coding overview](introduction/): An overview of AI-assisted coding concepts, available tools and agents, and how they integrate with the ESP-IDF development workflow.
- [Assignment 1: Set up your AI agent coding environment](assignment-1/): Install and configure the tools needed to start coding with AI agent assistance, including ESP-IDF, your IDE, MCP servers, and SKILLs.
- [Lecture 1: The new workflow for embedded development](lecture-1/): How AI agents change the embedded development loop and what that means for your day-to-day workflow.
- [Lecture 2: What you should know about ESP-IDF to work effectively with AI Agents](lecture-2/): The ESP-IDF concepts and conventions that help you guide an agent effectively.
- [Lecture 3: Spec-driven development](lecture-3/): How to write a clear spec before prompting the agent, and why it produces better results.
- [Assignment 2: Create a new project](assignment-2/): Use an AI agent to scaffold and build a basic ESP-IDF project from a natural language description.
- [Assignment 3: Create a component](assignment-3/): Write and refine a custom ESP-IDF component with AI agent support.
- [Lecture 4: Tools and tricks for agent development with ESP-IDF](lecture-4/): Techniques for scaling up, keeping the agent on track, and knowing when not to use it.
- **Bonus: [Assignment 4: Debugging and refactoring with AI](assignment-4/):** Use AI agents to identify issues, suggest fixes, and refactor existing firmware code.

## Time requirements

{{< alert icon="mug-hot" >}}
**Estimated time: 180 min**
{{< /alert >}}


## Feedback

If you have any feedback about the workshop, feel free to start a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).


## Conclusion

We hope this workshop has given you the practical skills to integrate AI agents into your ESP-IDF development workflow. Thank you for participating, and we look forward to seeing what you build!

## Next step

[Introduction: AI agent coding overview](introduction/)

---
