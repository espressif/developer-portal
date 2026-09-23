---
title: "Assignment 1: Environment Setup"
date: 2025-06-03T00:00:00+01:00
showTableOfContents: true
series: ["slint-no-std"]
series_order: 1
showAuthor: false
---

## Assignment 1: Environment Setup

In this assignment, we will set up the Rust development environment for ESP32-S3 programming using the official [`espup`](https://github.com/esp-rs/espup) tool.

Slint supports building applications for microcontrollers like the ESP32-S3 using Rust in both `no_std` (bare-metal) and `std` (ESP-IDF) modes. **This workshop primarily uses the `no_std` approach** due to its simplicity and better performance.

---

### Step 1: Install Rust

Install the Rust stable toolchain using `rustup` if you haven't already:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Once installed, ensure you have the latest stable toolchain:

```sh
rustup update
```

---

### Step 2: Install `espup`

We recommend installing `espup` using Cargo:

```sh
cargo install espup --locked
```

Alternatively, you may use pre-built binaries or `cargo-binstall` (see espup GitHub README for details).

---

### Step 3: Run `espup install`

To install the toolchain for **no_std** development (which includes the GCC linker), run:

```sh
espup install
```

This will install:

- The Espressif Xtensa Rust toolchain
- LLVM with Xtensa backend
- GCC cross compiler
- `export-esp.sh` file containing environment variables

You may customize targets like so:

```sh
espup install --targets esp32s3
```

⚠️ Do **not** use the `--std` flag — we are developing in `no_std`.

---

### Step 4: Source the environment variables (Unix-based systems)

After `espup install`, you'll find `export-esp.sh` under `$HOME`.

You need to load this file to correctly configure your environment:

#### Temporary (for current shell)

```sh
. $HOME/export-esp.sh
```

#### Persistent (recommended)

Append the export file to your shell configuration (e.g. `.bashrc`, `.zshrc`):

```sh
cat $HOME/export-esp.sh >> ~/.bashrc
```

Then:

```sh
source ~/.bashrc
```

On **Windows**, this is done automatically.

---

### Step 5: Verify the installation

Check that the Rust Xtensa toolchain is active:

```sh
rustc --version
cargo --version
```

Check that `espflash` is installed:

```sh
cargo install espflash
```

You're now ready to compile `no_std` Rust applications targeting the ESP32-S3!

---

## Development Approach: `no_std` vs `std`

### `no_std` Approach

**This workshop uses the `no_std` approach by default.** The setup above is perfect for `no_std` development.

**Project Directory Structure:**
```
esp32/no_std/
├── m5stack-cores3/          # M5Stack CoreS3 implementation
├── esope-sld-c-w-s3/        # ESoPe board implementation  
├── esp32-s3-box-3/          # ESP32-S3-BOX-3 implementation
└── esp32-s3-lcd-ev-board/   # LCD-EV board implementation
```

### `std` Approach

**If you specifically need ESP-IDF/std features**, you can also set up for `std` development:

```sh
# For std development, install with --std flag
espup install --std
```

**Project Directory Structure:**
```
esp32/std/
├── m5stack-cores3/          # M5Stack CoreS3 std implementation
├── esope-sld-c-w-s3/        # ESoPe board std implementation
├── esp32-s3-box-3/          # ESP32-S3-BOX-3 std implementation
└── esp32-s3-lcd-ev-board/   # LCD-EV board std implementation
```

**Note:** `std` approach requires additional ESP-IDF setup and is more complex. **We recommend starting with `no_std`** for this workshop.

---

### Next Step

Now that your environment is ready, let’s run our first Slint GUI app on the desktop.

[Continue to Assignment 2](../assignment-2/)
