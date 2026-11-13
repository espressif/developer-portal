---
title: "Getting started with esp-hal: Assignment 3"
date: 2026-11-13
showTableOfContents: true
series: ["WS-RUST-ESP-HAL"]
series_order: 5
showAuthor: false
---

In this assignment, the boards in the room talk to each other directly over ESP-NOW, with no router in between. You'll run a chat room: type a line in the serial monitor and every other board prints it, type a color and every other board's RGB LED changes, or press BOOT to send everyone the next color.

This assignment is a Rust port of [Assignment 5: ESP-NOW Chat Room](https://honza0297.github.io/EN/assignment-5/) from Jan Beran's ESP-IDF and ESP32-C6 workshop. The idea, the commands, the board names, and the wire format all come from Jan's assignment. Because the wire format is the same, **boards running this Rust firmware and boards running Jan's C firmware can share one room**.

## What is ESP-NOW?

ESP-NOW is a connectionless protocol from Espressif that runs on the Wi-Fi radio. It differs from regular Wi-Fi in a few ways:

- **No access point, no connection.** A board doesn't join a network: there is no association, no DHCP, and no IP address. It simply sends a packet, and every board listening on the same Wi-Fi channel can receive it. With so little protocol in the way, sending is fast.
- **Boards are addressed by MAC address.** You send to a *peer*, identified by its Wi-Fi MAC address. The special address `FF:FF:FF:FF:FF:FF` is the broadcast address: every nearby ESP-NOW board receives what you send to it.
- **Small, unordered packets.** One packet carries at most 250 bytes. ESP-NOW doesn't retry or reorder for you, although a direct (not broadcast) packet is acknowledged by the receiving radio, so the sender learns whether it arrived.
- **Optional encryption, but not for broadcast.** Packets to a single peer can be encrypted; broadcasts can't, because there is no single peer to share a key with.

That makes ESP-NOW a good fit for remote controls, synchronized lights, and sensor swarms, or a room full of workshop boards.

## 1. Get the project

The chat room is a bit too big to type in during a workshop: five source files that together show how a real Embassy application is put together. You'll start from the finished project and then read and change it.

Clone the repository:

```bash
git clone https://github.com/Hahihula/esp-now-rgb-rust-demo
cd esp-now-rgb-rust-demo
```

The project supports all the workshop boards from one code base. Each board has a Cargo feature, and `.cargo/config.toml` defines a pair of aliases per board: `cargo build-<board>` only compiles, and `cargo run-<board>` also flashes the board and opens the monitor.

Flash your board:

{{< tabs group="board" >}}
{{< tab label="S31-CoreBoard" >}}
```bash
cargo run-s31
```
{{< /tab >}}
{{< tab label="S31-Korvo-1" >}}
```bash
cargo run-korvo
```
{{< /tab >}}
{{< tab label="C6-DevKitC-1" >}}
```bash
cargo run-c6
```
{{< /tab >}}
{{< tab label="C5-DevKitC-1" >}}
```bash
cargo run-c5
```
{{< /tab >}}
{{< tab label="C3-DevKit-RUST-1" >}}
```bash
cargo run-c3
```
{{< /tab >}}
{{< tab label="C3-LCDkit" >}}
```bash
cargo run-c3-lcdkit
```
{{< /tab >}}
{{< /tabs >}}

After boot, the board introduces itself:

```
INFO - This board is "bear83e8" (1c:29:04:aa:83:e8).
INFO - Broadcast a message, or: red, green, blue, white, on, off.
INFO - Direct message: <8-character name>:<message or command>.
INFO - Type list to print the names and MAC addresses this board knows.
INFO - Press BOOT to send everyone the next color.
```

Each board names itself from its MAC address: a 4-letter animal plus the last two bytes of the MAC in hex. Nobody has to pick a name, and two boards are very unlikely to end up with the same one.

## 2. Try it

The monitor sends every key you press to the board, and the board echoes it back. Try these with your neighbors (in the examples, your board is `bear83e8` and theirs is `wolf1f42`):

| You type | What happens |
|----------|--------------|
| `hello` | Every other board prints `User bear83e8: hello`. |
| `red`, `green`, `blue`, `white`, `on`, `off` | Every other board's LED changes, and it prints `User bear83e8 set your LED to 20,0,0`. |
| `wolf1f42:hello` or `wolf1f42:blue` | Only `wolf1f42` gets it. That board must have sent something first. |
| `list` | Prints the boards yours has heard, with their MAC addresses. Nothing is sent. |
| **BOOT** button | Sends everyone the next color: red, green, blue, white, off, and around again. |

A few rules carried over from the original:

- Only printable ASCII is sent; a line with other characters is refused.
- A line longer than one packet is cut to fit.
- A board never receives its own broadcast.
- The room remembers 19 names: ESP-NOW keeps 20 peers, and one of them is the broadcast address.

## 3. Find your way around the project

| File | What it does |
|------|--------------|
| `src/main.rs` | Start-up, and the chat task: one loop that waits for a packet, a typed line, or a button press |
| `src/chat.rs` | The protocol and the contact book: names, color words, parsing typed lines, encoding and decoding packets. No hardware. |
| `src/console.rs` | Reads keys from the monitor, echoes them, and hands finished lines to the chat task |
| `src/led.rs` | Drives the WS2812 RGB LED with RMT, the async version of what you wrote in Assignment 1 |
| `src/board.rs` | The pin numbers of each board |

The rest of this section walks through the parts that are new compared with Assignment 1.

### 3.1 One code base, many boards

`Cargo.toml` has one feature per board, and each board feature turns on the matching chip feature in every esp-rs crate:

```toml
[features]
c6-devkitc = ["esp32c6"]
c3-lcdkit  = ["esp32c3"]
# ...
esp32c6 = [
    "esp-hal/esp32c6",
    "esp-radio/esp32c6",
    # ...
]
```

`src/board.rs` then defines the pins for the selected board:

```rust
#[cfg(feature = "c6-devkitc")]
macro_rules! board_pins {
    ($p:ident) => {
        ($p.GPIO8, $p.GPIO9, $p.GPIO17)
    };
}
```

It is a macro, not a function, because each board's pins have different types (`GPIO8`, `GPIO60`, ...) and because it moves single fields out of `peripherals` while leaving the rest usable in `main`.

### 3.2 The LED, now async

Compare `src/led.rs` with your Assignment 1 code. The pulse encoding is the same, but the RMT channel is created with `.into_async()`, and sending is a single `await`:

```rust
if let Err(e) = self.channel.transmit(&pulses).await {
    log::warn!("LED update failed: {e:?}");
}
```

In async mode, `transmit()` borrows the channel instead of taking it by value. The future it returns holds the borrow, so the compiler still guarantees that nothing else touches the channel or the `pulses` buffer until the transfer is done, without passing the channel in and out by hand. While the pulses go out, the executor is free to run other tasks.

### 3.3 Starting the radio

The start of `main` sets up everything ESP-NOW needs:

```rust
// The Wi-Fi driver needs a heap.
esp_alloc::heap_allocator!(size: 72 * 1024);

let timg0 = TimerGroup::new(peripherals.TIMG0);
esp_rtos::start(timg0.timer0);
```

- The Wi-Fi driver allocates memory at run time, so the program needs a heap, provided by `esp-alloc`.
- `esp_rtos::start()` starts the scheduler that Embassy and the Wi-Fi driver run on. It needs a hardware timer, here timer 0 of timer group 0.

Then it turns on the Wi-Fi radio and gets ESP-NOW from it:

```rust
let wifi = esp_radio::wifi::WifiController::new(peripherals.WIFI, Default::default())
    .expect("Wi-Fi init failed");
// ESP-NOW starts with the broadcast peer (FF:FF:FF:FF:FF:FF) already added.
let esp_now = wifi.esp_now();
esp_now
    .set_channel(ESP_NOW_CHANNEL)
    .expect("Setting the Wi-Fi channel failed");
let (manager, sender, mut receiver) = esp_now.split();
```

ESP-NOW needs the radio on but doesn't connect to anything. All boards in a room must use the same channel; `ESP_NOW_CHANNEL` is 1, the channel an ESP-IDF station sits on before it joins a router, so it matches the C version.

`split()` hands out three handles: the **manager** adds and removes peers, the **sender** sends, and the **receiver** receives. Each can be owned by a different part of the program.

### 3.4 One loop for everything

The heart of the program is a loop that waits for whichever happens first: a local event (a typed line or a button press) or a packet from the radio.

```rust
loop {
    match select(EVENTS.receive(), receiver.receive_async()).await {
        Either::First(Event::Line(line)) => room.on_line(&line).await,
        Either::First(Event::Button) => room.on_button().await,
        Either::Second(packet) => {
            room.on_packet(&packet.info.src_address, packet.data())
                .await;
        }
    }
}
```

`select` from `embassy-futures` runs two futures at the same time and returns as soon as one of them finishes. Because this one loop owns the contact book, the ESP-NOW handles, and the LED, nothing else can touch them, so no mutex is needed. The ESP-IDF version needs a receive callback, a queue, two tasks, and a mutex to do the same.

### 3.5 Tasks and channels

Typing and the BOOT button are handled by their own Embassy tasks, which pass events to the main loop through a static channel:

```rust
pub static EVENTS: Channel<CriticalSectionRawMutex, Event, 4> = Channel::new();
```

The button task shows how pleasant async GPIO is: no interrupt handler, no polling loop.

```rust
#[embassy_executor::task]
async fn button(pin: AnyPin<'static>) {
    let mut button = Input::new(pin, InputConfig::default().with_pull(Pull::Up));
    loop {
        button.wait_for_falling_edge().await;
        // Let the contacts settle, then check the button is really held.
        Timer::after(Duration::from_millis(20)).await;
        if button.is_high() {
            continue;
        }
        EVENTS.send(Event::Button).await;
        // One press, one event: wait for release, and let the release bounce settle too.
        button.wait_for_high().await;
        Timer::after(Duration::from_millis(50)).await;
    }
}
```

`main` starts it with `spawner.spawn(button(button_pin.into()).unwrap())`. The `.into()` turns the board-specific pin type into `AnyPin`, because a task can't be generic.

`src/console.rs` reads keys from both UART0 and the chip's USB-Serial-JTAG port, because some boards reach your computer through a USB-to-UART bridge and others through the chip's own USB. Whichever connector you plugged in, typing works.

### 3.6 Sending and peers

A packet is the sender's 8-character name, a colon, and the body:

```text
bear83e8:hello      chat text from bear83e8
bear83e8:20,0,0     bear83e8 sets your LED to r=20, g=0, b=0
```

A body of exactly three numbers from 0 to 255 is a color; anything else is chat text. Color words such as `red` never go over the air, only their numbers, so a new color word only has to be known by the board that sends it.

Sending is one call on the sender handle:

```rust
match self.sender.send_async(dest, &packet).await {
    Ok(()) => true,
    // ...
}
```

A broadcast works right away, but a direct send only works to a MAC that has been added as a peer. So the first time a board hears from someone, `Room::remember()` adds them with the manager handle:

```rust
let peer = PeerInfo {
    interface: EspNowWifiInterface::Station,
    peer_address: mac,
    lmk: None,
    channel: None, // the radio's channel, see ESP_NOW_CHANNEL
    encrypt: false,
};
self.manager.add_peer(peer)
```

## 4. Exercises

### 4.1 Teach the room a new color

Add a color word, for example `purple`, and send it to your neighbors. Do their boards need the new firmware to understand it?

Hint: look at `COMMANDS` in `src/chat.rs`.

<details><summary>Show the solution</summary>

Add a row to `COMMANDS` in `src/chat.rs`:

```rust
pub const COMMANDS: &[(&str, Rgb)] = &[
    ("red", Rgb::new(20, 0, 0)),
    ("green", Rgb::new(0, 20, 0)),
    ("blue", Rgb::new(0, 0, 20)),
    ("purple", Rgb::new(12, 0, 20)),
    ("white", Rgb::new(20, 20, 20)),
    ("on", Rgb::new(20, 20, 20)),
    ("off", Rgb::new(0, 0, 0)),
];
```

The other boards don't need new firmware: only the numbers `12,0,20` go over the air.

</details>

### 4.2 Open your own room

With everyone on channel 1, the room gets busy. Agree on a channel from 1 to 13 with the people at your table and move there. Can you still hear the boards on channel 1?

<details><summary>Show the solution</summary>

Change the constant at the top of `src/main.rs` to the channel you agreed on, for example:

```rust
const ESP_NOW_CHANNEL: u8 = 6;
```

Then flash again. You no longer hear the boards on channel 1, and they don't hear you.

</details>

### 4.3 Say thank you

When someone sets your LED, send them a direct message saying `thanks!`.

Hint: the place to do it is `Room::on_packet()` in `src/main.rs`. By the time the color is applied, `remember()` has already added the sender as a peer, so a direct send to `src` works.

<details><summary>Show the solution</summary>

In `Room::on_packet()` in `src/main.rs`, send the reply after setting the LED:

```rust
match chat::parse_rgb(body) {
    Some(rgb) => {
        self.led.set(rgb).await;
        info!(
            "User {} set your LED to {}",
            name_str(&sender),
            chat::encode_color(rgb)
        );
        self.send(src, Body::Text("thanks!")).await;
    }
    None => info!("User {}: {body}", name_str(&sender)),
}
```

The other board prints `User bear83e8: thanks!`. Don't reply to chat text the same way: two boards running that code would thank each other forever.

</details>

## Complete code

The complete project is in the [esp-now-rgb-rust-demo](https://github.com/Hahihula/esp-now-rgb-rust-demo) repository. Cloning it is easier than copying the files below:

```bash
git clone https://github.com/Hahihula/esp-now-rgb-rust-demo
```

<details><summary>Show all project files</summary>

{{< tabs >}}
{{< tab label="src/main.rs" >}}
```rust
//! ESP-NOW chat room with remote RGB LED control.
//!
//! A `no_std` Rust (esp-hal) port of "Assignment 5: ESP-NOW Chat Room" from Jan Beran's
//! ESP-IDF workshop: <https://honza0297.github.io/EN/assignment-5/>.
//!
//! Type in the serial monitor:
//! - `hello`                broadcast a line to every board in the room
//! - `red`, `green`, ...    set everyone else's LED (see `chat::COMMANDS`)
//! - `wolf1f42:hello`       send to one board only (it must have sent something first)
//! - `list`                 print the boards this one has heard
//!
//! Press BOOT to broadcast the next color in `chat::BUTTON_CYCLE`.

#![no_std]
#![no_main]

extern crate alloc;

mod board;
mod chat;
mod console;
mod led;

use chat::{Body, Contacts, Mac, MacFmt, Name, Remembered, Typed, name_str};
use console::{EVENTS, Event};
use embassy_executor::Spawner;
use embassy_futures::select::{Either, select};
use embassy_time::{Duration, Timer};
use esp_backtrace as _;
use esp_hal::{
    clock::CpuClock,
    efuse::{self, InterfaceMacAddress},
    gpio::{AnyPin, Input, InputConfig, Pull},
    timer::timg::TimerGroup,
    uart::{self, UartRx},
    usb::usb_serial_jtag::UsbSerialJtag,
};
use esp_radio::esp_now::{
    BROADCAST_ADDRESS,
    EspNowManager,
    EspNowSender,
    EspNowWifiInterface,
    PeerInfo,
};
use led::Led;
use log::{info, warn};

esp_bootloader_esp_idf::esp_app_desc!();

/// The Wi-Fi channel the radio listens and sends on. Every board in a room must use the same one.
/// Boards running the original ESP-IDF firmware stay on the default channel, 1.
///
/// `set_channel` below calls `esp_wifi_set_channel`, which tunes the radio itself, so broadcasts
/// and direct messages (peers added with `channel: None`) all use this channel.
const ESP_NOW_CHANNEL: u8 = 1;

#[esp_hal::main]
async fn main(spawner: Spawner) -> ! {
    esp_println::logger::init_logger_from_env();
    let peripherals = esp_hal::init(esp_hal::Config::default().with_cpu_clock(CpuClock::max()));

    // The Wi-Fi driver needs a heap.
    esp_alloc::heap_allocator!(size: 72 * 1024);

    let timg0 = TimerGroup::new(peripherals.TIMG0);
    esp_rtos::start(timg0.timer0);

    let (led_pin, button_pin, uart_rx_pin) = board::board_pins!(peripherals);

    // ---- RGB LED, off until someone sets it ----
    let mut led = Led::new(peripherals.RMT, led_pin);
    led.set(chat::Rgb::new(0, 0, 0)).await;

    // ---- Keyboard: listen on UART0 and on USB-Serial-JTAG ----
    let uart_rx = UartRx::new(peripherals.UART0, uart::Config::default())
        .expect("UART0 init failed")
        .with_rx(uart_rx_pin)
        .into_async();
    spawner.spawn(console::uart_console(uart_rx).unwrap());

    let (usb_rx, _usb_tx) = UsbSerialJtag::new(peripherals.USB_DEVICE)
        .into_async()
        .split();
    spawner.spawn(console::usb_console(usb_rx).unwrap());

    // ---- BOOT button ----
    spawner.spawn(button(button_pin.into()).unwrap());

    // ---- Wi-Fi radio on (no router), then ESP-NOW ----
    // `esp_now` holds its own reference to the Wi-Fi driver, so the radio stays on as long as
    // the ESP-NOW handles live, even if `wifi` is dropped.
    let wifi = esp_radio::wifi::WifiController::new(peripherals.WIFI, Default::default())
        .expect("Wi-Fi init failed");
    // ESP-NOW starts with the broadcast peer (FF:FF:FF:FF:FF:FF) already added.
    let esp_now = wifi.esp_now();
    esp_now
        .set_channel(ESP_NOW_CHANNEL)
        .expect("Setting the Wi-Fi channel failed");
    let (manager, sender, mut receiver) = esp_now.split();

    // ---- Our name in the room ----
    let mac = efuse::interface_mac_address(InterfaceMacAddress::Station);
    let mut mac_bytes: Mac = [0; 6];
    mac_bytes.copy_from_slice(mac.as_bytes());
    let me = chat::node_name(&mac_bytes);

    let mut room = Room {
        me,
        contacts: Contacts::default(),
        manager,
        sender,
        led,
        next_button_color: 0,
    };

    info!(
        "Board: {}, ESP-NOW channel {ESP_NOW_CHANNEL}",
        board::BOARD_NAME
    );
    info!(
        "This board is \"{}\" ({}).",
        name_str(&me),
        MacFmt(&mac_bytes)
    );
    info!("Broadcast a message, or: red, green, blue, white, on, off.");
    info!("Direct message: <8-character name>:<message or command>.");
    info!("Type list to print the names and MAC addresses this board knows.");
    info!("Press BOOT to send everyone the next color.");

    loop {
        // `select` polls the first future first. Local events go first: they are rare, so they
        // cannot starve the radio, while a busy room could otherwise delay your typing.
        match select(EVENTS.receive(), receiver.receive_async()).await {
            Either::First(Event::Line(line)) => room.on_line(&line).await,
            Either::First(Event::Button) => room.on_button().await,
            Either::Second(packet) => {
                room.on_packet(&packet.info.src_address, packet.data())
                    .await;
            }
        }
    }
}

/// Everything the chat room owns. Only the main loop touches it, so no locking is needed.
struct Room {
    me: Name,
    contacts: Contacts,
    manager: EspNowManager,
    sender: EspNowSender,
    led: Led,
    next_button_color: usize,
}

impl Room {
    /// A line typed in the monitor.
    async fn on_line(&mut self, line: &[u8]) {
        match chat::parse_line(line) {
            Typed::Nothing => {}
            Typed::NotAscii => warn!("Only ASCII characters are allowed"),
            Typed::List => self.list(),
            Typed::Send {
                to: None,
                body,
                typed,
            } => {
                if self.send(&BROADCAST_ADDRESS, body).await {
                    info!("Sent: {typed}");
                }
            }
            Typed::Send {
                to: Some(name),
                body,
                typed,
            } => {
                let Some(mac) = self.contacts.lookup(&name) else {
                    warn!(
                        "No contact named {} yet. Wait until that board sends something.",
                        name_str(&name)
                    );
                    return;
                };
                if self.send(&mac, body).await {
                    info!("Sent to {}: {typed}", name_str(&name));
                }
            }
        }
    }

    /// BOOT: broadcast the next color in `chat::BUTTON_CYCLE`.
    async fn on_button(&mut self) {
        let word = chat::BUTTON_CYCLE[self.next_button_color];
        self.next_button_color = (self.next_button_color + 1) % chat::BUTTON_CYCLE.len();
        let rgb = chat::find_command(word).expect("BUTTON_CYCLE words are in COMMANDS");
        if self.send(&BROADCAST_ADDRESS, Body::Color(rgb)).await {
            info!("BOOT pressed, sent: {word}");
        }
    }

    /// One ESP-NOW packet from another board.
    async fn on_packet(&mut self, src: &Mac, data: &[u8]) {
        let Some((sender, body)) = chat::decode(data) else {
            if data.len() > chat::NAME_LEN && !chat::is_printable_ascii(data) {
                warn!("Ignored a packet that was not ASCII");
            }
            return;
        };

        // Our own broadcasts never come back to us, so this is a different board. Show nothing
        // of what it sent: printing "User <our name>: ..." would only add to the confusion.
        if sender == self.me {
            warn!(
                "Another board ({}) is using your name {}; ignoring its message",
                MacFmt(src),
                name_str(&sender)
            );
            return;
        }
        self.remember(sender, *src);

        if body.is_empty() {
            return;
        }
        match chat::parse_rgb(body) {
            Some(rgb) => {
                self.led.set(rgb).await;
                info!(
                    "User {} set your LED to {}",
                    name_str(&sender),
                    chat::encode_color(rgb)
                );
            }
            None => info!("User {}: {body}", name_str(&sender)),
        }
    }

    /// Keep the contact book and the ESP-NOW peer list in step.
    /// A direct send only works to a MAC that is a registered peer.
    fn remember(&mut self, name: Name, mac: Mac) {
        let old_mac = match self.contacts.remember(name, mac) {
            Remembered::Known => return,
            Remembered::Full => {
                warn!("Contact book is full, not saving {}", name_str(&name));
                return;
            }
            Remembered::New => None,
            Remembered::Moved { old_mac } => Some(old_mac),
        };

        // Add the new peer first, so a failure leaves the old, working state in place.
        let peer = PeerInfo {
            interface: EspNowWifiInterface::Station,
            peer_address: mac,
            lmk: None,
            channel: None, // the radio's channel, see ESP_NOW_CHANNEL
            encrypt: false,
        };
        if !self.manager.peer_exists(&mac)
            && let Err(e) = self.manager.add_peer(peer)
        {
            warn!(
                "Could not add an ESP-NOW peer for {} ({e:?})",
                name_str(&name)
            );
            match old_mac {
                Some(old_mac) => {
                    self.contacts.remember(name, old_mac);
                }
                None => self.contacts.forget(&name),
            }
            return;
        }

        if let Some(old_mac) = old_mac
            && let Err(e) = self.manager.remove_peer(&old_mac)
        {
            warn!(
                "Could not remove the old ESP-NOW peer {} ({e:?})",
                MacFmt(&old_mac)
            );
        }
        info!("Saved contact {} ({})", name_str(&name), MacFmt(&mac));
    }

    fn list(&self) {
        if self.contacts.is_empty() {
            info!("No contacts yet. Wait until another board sends something.");
            return;
        }
        info!("Known contacts ({}):", self.contacts.len());
        for c in self.contacts.iter() {
            info!("  {}  {}", name_str(&c.name), MacFmt(&c.mac));
        }
    }

    /// Returns `true` once the radio has sent the packet.
    ///
    /// For a direct message the result also says whether the other board acknowledged it.
    /// Broadcasts are never acknowledged, so they always count as sent.
    async fn send(&mut self, dest: &Mac, body: Body<'_>) -> bool {
        let (packet, trimmed) = chat::encode(&self.me, body);
        if trimmed {
            warn!("Trimming the message to {} bytes", chat::MAX_PACKET_LEN);
        }
        match self.sender.send_async(dest, &packet).await {
            Ok(()) => true,
            Err(e) if *dest != BROADCAST_ADDRESS => {
                warn!(
                    "Send failed, no acknowledgement from {} ({e:?})",
                    MacFmt(dest)
                );
                false
            }
            Err(e) => {
                warn!("Send failed: {e:?}");
                false
            }
        }
    }
}

/// Waits for BOOT presses and tells the chat task. The button pulls the pin low.
#[embassy_executor::task]
async fn button(pin: AnyPin<'static>) {
    let mut button = Input::new(pin, InputConfig::default().with_pull(Pull::Up));
    loop {
        button.wait_for_falling_edge().await;
        // Let the contacts settle, then check the button is really held. A bounce or a glitch
        // that is already over does not count.
        Timer::after(Duration::from_millis(20)).await;
        if button.is_high() {
            continue;
        }
        EVENTS.send(Event::Button).await;
        // One press, one event: wait for release, and let the release bounce settle too.
        button.wait_for_high().await;
        Timer::after(Duration::from_millis(50)).await;
    }
}
```
{{< /tab >}}
{{< tab label="src/chat.rs" >}}
```rust
//! The chat room protocol and the contact book. No hardware in here.
//!
//! The wire format is the same as in the original ESP-IDF chat room, so Rust and C boards can
//! share one room:
//!
//! ```text
//! bear83e8:hello      <- chat text from bear83e8
//! bear83e8:20,0,0     <- bear83e8 sets your LED to r=20 g=0 b=0
//! ```
//!
//! Every packet is plain ASCII: the sender's 8-character name, `:`, then the body.
//! Color words such as `red` never go over the air, only their numbers do.

use core::fmt::Write;

/// Every board name is exactly this long.
pub const NAME_LEN: usize = 8;

/// ESP-NOW v1 payload limit (`ESP_NOW_MAX_DATA_LEN`).
pub const MAX_PACKET_LEN: usize = 250;

/// ESP-NOW keeps 20 peers and one is the broadcast address.
pub const MAX_CONTACTS: usize = 19;

pub type Name = [u8; NAME_LEN];
pub type Mac = [u8; 6];
pub type Packet = heapless::Vec<u8, MAX_PACKET_LEN>;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Rgb {
    pub r: u8,
    pub g: u8,
    pub b: u8,
}

impl Rgb {
    pub const fn new(r: u8, g: u8, b: u8) -> Self {
        Self { r, g, b }
    }
}

/// Add a row to teach the room a new color word. Other boards only ever see the numbers.
pub const COMMANDS: &[(&str, Rgb)] = &[
    ("red", Rgb::new(20, 0, 0)),
    ("green", Rgb::new(0, 20, 0)),
    ("blue", Rgb::new(0, 0, 20)),
    ("white", Rgb::new(20, 20, 20)),
    ("on", Rgb::new(20, 20, 20)),
    ("off", Rgb::new(0, 0, 0)),
];

/// Colors the BOOT button cycles through.
pub const BUTTON_CYCLE: &[&str] = &["red", "green", "blue", "white", "off"];

pub fn find_command(word: &str) -> Option<Rgb> {
    COMMANDS
        .iter()
        .find(|(name, _)| *name == word)
        .map(|(_, rgb)| *rgb)
}

/// Printable ASCII only (0x20..=0x7E), like the original.
pub fn is_printable_ascii(bytes: &[u8]) -> bool {
    bytes.iter().all(|b| (0x20..=0x7E).contains(b))
}

const ANIMALS: [&str; 16] = [
    "bear", "wolf", "lynx", "seal", "crab", "frog", "duck", "goat", "hawk", "mole", "newt", "swan",
    "toad", "moth", "deer", "orca",
];

/// A 4-letter animal picked from the MAC, then the last two MAC bytes in hex: `bear83e8`.
/// Same recipe as the C version, so a board keeps its name whichever firmware it runs.
pub fn node_name(mac: &Mac) -> Name {
    let animal = ANIMALS[usize::from(mac[3] ^ mac[4] ^ mac[5]) % ANIMALS.len()];
    let mut s: heapless::String<NAME_LEN> = heapless::String::new();
    write!(s, "{animal}{:02x}{:02x}", mac[4], mac[5]).expect("a name is 4 + 2 * 2 characters");
    let mut name = [0; NAME_LEN];
    name.copy_from_slice(s.as_bytes());
    name
}

pub fn name_str(name: &Name) -> &str {
    // Names are only ever built from printable ASCII.
    core::str::from_utf8(name).unwrap_or("????????")
}

/// `"20,0,0"` is a color. Anything else, including extra characters or spaces, is chat text.
pub fn parse_rgb(s: &str) -> Option<Rgb> {
    let mut parts = s.split(',');
    let mut next = || -> Option<u8> {
        let part = parts.next()?;
        if part.is_empty() || part.len() > 3 || !part.bytes().all(|b| b.is_ascii_digit()) {
            return None;
        }
        part.parse().ok()
    };
    let rgb = Rgb::new(next()?, next()?, next()?);
    if parts.next().is_some() {
        return None;
    }
    Some(rgb)
}

/// What goes after `<name>:` in a packet.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Body<'a> {
    Text(&'a str),
    /// Sent as its numbers, so the receiver needs no word list.
    Color(Rgb),
}

/// `"20,0,0"`: at most 3 digits per channel, so it always fits.
pub type ColorText = heapless::String<11>;

pub fn encode_color(rgb: Rgb) -> ColorText {
    let mut s = ColorText::new();
    write!(s, "{},{},{}", rgb.r, rgb.g, rgb.b).expect("3 * 3 digits + 2 commas");
    s
}

/// `"<name>:<body>"`, cut to fit one ESP-NOW packet. The flag says whether it was cut.
pub fn encode(from: &Name, body: Body<'_>) -> (Packet, bool) {
    let color;
    let text = match body {
        Body::Text(text) => text.as_bytes(),
        Body::Color(rgb) => {
            color = encode_color(rgb);
            color.as_bytes()
        }
    };

    let mut packet = Packet::new();
    // The name and ':' are 9 bytes; the text is cut to the space left, so nothing overflows.
    let room = MAX_PACKET_LEN - (NAME_LEN + 1);
    let len = text.len().min(room);
    packet.extend_from_slice(from).unwrap();
    packet.push(b':').unwrap();
    packet.extend_from_slice(&text[..len]).unwrap();
    (packet, len < text.len())
}

/// Splits a received packet into sender and body. `None` if it is not a chat packet.
pub fn decode(data: &[u8]) -> Option<(Name, &str)> {
    if data.len() < NAME_LEN + 1 || data[NAME_LEN] != b':' || !is_printable_ascii(data) {
        return None;
    }
    let mut name = [0; NAME_LEN];
    name.copy_from_slice(&data[..NAME_LEN]);
    let body = core::str::from_utf8(&data[NAME_LEN + 1..]).ok()?;
    Some((name, body))
}

/// What a line typed in the monitor asks for.
#[derive(Debug, PartialEq, Eq)]
pub enum Typed<'a> {
    /// Empty line, or a direct message with nothing after the colon.
    Nothing,
    /// The line has bytes outside printable ASCII.
    NotAscii,
    /// `list`: print the contact book. Nothing is sent.
    List,
    /// Send `body`, to everyone (`to: None`) or to one contact. `typed` is the body as typed,
    /// for the "Sent: ..." log line.
    Send {
        to: Option<Name>,
        body: Body<'a>,
        typed: &'a str,
    },
}

/// Turns a typed line into an [`Typed`]. All command words live here or in [`COMMANDS`].
pub fn parse_line(line: &[u8]) -> Typed<'_> {
    if line.is_empty() {
        return Typed::Nothing;
    }
    if !is_printable_ascii(line) {
        return Typed::NotAscii;
    }
    // Printable ASCII is valid UTF-8.
    let Ok(line) = core::str::from_utf8(line) else {
        return Typed::NotAscii;
    };
    if line == "list" {
        return Typed::List;
    }

    // `<8-character name>:<body>` is a direct message.
    let (to, typed) = match line.as_bytes().get(NAME_LEN) {
        Some(b':') => {
            let mut name = [0; NAME_LEN];
            name.copy_from_slice(&line.as_bytes()[..NAME_LEN]);
            (Some(name), &line[NAME_LEN + 1..])
        }
        _ => (None, line),
    };
    if typed.is_empty() {
        return Typed::Nothing;
    }

    let body = match find_command(typed) {
        Some(rgb) => Body::Color(rgb),
        None => Body::Text(typed),
    };
    Typed::Send { to, body, typed }
}

