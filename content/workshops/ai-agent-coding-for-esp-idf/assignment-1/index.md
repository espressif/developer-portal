---
title: "AI agent coding for ESP-IDF workshop - Assignment 1: Set up your AI agent coding environment"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
showTableOfContents: false
series: ["WS003EN"]
series_order: 2
showAuthor: false
---

## Assignment 1: Set up your AI agent coding environment

---

In this assignment, you will install and configure all the tools needed for AI-assisted ESP-IDF development. By the end, your environment will be ready to accept natural language instructions and produce buildable firmware.

### Step 1: Install ESP-IDF

We will need the ESP-IDF installed.

> [!NOTE]
> If you already have ESP-IDF v6.0.2 or later installed, skip to Step 2.

The recommended way to install ESP-IDF is with [EIM](https://docs.espressif.com/projects/idf-im-ui/en/latest/) (ESP-IDF Installation Manager), a cross-platform tool that handles prerequisites, ESP-IDF itself, and the required build tools.

**1. Install EIM**

If you prefer to download the installer directly instead of using a package manager, visit **[dl.espressif.com/dl/eim](https://dl.espressif.com/dl/eim/)** for online and offline installer packages for all platforms.

{{< tabs group="os" >}}
  {{< tab label="macOS" >}}
```bash
brew tap espressif/eim
brew install eim
```
  {{< /tab >}}
  {{< tab label="Linux (Debian/Ubuntu)" >}}
Add the Espressif APT repository, then install:

```bash
echo "deb [trusted=yes] https://dl.espressif.com/dl/eim/apt/ stable main" | sudo tee /etc/apt/sources.list.d/espressif.list
sudo apt update
sudo apt install eim-cli
```
  {{< /tab >}}
  {{< tab label="Linux (Fedora/RHEL)" >}}
Add the Espressif DNF repository, then install:

```bash
sudo tee /etc/yum.repos.d/espressif-eim.repo << 'EOF'
[eim]
name=ESP-IDF Installation Manager
baseurl=https://dl.espressif.com/dl/eim/rpm/$basearch
enabled=1
gpgcheck=0
EOF
sudo dnf install eim-cli
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

**2. Install ESP-IDF v6.0.2**

For the installation, we will use the CLI.

> [!NOTE]
> This workshop uses **ESP-IDF v6.0.2**. Install this specific version to ensure all examples and prompts work as expected.


```bash
eim install -i v6.0.2
```

If you'd prefer a guided setup, run `eim wizard` instead and follow the prompts.

To verify the installation and activate the environment:

```bash
eim list
eim select v6.0.2
```

> [!TIP]
> If `eim` is not found after installation, run `eim --help` to confirm the install completed and check that the EIM binary is on your PATH.

### Step 2: Install Cursor IDE (or VS Code with Copilot)

Now it's time to install the Agent. We will cover Cursor and Copilot, but any other Agent can be used on this workshop.

{{< tabs group="ide" >}}
  {{< tab label="Cursor" >}}
1. Download and install [Cursor](https://www.cursor.com/) for your operating system.
2. Open Cursor and sign in or create an account.
3. Install the **ESP-IDF** extension from the Extensions panel (Ctrl+Shift+X).
4. Run **ESP-IDF: Configure ESP-IDF Extension** from the Command Palette (Ctrl+Shift+P) and point it to your ESP-IDF installation.
5. Open the Agent chat, select the model menu, and choose **GPT-5.6 Sol**. This is the model we'll use throughout the workshop.
  {{< /tab >}}
  {{< tab label="VS Code + GitHub Copilot" >}}
1. Download and install [Visual Studio Code](https://code.visualstudio.com/download).
2. Install the **ESP-IDF** extension and configure it as described in [Assignment 1 of the ESP-IDF and ESP32-C5 Workshop](../../esp-idf-with-esp32-c6/assignment-1).
3. Install the **GitHub Copilot** and **GitHub Copilot Chat** extensions.
4. Sign in with your GitHub account and verify Copilot is active.
  {{< /tab >}}
{{< /tabs >}}

### Step 3: Install the Espressif Documentation MCP server

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

Before starting a session with the agent, make sure the MCP server is running. You can check from the Cursor CLI:

```bash
/mcp list
```

You will see:

```bash
 MCP Servers (2 servers)

 Filter:

 User
  → ESP Component Registry - enabled (Enter to view details)
    Espressif Documentation - enabled
```

The Espressif Documentation server should appear in the list with a connected status. If it doesn't, restart your IDE or re-authenticate via **Settings > Tools & MCP**.

### Step 4: Add SKILLs to your project

SKILLs are reusable instruction sets for the agent, recipes it can follow for specific tasks like creating a component, running validation, or generating documentation. You install them into your project so they're always available.

To add the SKILLs for this workshop, run the following command from your project root:

```bash
npx skills add
```

> [!TIP]
> The specific SKILLs for this workshop will be provided during the session.

### Step 5: Add AGENTS.md to your project

`AGENTS.md` is a file you commit to your project that gives the agent its standing instructions. Every time you open a session, the agent reads it automatically, so you don't have to repeat the target SoC, ESP-IDF version, or coding conventions in every prompt.

Create `AGENTS.md` in your project root with at least the following:

```markdown
# AGENTS.md
...
```

Update this file as your project evolves. If you change the target SoC or add new conventions, keep `AGENTS.md` in sync: it's the single source of truth for the agent.

### Step 6: Verify the setup

1. Open your project folder in Cursor or VS Code.
2. Open the AI chat panel and ask:

```
What is the latest release version of the ESP-IDF?
```

3. The agent should answer correctly based on your rules file and project configuration.

You are now ready to start using AI agents for ESP-IDF development.

## Next step

[Lecture 1: The new workflow for embedded development](../lecture-1)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
