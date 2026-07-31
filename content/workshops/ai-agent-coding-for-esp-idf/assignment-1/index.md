---
title: "AI Agent Coding for ESP-IDF Workshop - Assignment 1: Set Up Your AI Agent Coding Environment"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
showTableOfContents: false
series: ["WS003EN"]
series_order: 2
showAuthor: false
---

## Assignment 1: Set Up Your AI Agent Coding Environment

---

In this assignment, you will install and configure all the tools needed for AI-assisted ESP-IDF development. By the end, your environment will be ready to accept natural language instructions and produce buildable firmware.

### Step 1: Install ESP-IDF

> If you already have ESP-IDF v6.0.2 or later installed, skip to Step 2.

The recommended way to install ESP-IDF is with [EIM](https://github.com/espressif/idf-im-cli) (ESP-IDF Installation Manager), a CLI tool that handles downloading, installing, and switching between ESP-IDF versions.

{{< tabs group="os" >}}
  {{< tab label="macOS" >}}
```bash
brew tap espressif/eim && brew install eim
```
  {{< /tab >}}
  {{< tab label="Linux (Debian/Ubuntu)" >}}
```bash
sudo apt install eim-cli
```
  {{< /tab >}}
  {{< tab label="Windows" >}}
Run the following in PowerShell or Command Prompt:

```bash
winget install Espressif.EIM-CLI
```

`winget` is pre-installed on Windows 11 and Windows 10 (version 1809 or later). If the command is not recognised, open the **Microsoft Store**, search for **App Installer**, and install or update it. Alternatively, download the EIM installer directly from the [EIM releases page](https://github.com/espressif/idf-im-cli/releases).
  {{< /tab >}}
{{< /tabs >}}

Once EIM is installed, install ESP-IDF v6.0.2:

```bash
eim install -i v6.0.2
```

To verify the installation and activate the environment:

```bash
eim list
eim select v6.0.2
```

{{< alert icon="circle-info" >}}
If `eim` is not found after installation, run `eim --help` to confirm the install completed and check that the EIM binary is on your PATH.
{{< /alert >}}

### Step 2: Install Cursor IDE (or VS Code with Copilot)

{{< tabs group="ide" >}}
  {{< tab label="Cursor" >}}
1. Download and install [Cursor](https://www.cursor.com/) for your operating system.
2. Open Cursor and sign in or create an account.
3. Install the **ESP-IDF** extension from the Extensions panel (Ctrl+Shift+X).
4. Run **ESP-IDF: Configure ESP-IDF Extension** from the Command Palette (Ctrl+Shift+P) and point it to your ESP-IDF installation.
  {{< /tab >}}
  {{< tab label="VS Code + GitHub Copilot" >}}
1. Download and install [Visual Studio Code](https://code.visualstudio.com/download).
2. Install the **ESP-IDF** extension and configure it as described in [Assignment 1 of the ESP-IDF and ESP32-C6 Workshop](../../esp-idf-with-esp32-c6/assignment-1).
3. Install the **GitHub Copilot** and **GitHub Copilot Chat** extensions.
4. Sign in with your GitHub account and verify Copilot is active.
  {{< /tab >}}
{{< /tabs >}}

### Step 3: Install the Espressif Documentation MCP Server

The [Espressif Documentation MCP Server](https://mcp.espressif.com/docs) connects your AI agent directly to official, up-to-date Espressif documentation. With it installed, the agent can look up ESP-IDF APIs, hardware design guidelines, datasheets, and more without leaving your IDE, and without relying on potentially outdated training data.

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

{{< alert icon="circle-info" >}}
To confirm the MCP server is active during a session, watch for the tool call indicator in your agent's response. If you don't see it, add `"refer to Espressif documentation"` to your prompt, or add the following rule to your `AGENTS.md`:

```
Always use the Espressif documentation MCP server when working with ESP chips or ESP-IDF.
```
{{< /alert >}}

### Step 4: Verify the Setup

1. Open your project folder in Cursor or VS Code.
2. Open the AI chat panel and ask: *"What target chip is this project configured for?"*
3. The agent should answer correctly based on your rules file and project configuration.
4. Run a basic build to confirm ESP-IDF is working: `idf.py build`

{{< alert icon="circle-info" >}}
If the agent cannot see your project files, make sure the project folder is opened as a workspace root, not a subfolder.
{{< /alert >}}

You are now ready to start using AI agents for ESP-IDF development.

## Next step

[Lecture 1: The New Workflow for Embedded Development](../lecture-1)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
