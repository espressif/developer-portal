---
title: "Assignment 4: Board Support Package"
date: 2026-05-18T00:00:00+01:00
lastmod: 2026-06-17
showTableOfContents: true
series: ["WS-RUST-ESP"]
series_order: 6
showAuthor: false
---

You've now worked at the **HAL level** (GPIO, I2C with esp-hal) and used **driver crates** (I/O expander). There's one more layer in the stack: the **Board Support Package** (BSP).

A BSP allows us to skip the **Configure** step. The pattern becomes simply **Instantiate → Control**.

## What Is a BSP?

A BSP encapsulates board-specific knowledge — pin assignments, peripheral configuration, and hardware defaults.

### Without BSP (raw HAL)

```rust
// Instantiate
let peripherals = esp_hal::init(Config::default());

// Configure
let led = Output::new(
    peripherals.GPIO5,
    Level::Low,
    OutputConfig::default(),
);

// Control
led.set_high();
```

### With BSP

```rust
// Instantiate (BSP takes HAL peripherals as input)
let peripherals = esp_hal::init(Config::default());
let mut uferris = uferris_init(peripherals).unwrap();

// Control — no configure step needed
uferris.led1_on();
```

The BSP still requires instantiation — you pass the HAL peripherals into the init function. But the board-specific configuration (which pin, what drive strength, which pull resistor) is all handled internally.

## It's Not Magic

The BSP is just Rust code that does exactly what you've been doing — but packages it up with meaningful names. Open the source and you'll see `Output::new()`, `I2c::new()`, and all the same patterns.

The value is:
- **No pin lookup errors** — the board knows its own pin assignments
- **Sensible defaults** — configurations chosen for the specific hardware
- **Convenience** — less boilerplate for common setups

## When to Use a BSP vs. Raw HAL

| Use BSP When | Use Raw HAL When |
|-------------|-----------------|
| Quick prototyping | You need non-default configurations |
| Your board has a BSP | You're using custom hardware |
| You don't need fine control | You want to learn the lower layers |

---

## Exercise: Explore the BSP

**Goal:** Redo your earlier exercises using a BSP. See how the BSP simplifies the pattern to **Instantiate → Control**.

### Step 1: Create a New Project

```bash
esp-generate --chip esp32c3 -o unstable-hal -o vscode -o esp-backtrace -o log --headless bsp_blinky
cd bsp_blinky
```

### Step 2: Read the BSP Source

Open your BSP crate source code. Don't use it yet — just *read* it.

Answer these questions:
1. How does the BSP map pin numbers to named functions?
2. What configuration choices has the BSP author made? (Drive strength? Pull resistors? I2C speed?)
3. Can you find the Instantiate → Configure → Control pattern inside the BSP code?

### Step 3: Redo Blinky with BSP

Refactor your blinky exercise to use the BSP. You still need to instantiate the board, then get the LED from it. Notice how the pin number and configuration are no longer your concern.

### Step 4: Redo Button Input with BSP

Refactor the button exercise. How does the BSP handle:
- Pin assignment?
- Pull-up configuration?

### Step 5: Redo I2C with BSP

Refactor the I2C exercise. The BSP should provide a pre-configured I2C bus — no need to specify pins or clock speed.

### Step 6: Examine the Adapter Layer

Look at the BSP source code for the ESP32-C3 adapter:
- How are HAL types mapped to board-level names?
- What abstractions does the adapter provide?
- Could you write an adapter for a different module?

{{< alert icon="circle-info" >}}
Every layer builds on the one below it. The BSP calls into the HAL, which calls into the PAC, which writes to hardware registers.
{{< /alert >}}
