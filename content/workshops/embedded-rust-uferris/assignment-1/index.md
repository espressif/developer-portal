---
title: "Assignment 1: GPIO"
date: 2026-05-18T00:00:00+01:00
showTableOfContents: true
series: ["WS-RUST-ESP"]
series_order: 3
showAuthor: false
---

Time to get hands-on. In this module, you'll apply the **Instantiate → Configure → Control** pattern to GPIO — the most fundamental peripheral on any microcontroller.

## GPIO Foundations

### What is GPIO?

**General Purpose Input/Output** — the standard digital interface to the outer world. The most basic peripheral: making pins go high or low, and reading whether they're high or low.

### Configurations: Direction

- **Output** — you drive the pin (e.g., turn on an LED)
- **Input** — you read the pin (e.g., detect a button press)

### Output Modes

- **Push-pull** (typically default) — actively drives the pin high and low
- **Open-drain** — actively drives low, but floats when "high" (needs external pull-up)

**Drive Strength:** How much current the pin can source or sink. Higher drive strength = brighter LED, but more power consumption.

[This article]( https://developer.espressif.com/blog/2026/02/esp-idf-tutorial-gpio-get-started/#output-configuration) is also a good reference for more detail about output modes.

### Input Pull Resistors

- **Pull-up** — pin reads high when nothing is connected; button pulls it low
- **Pull-down** — pin reads low when nothing is connected; button pulls it high
- **Floating** — no pull resistor; pin state is undefined when nothing is connected

---

## Exercise A: Blinky

**Goal:** Get an LED blinking by finding and adapting an existing example from the `esp-hal` documentation.

### 1. Create a New Project

```bash
esp-generate --chip esp32c3 -o unstable-hal -o vscode -o esp-backtrace -o log --headless gpio_blinky
cd gpio_blinky
```

### 2. Find the Example

Navigate to the [esp-hal GPIO documentation](https://docs.espressif.com/projects/rust/esp-hal/latest/esp32c3/esp_hal/gpio/struct.Output.html).

Look for a blinky example — check:
- The module-level documentation (`esp_hal::gpio`)
- The `Output` struct page
- The [esp-hal examples directory on GitHub](https://github.com/esp-rs/esp-hal/tree/main/examples)

### 3. Apply the Mental Model

Read the example and identify:
- **Instantiate** — How is the `Output` created? What arguments does it take?
- **Configure** — What configuration is applied? (Level, OutputConfig)
- **Control** — What method is used to change the LED state?

### 4. Adapt to Your Hardware

- Check your board's pinout for the LED pin
- Update the GPIO pin in the example to match
- Make sure the initial level matches your hardware (active high or active low?)

### 5. Build and Flash

```bash
cargo build --release
espflash flash target/riscv32imc-unknown-none-elf/release/gpio_blinky --monitor
```

{{< alert icon="circle-info" >}}
The `Output::new()` call combines **Instantiate** and **Configure** in one statement. Look at what other methods `Output` provides besides the one used in the example.
{{< /alert >}}

---

## Exercise B: Button Input

**Goal:** Read a physical button press and use it to control the LED. You'll need to find the **Input** abstraction and configure it correctly.

### 1. Create a New Project

```bash
esp-generate --chip esp32c3 -o unstable-hal -o vscode -o esp-backtrace -o log --headless gpio_button
cd gpio_button
```

### 2. Find the Input Abstraction

Navigate to the [esp-hal GPIO documentation](https://docs.espressif.com/projects/rust/esp-hal/latest/esp32c3/esp_hal/gpio/index.html).

- Find the `Input` struct
- Read what arguments its constructor takes
- Look at what configuration options are available

### 3. Understand the Hardware

The button is wired to pull the pin **to ground** when pressed:
- When **not pressed**: pin floats (needs pull-up to read high)
- When **pressed**: pin is pulled low

This means you need a **pull-up** resistor configuration and detect a **low** level to know the button is pressed.

### 4. Configure the Input

Apply the mental model:
- **Instantiate** — Create an `Input` instance for the button pin
- **Configure** — Set the pull resistor to pull-up

Check the `InputConfig` struct and its methods. How do you set the pull direction?

### 5. Read the Button and Control the LED

Find the method on `Input` that reads the current pin state. Use it to:
- Detect when the button is pressed (low)
- Turn on the LED when pressed
- Turn off the LED when released

### 6. Build and Flash

```bash
cargo build --release
espflash flash target/riscv32imc-unknown-none-elf/release/gpio_button --monitor
```

---

## Exercise C: Alternative Blink

**Goal:** Find a different way to achieve the same blink behavior, without using the same approach as in Exercise A.

### 1. Create a New Project

```bash
esp-generate --chip esp32c3 -o unstable-hal -o vscode -o esp-backtrace -o log --headless gpio_challenge
cd gpio_challenge
```

### 2. Explore the Output Documentation

Go back to the [`Output` struct documentation](https://docs.espressif.com/projects/rust/esp-hal/latest/esp32c3/esp_hal/gpio/struct.Output.html) and scroll through all the available methods.

### 3. Find an Alternative

The blinky example in Exercise A used one specific approach. Your task: find a **different method** that achieves the same result.

Hints:
- There's more than one way to change pin state
- Some methods combine multiple operations
- Check both the inherent methods and the trait methods

### 4. Modify and Test

Update your blinky code to use the alternative approach. The LED should still blink at the same rate.

```bash
cargo build --release
espflash flash target/riscv32imc-unknown-none-elf/release/gpio_challenge --monitor
```

---

## Cross-HAL Comparison

How do other HALs handle GPIO? Navigate the documentation for these two libraries and find how they approach the same tasks:

- [rp2040-hal](https://docs.rs/rp2040-hal/latest/rp2040_hal/)
- [stm32f4xx-hal](https://docs.rs/stm32f4xx-hal/latest/stm32f4xx_hal/)

Compare how each HAL handles **Instantiate**, **Configure**, and **Control** for GPIO.
