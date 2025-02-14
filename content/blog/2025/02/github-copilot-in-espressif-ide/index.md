---
title: "GitHub Copilot Now in Espressif-IDE with Copilot4Eclipse"
date: 2025-02-13
showAuthor: false
disableComments: false
tags: ["Espressif-IDE", "GitHub Copilot", "IDE","AI","ESP-IDF"]
authors:
- "kondal-kolipaka"
---

We all love [GitHub Copilot](https://github.com/features/copilot) as a powerful AI-powered coding assistant that enhances productivity. However, until now, it has been officially available only for VS Code and a few other editors. But here’s some good news for Eclipse users! We have tried the [Copilot4Eclipse](https://www.genuitec.com/products/copilot4eclipse/) plugin with the [Espressif-IDE LSP C/C++ Editor](https://docs.espressif.com/projects/espressif-ide/en/latest/additionalfeatures/lspeditor.html#lsp-c-c-editor), and it works amazingly well, helping to write code faster and fix bugs.

## Introducing Copilot4Eclipse

If you've been waiting for GitHub Copilot support in Eclipse, look no further than [Copilot4Eclipse](https://www.genuitec.com/products/copilot4eclipse/) — a fantastic plugin that brings Copilot's AI-assisted code generation to the Eclipse IDE. While the experience may not be identical to VS Code, Copilot4Eclipse offers similar features, making AI-assisted development possible within Eclipse.

## How Copilot4Eclipse Enhances Development

### AI-Powered Code Suggestions

Copilot4Eclipse streamlines development and boosts efficiency by generating entire functions, suggesting code completions, and refactoring snippets. It assists with boilerplate code, ESP32 API calls, and even offers intelligent improvements to your implementation—helping you write better code, faster.

{{< figure default=true src="assets/copilot-with-espressif-ide.webp" >}}

### Seamless Integration with Espressif-IDE

Once you install Copilot4Eclipse in Espressif-IDE, you’ll see the Copilot menu, where you can enable GitHub Copilot suggestions. We tested Copilot4Eclipse with Espressif-IDE on ESP-IDF projects, and it worked flawlessly!

{{< figure default=true src="assets/copilot-menu.webp" >}}

### GitHub Copilot Chat

GitHub Copilot Chat is an AI-powered coding assistant that provides real-time guidance directly within your IDE. It allows developers to choose a file, ask questions, get code explanations, debug errors, and generate code snippets—all through an interactive chat interface.

{{< figure default=true src="assets/copilot-chat.webp" >}}

### Support for Various Languages

Whether you're coding in C or C++, GitHub Copilot’s AI-driven suggestions can help you write better code, faster.

{{< figure default=true src="assets/preferences.webp" >}}

## How to Start Using Copilot4Eclipse

To get started with Copilot4Eclipse, you will need to:

1. **Install the [Copilot4Eclipse](https://www.genuitec.com/products/copilot4eclipse/docs/installation) Plugin** - Download and install the Copilot4Eclipse extension from the [Eclipse Marketplace](https://marketplace.eclipse.org/content/copilot4eclipse).
  {{< figure default=true src="assets/copilot-marketplace.webp" >}}
2. **Authenticate with GitHub** - Sign in with your GitHub Copilot subscription to activate AI-powered assistance.
3. **Start Coding with AI Support** - As you write code, Copilot4Eclipse provides intelligent suggestions, making coding easier and more productive.

## Conclusion

If you are working with Espressif-IDE or considering it for your development environment, the Copilot4Eclipse plugin can significantly enhance your productivity, help you write better code, generate boilerplate code for ESP-IDF, and assist in fixing bugs.

Give it a try and let us know how it goes!