#[derive(Clone, Copy)]
pub struct Contact {
    pub name: Name,
    pub mac: Mac,
}

/// What `Contacts::remember` changed, so the caller can update the ESP-NOW peer list.
pub enum Remembered {
    /// Seen before with the same MAC. Nothing to do.
    Known,
    /// A new board. Add its MAC as a peer.
    New,
    /// A known name came from a different MAC. Replace the old peer with the new one.
    Moved { old_mac: Mac },
    /// The book is full.
    Full,
}

/// Names this board has heard, with the MAC each one came from.
#[derive(Default)]
pub struct Contacts {
    entries: heapless::Vec<Contact, MAX_CONTACTS>,
}

impl Contacts {
    pub fn lookup(&self, name: &Name) -> Option<Mac> {
        self.entries.iter().find(|c| &c.name == name).map(|c| c.mac)
    }

    pub fn remember(&mut self, name: Name, mac: Mac) -> Remembered {
        if let Some(contact) = self.entries.iter_mut().find(|c| c.name == name) {
            if contact.mac == mac {
                return Remembered::Known;
            }
            let old_mac = core::mem::replace(&mut contact.mac, mac);
            return Remembered::Moved { old_mac };
        }
        match self.entries.push(Contact { name, mac }) {
            Ok(()) => Remembered::New,
            Err(_) => Remembered::Full,
        }
    }

