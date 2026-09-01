---
title: "AI agent coding for ESP-IDF workshop - Assignment 4: Refactor an application into a reusable component"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-08-28
showTableOfContents: true
series: ["WS003EN"]
series_order: 8
showAuthor: false
---

## Assignment steps

In Assignment 3, you created a working LED blink application for the ESP32-C5-DevKitC-1. The addressable LED driver, FreeRTOS task, and timing logic currently live in `main/led_blink.c`.

In this assignment, you will move that logic into a reusable local component. You have already practised the ESP-IDF concepts and spec-driven workflow involved, so each step below focuses on one checkpoint.

### What you will build

A local `led_blink` component that:

- Owns the addressable LED driver, blink task, and timing logic.
- Exposes `led_blink_init`, `led_blink_start`, and `led_blink_stop`.
- Uses Kconfig for the LED GPIO and blink interval.
- Keeps `app_main` limited to initialising and starting the component.

### Step 1: Update the specification

Update `PLAN.md` so it identifies the exact board and states the refactoring goal:

```markdown
## Goal
Refactor the working onboard addressable LED application into a reusable local
component without changing its behaviour.

## Target
- Board: ESP32-C5-DevKitC-1
- SoC: ESP32-C5
- ESP-IDF: v6.0.2
```

Replace the relevant component and file sections in `ARCHITECTURE.md` with:

```markdown
## Components

### led_blink (`components/led_blink/`)
Owns the addressable LED driver, FreeRTOS task, and timing logic.

Public API (`include/led_blink.h`):
- `esp_err_t led_blink_init(void);`
- `esp_err_t led_blink_start(void);`
- `esp_err_t led_blink_stop(void);`

Configuration (`Kconfig`):
- `LED_BLINK_GPIO`: addressable LED data GPIO, default 27, range 0–28
- `LED_BLINK_PERIOD_MS`: blink interval in ms, default 500, range 100–5000

Dependency:
- `espressif/led_strip`, using the RMT backend

Files:
- `components/led_blink/CMakeLists.txt`
- `components/led_blink/idf_component.yml`
- `components/led_blink/Kconfig`
- `components/led_blink/include/led_blink.h`
- `components/led_blink/led_blink.c`

## Entry point (`main/led_blink.c`)

`app_main` calls `led_blink_init()` and `led_blink_start()`, checks both results,
and then returns.
```

Update `STEP.md` with the current task:

```markdown
# Step 2: Refactor LED logic into a component

Read PLAN.md and ARCHITECTURE.md, then move the working addressable LED
implementation into the `led_blink` component.

## Acceptance criteria

- [ ] The component contains every file listed in `ARCHITECTURE.md`.
- [ ] The public header declares `led_blink_init`, `led_blink_start`, and
      `led_blink_stop` with `esp_err_t` return types.
- [ ] The component uses `espressif/led_strip` with the RMT backend.
- [ ] The blink loop runs in a FreeRTOS task owned by the component.
- [ ] `led_blink_stop` stops the task and turns off the LED.
- [ ] GPIO and period settings are defined by the component's `Kconfig`.
- [ ] `main/led_blink.c` contains no LED driver, GPIO, task, or delay logic.
- [ ] `main/CMakeLists.txt` declares the `led_blink` dependency.
- [ ] `idf.py build` succeeds.
```

Checkpoint: review the three files and confirm that the goal, architecture, task, and acceptance criteria agree before continuing.

### Step 2: Review the implementation plan

Switch to planning mode and ask:

```text
Read PLAN.md, ARCHITECTURE.md, and STEP.md.
Describe the files you will create, modify, and remove to satisfy the spec.
Do not implement anything yet.
```

Confirm that the plan will:

- Move the working driver and task logic instead of duplicating it.
- Put configuration and the `led_strip` dependency inside the component.
- Reduce `app_main` to calls through the public API.
- Build and verify the same behaviour after refactoring.

If anything is missing, correct the plan before implementation.

### Step 3: Implement the component

Approve the plan using the option provided by your agent. If the agent requires a separate implementation prompt, switch to agent mode and send:

```text
Implement the approved plan. Keep the existing LED behaviour unchanged.
```

Checkpoint: inspect the generated component structure and compare the public API, configuration, dependencies, and `app_main` with `ARCHITECTURE.md`.

### Step 4: Build, flash, and verify

Ask the agent to complete the validation loop:

```text
Run idf.py build and fix any errors without changing the requirements.
Then detect the ESP32-C5 serial port. If no port or more than one suitable port
is found, ask me which one to use.
Flash the application, monitor at least two LED ON/OFF cycles, and report the
captured output.
```

Confirm both results:

- The serial log shows transitions at 500 ms intervals.
- The physical onboard addressable LED blinks as it did before the refactoring.

The core assignment is complete when the build succeeds and the behaviour is unchanged.

### Optional challenge: Add a colour API

After completing the core assignment, extend the component with:

```c
esp_err_t led_blink_set_color(uint8_t red, uint8_t green, uint8_t blue);
```

Update `ARCHITECTURE.md` and `STEP.md` first with these requirements:

- Each colour value accepts the range 0–255.
- The function returns `ESP_ERR_INVALID_STATE` before successful initialisation.
- The colour can change safely while the blink task is running.
- `main/led_blink.c` selects blue with `led_blink_set_color(0, 0, 32)` before starting the task.

Then ask the agent to plan, implement, build, flash, and verify the extension. Confirm that the physical LED blinks blue before considering the challenge complete.

## Next step

[Lecture 3: Reducing token usage in AI agent workflows](../lecture-3)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
