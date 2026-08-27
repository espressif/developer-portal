---
title: "AI agent coding for ESP-IDF workshop - Lecture 3: Spec-driven development"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
showTableOfContents: true
series: ["WS003EN"]
series_order: 5
showAuthor: false
---

## Introduction

Spec-driven development is a workflow where you write a clear specification first and let the AI agent generate the implementation from it. This approach produces more consistent, reviewable code and reduces the number of correction cycles.

### What is a spec?

A spec is a structured description of what you want to build. For ESP-IDF components, a good spec covers:

- **Purpose:** what the component does and why.
- **API surface:** the public functions, their signatures, and their return types.
- **Configuration:** any `Kconfig` options, their names, defaults, and valid ranges.
- **Dependencies:** the ESP-IDF components, header files, and external libraries that are required.
- **Behaviour and errors:** expected results, failure cases, and error codes.
- **Lifecycle and concurrency:** valid call order, resource cleanup, and whether functions are thread-safe.
- **Constraints:** target SoC, IDF version, coding conventions.
- **Acceptance criteria:** checks that prove the implementation meets the requirements.

### Writing a spec for an ESP-IDF component

A spec does not need to be a formal document. A well-structured prompt is sufficient, but saving it as `SPEC.md` keeps it version-controlled and reusable across agent sessions. For example:

**`SPEC.md`**

```markdown
Component: temperature_sensor
Target: ESP32-C5, ESP-IDF v6.0.2

API:
  esp_err_t temperature_sensor_init(void);
  esp_err_t temperature_sensor_read(float *out_celsius);
  esp_err_t temperature_sensor_deinit(void);

Kconfig:
  TEMPERATURE_SENSOR_SAMPLE_PERIOD_MS: sampling period in ms, default 1000, range 100-60000

Dependencies:
  - Build component: esp_driver_tsens (PRIV_REQUIRES)
  - Header: driver/temperature_sensor.h

Constraints:
  - Use ESP_LOGI with tag "temp_sensor" for all log output.
  - Do not call the API from an interrupt service routine.
  - The caller must serialise access; the API is not thread-safe.
  - Follow the component structure in AGENTS.md.

Behaviour and errors:
  - init returns ESP_ERR_INVALID_STATE if the component is already initialised.
  - Return ESP_ERR_INVALID_ARG if out_celsius is NULL.
  - read and deinit return ESP_ERR_INVALID_STATE if the component is not initialised.
  - deinit releases all resources allocated by init.

Acceptance criteria:
  - The component declares esp_driver_tsens in PRIV_REQUIRES.
  - idf.py build succeeds for ESP32-C5.
  - On target hardware, init, read, and deinit return ESP_OK and read produces
    a valid Celsius value.
```

If a requirement is unknown, record it as an open question instead of leaving the agent to guess. Ask the agent to list ambiguities and assumptions before it starts implementing, then resolve anything that could affect the API or architecture.

### The spec-driven workflow

1. **Write the spec** before writing any code. This forces you to think through the design.
2. **Ask the agent to review it** and identify ambiguities, missing requirements, and assumptions.
3. **Resolve the open questions**, then ask the agent to implement the approved spec.
4. **Review the generated files** against the spec: check API names, Kconfig entries, dependencies, error handling, and cleanup.
5. **Build and test:** ask the agent to run the checks when it has access to the tools; otherwise, run them yourself and share the output.
6. **Update the spec first** when requirements change, then ask the agent to update the implementation to match.

### Keep the spec as the source of truth

Commit the spec alongside the code and review changes to both together. If the implementation needs to deviate from the spec, document and approve that change rather than allowing the two to drift apart. This gives future developers and agent sessions an accurate description of the intended behaviour.

### Tools for spec-driven development

You can manage specifications with ordinary Markdown files, or use a toolkit that provides a more structured workflow. [GitHub Spec Kit](https://github.com/github/spec-kit/) helps you turn a feature description into a specification, implementation plan, and actionable tasks for an AI coding agent.

Such tools are optional and are not specific to ESP-IDF. Review their generated files, add the hardware and ESP-IDF constraints described above, and keep the resulting specifications in version control with the code.

### Why this works well for embedded code

Embedded firmware has well-defined interfaces (GPIO, I2C, SPI, UART) and strict conventions (ESP-IDF component structure, `idf_component_register`, error codes). These constraints give the agent enough structure to generate correct code from a spec with minimal guesswork.

Spec-driven development also makes reviews easier: instead of reviewing free-form generated code, reviewers can compare the implementation against the stated spec.

## Next step

[Assignment 2: Create a new project](../assignment-2)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