    /// Undo a `New` when the ESP-NOW peer could not be added. (Undo a `Moved` by remembering
    /// the old MAC again.)
    pub fn forget(&mut self, name: &Name) {
        self.entries.retain(|c| &c.name != name);
    }

    pub fn iter(&self) -> impl Iterator<Item = &Contact> {
        self.entries.iter()
    }

    pub fn len(&self) -> usize {
        self.entries.len()
    }

    pub fn is_empty(&self) -> bool {
        self.entries.is_empty()
    }
}

pub struct MacFmt<'a>(pub &'a Mac);

impl core::fmt::Display for MacFmt<'_> {
    fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
        let m = self.0;
        write!(
            f,
            "{:02x}:{:02x}:{:02x}:{:02x}:{:02x}:{:02x}",
            m[0], m[1], m[2], m[3], m[4], m[5]
        )
    }
}
```
{{< /tab >}}
{{< tab label="src/console.rs" >}}
```rust
//! Keyboard input from the serial monitor.
//!
//! `espflash monitor` (and `cargo run-<board>`, which ends in it) sends every key you press to
//! the board. Dev boards reach the PC either through a USB-to-UART bridge chip (UART0) or the
//! chip's own USB-Serial-JTAG port, and some boards have both. We listen on both, so it does not
//! matter which USB connector you plugged in.
//!
//! Each listener echoes what you type and hands finished lines to the chat task.

