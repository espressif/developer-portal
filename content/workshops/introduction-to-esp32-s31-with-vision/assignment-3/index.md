---
title: "Introduction to the ESP32-S31 with Vision: Assignment 3"
date: 2026-09-28
showTableOfContents: true
series: ["ESP32-S31-VISION"]
series_order: 5
showAuthor: false
---

## Assignment 3: Set up the ESP-Vision MCP server

> [!NOTE]
> This assignment is optional. If you are not going to use an AI coding agent, continue directly to [Assignment 4: LED blink with ESP-Vision](../assignment-4).

The Model Context Protocol (MCP) gives an AI coding assistant access to tools and documentation outside its built-in knowledge. See the official [ESP-Vision MCP page](https://mcp.espressif.com/#esp-vision) for service details. In this assignment, you will connect a compatible client to the endpoint `https://mcp.vision.espressif.com`.

The connection helps the assistant verify APIs, chip capabilities, examples, and concepts before generating code.

This workshop uses **Cursor**. You can follow the same workflow with another agent that supports remote MCP servers, such as:

- Visual Studio Code with GitHub Copilot agent mode
- Claude Code
- Claude Desktop
- Another MCP-compatible IDE or coding agent

> [!TIP]
> If you choose Visual Studio Code, you can combine its MCP-capable agent with the ESP-Vision extension from the [ESP-Vision website](https://vision.espressif.com/en). The agent uses the MCP server for documentation, while the extension handles the local board and script workflow.

## ESP-Vision MCP server

The server can:

- Report modules available on `esp32s31`, `esp32p4`, and `esp32s3`
- Check whether a symbol is available for a selected target
- Return authoritative signatures for ESP-Vision and MicroPython APIs
- Find and return runnable examples
- Explain camera, image, inference, and model workflows

This prevents a common failure mode: generating desktop Python code or a board API that is not present in the ESP-Vision firmware.

> [!NOTE]
> The MCP server supplies documentation and examples to the assistant. It does not grant the remote server access to your board. Uploading and running a script still happens through your local ESP-Vision development workflow.

## Configure your agent

Choose the tab for the agent or application you are using.

{{< tabs group="mcp-client" >}}
  {{< tab label="Cursor" >}}

This is the agent used in this workshop.

Create `.cursor/mcp.json` in your project:

```json
{
  "mcpServers": {
    "esp-vision-mcp": {
      "url": "https://mcp.vision.espressif.com"
    }
  }
}
```

Open Cursor settings, navigate to **Tools & MCP**, and confirm that `esp-vision-mcp` is enabled. Reload the window if it does not appear immediately.

For a user-wide configuration, place the same server entry in Cursor's user MCP configuration instead of the project file.

  {{< /tab >}}
  {{< tab label="Visual Studio Code" >}}

Create `.vscode/mcp.json`:

```json
{
  "servers": {
    "esp-vision-mcp": {
      "type": "http",
      "url": "https://mcp.vision.espressif.com"
    }
  }
}
```

Start the server from Visual Studio Code's MCP server list, then open GitHub Copilot Chat in agent mode. If your MCP-capable extension defines a different configuration schema, use its HTTP MCP instructions with the same endpoint.

  {{< /tab >}}
  {{< tab label="Claude Code" >}}

From the workshop project directory, run:

```bash
claude mcp add --transport http esp-vision-mcp \
  https://mcp.vision.espressif.com
```

Verify the registration:

```bash
claude mcp list
```

Use the user scope if you want the server in every project. Consult `claude mcp add --help` because scope flags can vary by Claude Code version.

  {{< /tab >}}
  {{< tab label="Claude Desktop" >}}

1. Open **Settings** in Claude Desktop.
2. Open **Connectors**.
3. Select **Add custom connector**.
4. Set the name to `esp-vision-mcp`.
5. Set the remote MCP URL to `https://mcp.vision.espressif.com`.

6. Enable the connector for the conversation.

The exact labels can vary between Claude Desktop releases. Select the remote HTTP or custom connector option, not a local `stdio` command.

  {{< /tab >}}
  {{< tab label="Other MCP client" >}}

For any client that supports remote MCP servers, use:

| Setting | Value |
|---------|-------|
| Name | `esp-vision-mcp` |
| Transport | HTTP or Streamable HTTP |
| URL | `https://mcp.vision.espressif.com` |
| Authentication | None, unless the service documentation states otherwise |

Configuration key names are client-specific. Do not select the `stdio` transport: that transport expects a local executable, not a remote URL.

  {{< /tab >}}
{{< /tabs >}}

## Test the integration

Ask your assistant:

```text
Use the ESP-Vision MCP server to list the modules supported by esp32s31.
Do not answer from memory.
```

The answer should include `sensor`, `image`, `display`, `espdl`, `tflite`, and `imageio`.

Then ask:

```text
Check the ESP-Vision APIs available on esp32s31 and write a bounded camera
test. Print VISION_TEST:OK only after a frame has been captured.
```

Review the result:

- It should import `sensor`, not a desktop camera package.
- It should call `sensor.reset()` before capture.
- It should use a supported frame size and pixel format.
- It should call `sensor.shutdown()` during cleanup.
- It should not use `pip`, `requirements.txt`, `subprocess`, or a PC filesystem path.

If the response contains unsupported code, explicitly ask the assistant to check each symbol with the MCP server and regenerate the script.

## Complete working configuration

<details><summary>Show the complete MCP configurations</summary>

**Cursor — `.cursor/mcp.json`:**

```json
{
  "mcpServers": {
    "esp-vision-mcp": {
      "url": "https://mcp.vision.espressif.com"
    }
  }
}
```

**Visual Studio Code — `.vscode/mcp.json`:**

```json
{
  "servers": {
    "esp-vision-mcp": {
      "type": "http",
      "url": "https://mcp.vision.espressif.com"
    }
  }
}
```

**Claude Code:**

```bash
claude mcp add --transport http esp-vision-mcp \
  https://mcp.vision.espressif.com
```

</details>

## What you learned

In this assignment, you:

- Connected Cursor, Visual Studio Code, Claude Code, or another client to the ESP-Vision MCP server
- Learned what information the MCP server provides
- Verified ESP32-S31 modules and APIs through tools rather than model memory
- Recognized desktop Python patterns that do not work in device-side MicroPython

## Next step

[Assignment 4: LED blink with ESP-Vision](../assignment-4)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-with-vision/)
