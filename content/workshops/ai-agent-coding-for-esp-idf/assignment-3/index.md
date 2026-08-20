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

In the previous assignment, the LED blink task and addressable LED driver logic lived in `main/led_blink.c`. That's fine for a quick test, but it's not reusable. If you wanted to use the same LED in a second project, you'd be copying and pasting code.

In this assignment, you'll ask the agent to refactor that logic into a proper local component called `led_blink`. The component exposes a clean public API, uses Kconfig for configuration, and controls the ESP32-C5-DevKitC-1's addressable LED with the appropriate driver.

You'll do this by updating the spec files from Assignment 2 and asking the agent to implement the changes, the same workflow you'd use for any new feature.

### What you will build

A local `led_blink` component that:

- Keeps all addressable LED control, FreeRTOS task, and timing logic out of `app_main`.
- Exposes a simple public API: `led_blink_init`, `led_blink_start`, and `led_blink_stop`.
- Uses Kconfig to configure the GPIO pin and blink interval.
- Leaves `app_main` clean: it only initialises the component and starts blinking.

### Step 1: Update the spec files

First, update `PLAN.md` with the board information learned in assignment 2:

**`PLAN.md`**

```markdown
# LED blink

## Goal
Refactor the working onboard addressable LED application into a reusable local component without changing its behaviour.

## Target
- Board: ESP32-C5-DevKitC-1
- SoC: ESP32-C5
- ESP-IDF: v6.0.2

## Constraints
- Use the onboard addressable LED, not a regular GPIO-driven LED
- Use the espressif/led_strip component with the RMT backend
- LED GPIO pin must be configurable via Kconfig
- Blink interval must be configurable via Kconfig
- LED blinking must run in a separate FreeRTOS task
- The physical LED must be verified before the task is considered complete
```

Then replace `ARCHITECTURE.md` with the new component structure:

**`ARCHITECTURE.md`**

```markdown
# Architecture

## Components

### led_blink (components/led_blink/)
Encapsulates addressable LED driver setup and blinking logic.

Public API (include/led_blink.h):
  esp_err_t led_blink_init(void);
  esp_err_t led_blink_start(void);
  esp_err_t led_blink_stop(void);

Configuration (Kconfig):
  LED_BLINK_GPIO: addressable LED data GPIO, default 27, range 0–28
  LED_BLINK_PERIOD_MS: blink interval in ms, default 500, range 100–5000

Dependencies:
  espressif/led_strip: addressable LED driver using the RMT backend

Files:
  components/led_blink/CMakeLists.txt
  components/led_blink/idf_component.yml
  components/led_blink/Kconfig
  components/led_blink/include/led_blink.h
  components/led_blink/led_blink.c

## Entry point (main/led_blink.c)
void app_main(void):
1. Call led_blink_init().
2. Call led_blink_start().
3. Return (the blink loop runs in a FreeRTOS task inside the component).

Files:
  main/led_blink.c
  main/CMakeLists.txt (add led_blink to REQUIRES)
```

Then update `STEP.md`:

**`STEP.md`**

```markdown
# Step 2: Refactor LED logic into a component

Read PLAN.md and ARCHITECTURE.md, then:

1. Create the `led_blink` component under `components/led_blink/` as described.
2. Move all addressable LED driver configuration and blink task logic from `main/led_blink.c` into the component.
3. Update `main/led_blink.c` to use only the public API: `led_blink_init` and `led_blink_start`.
4. Remove the Kconfig entries from `main/Kconfig.projbuild`, as they now live in the component's `Kconfig`.
5. Update `main/CMakeLists.txt` to add `led_blink` to `REQUIRES`.
6. Declare the `espressif/led_strip` dependency in `components/led_blink/idf_component.yml` and remove any direct dependency on it from `main`.

## Acceptance criteria

- [ ] `components/led_blink/` exists with `CMakeLists.txt`, `idf_component.yml`, `Kconfig`, `include/led_blink.h`, and `led_blink.c`.
- [ ] `led_blink.h` declares `led_blink_init`, `led_blink_start`, and `led_blink_stop` with `esp_err_t` return types.
- [ ] `led_blink.c` implements all three functions using the `led_strip` API and the RMT backend, not direct GPIO level changes.
- [ ] The blink loop runs in a FreeRTOS task created by `led_blink_start`, and `led_blink_stop` stops the task and turns off the LED.
- [ ] `idf_component.yml` declares the `espressif/led_strip` dependency.
- [ ] `Kconfig` defines `LED_BLINK_GPIO` and `LED_BLINK_PERIOD_MS` with defaults and help text.
- [ ] `app_main` only calls `led_blink_init()` and `led_blink_start()`, with no GPIO or delay logic in main.
- [ ] `main/CMakeLists.txt` lists `led_blink` in `REQUIRES`.
- [ ] `idf.py build` succeeds with no errors.
```

### Step 2: Plan before you implement

Before asking the agent to make any changes, use **planning mode** to review what it intends to do first.

Planning mode is a read-only mode where the agent reads your project and spec files, then describes the changes it would make without actually touching any files. This is especially useful for refactoring tasks like this one, where the agent will be modifying existing code across multiple files. A misunderstood spec is much cheaper to fix in a plan than in a partially applied implementation.

To use planning mode in Cursor, open the agent chat, switch to **Plan** (**/plan**) mode using the mode selector, and send:

```
/plan Read PLAN.md, ARCHITECTURE.md, and STEP.md, then describe the changes you would make.
```

The agent will respond with a structured breakdown of what it plans to create, modify, and remove. Review it against your spec:

- Does it plan to create all the files listed in `ARCHITECTURE.md`?
- Does it plan to move the addressable LED driver and blink task logic, not duplicate it?
- Does it preserve the working `led_strip` configuration from assignment 2?
- Does it declare `espressif/led_strip` as a dependency of the new component?
- Does it plan to update `main/CMakeLists.txt` to add `led_blink` to `REQUIRES`?
- Does it plan to clean up `main/Kconfig.projbuild`?

**The plan**

```text
 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 │ Plan                                                                                                                                                                          │
 │                                                                                                                                                                               │
 │ Refactor LED Blink into a Component                                                                                                                                           │
 │                                                                                                                                                                               │
 │ • Create components/led_blink/ (components/led_blink/) with:                                                                                                                  │
 │   • include/led_blink.h (components/led_blink/include/led_blink.h) exposing led_blink_init, led_blink_start, and led_blink_stop as esp_err_t APIs.                            │
 │   • led_blink.c (components/led_blink/led_blink.c) owning the led_strip RMT handle, lifecycle state, FreeRTOS task, ON/OFF updates, logging, and cleanup. start creates       │
 │     the task; stop deletes it and clears the LED.                                                                                                                             │
 │   • Kconfig (components/led_blink/Kconfig) defining GPIO 27 by default (range 0–28) and the existing 500 ms period (range 100–5000), both with help text.                     │
 │   • CMakeLists.txt (components/led_blink/CMakeLists.txt) registering the source and public include directory.                                                                 │
 │   • idf_component.yml (components/led_blink/idf_component.yml) declaring espressif/led_strip ^3.0.3.                                                                          │
 │ • Reduce main/led_blink.c (main/led_blink.c) to app_main, which calls only led_blink_init() and led_blink_start() and checks their returned errors.                           │
 │ • Update main/CMakeLists.txt (main/CMakeLists.txt) to require led_blink; remove main/idf_component.yml (main/idf_component.yml) so main no longer depends directly on         │
 │   led_strip.                                                                                                                                                                  │
 │ • Move configuration ownership out of main by removing main/Kconfig.projbuild (main/Kconfig.projbuild) and the obsolete root Kconfig.projbuild (Kconfig.projbuild); the       │
 │   component Kconfig becomes the single source of the symbols.                                                                                                                 │
 │ • Build with ESP-IDF v6.0.2, flash the detected ESP32-C5 port, monitor at least two ON/OFF cycles, stop monitoring, and confirm 500 ms transitions. Ask for visual            │
 │   confirmation that the physical onboard LED blinks before marking the task complete.                                                                                         │
 │                                                                                                                                                                               │
 │  Saved to Users/pedrominatel/.cursor/plans/Refactor LED Component-705440e8.plan.md                                                                                            │
 │ ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── │
 │                                                                                                                                                                               │
 │ Ready to build?                                                                                                                                                               │
 │                                                                                                                                                                               │
 │  → 1. Yes, build locally (b)                                                                                                                                                  │
 │    2. No, propose changes (p or Esc)                                                                                                                                          │
 │                                                                                                                                                                               │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

If something looks off, clarify it in the chat before switching to implementation. This is the moment to catch misunderstandings cheaply.

### Step 3: Ask the agent to implement

How you proceed depends on the agent. It may ask you to confirm the plan, present a checkbox or button to start implementation, or require you to switch back to **Agent** mode manually. If the plan needs no changes, approve it using the option provided. Otherwise, ask the agent to update the plan before implementation.

If there is no built-in option to proceed, switch back to **Agent** mode and send:

```
Implement the plan.
```

The agent will create the component, move the logic, and clean up `app_main`. Review the changes before accepting. Make sure the component structure matches what's in `ARCHITECTURE.md` and that no addressable LED driver logic remains in `main`.

### Step 4: Build, flash, and verify

Ask the agent to build the refactored application and fix any errors before flashing it:

```text
Run idf.py build, read the output, and fix any errors without changing the
requirements. Repeat until the build succeeds.
Then detect the ESP32-C5 serial port, flash the application, and monitor at
least two LED ON/OFF cycles before stopping the monitor.
Report the build result and captured log output.
```

Behaviour should be identical to Assignment 2: the LED blinks at 500 ms intervals. The difference is where the code lives: `app_main` is now just a few lines, and the blink logic is self-contained in the component.

The agent can verify the build, flashing, and serial output, but it cannot see the physical LED. Confirm that the addressable LED is blinking before moving to the next step.

### Step 5: Add an API to change the LED colour

Extend the component with a public API that changes the colour used while the LED is on:

```c
esp_err_t led_blink_set_color(uint8_t red, uint8_t green, uint8_t blue);
```

Update `ARCHITECTURE.md` and `STEP.md` before changing the implementation. Add these requirements:

- `led_blink_set_color` accepts red, green, and blue values from 0 to 255.
- The function returns `ESP_ERR_INVALID_STATE` if `led_blink_init` has not completed successfully.
- The colour can be changed while the blink task is running without restarting the task.
- Access to the colour values is safe between the calling task and the blink task.
- `main/led_blink.c` sets the LED to blue with `led_blink_set_color(0, 0, 32)` after initialisation and before starting the blink task.

Ask the agent to review the updated specifications, implement the new API, and verify the result:

```text
Read the updated PLAN.md, ARCHITECTURE.md, and STEP.md.
Plan and implement the new led_blink_set_color API.
Build the project, fix any errors, then flash and monitor the application.
Report the result and ask me to confirm that the physical LED is blinking blue.
```

Do not continue until the component builds successfully and the physical LED blinks in the selected colour.

## Next step

[Lecture 4: Tools and tricks for agent development with ESP-IDF](../lecture-4)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