use embassy_sync::{blocking_mutex::raw::CriticalSectionRawMutex, channel::Channel};
use esp_hal::{Async, uart::UartRx, usb::usb_serial_jtag::UsbSerialJtagRx};
use esp_println::print;

/// Longer lines are cut; a packet only carries 250 bytes anyway.
pub const LINE_MAX: usize = 256;

/// Raw bytes as typed. The chat task decides whether they are acceptable (printable ASCII).
pub type Line = heapless::Vec<u8, LINE_MAX>;

/// Everything that can wake up the chat task besides an incoming packet.
// `Line` is much bigger than `Button`; with a 4-slot queue that costs about 1 KiB, which is fine.
#[allow(clippy::large_enum_variant)]
pub enum Event {
    Line(Line),
    Button,
}

pub static EVENTS: Channel<CriticalSectionRawMutex, Event, 4> = Channel::new();

/// A tiny line editor: echo, backspace, Enter.
#[derive(Default)]
struct LineEditor {
    line: Line,
}

impl LineEditor {
    async fn feed(&mut self, bytes: &[u8]) {
        for &byte in bytes {
            match byte {
                b'\r' | b'\n' => {
                    print!("\r\n");
                    let line = core::mem::take(&mut self.line);
                    // "\r\n" gives an empty second line; the chat task ignores those.
                    EVENTS.send(Event::Line(line)).await;
                }
                0x08 | 0x7F => {
                    if self.line.pop().is_some() {
                        print!("\x08 \x08");
                    }
                }
                // Every byte we keep is echoed as exactly one column, so backspace stays in step.
                // Non-ASCII bytes are kept (shown as `?`) so the chat task refuses the line, like
                // the original does. A multi-byte UTF-8 character shows as several `?`.
                0x20.. => {
                    if self.line.push(byte).is_err() {
                        continue; // line is full
                    }
                    let shown = if byte < 0x7F { char::from(byte) } else { '?' };
                    print!("{shown}");
                }
                _ => {} // other control characters
            }
        }
    }
}

