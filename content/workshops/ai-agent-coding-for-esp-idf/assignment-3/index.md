---
title: "AI agent coding for ESP-IDF workshop - Assignment 3: Create a component"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
showTableOfContents: false
series: ["WS003EN"]
series_order: 7
showAuthor: false
---

## Assignment 3: Create a component

---

In the previous assignment, the LED blink logic lived directly in `app_main`. That's fine for a quick test, but it's not reusable. If you wanted to use the same LED in a second project, you'd be copying and pasting code.

In this assignment, you'll ask the agent to refactor that logic into a proper local component called `led_blink`. The component exposes a clean public API, uses Kconfig for configuration, and can be dropped into any ESP-IDF project.

You'll do this by updating the spec files from assignment-2 and asking the agent to implement the changes, the same workflow you'd use for any new feature.

### What you will build

A local `led_blink` component that:

- Encapsulates all GPIO and timing logic away from `app_main`.
- Exposes a simple public API: `led_blink_init`, `led_blink_start`, `led_blink_stop`.
- Uses Kconfig to configure the GPIO pin and blink interval.
- Leaves `app_main` clean: it only initialises the component and starts blinking.

### Step 1: Update the spec files

Open `ARCHITECTURE.md` and replace its contents with the new structure:

**`ARCHITECTURE.md`**

```markdown
# Architecture

## Components

### led_blink (components/led_blink/)
Encapsulates LED GPIO control and blinking logic.

Public API (include/led_blink.h):
  esp_err_t led_blink_init(void);
  esp_err_t led_blink_start(void);
  esp_err_t led_blink_stop(void);

Configuration (Kconfig):
  LED_BLINK_GPIO: GPIO pin number, default 8, range 0–48
  LED_BLINK_PERIOD_MS: blink interval in ms, default 500, range 100–5000

Files:
  components/led_blink/CMakeLists.txt
  components/led_blink/Kconfig
  components/led_blink/include/led_blink.h
  components/led_blink/led_blink.c

## Entry point (main/led_blink_main.c)
void app_main(void):
1. Call led_blink_init().
2. Call led_blink_start().
3. Return (the blink loop runs in a FreeRTOS task inside the component).

Files:
  main/led_blink_main.c
  main/CMakeLists.txt (add led_blink to REQUIRES)
```

Then update `STEP.md`:

**`STEP.md`**

```markdown
# Step 2: Refactor LED logic into a component

Read PLAN.md and ARCHITECTURE.md, then:

1. Create the `led_blink` component under `components/led_blink/` as described.
2. Move all GPIO configuration and blink logic from `main/led_blink.c` into the component.
3. Update `main/led_blink_main.c` to use only the public API: `led_blink_init` and `led_blink_start`.
4. Remove the Kconfig entries from `Kconfig.projbuild`, as they now live in the component's `Kconfig`.
5. Update `main/CMakeLists.txt` to add `led_blink` to `REQUIRES`.

## Acceptance criteria

- [ ] `components/led_blink/` exists with `CMakeLists.txt`, `Kconfig`, `include/led_blink.h`, and `led_blink.c`.
- [ ] `led_blink.h` declares `led_blink_init`, `led_blink_start`, and `led_blink_stop` with `esp_err_t` return types.
- [ ] `led_blink.c` implements all three functions. The blink loop runs in a FreeRTOS task created by `led_blink_start`.
- [ ] `Kconfig` defines `LED_BLINK_GPIO` and `LED_BLINK_PERIOD_MS` with defaults and help text.
- [ ] `app_main` only calls `led_blink_init()` and `led_blink_start()`, with no GPIO or delay logic in main.
- [ ] `main/CMakeLists.txt` lists `led_blink` in `REQUIRES`.
- [ ] `idf.py build` succeeds with no errors.
```

### Step 2: Plan before you implement

Before asking the agent to make any changes, use **planning mode** to review what it intends to do first.

Planning mode is a read-only mode where the agent reads your project and spec files, then describes the changes it would make without actually touching any files. This is especially useful for refactoring tasks like this one, where the agent will be modifying existing code across multiple files. A misunderstood spec is much cheaper to fix in a plan than in a partially-applied implementation.

To use planning mode in Cursor, open the agent chat, switch to **Plan** (**/plan**) mode using the mode selector, and send:

```
/plan Read PLAN.md, ARCHITECTURE.md, and STEP.md, then describe the changes you would make.
```

The agent will respond with a structured breakdown of what it plans to create, modify, and remove. Review it against your spec:

- Does it plan to create all the files listed in `ARCHITECTURE.md`?
- Does it plan to move the GPIO and blink logic, not duplicate it?
- Does it plan to update `main/CMakeLists.txt` to add `led_blink` to `REQUIRES`?
- Does it plan to clean up `Kconfig.projbuild`?

If something looks off, clarify it in the chat before switching to implementation. This is the moment to catch misunderstandings cheaply.

### Step 3: Ask the agent to implement

Once the plan looks right, switch back to **Agent** mode and send:

```
Implement the plan.
```

The agent will create the component, move the logic, and clean up `app_main`. Review the changes before accepting. Make sure the component structure matches what's in `ARCHITECTURE.md` and that no GPIO logic leaked back into `main`.

### Step 4: Build and test

```bash
idf.py build
idf.py -p <PORT> flash monitor
```

Behaviour should be identical to assignment-2: the LED blinks at 500 ms intervals. The difference is where the code lives: `app_main` is now just a few lines, and the blink logic is self-contained in the component.

{{< alert icon="circle-info" >}}
If your devkit has an addressable RGB LED (e.g. the ESP32-C5-DevKitC uses GPIO8), ask the agent to adapt the component to use the WS2812 driver instead of the plain GPIO driver.
{{< /alert >}}

## Next step

[Lecture 4: Tools and tricks for agent development with ESP-IDF](../lecture-4)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
