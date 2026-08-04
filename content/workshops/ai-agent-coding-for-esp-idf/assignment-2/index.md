---
title: "AI Agent Coding for ESP-IDF Workshop - Assignment 2: Your First AI-Generated ESP-IDF Project"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
showTableOfContents: false
series: ["WS003EN"]
series_order: 6
showAuthor: false
---

## Assignment 2: Your First AI-Generated ESP-IDF Project

---

In this assignment, you will use an AI agent to scaffold and build a basic ESP-IDF project from a natural language description. You will learn how to write effective prompts and evaluate the generated output before running a build.

### What you will build

A simple ESP-IDF application that:

- Initialises the NVS flash storage.
- Connects to a Wi-Fi network using credentials stored in `sdkconfig.defaults`.
- Logs the assigned IP address to the serial console.

### Step 1: Create a New Project

Create a new ESP-IDF project using the ESP-IDF extension:

1. Open the Command Palette (Ctrl+Shift+P).
2. Select **ESP-IDF: Create Project from Extension Template**.
3. Choose the `hello_world` template as a starting point.
4. Name the project `ai-wifi-connect` and select a location.

### Step 2: Write Your First Agent Prompt

Open the AI chat panel and enter the following prompt:

```
Using ESP-IDF v6.0.2 for ESP32-C5, modify the hello_world project to:
1. Initialize NVS flash.
2. Connect to Wi-Fi using SSID and password defined as CONFIG_WIFI_SSID and CONFIG_WIFI_PASSWORD in Kconfig.projbuild.
3. Log the device IP address once connected.
4. Use ESP_LOGI for all log output with the tag "app".
Follow the project rules in AGENTS.md.
```

Review the files the agent proposes to create or modify before accepting the changes.

### Step 3: Evaluate the Output

Check the following before building:

- [ ] `main/ai-wifi-connect.c` contains `app_main` and calls `nvs_flash_init()`.
- [ ] `Kconfig.projbuild` defines `CONFIG_WIFI_SSID` and `CONFIG_WIFI_PASSWORD` with help text and defaults.
- [ ] `sdkconfig.defaults` does **not** contain plain-text credentials.
- [ ] `CMakeLists.txt` in `main/` references the correct source file.

{{< alert icon="triangle-exclamation" >}}
Never commit real Wi-Fi credentials to version control. Always use placeholder defaults in `Kconfig.projbuild` (e.g. `default "your_ssid_here"`) and override them locally via `menuconfig` or a private `sdkconfig.defaults.local` file that is listed in `.gitignore`.
{{< /alert >}}

### Step 4: Build and Fix

Run the build:

```bash
idf.py build
```

If the build fails, copy the error output and paste it into the agent chat:

```
The build failed with the following error. Please fix it:
<paste error here>
```

Repeat until the build succeeds.

### Step 5: Flash and Verify

Set your target and flash:

```bash
idf.py set-target esp32c6
idf.py -p <PORT> flash monitor
```

You should see the device connect to Wi-Fi and print its IP address.

## Next step

[Assignment 3: AI-Assisted Component Development](../assignment-3)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