#[embassy_executor::task]
pub async fn uart_console(mut rx: UartRx<'static, Async>) {
    let mut editor = LineEditor::default();
    let mut buf = [0u8; 64];
    loop {
        match rx.read_async(&mut buf).await {
            Ok(n) => editor.feed(&buf[..n]).await,
            Err(e) => log::debug!("UART RX error: {e:?}"),
        }
    }
}

#[embassy_executor::task]
pub async fn usb_console(mut rx: UsbSerialJtagRx<'static, Async>) {
    let mut editor = LineEditor::default();
    let mut buf = [0u8; 64];
    loop {
        // USB-Serial-JTAG reads cannot fail (the error type is `Infallible`).
        let Ok(n) = embedded_io_async::Read::read(&mut rx, &mut buf).await;
        editor.feed(&buf[..n]).await;
    }
}
```
{{< /tab >}}
{{< tab label="src/led.rs" >}}
```rust
//! A single WS2812 ("NeoPixel") RGB LED driven by the RMT peripheral.
//!
//! The LED reads 24 bits (green, red, blue; most significant bit first). Each bit is one high
//! pulse followed by one low pulse, and only the pulse lengths tell a 0 from a 1. RMT is a
//! peripheral made for exactly that: we hand it a list of `PulseCode`s and it plays them on a
//! pin with exact timing, while the CPU does something else.

