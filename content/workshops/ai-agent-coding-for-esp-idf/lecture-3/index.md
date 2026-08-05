---
title: "AI agent coding for ESP-IDF workshop - Lecture 3: Spec-driven development"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
showTableOfContents: false
series: ["WS003EN"]
series_order: 5
showAuthor: false
---

## Lecture 3: Spec-driven development

Spec-driven development is a workflow where you write a clear specification first and let the AI agent generate the implementation from it. This approach produces more consistent, reviewable code and reduces the number of correction cycles.

### What is a spec?

A spec is a structured description of what you want to build. For ESP-IDF components, a good spec covers:

- **Purpose:** what the component does and why.
- **API surface:** the public functions, their signatures, and their return types.
- **Configuration:** any `Kconfig` options, their names, defaults, and valid ranges.
- **Dependencies:** which ESP-IDF components or external libraries are required.
- **Constraints:** target chip, IDF version, coding conventions.

### Writing a spec for an ESP-IDF component

A spec does not need to be a formal document. A well-structured prompt is sufficient. Example:

```
Component: temperature_sensor
Target: ESP32-C5, ESP-IDF v6.0.2

API:
  esp_err_t temperature_sensor_init(void);
  esp_err_t temperature_sensor_read(float *out_celsius);
  esp_err_t temperature_sensor_deinit(void);

Kconfig:
  TEMPERATURE_SENSOR_SAMPLE_PERIOD_MS: sampling period in ms, default 1000, range 100-60000

Dependencies: driver/temperature_sensor.h (ESP-IDF internal temperature sensor)

Constraints:
  - Use ESP_LOGI with tag "temp_sensor" for all log output.
  - Return ESP_ERR_INVALID_ARG if out_celsius is NULL.
  - Follow the component structure in AGENTS.md.
```

### The spec-driven workflow

1. **Write the spec** before writing any code. This forces you to think through the design.
2. **Share the spec with the agent** as a single prompt.
3. **Review the generated files** against the spec: check API names, Kconfig entries, and dependencies.
4. **Build and iterate:** share any errors back to the agent.
5. **Update the spec** if requirements change, then ask the agent to update the implementation to match.

### Why this works well for embedded code

Embedded firmware has well-defined interfaces (GPIO, I2C, SPI, UART) and strict conventions (ESP-IDF component structure, `idf_component_register`, error codes). These constraints give the agent enough structure to generate correct code from a spec with minimal guesswork.

Spec-driven development also makes reviews easier: instead of reviewing free-form generated code, reviewers can compare the implementation against the stated spec.

## Next step

[Assignment 2: Create a new project](../assignment-2)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
