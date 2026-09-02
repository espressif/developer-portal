---
title: "AI agent coding for ESP-IDF workshop - Optional: Refactor an ESP-IDF component with AI"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-08-28
showTableOfContents: true
showAuthor: false
---

## Refactor an ESP-IDF component with AI

This optional exercise practises changing internal structure without changing observable behaviour. You will move the `led_blink` task's stack size and priority from hardcoded source values into Kconfig.

### Step 1: Record the baseline

Build, flash, and monitor the working project. Confirm the current blink interval and physical LED behaviour before refactoring.

### Step 2: Update the specification

Add these settings to the `Configuration (Kconfig)` section in `ARCHITECTURE.md`:

```markdown
- `LED_BLINK_TASK_STACK_SIZE`: task stack size, default 2048, range 1024–8192
- `LED_BLINK_TASK_PRIORITY`: task priority, default 5, range 1–24
```

Update `STEP.md`:

```markdown
# Step 3: Make blink task settings configurable

Read PLAN.md and ARCHITECTURE.md, then refactor the led_blink component:

1. Add `LED_BLINK_TASK_STACK_SIZE` to Kconfig.
2. Add `LED_BLINK_TASK_PRIORITY` to Kconfig.
3. Use the generated `CONFIG_*` values when creating the blink task.
4. Preserve the component's existing public API and runtime behaviour.

## Acceptance criteria

- [ ] Both Kconfig options include prompts, ranges, defaults, and help text.
- [ ] Stack size and priority are not hardcoded in `led_blink.c`.
- [ ] `led_blink_stop()` followed by `led_blink_start()` still works.
- [ ] `idf.py build` succeeds.
- [ ] The physical LED behaviour is unchanged.
```

If you completed the optional colour API challenge in Assignment 4, add an acceptance criterion requiring `led_blink_set_color()` to keep working while the task runs.

### Step 3: Review and implement the plan

Ask the agent to plan before editing:

```text
Read PLAN.md, ARCHITECTURE.md, and STEP.md.
Explain how you will move the blink task stack size and priority into Kconfig
without changing runtime behaviour. Do not edit files yet.
```

Check that the plan changes only the component's Kconfig and task creation code. Then approve the plan and ask the agent to implement it.

### Step 4: Verify unchanged behaviour

Ask the agent to build, flash, and monitor the refactored project. Confirm:

- The build succeeds.
- Logs retain the specified interval.
- The physical LED behaves exactly as it did in the baseline.
- No temporary test code remains.

## Next step

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