use embassy_time::Timer;
use esp_hal::{
    Async,
    gpio::{Level, interconnect::PeripheralOutput},
    peripherals::RMT,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};

use crate::chat::Rgb;

/// RMT tick frequency. With `clk_divider(1)` one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

// WS2812 timing in ticks of 12.5 ns (datasheet: T0H 0.4 us, T0L 0.85 us, T1H 0.8 us, T1L 0.45 us).
const T0H: u16 = 32;
const T0L: u16 = 68;
const T1H: u16 = 64;
const T1L: u16 = 36;

/// Reset (latch) time in microseconds.
const RESET_US: u64 = 300;

pub struct Led {
    channel: Channel<'static, Async, Tx>,
}

impl Led {
    pub fn new(rmt: RMT<'static>, pin: impl PeripheralOutput<'static>) -> Self {
        let rmt = Rmt::new(rmt, Rate::from_mhz(RMT_FREQ_MHZ))
            .expect("RMT init failed")
            .into_async();
        let channel = rmt
            .channel0
            .configure_tx(
                &TxChannelConfig::default()
                    .with_clk_divider(1)
                    .with_idle_output(true)
                    .with_idle_output_level(Level::Low),
            )
            .expect("RMT channel config failed")
            .with_pin(pin);
        Self { channel }
    }

