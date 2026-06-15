---
title: "Assignment 3: Interrupts"
date: 2026-05-18T00:00:00+01:00
lastmod: 2026-06-15
showTableOfContents: true
series: ["WS-RUST-ESP"]
series_order: 5
showAuthor: false
---

So far, all your code has been **polling** — checking the button state in a loop, reading sensors repeatedly. This works, but it's wasteful. The CPU spins constantly even when nothing is happening.

**Interrupts** let the hardware notify your code when something happens. The CPU can do other work (or sleep) until an event occurs.

## Polling vs. Interrupts

### Polling

The CPU constantly checks the state of a peripheral in a loop. Simple to implement but wastes CPU cycles:

```rust
loop {
    if button.is_low() {
        // react to button press
    }
    // CPU is busy-waiting here, doing nothing useful
}
```

### Interrupts

The hardware notifies the CPU when an event occurs. The CPU can sleep or do other work, only waking when needed:

```rust
loop {
    // CPU can sleep or do other work
}

// Hardware triggers this handler automatically
#[handler]
fn gpio_handler() {
    // react to the event
}
```

## Components of Interrupt Code

Interrupt code has three components:

### 1. Global Shared Data

Any data shared between the main thread and the interrupt handler:

```rust
static SHARED: Mutex<RefCell<Option<Input>>> =
    Mutex::new(RefCell::new(None));
```

### 2. Interrupt Setup

Configuring the interrupt per peripheral — what event to listen for, enabling it, moving data to shared state:

```rust
button.listen(Event::FallingEdge);
critical_section::with(|cs| {
    SHARED.borrow_ref_mut(cs).replace(button);
});
```

### 3. Interrupt Service Routine (ISR)

The code that reacts to the interrupt event:

```rust
#[handler]
fn gpio_handler() {
    critical_section::with(|cs| {
        // handle event, clear interrupt
    });
}
```

## Setup Happens in the Configure Stage

Setup involves three steps:

1. **Configuring the interrupt** — What do we want to listen to? Edge events (rising, falling, any) or level events (high, low)
2. **Enabling the interrupt** — Peripheral-level enable and interrupt controller enable
3. **Configuring global shared data** — `Mutex<RefCell<Option<T>>>` pattern, moving peripherals into global statics via `critical_section`

---

## Exercise A: Interrupt-Driven Button

**Goal:** Convert the GPIO button example from Part 2 to use interrupts instead of polling.

### 1. Create a New Project

```bash
esp-generate --chip esp32c3 -o unstable-hal -o vscode -o esp-backtrace -o log --headless gpio_interrupt
cd gpio_interrupt
```

### 2. Find Interrupt Examples

Search the GPIO Input documentation or the [esp-hal examples directory](https://github.com/esp-rs/esp-hal/tree/main/examples) for interrupt examples.

Look for how interrupts are set up — recall the three components:
1. Interrupt Setup
2. Interrupt Service Routine
3. Global Shared Data

### 3. Apply the Pattern

Convert your polling code to use interrupts:
- **Configure** the interrupt (what event to listen to?)
- **Enable** the interrupt (allow events to go through)
- **Set up global shared data** (how will the handler communicate with the main loop?)

### 4. Build and Flash

```bash
cargo build --release
espflash flash target/riscv32imc-unknown-none-elf/release/gpio_interrupt --monitor
```

Press the button. The LED should toggle.

### 5. Explore Trigger Configurations

Look up the `Event` enum in esp-hal's GPIO module. What variants are available?

{{< alert icon="circle-info" >}}
You must always call `clear_interrupt()` in the handler. Compare: what can the main loop do now that it couldn't when polling?
{{< /alert >}}

---

## Exercise B: I/O Expander Interrupt

**Goal:** Use the TCA6424's INT output to detect input changes without polling over I2C.

The TCA6424 I/O expander has an **INT** output pin connected to a GPIO pin. Instead of polling the I/O expander over I2C, use this interrupt line to get notified when an input changes.

### Steps

1. **Create a new project**

```bash
esp-generate --chip esp32c3 -o unstable-hal -o vscode -o esp-backtrace -o log --headless expander_interrupt
cd expander_interrupt
```

2. **Find the INT pin** — check your board's pinout to see which GPIO pin the I/O expander's INT output is connected to.

3. **Configure a GPIO interrupt** on that pin — the INT line is typically active-low, so configure for a falling edge trigger.

4. **In the interrupt handler**, set a flag indicating that the I/O expander state has changed.

5. **In the main loop**, when the flag is set, read the I/O expander's input register over I2C to determine which button was pressed, then react accordingly.

{{< alert icon="circle-info" >}}
This combines two peripherals: GPIO interrupts and I2C communication. The interrupt tells you *something* changed, but you still need I2C to find out *what* changed.
{{< /alert >}}
