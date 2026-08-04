---
title: "AI Agent Coding for ESP-IDF Workshop - Bonus: Debugging and Refactoring with AI"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
showTableOfContents: false
series: ["WS003EN"]
series_order: 9
showAuthor: false
---

## Bonus: Debugging and Refactoring with AI

{{< alert icon="circle-info" >}}
This is an optional assignment. If you've finished the main workshop content, this is a great way to practice two more high-value AI agent workflows: diagnosing bugs and improving code structure.
{{< /alert >}}

---

In this assignment, you will practice using an AI agent to identify and fix bugs in firmware code, and to refactor existing code to meet better coding standards. This is one of the most practical uses of AI agents in embedded development.

### Part A: Debugging with AI

#### Step 1: Introduce a Bug

To practice the debugging workflow, intentionally introduce a bug into the `led_indicator` component from the previous assignment. For example, remove the `gpio_config_t` initialisation from `led_indicator_init`, or pass an invalid GPIO number.

Build the project and note the resulting error or unexpected runtime behaviour.

#### Step 2: Share the Error with the Agent

Provide the agent with the full context needed to reproduce the issue:

```
I have the following ESP-IDF build error (or runtime panic). Here is the relevant code and the full error output.
Please identify the root cause and provide a fix.

[paste the error or panic output here]
[paste the relevant source code here]
```

{{< alert icon="circle-info" >}}
The more context you give the agent — including the full stack trace, the relevant source files, and what you expected to happen — the more accurate and useful the fix will be.
{{< /alert >}}

#### Step 3: Apply and Verify the Fix

Review the agent's proposed fix before applying it. Ask follow-up questions if the explanation is unclear:

```
Why does this fix address the root cause? What would happen without it?
```

Rebuild and flash to confirm the fix resolves the issue.

### Part B: Refactoring with AI

#### Step 1: Identify Code to Refactor

Open `main/ai-wifi-connect.c` from the previous assignment. It likely contains all logic directly in `app_main`, including the Wi-Fi connection and LED control loop.

#### Step 2: Prompt for Refactoring

Ask the agent to improve the code structure:

```
Refactor app_main.c to:
1. Move the Wi-Fi connection logic into a separate function wifi_connect().
2. Move the LED blink loop into a FreeRTOS task called led_task, created with xTaskCreate.
3. Keep app_main clean: it should only call nvs_flash_init, wifi_connect, and xTaskCreate for led_task.
4. Ensure all functions return esp_err_t and use ESP_ERROR_CHECK where appropriate.
```

#### Step 3: Review the Refactored Code

Check that:

- [ ] `wifi_connect()` is a self-contained function that handles Wi-Fi init, connection, and IP logging.
- [ ] `led_task` is a proper FreeRTOS task function (`void led_task(void *pvParameters)`).
- [ ] `app_main` is concise and readable.
- [ ] No functionality has been lost or broken.

#### Step 4: Build and Test

```bash
idf.py build
idf.py -p <PORT> flash monitor
```

Behaviour should be identical to before the refactor — the LED blinks and the IP address is logged after Wi-Fi connects.

## Next step

[Lecture 3: Tips and Tricks](../lecture-3)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
