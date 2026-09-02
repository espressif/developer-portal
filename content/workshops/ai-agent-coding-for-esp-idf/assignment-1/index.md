---
title: "AI agent coding for ESP-IDF workshop - Assignment 1: Set up your AI coding agent"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-08-28
showTableOfContents: true
series: ["WS003EN"]
series_order: 2
showAuthor: false
---

## Assignment steps

In this assignment, you will install an AI coding agent and connect it to the Espressif Documentation MCP server. By the end, your agent will be able to access current Espressif documentation directly from your development environment.

### Before you begin

This workshop assumes that the ESP-IDF toolchain and extension are already configured. If they are not, complete the [ESP-IDF workshop preliminary setup](/workshops/esp-idf-setup/) before continuing.

> [!NOTE]
> This workshop uses **ESP-IDF v6.0.2**. Select this version when following the preliminary setup so that the examples and prompts behave as expected.

### Step 1: Install Cursor IDE or VS Code with Copilot

We will cover Cursor and GitHub Copilot, but you can use another coding agent for this workshop.

{{< tabs group="ide" >}}
  {{< tab label="Cursor" >}}
1. Download and install [Cursor](https://www.cursor.com/) for your operating system.
2. Open Cursor and sign in or create an account.
3. Open the Agent chat, select the model menu, and choose **GPT-5.6 Sol**. This is the model we'll use throughout the workshop.
  {{< /tab >}}
  {{< tab label="VS Code + GitHub Copilot" >}}
1. Download and install [Visual Studio Code](https://code.visualstudio.com/download).
2. Install the **GitHub Copilot** and **GitHub Copilot Chat** extensions.
3. Sign in with your GitHub account and verify that Copilot is active.
  {{< /tab >}}
{{< /tabs >}}

### Step 2: Install the Espressif Documentation MCP server

The [Espressif Documentation MCP Server](https://mcp.espressif.com/#espressif-documentation) connects your AI agent directly to official, up-to-date Espressif documentation. The agent can use it to look up ESP-IDF APIs, hardware design guidelines, datasheets, and more without relying only on its training data.

You need a GitHub or WeChat account to authenticate with the server.

{{< tabs group="ide" >}}
  {{< tab label="Cursor" >}}
1. Open the [Espressif Documentation chatbot](https://chat.espressif.com) and click **MCP Server** in the upper-right corner of the widget.
2. Click **Add to Cursor**. Allow the browser to open Cursor when prompted.
3. In Cursor, click **Install** under "Install MCP Server?".
4. Click **Connect** and sign in with GitHub or WeChat to authenticate.

If clicking **Add to Cursor** does nothing, add the server manually. Create or edit `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "espressif-docs": {
      "url": "https://mcp.espressif.com/docs"
    }
  }
}
```

Save the file, restart Cursor, and authenticate via **Settings > Tools & MCP**.
  {{< /tab >}}
  {{< tab label="VS Code + GitHub Copilot" >}}
1. Open the [Espressif Documentation chatbot](https://chat.espressif.com) and click **MCP Server** in the upper-right corner of the widget.
2. Click **Add to VS Code**. Allow the browser to open VS Code when prompted.
3. Click **Install** on the MCP installation page.
4. Sign in with GitHub or WeChat to authenticate. The server will appear under **Extensions > MCP SERVERS – INSTALLED**.

If clicking **Add to VS Code** does nothing, add the server manually. Create or edit `~/.vscode/mcp.json`:

```json
{
  "servers": {
    "espressif-docs": {
      "url": "https://mcp.espressif.com/docs"
    }
  }
}
```

Save the file and click **Start** above the entry to open the authentication page.
  {{< /tab >}}
{{< /tabs >}}

Confirm that the Espressif Documentation server appears with a connected status in your IDE's MCP settings. In Cursor, you can also check from the Agent chat:

```text
/mcp list
```

If the server is not connected, restart the IDE or re-authenticate from its MCP settings.

## Next step

Now that your coding agent can access current Espressif documentation, learn how agents apply to ESP-IDF development.

[AI agents and ESP-IDF](../ai-agents-and-esp-idf)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
