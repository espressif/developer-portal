---
title: "AI agent coding for ESP-IDF workshop - Assignment 2: Create a new project"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
showTableOfContents: false
series: ["WS003EN"]
series_order: 6
showAuthor: false
---

## Assignment 2: Create a new project

---

In this assignment, you'll use an AI agent to create a simple LED blink application, the embedded "Hello World". But the goal isn't just to get the code working. You'll try three different ways of prompting the agent and observe how the quality and precision of the output changes with each one.

By the end, you'll have a clear feel for why a good spec saves time.

{{< alert icon="triangle-exclamation" cardColor="#b3e0f2" iconColor="#04a5e5">}}
AI-generated code is **probabilistic** and **non-deterministic**. Even with identical spec files and prompts, the output can vary between runs, agents, and models. What you see in your session may look different from what someone next to you gets. That's expected. The goal of a good spec isn't to guarantee identical output — it's to keep the variation within acceptable bounds and reduce the number of correction cycles.
{{< /alert >}}

### What you will build

A simple ESP-IDF application for **ESP32-C5** that blinks an LED connected to a GPIO pin at a configurable interval.

### Step 1: Create a new project

Create a new ESP-IDF project using the ESP-IDF extension:

1. Open the Command Palette (Ctrl+Shift+P).
2. Select **ESP-IDF: Create Project from Extension Template**.
3. Choose the `hello_world` template as a starting point.
4. Name the project `led-blink` and select a location.
5. Open the project folder in your IDE.

---

### Approach 1: The simple prompt

Start with the most natural thing you might type. Open the AI chat panel and enter:

```
Create a LED blink project for ESP-IDF.
```

Hit send and watch what happens.

The agent will likely ask several clarifying questions before writing a single line of code: which chip? which GPIO? which IDF version? what blink rate? should it use a FreeRTOS task or a simple loop? The more it has to guess, the more it asks, or worse, it makes assumptions that don't match your setup.

This isn't a failure. It's a signal that the prompt didn't give the agent enough to work with.

---

### Approach 2: The detailed prompt

Now give the agent the context it needs. Open a new chat and enter:

```
Using ESP-IDF v6.0.2 for ESP32-C5, modify the hello_world project to create a LED blink application called "led-blink":

1. Blink the LED connected to GPIO 8 at a 500 ms interval.
2. Define the GPIO pin number as CONFIG_LED_BLINK_GPIO (Kconfig.projbuild, default 8, range 0–48).
3. Define the blink interval as CONFIG_LED_BLINK_PERIOD_MS (Kconfig.projbuild, default 500, range 100–5000).
4. Use a simple toggle loop in app_main with vTaskDelay. No separate FreeRTOS task needed.
5. Use ESP_LOGI with tag "app" for log output.

Follow the project rules in AGENTS.md.
```

The agent will start writing immediately. The output will be more complete, better structured, and much closer to what you actually want on the first try. Notice how few (if any) follow-up questions it asks compared to Approach 1.

Review the generated files before accepting:

- [ ] `main/led_blink.c` contains `app_main` with a GPIO toggle loop.
- [ ] `Kconfig.projbuild` defines `LED_BLINK_GPIO` and `LED_BLINK_PERIOD_MS` with defaults and help text.
- [ ] `main/CMakeLists.txt` registers `led_blink.c` as the source file.

---

### Approach 3: Spec files

The most reliable approach is to write the spec as Markdown files before touching the agent at all. This keeps the spec in version control, makes it easy to update, and gives the agent a stable reference across sessions.

Create the following three files in your project root:

**`PLAN.md`**

```markdown
# LED blink

## Goal
A minimal ESP-IDF application that blinks an LED to verify the environment is working end-to-end.

## Target
- Chip: ESP32-C5
- ESP-IDF: v6.0.2

## Constraints
- GPIO pin must be configurable via Kconfig
- Blink interval must be configurable via Kconfig
- Simple toggle loop in app_main, no separate FreeRTOS task
- Follow all conventions in AGENTS.md
```

**`ARCHITECTURE.md`**

```markdown
# Architecture

## Entry point
void app_main(void):
1. Configure GPIO pin as output.
2. Loop: toggle LED state, delay by CONFIG_LED_BLINK_PERIOD_MS, repeat.

## Configuration (Kconfig.projbuild)
- LED_BLINK_GPIO: GPIO pin number, default 8, range 0–48
- LED_BLINK_PERIOD_MS: blink interval in ms, default 500, range 100–5000

## Files
- main/led_blink.c
- main/CMakeLists.txt
- Kconfig.projbuild
- sdkconfig.defaults
```

**`STEP.md`**

```markdown
# Step 1: Implement the LED blink application

Read PLAN.md and ARCHITECTURE.md, then implement the application exactly as described.
Create all files listed under Architecture > Files.

## Acceptance criteria

Verify the following before considering this step complete:

- [ ] `main/led_blink.c` exists and contains `app_main` with a GPIO toggle loop.
- [ ] `Kconfig.projbuild` defines `LED_BLINK_GPIO` (default 8, range 0–48) and `LED_BLINK_PERIOD_MS` (default 500, range 100–5000), both with help text.
- [ ] `main/CMakeLists.txt` registers `led_blink.c` as the source file.
- [ ] No GPIO pin or interval is hardcoded in the source: both reference `CONFIG_LED_BLINK_GPIO` and `CONFIG_LED_BLINK_PERIOD_MS`.
- [ ] All log output uses `ESP_LOGI` with tag `"app"`.
- [ ] `sdkconfig.defaults` is present and does not override defaults unnecessarily.
- [ ] `idf.py build` succeeds with no errors.
```

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
Notice the difference across all three approaches: the simpler the prompt, the more the agent has to guess. The spec files approach inverts this: you do the thinking up front, and the agent does the implementation.
{{< /alert >}}

---

### Step 2: Build and fix

Whichever approach produced the best result, run the build:

```bash
idf.py set-target esp32c5
idf.py build
```

If the build fails, share the error with the agent:

```
The build failed with the following error. Please fix it:
<paste error here>
```

Repeat until the build succeeds.

Alternatively, let the agent handle the build and fix cycle on its own:

```
Run idf.py build, read the output, fix any errors, and repeat until the build succeeds.
```

If the build fails because `idf.py` is not found or the environment is not set up, ask the agent to export it first:

```
Export the ESP-IDF environment from <path to your ESP-IDF installation>, then run idf.py build.
```

Replace `<path to your ESP-IDF installation>` with the actual path, for example `~/esp/v6.0.2/esp-idf`. The agent will source the export script and retry the build.

### Step 3: Flash and verify

```bash
idf.py -p <PORT> flash monitor
```

You should see the LED blinking and log output similar to:

```
I (123) app: LED ON
I (623) app: LED OFF
```

If the LED doesn't match your hardware's GPIO, adjust `CONFIG_LED_BLINK_GPIO` via `menuconfig` or `sdkconfig.defaults`.

## Next step

[Assignment 3: Create a component](../assignment-3)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
