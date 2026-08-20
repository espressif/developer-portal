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

You will need ESP-IDF installed.

> [!NOTE]
> If you already have ESP-IDF v6.0.2 or later installed, skip to Step 2.

The recommended way to install ESP-IDF is with [EIM](https://docs.espressif.com/projects/idf-im-ui/en/latest/) (ESP-IDF Installation Manager), a cross-platform tool that handles prerequisites, ESP-IDF itself, and the required build tools.

**1. Install EIM**

If you prefer to download the installer directly instead of using a package manager, visit **[dl.espressif.com/dl/eim](https://dl.espressif.com/dl/eim/)** for online and offline installer packages for all platforms.

{{< tabs group="os" >}}
  {{< tab label="macOS" >}}

**CLI** — install with Homebrew:

```bash
brew tap espressif/eim
brew install eim
```

**GUI** — install the desktop application with Homebrew:

```bash
brew tap espressif/eim
brew install --cask eim-gui
```

  {{< /tab >}}
  {{< tab label="Linux" >}}

**CLI** — install via the Espressif APT repository:

```bash
echo "deb [trusted=yes] https://dl.espressif.com/dl/eim/apt/ stable main" | sudo tee /etc/apt/sources.list.d/espressif.list
sudo apt update
sudo apt install eim-cli
```

**GUI** — install the full package (includes the CLI):

```bash
echo "deb [trusted=yes] https://dl.espressif.com/dl/eim/apt/ stable main" | sudo tee /etc/apt/sources.list.d/espressif.list
sudo apt update
sudo apt install eim
```

  {{< /tab >}}
  {{< tab label="Windows" >}}

**CLI** — open Windows Terminal with a PowerShell or Command Prompt profile and run:

```powershell
winget install Espressif.EIM-CLI
```

`winget` works in both PowerShell and Command Prompt profiles.

**GUI** — download the Windows installer from the EIM download page and run the setup wizard:

[Download EIM for Windows](https://dl.espressif.com/dl/eim/)

  {{< /tab >}}
{{< /tabs >}}

**2. Install ESP-IDF v6.0.2**

For this installation, use the CLI.

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
> If `eim` is not found after installation, check that the EIM binary is on your PATH. Once it is available, run `eim --help` to verify the installation.

### Step 2: Install Cursor IDE (or VS Code with Copilot)

Now it's time to install an agent. We will cover Cursor and Copilot, but you can use another agent for this workshop.

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
2. Install the **ESP-IDF** extension and configure it as described in [Assignment 1 of the ESP-IDF and ESP32-C6 Workshop](../../esp-idf-with-esp32-c6/assignment-1).
3. Install the **GitHub Copilot** and **GitHub Copilot Chat** extensions.
4. Sign in with your GitHub account and verify Copilot is active.
  {{< /tab >}}
{{< /tabs >}}

### Step 3: Install the Espressif Documentation MCP server

The [Espressif Documentation MCP Server](https://mcp.espressif.com/docs) connects your AI agent directly to official, up-to-date Espressif documentation. With it installed, the agent can look up ESP-IDF APIs, hardware design guidelines, datasheets, and more without leaving your IDE or relying on potentially outdated training data.

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

**ESP-IDF**

```sh
npx skills add pedrominatel/awesome-esp-ai@esp-idf
```

**ESP-IDF Components**

```sh
npx skills add pedrominatel/awesome-esp-ai@esp-idf-components
```

> [!TIP]
> The specific SKILLs for this workshop will be provided during the session.

### Step 5: Add AGENTS.md to your project

`AGENTS.md` is a file you commit to your project that gives the agent its standing instructions. Every time you open a session, the agent reads it automatically, so you don't have to repeat the target SoC, ESP-IDF version, or coding conventions in every prompt.

Create `AGENTS.md` in your project root with at least the following:

```markdown
# ESP-IDF Agent Instructions

This file is a reusable baseline for coding agents working in ESP-IDF application
and component repositories. Follow more specific instructions in the target
repository when they override this baseline.

## Discover the Project First

- Locate the ESP-IDF project root before running commands. A project root normally
  contains a top-level `CMakeLists.txt` with a `project(...)` call.
- In repositories with multiple applications or test apps, identify the affected
  project roots and run commands from each relevant root.
- Read the repository README, CI configuration, top-level `CMakeLists.txt`,
  `sdkconfig.defaults*`, component manifests, partition tables, and existing build
  scripts before choosing commands.
- Determine the required ESP-IDF version, supported targets, board assumptions,
  and project-specific validation commands. Prefer repository and CI commands over
  generic commands in this file.
- If no project is present, do not create a scaffold unless the user requested a
  new project or the task clearly requires one.
- When a new project scaffold is required, use
  `idf.py create-project <PROJECT_NAME>` instead of manually generating the
  boilerplate files.

## Environment and Documentation

- Ensure the correct ESP-IDF environment is active before using `idf.py`.
- Prefer EIM CLI for installing and selecting ESP-IDF versions when the repository
  does not prescribe another setup. Use these commands as needed:
  - Verify EIM is available: `eim --version`
  - List installed ESP-IDF versions, their absolute installation paths, and the
    selected version: `eim list`
  - Select an installed version: `eim select <ESP_IDF_VERSION>`
  - Run with the selected version: `eim run "idf.py <command>"`
  - Run with a specific version without changing the selection:
    `eim run "idf.py <command>" <ESP_IDF_VERSION>`
  - Verify a specific ESP-IDF environment before building:
    `eim run "idf.py --version" <ESP_IDF_VERSION>`
  - Install a missing version when authorized:
    `eim install -i <ESP_IDF_VERSION>`
  - Open the interactive installer when requested: `eim wizard`
- Use the installation path reported by `eim list` when a task needs `IDF_PATH`
  or direct access to a matching ESP-IDF checkout. Do not guess installation
  paths.
- If the environment is sourced directly, verify that `idf.py --version` matches
  the version required by the project.
- Prefer `idf.py` workflows over invoking CMake or Ninja directly.
- Use ESP-IDF documentation and migration guides matching the project's version
  and target. Do not rely on `latest` documentation for version-sensitive APIs.

## Standard Commands

- Reconfigure: `idf.py reconfigure`
- Build: `idf.py build`
- Select target: `idf.py set-target <TARGET>`
- Flash: `idf.py -p <PORT> flash`
- Monitor: `idf.py -p <PORT> monitor`
- Flash and monitor: `idf.py -p <PORT> flash monitor`

`idf.py set-target` already clears the build directory, moves the previous
`sdkconfig` to `sdkconfig.old`, and reconfigures the project. Ask the user before
running it because it replaces configuration and build state. Do not run a
redundant `idf.py fullclean` afterward. Use `fullclean` only when stale artifacts
are a demonstrated problem, and ask before deleting build state.

## Configuration and Generated Files

- Treat `sdkconfig` as generated configuration. Do not edit it directly unless the
  user explicitly requests that exact file.
- Store intentional project defaults in `sdkconfig.defaults` and target-specific
  overrides in files such as `sdkconfig.defaults.esp32c6`. Keep changes minimal,
  then ask the user whether to run `idf.py reconfigure`.
- A target-specific defaults file is used only when the base
  `sdkconfig.defaults` file also exists; create an empty base file when no common
  defaults are needed.
- `Kconfig` and `Kconfig.projbuild` define configuration symbols, prompts,
  dependencies, and defaults. They do not store the project's selected values.
- Use component `Kconfig` for component-local options. Use `Kconfig.projbuild`
  only when an option must appear at project scope.
- Namespace new symbols, provide a prompt, a sensible default, and useful help
  text. Put configurable hardware assignments such as GPIOs in Kconfig instead
  of hardcoding them.
- After changing `Kconfig` or `Kconfig.projbuild`, ask the user whether to run
  `idf.py reconfigure` before the next build or validation step.
- `idf.py build` normally detects Kconfig definition changes and invokes CMake
  reconfiguration automatically. An explicit `idf.py reconfigure` remains useful
  for validating configuration separately before a build.
- Changing a Kconfig default does not necessarily replace a value already stored
  in `sdkconfig`. When the project's selected value must change, update the
  appropriate `sdkconfig.defaults*` file and reconfigure with user approval.
- Never edit files under `build/` or `managed_components/`.
- Never edit `dependencies.lock` manually. Allow Component Manager to regenerate
  it, and commit the resulting lock file when the application repository tracks
  managed dependencies for reproducible builds.

## Components and Code Conventions

- Before implementing a dependency, search the ESP Component Registry and inspect
  existing `idf_component.yml` manifests. Prefer adding a suitable managed
  dependency over duplicating it locally.
- Add a managed dependency with
  `idf.py add-dependency "namespace/component^<VERSION>"`. From the project root,
  this updates the `main` component by default. Use `--component=<NAME>` for a
  component under `components/` or `--path=<PATH>` for another component
  directory.
- Prefer `idf.py create-component <name>` when creating a project-local component.
  Keep public headers in `include/`, register sources with
  `idf_component_register(...)`, and declare dependencies explicitly with
  `REQUIRES` or `PRIV_REQUIRES`.
- Keep reusable functionality in components rather than a monolithic application.
  A component intended for publication should be self-contained, documented,
  licensed, versioned, and tested in one or more test applications.
- Keep the firmware entry point as `void app_main(void)`.
- Prefer ESP-IDF APIs and `ESP_LOGI/W/E` for application logging. Handle
  `esp_err_t` results explicitly and avoid long blocking operations without
  yielding where appropriate.

## Validation

- Match validation to the change and follow the repository's CI matrix:
  - documentation-only changes: run relevant documentation checks
  - Kconfig changes: ask whether to run `idf.py reconfigure`
  - manifest or build-system changes: run `idf.py reconfigure`
  - firmware changes: build every affected supported target that is practical
  - component changes: build or test the component's relevant test applications
- Use host-based tests before hardware tests when both cover the behavior.
- Do not flash merely because a serial device is connected. Flash only when the
  user requested it or explicitly authorized hardware validation.
- Before flashing, confirm the port, target, and that the device is safe to
  overwrite. Never assume a port or monitor baud rate.
- When authorized hardware validation is required, use the project's documented
  command, normally `idf.py -p <PORT> flash monitor`, and capture the relevant
  runtime output.
- Report the exact commands, ESP-IDF version, target, and tests run. Summarize
  configuration changes and clearly state anything not validated.

## Safety and Collaboration

- Keep changes narrowly scoped. If unrelated workspace changes appear, stop and
  ask how to proceed.
- Ask before destructive actions such as `fullclean`, deleting files, erasing
  flash, changing eFuses, or broadly regenerating configuration.
- Do not commit build outputs, transient logs, generated binaries, or
  `managed_components/` unless the repository explicitly requires them.
- Never hardcode or commit SSIDs, passwords, API keys, certificates, private
  keys, tokens, or device secrets. Use placeholders, configuration, environment
  variables, or secure provisioning.
- Review partition size and OTA/rollback implications when changes affect
  application size, partition tables, or update behavior.

## Specialized Guidance

When these files are present, use the relevant workflow:

- Firmware development: `skills/esp-idf/SKILL.md`
- Component creation and publication:
  `skills/esp-idf-components/SKILL.md`
- ESP-IDF 5.x to 6.0 migration:
  `skills/esp-idf-v6-migration/SKILL.md`
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
