---
title: "AI agent coding for ESP-IDF workshop - Assignment 6: Debug an ESP-IDF application with AI"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-08-28
showTableOfContents: true
series: ["WS003EN"]
series_order: 12
showAuthor: false
---

## Assignment steps

---

In this assignment, you will introduce one controlled defect into the working `led_blink` component, collect evidence, and use an AI agent to diagnose and fix the root cause.

The defect changes physical LED behaviour while allowing the project to build and logs to continue. This demonstrates why runtime logs alone are not proof that hardware behaves correctly.

### Step 1: Confirm the working baseline

Before introducing the defect:

1. Build and flash the project from Assignment 4.
2. Monitor at least two LED ON/OFF cycles.
3. Confirm that the physical onboard LED blinks.
4. Record the expected 500 ms interval and relevant log output.

Do not continue until the software output and physical behaviour both match the specification.

### Step 2: Introduce the defect

Open `components/led_blink/led_blink.c` and locate the call that refreshes the addressable LED after updating its pixel value:

```c
led_strip_refresh(/* ... */);
```

Temporarily remove or comment out that call. Do not change `PLAN.md`, `ARCHITECTURE.md`, or `STEP.md`; the implementation is intentionally violating the existing specification.

Rebuild the project to confirm that the defect does not cause a compiler error.

### Step 3: Reproduce and record the symptom

Flash the modified application and monitor at least two LED ON/OFF log cycles.

Record facts separately:

| Evidence | Observation |
|---|---|
| Build result | |
| Flash result | |
| Serial log | |
| Physical LED | |
| Exact board | ESP32-C5-DevKitC-1 |
| ESP-IDF version | v6.0.2 |

The expected symptom is that the build and flash succeed and the logs change, but the physical LED does not update correctly.

### Step 4: Ask for a diagnosis before a fix

Give the agent the evidence you recorded:

```text
Expected: the onboard addressable LED blinks every 500 ms.
Observed: the build and flash succeed, and the monitor logs alternate between
ON and OFF, but the physical LED does not change.
Board: ESP32-C5-DevKitC-1. ESP-IDF: v6.0.2.

Inspect the led_blink component and current Git diff.
Identify the most likely root cause and cite the code and evidence that support
it. Explain one focused check that confirms the diagnosis.
Do not edit any files yet.
```

Review the response. It should distinguish the log message from the physical LED update and explain that changing pixel data does not transmit it to the LED until the strip is refreshed.

If the diagnosis is unsupported or the agent proposes unrelated changes, ask it to reassess the evidence before continuing.

### Step 5: Apply the minimal fix

After accepting the diagnosis, ask:

```text
Apply the minimal fix for the confirmed root cause.
Do not refactor unrelated code or change the specification.
Then show the exact change and explain why it fixes the physical symptom.
```

Confirm that the change restores the required refresh operation without modifying unrelated files.

### Step 6: Verify the fix

Ask the agent to perform the software checks:

```text
Build the project and fix only errors caused by the current change.
Then detect the ESP32-C5 serial port. If no port or more than one suitable port
is found, ask me which one to use.
Flash the application, monitor at least two LED ON/OFF cycles, and report the
captured output. Ask me to confirm the physical LED behaviour.
```

Complete the assignment only when:

- The build and flash succeed.
- Logs alternate at the specified interval.
- You confirm that the physical LED blinks.
- The agent's explanation connects the missing refresh to the symptom.
- No temporary diagnostic code or unrelated changes remain.

## Optional next steps

- [Refactor an ESP-IDF component with AI](../optional-refactoring/)
- [Analyze addressable LED frames with Saleae Logic 2](../optional-saleae/)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