    pub async fn set(&mut self, color: Rgb) {
        let zero = PulseCode::new(Level::High, T0H, Level::Low, T0L);
        let one = PulseCode::new(Level::High, T1H, Level::Low, T1L);

        // 24 data bits plus the end marker. The LED latches the color once the line stays low.
        let mut pulses = [PulseCode::end_marker(); 25];
        let grb = u32::from(color.g) << 16 | u32::from(color.r) << 8 | u32::from(color.b);
        for (i, pulse) in pulses.iter_mut().take(24).enumerate() {
            *pulse = if grb & (1 << (23 - i)) != 0 {
                one
            } else {
                zero
            };
        }

        if let Err(e) = self.channel.transmit(&pulses).await {
            log::warn!("LED update failed: {e:?}");
        }
        // The LED shows the new color only after the line has been low for the reset time.
        // Wait it out here, so a quick second update cannot run into this one. Newer WS2812B
        // parts need 280 us, older ones 50 us.
        Timer::after_micros(RESET_US).await;
    }
}
```
{{< /tab >}}
{{< tab label="src/board.rs" >}}
```rust
//! Board pin map.
//!
//! Exactly one board feature is enabled, normally by a cargo alias such as `cargo run-c6`.
//! Adding a new board means: a feature in `Cargo.toml`, an alias in `.cargo/config.toml`
//! and one `cfg` block here.

#[cfg(not(any(
    feature = "s31-function-coreboard",
    feature = "s31-korvo",
    feature = "c6-devkitc",
    feature = "c5-devkitc",
    feature = "c3-rust-board",
    feature = "c3-lcdkit",
)))]
compile_error!(
    "Select a board, for example `cargo run-c6`. See the [alias] table in .cargo/config.toml."
);

/// Takes the board's pins out of `esp_hal::Peripherals`:
/// `(RGB LED data pin, BOOT button pin, UART0 RX pin)`.
///
/// It is a macro rather than a function because it moves single fields out of the
/// peripherals struct; the rest stays usable in `main`.
#[cfg(feature = "s31-function-coreboard")]
macro_rules! board_pins {
    ($p:ident) => {
        ($p.GPIO60, $p.GPIO61, $p.GPIO59)
    };
}
#[cfg(feature = "s31-function-coreboard")]
pub const BOARD_NAME: &str = "ESP32-S31-Function-CoreBoard-1";

#[cfg(feature = "s31-korvo")]
macro_rules! board_pins {
    ($p:ident) => {
        ($p.GPIO37, $p.GPIO61, $p.GPIO59)
    };
}
#[cfg(feature = "s31-korvo")]
pub const BOARD_NAME: &str = "ESP32-S31-Korvo-1";

#[cfg(feature = "c6-devkitc")]
macro_rules! board_pins {
    ($p:ident) => {
        ($p.GPIO8, $p.GPIO9, $p.GPIO17)
    };
}
#[cfg(feature = "c6-devkitc")]
pub const BOARD_NAME: &str = "ESP32-C6-DevKitC-1";

#[cfg(feature = "c5-devkitc")]
macro_rules! board_pins {
    ($p:ident) => {
        ($p.GPIO27, $p.GPIO28, $p.GPIO12)
    };
}
#[cfg(feature = "c5-devkitc")]
pub const BOARD_NAME: &str = "ESP32-C5-DevKitC-1";

#[cfg(feature = "c3-rust-board")]
macro_rules! board_pins {
    ($p:ident) => {
        ($p.GPIO2, $p.GPIO9, $p.GPIO20)
    };
}
#[cfg(feature = "c3-rust-board")]
pub const BOARD_NAME: &str = "ESP32-C3-DevKit-RUST-1";

// The rotary encoder's push switch is wired to GPIO9, the ESP32-C3 BOOT strapping pin.
#[cfg(feature = "c3-lcdkit")]
macro_rules! board_pins {
    ($p:ident) => {
        ($p.GPIO8, $p.GPIO9, $p.GPIO20)
    };
}
#[cfg(feature = "c3-lcdkit")]
pub const BOARD_NAME: &str = "ESP32-C3-LCDkit";

pub(crate) use board_pins;

// Two boards at once would define the pins twice. Fail with a clear message instead.
const _: () = assert!(
    (cfg!(feature = "s31-function-coreboard") as u8
        + cfg!(feature = "s31-korvo") as u8
        + cfg!(feature = "c6-devkitc") as u8
        + cfg!(feature = "c5-devkitc") as u8
        + cfg!(feature = "c3-rust-board") as u8
        + cfg!(feature = "c3-lcdkit") as u8)
        <= 1,
    "Select exactly one board feature."
);
```
{{< /tab >}}
{{< tab label="Cargo.toml" >}}
```toml
[package]
name        = "esp-now-rgb-rust-demo"
version     = "0.1.0"
edition     = "2024"
publish     = false
description = "ESP-NOW chat room with remote RGB LED control. no_std Rust port of Jan Beran's ESP-IDF workshop Assignment 5."

[[bin]]
name = "esp-now-rgb-rust-demo"
path = "src/main.rs"
test = false
bench = false

[dependencies]
embassy-executor       = "0.10.0"
embassy-futures        = "0.1"
embassy-sync           = "0.8"
embassy-time           = "0.5.0"
embedded-io-async      = "0.7"
esp-alloc              = "0.11.0"
esp-backtrace          = { version = "0.20.0", features = ["panic-handler", "println"] }
esp-bootloader-esp-idf = "0.6.0"
esp-hal                = { version = "1.2.0", features = ["log-04", "unstable"] }
esp-println            = { version = "0.18.0", features = ["log-04"] }
esp-radio              = { version = "1.0.0-beta.2", features = ["esp-now", "log-04", "unstable", "wifi"] }
esp-rtos               = { version = "0.4.0", features = ["embassy", "esp-radio", "log-04"] }
heapless               = "0.9"
log                    = "0.4"
static_cell            = "2.1.1"

[features]
# ---- Boards: select exactly one (the cargo aliases in .cargo/config.toml do it for you) ----
s31-function-coreboard = ["esp32s31"]
s31-korvo              = ["esp32s31"]
c6-devkitc             = ["esp32c6"]
c5-devkitc             = ["esp32c5"]
c3-rust-board          = ["esp32c3"]
c3-lcdkit              = ["esp32c3"]

