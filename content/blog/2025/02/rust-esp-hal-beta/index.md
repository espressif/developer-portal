---
title: "esp-hal 1.0.0 beta announcement"
date: 2025-02-24
featureAsset: "img/featured/featured-rust.webp"
authors:
  - scott-mabin
tags:
  - Esp32
  - Rust
  - Xtensa
  - RISCV
  - Announcement

---

We're excited to announce the `1.0.0-beta.0` release for `esp-hal`, the _first_ vendor-backed Rust SDK! This has been a nearly 6 year long process to get to this point, and we now feel we have a solid 1.0 strategy.

Let us take you on the journey of how we got here. If you're just interested in what we're stabilizing today, [click here](#targeting-stability) to jump to it.

### Where It All Started

In 2019, I created the esp-rs organization, which laid dormant for some time. At the time, [Espressif] was exclusively using the [Xtensa] architecture for their chips which, whilst powerful, had one big caveat for Rust support: there was no LLVM backend for Xtensa. I tried to use [mrustc] to cross-compile Rust to C, and then use the GCC Xtensa toolchain but whilst I had some minor success the workflow was far too cumbersome.

Fast-forward a few months and Espressif announced the first iteration of their [Xtensa enabled LLVM fork] with the intention of getting it upstreamed. I was excited about this, and I got to work integrating this Xtensa enabled LLVM into the Rust compiler. I succeeded, with a lot of help from members of the Rust community and a reference set of PRs for RISC-V which had been merged just a bit earlier in the year. This project was set aside for a while, but I got back to it and managed to write the world's first Rust blinky on an ESP32! I documented my early findings in a series of [posts on my personal website]. I read these posts again (mostly to remind myself what on earth I was doing 5 years ago), and one quote from my first post stood out to me.

> Now I know what most of you are thinking at this point, it's not very Rusty; it contains bundles of unsafe code and there are no real abstractions here, and you are right; but it's something to get the ball rolling.

It's safe to say the ball definitely rolled.

### Espressif’s Official Support for Rust

Not long after that initial blog post, Espressif started sponsoring my work and allowed me to continue working on it in my spare time. At the same time, the community around esp-rs was starting to grow, and I really can't thank these early contributors enough. Myself and a few early contributors, namely [@jessebraham], and [@arjanmels] mostly focussed on the `no_std` side of things. Initially [@reitermarkus] and eventually [@ivmarkov] ported the Rust standard library which built on [ESP-IDF]. This was a great addition as it gave us a big head start because we could use the stable and tested code from ESP-IDF without having to write all the drivers from scratch for `no_std` immediately.

Espressif had been observing our work (and may I add, were _extremely_ helpful in answering any questions we had) and by 2021, they were keen to adopt it officially. They reached out to me and some other community contributors about a position in a newly forming Rust team, and I, along with [@jessebraham] gladly accepted.

### Bringing Up the Ecosystem

It has been possible to write embedded Rust applications on stable since 2018. Most of the ecosystem, however, revolved around chips using the ARM architecture, which posed a bit of an uphill battle for us. Espressif had just released its last Xtensa chip (the ESP32-S3) and was now bringing out RISC-V based chips.

Whilst most crates in the embedded Rust ecosystem are architecture independent, the tooling is a different story. Over the years we've spent _a lot_ of time contributing to various open source projects, like [probe-rs] to either improve, or in the case of Xtensa, add support. This work is still on going, but we're quite happy with the usability of the tooling on our chips now.

Xtensa based chips posed many challenges for us. We ended up writing [xtensa-lx and xtensa-lx-rt] using the proprietary (at the time, Cadence, the owners of the Xtensa IP have since released an open version) Xtensa instruction set manual. There was at least _some_ runtime/startup support for RISC-V, but absolutely nothing for Xtensa in the Rust ecosystem.

Another challenge we faced is that we were the primary users of the LLVM Xtensa fork. This meant when there was a bug in code-generation we were the unfortunate souls to run into it. This ate copious amounts of developer time, but in the end it was worth it, as the backend is in good shape now. There is also a huge amount of progress to report on the upstreaming front for LLVM (which was stalled for a long, long time). Most of the base ISA is now in LLVM proper, and the remaining patches can be submitted in parallel, see [the tracking issue] for more details.

### Focusing on `no_std` Crates

In late 2021, [@jessebraham] started [esp-hal] with the aims of replacing the chip specific `esp32-hal` which was currently being worked on. It worked out amazingly well, and we had a setup where we could share driver code across multiple chips! It wasn't long before most of Espressif's Rust team started to contributing to it whilst also maintaining the standard library port (more on that later).

Not long after, [@BjoernQ] joined the team and set out to add support for arguably the most important peripheral in an ESP32, the radio. He achieved success, and we've had `no_std` Wi-Fi, BLE and [ESP-NOW] support ever since! I cannot state how important these steps were, as it gave us confidence that we could build a fully functioning SDK supporting a whole lineup of chips, in pure Rust[^1]!

We spent the entirety of 2022 and most of 2023 working exclusively on chip support; making sure new chips were supported, and trying to support as many peripherals as possible. During this time, we also experimented with adding `async` versions of some drivers, as the [embassy] project began to flourish.

This seemed like a good idea at the time but by the end of 2023 we realized that trying to support everything that the chips can do (there is _a lot_, try looking at a reference manual if you're curious) whilst an admirable goal is likely unachievable in a reasonable time with the size of our team. We soon realized that API stability is far more important than having _everything_ supported.

### Targeting Stability

The first step to stability, and something that had been on our backlog for a while was getting hardware in loop testing (HIL) working. This would be crucial to ensure that we ship reliable, bug-free software. HIL testing works by running tests on the device itself, through a debugger interface to talk to the host machine.

We initially planned on using [defmt-test] to run tests on our devices, but sadly it only supports ARM. Fortunately around this time, [@t-moe] created [embedded-test] which works in a similar way to [defmt-test] but has a couple of advantages:

  * It supports ARM, RISC-V and Xtensa (thanks to some great work by [@bugadani] to add Xtensa support to [probe-rs])
  * It supported `async` tests

Its been working extremely well for us, and we've been amassing an ever growing list of test cases in the [hil-test](https://github.com/esp-rs/esp-hal/tree/main/hil-test/tests) crate.

The next step, was figuring out what our APIs should look like. After all we can't stabilize something unless we're sure we're going in the right direction. We spent some time reviewing the ecosystem and our own issue tracker for usability issues and found that many of the usability difficulties come from too many generic parameters on drivers.

This was not the only thing we found of course, but it was the biggest shift in our visible API. This was mostly inspired by the [embassy] project's in-tree HALs. The [official Rust embedded book] actually promotes the use of typestating etc, which is why many HALs, including esp-hal ended up in this situation, but in our opinion the less generics the better, for reasons beyond just usability; there are also some nice code size improvements which are really important for small constrained resources devices.

Here is a `diff` of type information of our old pin types, versus the new ones. Everything is now hidden within the type itself, **seven** generic paramters to zero. This makes storing a array of pins trivial, as they are all the same type!

```rust
- GpioPin<Output<OpenDrain>, RA, IRA, PINTYPE, SIG, GPIONUM>
+ Output
```

The remainder of our findings we placed in a living document, [DEVELOPER-GUIDELINES] which we used, and will continue to use to stabilize parts of the HAL.

The final step, was figuring out how we were going to document this. Supporting multiple chips from one crate poses an interesting challenge. We can no longer use docs.rs for our documentation (we can, and do, but only for one chip) so we've instead started self-hosting our docs, with a chip and version selector to combat this. You can view the docs on the official [docs.espressif.com/projects/rust] site. Once again, this was heavily inspired by [embassy]'s prior work in this area.

### Our Stabilization Strategy

Our stabilization strategy is quite simple, we've limited the scope of 1.0 stabilization to:

- Initializing the hal, `esp_hal::init` and the relevant configuration associated with that.
- Four "core" drivers to start:
  - GPIO
  - UART
  - SPI
  - I2C
- The `time` module, which provides `Instant`, `Duration`, and `Rate`.
- A couple of miscellaneous system APIs (SoC reset, etc.).
- `#[main]` macro.
- How esp-hal and friends are configured via [esp-config].

With the exception of the list above, everything else in esp-hal is now feature gated behind the `unstable` feature. With the scope limited, post 1.0 we can incrementally stabilize drivers, much like the Rust project itself does. This is quite a small amount to stabilize initially, however we feel it's enough to build a foundation on. It's expected that for most complex projects users will opt-in to the `unstable` feature. Over time, as we stabilize more drivers, and eventually more crates, users will be able to remove the `unstable` feature from their `Cargo.toml` files.

### What About the Other `no_std` `esp-*` Crates?

esp-hal is the foundation of many of the esp-rs ecosystem crates, [esp-wifi] is our next stabilization target, and builds directly on top of esp-hal. The end goal is of course to have every `esp-*` crate with a 1.0+ release.

### Call for Testing

As this is a beta release, we'd absolutely love to hear your feedback on esp-hal as it currently stands! Whether you've used it before, or you're about to try it out for the first time, any feedback is most welcome!

* Please open issues for anything that should be working that isn't
* Please open discussions to discuss API decisions that perhaps aren't quite as ergonomic or thought through as we intended

We've created our own project generation tool, [esp-generate] to bootstrap starting a project, which is often a bit of a tricky thing to set up in embedded. Please do give it a try by first installing the tool with

```bash
cargo install esp-generate
```

then, to generate a project for the ESP32-C6, run

```bash
esp-generate --chip esp32c6 NAME_OF_PROJECT
```

We're currently rewriting the [book], but in the meantime it can still be helpful to read it to get an overview of the ecosystem.

### Where Does This Leave the Standard Library Port?

At this time we're officially marking the `std` _crates_ as community supported, which we've reflected on the [organization landing page](https://github.com/esp-rs/). We will still maintain the upstream compiler targets, and ensure that those targets continue to function, but `esp-idf-sys`, `esp-idf-hal` and `esp-idf-svc` are now community projects. It's been moving this way for a while, but we'd like to officially announce it here. Users wanting a more stable (and official) development environment should transition to `esp-hal` and the other `no_std` crates.

### What’s Next?

Our focus now is to keep pushing until esp-hal 1.0. We'll then split our efforts and try to stabilize more things in esp-hal whilst also pushing for a stable Wi-Fi/BLE story. Preparing for the full esp-hal 1.0 release requires an overhaul of the [book], along with a bunch of documentation and polish all round. Finally, we need to ensure our tooling is in a good place, so we plan to make a new [espflash] release to accomplish that.

This release would not have been possible without the help from the embedded Rust community, the embedded working group, and of course the esp-rs community and contributors which have heavily impacted how we've developed our Rust offering. I also can't thank the Rust team at Espressif enough, they're awesome to work with and oh so very talented! If you're attending RustNL this year (2025) come say hi! We'll have an Espressif booth setup, and you can catch us walking around the event too!

If you're a company using (or considering) Rust on our chips, please do contact rust.support@espressif.com, we'd love to hear from you!

[^1]: There are some binary blobs to run the Wi-Fi driver which we link to.


[mrustc]: https://github.com/thepowersgang/mrustc
[Espressif]: https://www.espressif.com/
[Xtensa]: https://en.wikipedia.org/wiki/Tensilica
[Xtensa enabled LLVM fork]: https://esp32.com/viewtopic.php?t=9226&p=38466
[posts on my personal website]: https://mabez.dev/blog/posts/
[ESP-IDF]: https://github.com/espressif/esp-idf
[probe-rs]: https://probe.rs/
[embedded-test]: https://github.com/probe-rs/embedded-test
[embassy]: https://github.com/embassy-rs
[defmt-test]: https://github.com/knurling-rs/defmt/tree/main/firmware/defmt-test
[official Rust embedded book]: https://docs.rust-embedded.org/book/static-guarantees/typestate-programming.html
[DEVELOPER-GUIDELINES]: https://github.com/esp-rs/esp-hal/blob/main/documentation/DEVELOPER-GUIDELINES.md
[the tracking issue]: https://github.com/espressif/llvm-project/issues/4
[espflash]: https://github.com/esp-rs/espflash
[esp-hal]: https://github.com/esp-rs/esp-hal/tree/main/esp-hal
[esp-wifi]: https://github.com/esp-rs/esp-hal/tree/main/esp-radio
[ESP-NOW]: https://www.espressif.com/en/solutions/low-power-solutions/esp-now
[xtensa-lx and xtensa-lx-rt]: https://github.com/esp-rs/esp-hal/tree/main/xtensa-lx-rt
[esp-generate]: https://github.com/esp-rs/esp-generate
[book]: https://github.com/esp-rs/book
[esp-config]: https://crates.io/crates/esp-config
[docs.espressif.com/projects/rust]: https://docs.espressif.com/projects/rust/index.html
[@reitermarkus]: https://github.com/reitermarkus
[@ivmarkov]: https://github.com/ivmarkov
[@jessebraham]: https://github.com/jessebraham
[@BjoernQ]: https://github.com/BjoernQ
[@arjanmels]: https://github.com/arjanmels
[@t-moe]: https://github.com/t-moe
[@bugadani]: https://github.com/bugadani
