---
title: "AI agent coding for ESP-IDF workshop - Bonus: Debugging and refactoring with AI"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
showTableOfContents: false
series: ["WS003EN"]
series_order: 9
showAuthor: false
---

## Bonus: Debugging and refactoring with AI

{{< alert icon="circle-info" >}}
This is an optional assignment. If you've finished the main workshop content, this is a great way to practice two more high-value AI agent workflows: diagnosing bugs and improving code structure.
{{< /alert >}}

---

In this assignment, you will practice using an AI agent to identify and fix bugs in firmware code, and then to refactor the existing code to improve its structure. Both workflows build directly on the `led-blink` project and the `led_blink` component from assignments 2 and 3.

### Part A: Debugging with AI

#### Step 1: Introduce a bug

To practice the debugging workflow, intentionally introduce a bug into the `led_blink` component from assignment 3. A few options:

- Remove the `gpio_config_t` initialisation from `led_blink_init`, so the GPIO is never configured.
- Pass an invalid GPIO number to `gpio_set_level`.
- Remove the `vTaskDelay` call from the blink task so the task starves the scheduler.

Build the project and note the resulting error or unexpected runtime behaviour.

#### Step 2: Let the agent find and fix the error

Instead of copying and pasting the error output manually, let the agent run the build itself and read the output directly. Open the agent chat and send:

```
Run idf.py build, read the output, identify the root cause of any errors in the led_blink component, and fix them.
```

The agent will trigger the build, read the error or panic output from the terminal, trace it back to the source, and propose a fix — all without you having to copy anything. This is the closed-loop workflow from Lecture 1 in practice.

{{< alert icon="circle-info" >}}
If the agent doesn't have terminal access enabled, you can still share the output by pasting `build.log` or the serial monitor output into the chat. But giving the agent direct terminal access is faster and removes a manual step.
{{< /alert >}}

#### Step 3: Understand the fix

Before accepting the proposed change, ask the agent to explain it:

```
Why does this fix address the root cause? What would happen without it?
```

Understanding the fix is as important as applying it. If the explanation doesn't make sense, push back with follow-up questions until it does.

Rebuild and flash to confirm the fix resolves the issue:

```bash
idf.py build
idf.py -p <PORT> flash monitor
```

### Part B: Refactoring with AI

#### Step 1: Review the current state

At this point the `led-blink` project has:

- `main/led_blink_main.c` with a minimal `app_main` that calls `led_blink_init` and `led_blink_start`.
- `components/led_blink/` with the full blink logic.

The component works, but let's improve it. The `led_blink_start` function currently creates a FreeRTOS task internally without giving the caller any control over it. There's no way to stop the blink from outside the component, and the task stack size is hardcoded.

#### Step 2: Update the spec

Update `STEP.md` with the refactoring task:

**`STEP.md`**

```markdown
# Step 3: Refactor led_blink component

Read PLAN.md and ARCHITECTURE.md, then refactor the led_blink component:

1. Add `led_blink_stop()` implementation that actually stops the FreeRTOS task.
2. Use a task handle (`TaskHandle_t`) stored as a static variable to allow stopping.
3. Add `CONFIG_LED_BLINK_TASK_STACK_SIZE` to Kconfig (default 2048, range 1024-8192).
4. Add `CONFIG_LED_BLINK_TASK_PRIORITY` to Kconfig (default 5, range 1-24).
5. Use the new Kconfig values in `xTaskCreate`.

## Acceptance criteria

- [ ] `led_blink_stop()` deletes the blink task and sets the task handle to NULL.
- [ ] Calling `led_blink_stop()` followed by `led_blink_start()` restarts blinking correctly.
- [ ] `Kconfig` defines `LED_BLINK_TASK_STACK_SIZE` and `LED_BLINK_TASK_PRIORITY` with defaults and help text.
- [ ] No stack size or priority value is hardcoded in `led_blink.c`.
- [ ] `idf.py build` succeeds with no errors.
```

#### Step 3: Plan and implement

Switch to planning mode first and ask the agent to describe what it would change:

```
Read PLAN.md, ARCHITECTURE.md, and STEP.md, then describe the changes you would make.
```

Review the plan, then switch to agent mode to implement:

```
Read PLAN.md, ARCHITECTURE.md, and STEP.md, then implement accordingly.
```

#### Step 4: Build and test

```bash
idf.py build
idf.py -p <PORT> flash monitor
```

The LED should blink as before. To verify `led_blink_stop` works, temporarily add a call to it in `app_main` after a delay and confirm the LED stops blinking.

## Next step

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)

---

Thank you for completing the AI Agent Coding for ESP-IDF workshop!

We hope the sessions gave you a practical feel for how AI agents fit into embedded development, not as a magic shortcut, but as a genuine tool that saves time when used with intention.

The patterns you practised here — spec files, planning mode, closed-loop builds, reusable skills — work just as well on real projects as they do on workshop exercises. Take them with you.

If you build something useful, share it. Publish your components to the [ESP Component Registry](https://components.espressif.com/), post in the [ESP32 forum](https://esp32.com/), or open a discussion on [GitHub](https://github.com/espressif/developer-portal/discussions). The community grows when people share what they make.

See you at the next one.
