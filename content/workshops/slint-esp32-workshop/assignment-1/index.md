---
title: "Assignment 1: Environment Setup"
date: 2025-06-03T00:00:00+01:00
showTableOfContents: true
series: ["slint-no-std"]
series_order: 1
showAuthor: false
---

## Assignment 1: Environment Setup with `espup`

In this assignment, we will set up the Rust development environment for embedded `no_std` programming with the ESP32-S3 using the official [`espup`](https://github.com/esp-rs/espup) tool.

Slint supports building applications for microcontrollers like the ESP32-S3 using Rust in `no_std` mode. To achieve this, we need a properly configured Rust toolchain that includes Xtensa target support, which is provided by `espup`.

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

You’re now ready to compile `no_std` Rust applications targeting the ESP32-S3!

---

### Next Step

Now that your environment is ready, let’s run our first Slint GUI app on the desktop.

[Continue to Assignment 2](../assignment-2/)