# ---- Chips: selected by the board features above ----
esp32c3 = [
    "esp-alloc/esp32c3",
    "esp-backtrace/esp32c3",
    "esp-bootloader-esp-idf/esp32c3",
    "esp-hal/esp32c3",
    "esp-println/esp32c3",
    "esp-radio/esp32c3",
    "esp-rtos/esp32c3",
]
esp32c5 = [
    "esp-alloc/esp32c5",
    "esp-backtrace/esp32c5",
    "esp-bootloader-esp-idf/esp32c5",
    "esp-hal/esp32c5",
    "esp-println/esp32c5",
    "esp-radio/esp32c5",
    "esp-rtos/esp32c5",
]
esp32c6 = [
    "esp-alloc/esp32c6",
    "esp-backtrace/esp32c6",
    "esp-bootloader-esp-idf/esp32c6",
    "esp-hal/esp32c6",
    "esp-println/esp32c6",
    "esp-radio/esp32c6",
    "esp-rtos/esp32c6",
]
esp32s31 = [
    "esp-alloc/esp32s31",
    "esp-backtrace/esp32s31",
    "esp-bootloader-esp-idf/esp32s31",
    "esp-hal/esp32s31",
    "esp-println/esp32s31",
    "esp-radio/esp32s31",
    "esp-rtos/esp32s31",
]

# ESP32-S31 support is not in a crates.io release yet. This esp-hal revision is from 2026-10-15
# (the same one esp-touch-paint uses).
[patch.crates-io]
esp-alloc              = { git = "https://github.com/esp-rs/esp-hal", rev = "8a70d09fe0065d5387dac82e4fbe937e95e496e1" }
esp-backtrace          = { git = "https://github.com/esp-rs/esp-hal", rev = "8a70d09fe0065d5387dac82e4fbe937e95e496e1" }
esp-bootloader-esp-idf = { git = "https://github.com/esp-rs/esp-hal", rev = "8a70d09fe0065d5387dac82e4fbe937e95e496e1" }
esp-hal                = { git = "https://github.com/esp-rs/esp-hal", rev = "8a70d09fe0065d5387dac82e4fbe937e95e496e1" }
esp-println            = { git = "https://github.com/esp-rs/esp-hal", rev = "8a70d09fe0065d5387dac82e4fbe937e95e496e1" }
esp-radio              = { git = "https://github.com/esp-rs/esp-hal", rev = "8a70d09fe0065d5387dac82e4fbe937e95e496e1" }
esp-rtos               = { git = "https://github.com/esp-rs/esp-hal", rev = "8a70d09fe0065d5387dac82e4fbe937e95e496e1" }

[profile.dev]
opt-level = "s"

[profile.release]
codegen-units    = 1
debug            = true
debug-assertions = false
lto              = "fat"
opt-level        = "s"
```
{{< /tab >}}
{{< tab label=".cargo/config.toml" >}}
```toml
[target.riscv32imc-unknown-none-elf]
runner = "espflash flash --monitor"
rustflags = [
  "-C", "link-arg=-Tlinkall.x",
  "-C", "force-frame-pointers",
]

[target.riscv32imac-unknown-none-elf]
runner = "espflash flash --monitor"
rustflags = [
  "-C", "link-arg=-Tlinkall.x",
  "-C", "force-frame-pointers",
]

[target.riscv32imafc-unknown-none-elf]
runner = "espflash flash --monitor"
rustflags = [
  "-C", "link-arg=-Tlinkall.x",
  "-C", "force-frame-pointers",
]

[env]
ESP_LOG = "info"

[unstable]
build-std = ["alloc", "core"]

# One build/run pair per board. `cargo run-<board>` builds, flashes and opens the monitor.
[alias]
# ESP32-S31-Function-CoreBoard-1: RGB LED GPIO60, BOOT GPIO61
build-s31        = ["build", "--release", "--target", "riscv32imafc-unknown-none-elf", "--features", "s31-function-coreboard"]
run-s31          = ["run",   "--release", "--target", "riscv32imafc-unknown-none-elf", "--features", "s31-function-coreboard"]
# ESP32-S31-Korvo-1: RGB LED GPIO37, BOOT GPIO61
build-korvo      = ["build", "--release", "--target", "riscv32imafc-unknown-none-elf", "--features", "s31-korvo"]
run-korvo        = ["run",   "--release", "--target", "riscv32imafc-unknown-none-elf", "--features", "s31-korvo"]
# ESP32-C6-DevKitC-1: RGB LED GPIO8, BOOT GPIO9
build-c6         = ["build", "--release", "--target", "riscv32imac-unknown-none-elf",  "--features", "c6-devkitc"]
run-c6           = ["run",   "--release", "--target", "riscv32imac-unknown-none-elf",  "--features", "c6-devkitc"]
# ESP32-C5-DevKitC-1: RGB LED GPIO27, BOOT GPIO28
build-c5         = ["build", "--release", "--target", "riscv32imac-unknown-none-elf",  "--features", "c5-devkitc"]
run-c5           = ["run",   "--release", "--target", "riscv32imac-unknown-none-elf",  "--features", "c5-devkitc"]
# ESP32-C3-DevKit-RUST-1: RGB LED GPIO2, BOOT GPIO9
build-c3         = ["build", "--release", "--target", "riscv32imc-unknown-none-elf",   "--features", "c3-rust-board"]
run-c3           = ["run",   "--release", "--target", "riscv32imc-unknown-none-elf",   "--features", "c3-rust-board"]
# ESP32-C3-LCDkit (MB board): RGB LED GPIO8, rotary encoder switch GPIO9 (= BOOT)
build-c3-lcdkit  = ["build", "--release", "--target", "riscv32imc-unknown-none-elf",   "--features", "c3-lcdkit"]
run-c3-lcdkit    = ["run",   "--release", "--target", "riscv32imc-unknown-none-elf",   "--features", "c3-lcdkit"]
```
{{< /tab >}}
{{< tab label="rust-toolchain.toml" >}}
```toml
[toolchain]
channel    = "nightly-2026-09-17"
components = ["rust-src", "rustfmt", "clippy"]
targets    = [
    "riscv32imc-unknown-none-elf",   # ESP32-C3
    "riscv32imac-unknown-none-elf",  # ESP32-C5, ESP32-C6
    "riscv32imafc-unknown-none-elf", # ESP32-S31
]
```
{{< /tab >}}
{{< /tabs >}}

</details>

## What you learned

In this assignment, you:

- Learned what ESP-NOW is and how it differs from regular Wi-Fi
- Built one firmware for several boards with Cargo features and aliases
- Started the Wi-Fi radio with `esp-radio` and sent and received ESP-NOW broadcasts and direct messages
- Used Embassy tasks, channels, and `select` to wait for several things at once without locks
- Drove the RMT peripheral and GPIO inputs with async esp-hal APIs

## Next step

[Conclusion](../conclusion/)

[Return to the workshop main page](/workshops/rust-esp-hal-intro/)
