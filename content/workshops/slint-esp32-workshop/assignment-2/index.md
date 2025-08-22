

---
title: "Assignment 2: Run GUI on Desktop"
date: 2025-06-03T00:00:00+01:00
showTableOfContents: true
series: ["slint-no-std"]
series_order: 2
showAuthor: false
---

In this assignment, you will run your first Slint application on your desktop. This is a crucial step because Slint is designed to support a cross-platform development workflow — you can develop and preview your UI logic on a desktop machine, and later run it unmodified on an embedded device.

## Goals

- Run a simple Slint-based GUI desktop application
- Learn about the `.slint` UI syntax
- Understand the view-model structure used in this workshop

## Prerequisites

- Rust stable installed with `espup` (see Assignment 1)
- Git
- A desktop platform (Windows, Linux, macOS)
- Rust GUI dependencies installed via `cargo build`

## Step-by-Step Instructions

### 1. Clone the Example Repository

We will use a ready-to-run version of the project from the Slint ESP workshop:

```bash
git clone https://github.com/WilstonOreo/slint-esp-workshop.git
cd slint-esp-workshop/winit
```

### 2. Run the Application

Inside the `winit` directory, launch the desktop version with:

```bash
cargo run --release
```

You should see a GUI window open with two tabs:

- **Slint logo page** – a static graphical layout
- **Wi-Fi list placeholder page** – currently empty, but will later show available access points

If the application launches and you can switch tabs, you're ready to proceed.

---

## About `.slint` Files

The GUI is defined in `.slint` files under the `ui/` directory. Here's a brief overview:

- `appwindow.slint`: the top-level window layout
- `pages.slint`: contains the individual pages (e.g. logo and Wi-Fi list)
- `widgets.slint`: reusable UI elements
- `style.slint`: styling definitions (colors, spacing, fonts)
- `viewmodel.slint`: defines properties exposed to Rust (e.g. selected tab)

### Example:

```slint
export component MainWindow inherits Window {
    in-out property <int> current_tab: 0;

    TabWidget {
        current-tab: root.current_tab;
        Tab { title: "Logo"; /* ... */ }
        Tab { title: "Wi-Fi"; /* ... */ }
    }
}
```

This declarative syntax is both concise and powerful, making UI development intuitive.

---

## View Model Architecture

Slint supports two-way binding between Rust and UI via `in-out` properties and callbacks. The workshop uses a basic MVVM (Model-View-ViewModel) pattern:

- `.slint` defines structure & exposed properties
- `viewmodel.rs` or `main.rs` binds data to UI
- Events are handled in Rust and forwarded to Slint

This keeps rendering declarative and logic testable.

---

## Summary

You’ve now successfully launched a desktop GUI written in Slint. In the next step, you’ll bring this application to your embedded device.

[Continue to Assignment 3 →](../assignment-3/)