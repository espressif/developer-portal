---
title: "AI agent coding for ESP-IDF workshop - Assignment 5: Compare token usage between prompts"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-08-28
showTableOfContents: true
series: ["WS003EN"]
series_order: 10
showAuthor: false
---

## Assignment steps

---

In this assignment, you will ask the same agent to perform the same read-only review in two fresh sessions. The first prompt leaves the scope broad. The second defines the relevant files, review criteria, output limit, and stopping condition.

The goal is to compare efficiency without sacrificing result quality.

### Before you begin

Use the completed `led_blink` component from Assignment 4. Select the same fixed model for both runs; do not use automatic model selection.

For each session, record:

- Context usage before and after the review.
- Number of conversation turns.
- Number of tool calls, if shown.
- Approximate response length.
- Whether the result meets every quality criterion below.

In Cursor IDE, use the context indicator. In Cursor CLI, `/context` shows context-window consumption by category. These values show current context occupancy, not cumulative input and output tokens for every model call.

### Quality criteria

Score each review against the same checklist:

| Criterion | Pass condition |
|---|---|
| **API coverage** | Verifies that every public function declared in `led_blink.h` has a matching implementation and signature in `led_blink.c`. |
| **Error handling** | Checks whether `esp_err_t` failures are propagated or handled and identifies any unchecked operation that affects correctness. |
| **Lifecycle behaviour** | Reviews valid and invalid `init`, `start`, and `stop` call sequences, including repeated calls. |
| **Resource cleanup** | Checks task shutdown, LED state, and cleanup of resources created during initialisation. |
| **Evidence** | Supports each finding with the relevant file, function, and a concise explanation of its impact. |
| **Actionability** | Recommends a specific correction for each finding, or explicitly reports that no issue was found without inventing one. |
| **Scope control** | Makes no file changes, does not run firmware, and avoids unrelated project areas. |

Count one point for each pass condition, for a maximum quality score of **7**. A token comparison is meaningful only when both reviews achieve a similar quality score.

### Step 1: Run the broad prompt

Start a fresh session and send:

```text
Review the led_blink component. Check whether its public API, error handling,
and lifecycle behaviour are correct. Report any problems. Do not make changes.
```

Do not add clarification unless the agent asks for information required to proceed. When it finishes, record the measurements and evaluate the result against the quality criteria.

### Step 2: Run the scoped prompt

Start another fresh session, select the same model, and send:

```text
Review only these files:
- components/led_blink/include/led_blink.h
- components/led_blink/led_blink.c

Compare the public API with its implementation. Check only:
1. esp_err_t handling;
2. valid init, start, and stop call order;
3. cleanup and task lifecycle behaviour.

Report at most five actionable findings. For each finding, include the file and
relevant function. If there are no findings, say so. Do not edit files, run the
firmware, or inspect unrelated files.
```

Record the same measurements and evaluate the result against the same quality criteria.

### Step 3: Compare the runs

Complete the table with your observations:

| Measurement | Broad prompt | Scoped prompt |
|---|---:|---:|
| Context usage before | | |
| Context usage after | | |
| Conversation turns | | |
| Tool calls | | |
| Approximate response length | | |
| Quality score (out of 7) | | |

Then answer:

1. Did the scoped prompt inspect fewer unrelated files or make fewer tool calls?
2. Did it use less context or produce a shorter response?
3. Did either prompt require a clarification or correction turn?
4. Did reducing the scope omit evidence needed for a correct review?
5. Which parts of the scoped prompt contributed most to the result?

The scoped prompt is more efficient only if it achieves a similar quality score. A lower context value with an incomplete review is not an improvement.

### Optional: Compare exact token telemetry

The IDE context indicator does not provide cumulative model-token totals. Supported versions of the headless Cursor CLI can expose per-turn input, output, and cache-token data in `stream-json` output. If your CLI provides these fields, run both prompts headlessly with the same model and sum each session's reported values.

Check the current [Cursor CLI output format documentation](https://cursor.com/docs/cli/reference/output-format) before scripting this comparison because telemetry fields can change between CLI versions.

Even with exact telemetry, one pair of runs does not prove that a prompt will always use fewer tokens. Agent decisions, caching, and model output are non-deterministic. Repeat the comparison if you need stronger evidence.

## Next step

[Lecture 4: Evidence-driven debugging with AI](../lecture-4)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
