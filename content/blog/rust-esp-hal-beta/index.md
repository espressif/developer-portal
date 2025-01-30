---
title: "esp-hal 1.0.0 beta announcement"
date: 2024-02-11
showAuthor: true
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - scott-mabin
tags:
  - Esp32
  - Rust
  - Xtensa
  - RISCV
  - Announcement

---

We're extremely excited to announce the `1.0.0-beta.0` release for esp-hal, the _first_ vendor-backed Rust SDK! This has been a nearly 6 year long process to get to this point, and we now feel we have a solid 1.0 strategy. Let us take you on the the journey of how we got here. If you're just interested in what we're stabilizing today [click here](#targeting-stability) to jump to it.

### Where it all started

In 2019 I created the esp-rs org which laid dormant for some time. At the time, [Espressif] was still using the [Xtensa] architecture for it's chip lineup which whilst powerful had one big caveat for Rust support: there was no LLVM backend for Xtensa. I tried to use [mrustc] to cross compile Rust to C, and then use the GCC Xtensa toolchain but whilst I had some minor success the workflow was far to cumbersome. Fast-forward to 2020 and Espressif announced the first iteration of their [Xtensa enabled LLVM fork] with the intention of getting it upstreamed. I was extremely excited about this, and I got to work integrating this Xtensa enabled LLVM into the Rust compiler. I succeeded, with a lot of help from members of the Rust community and a reference set of  PRs for RISC-V which had fortunately been merged just a bit earlier. I had to set this project aside for a while, but I got back to it and managed to write the worlds first Rust blinky on an esp32! I documented my early findings in a series of [posts on my personal website]. I read these posts again (mostly to remind myself what on earth I was doing 5 years ago), and one quote from my first post really stood out to me.

> Now I know what most of you are thinking at this point, it's not very Rusty; it contains bundles of unsafe and there are no real abstractions here, and you are right; but it's something to get the ball rolling.

I think it's safe to say the ball definitely rolled.

### Espressif's official support for Rust

Not long after that initial blog post Espressif started sponsoring my work and allowed me continue working on it in my spare time. At the same time, the community around esp-rs was starting to grow, and I really can't thank these early contributors enough. Whilst myself and a few early contributors, namely [@jessebraham], and [@arjanmels] mostly focussed on the `no_std` side of things, [@reitermarkus] initially and eventually [@ivmarkov] ported the Rust standard library which built on [ESP-IDF] which was not only an amazing technical feat, but also gave users a big head start because we could use the stable and tested code from esp-idf without having to write all the drivers from scratch for `no_std` immediately.

Espressif had been observing our work (and may I add, were _extremely_ helpful in answering any questions we had) and by 2021, they we're keen to adopt it officially. They reached out to me and some other community contributors about a position in a newly forming Rust team and I along with [@jessebraham] gladly accepted.

### Bringing up the ecosystem

It has been possible to write embedded Rust applications on stable since 2018, but most of the ecosystem revolved around chips using the ARM architecture, which posed a bit of an uphill battle for us given that Espressif has just released its last Xtensa chip (the ESP32-S3) and was now bringing out RISC-V based chips. Whilst most crates in the embedded Rust ecosystem are arch independent, the tooling is a different story, and over the years we've spent _a lot_ of time contributing to various open source projects, like [probe-rs] to either improve, or in the case of Xtensa add support. This work is still on going, but we're quite happy with the usability of the tooling on our chips now.

Xtensa based chips posed many challenges for us. We ended up writing [xtensa-lx and xtensa-lx-rt] using the proprietary (at the time, they have since released an open version) Xtensa instruction set manual. There was at least _some_ runtime/startup support for RISC-V, but absolutely nothing for Xtensa in the Rust ecosystem. Another challenge we had is that we we're the primary users of the LLVM Xtensa fork, which meant when there was a bug in some code-gen we were the unfortunate souls to run into it. This ate copious amounts of developer time, but in the end it was worth it as the backend is in very good shape now. There is also a huge amount of progress to report on the upstreaming front for LLVM (which was stalled for a long long time), most of the base ISA is now in LLVM proper, and the remaining patches can be submitted in parallel.

### Focussing on `no_std` crates

In late 2021, [@jessebraham] started [esp-hal] with the aims of replacing the chip specific `esp32-hal` which was currently being worked on. It worked out amazingly well, and we had a setup where we could share driver code across multiple chips! It wasn't long before most of Espressif's Rust team started to contributing to it whilst also maintaining the standard library port (more on that later). Not long after, [@BjoernQ] joined the team and set out to add support for arguably the most important peripheral in an ESP32, the radio. He achieved success, and we've had `no_std` WiFi, BLE and [ESP-NOW] support ever since! I cannot state how important these steps were, as it gave us confidence that we could build a fully functioning SDK supporting a whole lineup of chips, in pure Rust[^1]!

We spent the entirety of 2022 and most of 2023 working exclusively on chip support. Making sure new chips were supported, and trying to support as many peripherals as possible. During this time we also experimented with adding `async` versions of some drivers, as the [embassy] project began to flourish. This seemed like a good idea at the time (and I wouldn't say it was a bad idea), but by the end of 2023 we realized that trying to support everything that the chips can do (and trust me, there is _a lot_ try looking at a reference manual if you're curious) whilst an admirable goal is likely unachievable in a reasonable time frame with the size of our team. We soon realized that API stability is far more important than having _everything_ supported.

### Targeting stability

The first step to stability, and something that had been on our backlog for a while was getting hardware in loop testing (HIL) working. This would be crucial to ensure that we ship reliable, bug-free software. HIL testing works by running tests on the device itself, through a debugger interface to talk to the host machine. We initially planned on using [defmt-test] to run tests on our devices, but sadly it only supports ARM. Fortunately around this time, [@t-moe] created [embedded-test] which worked in a very similar way to [defmt-test] but has a couple of advantages:

  * It supports ARM, RISC-V and Xtensa (thanks to some great work by [@bugadani] to add Xtensa support to [probe-rs])
  * It supported `async` tests

Its been working extremely well for us, and we've been amassing an ever growing list of test cases in the [hil-test](https://github.com/esp-rs/esp-hal/tree/main/hil-test/tests) crate.

The next step, was figuring out what our APIs should look like after all we can't stabilize something unless we're sure we're going in the right direction. We spent some time reviewing the ecosystem and our own issue tracker for usability issues and found that many of the usability difficulties come from too many generic parameters on drivers. This was not the only thing we found of course, but it was the biggest shift in our visible API. This was mostly inspired by the [embassy] project's in-tree HALs. The [official Rust embedded book] actually promotes the use of typestating etc, which I suppose is why many HALs including esp-hal ended up in this situation, but in our opinion the less generics the better, for reasons beyond just usability; there are also some nice code size improvements which are really important for small constrained resources devices. The remainder of our findings we placed in a living document, [DEVELOPER-GUIDELINES] which we used, and will continue to use to stabilize parts of the HAL.

The final step, was figuring out how we were going to document this. Supporting multiple chips from one crate poses an interesting challenge. We can no longer use docs.rs for our documentation (we can, and do, but only for one chip) so we've instead starting self-hosting our docs, with a chip and version selector to combat this. Once again, this was heavily inspired by [embassy]'s prior work in this area.

### Our stabilization strategy

Our stabilization strategy is quite simple, we've limited the scope of 1.0 stabilization to:

- Initializing the hal, `esp_hal::init` and the relevant configuration associated with that.
- Four "core" drivers to start
  - GPIO
  - UART
  - SPI
  - I2C
- A couple of miscellaneous system APIs (SoC reset, etc), 
- `#[main]` macro
- How esp-hal and friends are configured via [esp-config]

With the exception of the list above, everything in else in esp-hal is now feature gated behind the `unstable` feature. With the scope limited, post 1.0 we can incrementally stabilize drivers, much like the Rust project itself does. This is quite a small amount to stabilize initially, however we feel it's enough to build a foundation on. It's expected that for most complex projects users will opt-in to the `unstable` feature. Over time, as we stabilize more drivers, and eventually more crates users will be able to remove the `unstable` feature from their `Cargo.toml` files.

### What about the other no_std esp crates?

esp-hal is the foundation of many of the esp-rs ecosystem crates, [esp-wifi] is our next stabilization target, and builds directly on top of esp-hal. The end goal is of course to have every `esp-*` crate with a 1.0+ release.

### Do you plan on releasing esp-hal 2.0.0 at some point?

As of right now, we don't have plans to ever release a esp-hal 2.0 release. If we do need to, we have done some [semver experiments](https://github.com/MabezDev/semver-playground/tree/master) and we've determined that we can release a 2.0 release without breaking our ecosystem, provided we've got driver construction nailed. We've spent quite a lot of time and resources in this area, and we think we're in a good place.

### Call for testing

As this is a beta release, we'd absolutely love to hear your feedback on esp-hal as it currently stands! Whether you've used it before, or you're about to try it out for the first time, any feedback is most welcome!

* Please open issues for anything that should be working that isn't
* Please open discussions to discuss API decisions that perhaps aren't quite as ergonomic or thought through as we intended

We've created our own project generation tool, [esp-generate] to bootstrap starting a project, which is often a bit of a tricky thing to setup in embedded, please do give it a try by first installing the tool with 

```rust
cargo install esp-generate
```

then, to generate a project for the ESP32-C6, run

```rust
esp-generate --chip esp32c6 NAME_OF_PROJECT
```

We're currently rewriting the [book], but in the meantime it can still be helpful to read it to get an overview of the ecosystem.

### Where does this leave the standard library port?

At this time we're officially marking the `std` _crates_ as community supported, which we've reflected on the [organization landing page](https://github.com/esp-rs/). We will still maintain the upstream compiler targets, and ensure that those targets continue to function, but `esp-idf-sys`, `esp-idf-hal` and `esp-idf-svc` are now community projects. It's silently been moving this way for a while, but we'd like to officially announce it here. Users wanting a more stable (and official) development environment should transition to esp-hal and the other no_std crates. 

### What's next?

Our focus now is to keep pushing until esp-hal 1.0, at which point we'll split our efforts and try to stabilize more things in esp-hal, as well as push for a stable WiFi/BLE story. Preparing for the full esp-hal 1.0 release requires a overhaul of the [book], along with a bunch of documentation and polish all round. Finally we need to ensure our tooling is in a good place and we plan to make a new [espflash] release to accomplish that.

This release would not have been possible without the help from the embedded Rust community, the embedded working group, and of course the esp-rs community and contributors which have heavily impacted how we've developed our Rust offering. I also cannot thank the Rust team at Espressif, they're awesome to work with a oh so very talented! If you're attending RustNL this year come say hi!

If you're a company using (or considering) Rust on our chips, please do contact rust-support@espressif.com, we'd love to hear from you!

---

[^1]: There are some binary blobs to run the WiFi driver which we link to.


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

[espflash]: https://github.com/esp-rs/espflash
[esp-hal]: https://github.com/esp-rs/esp-hal/tree/main/esp-hal
[esp-wifi]: https://github.com/esp-rs/esp-hal/tree/main/esp-wifi
[ESP-NOW]: https://www.espressif.com/en/solutions/low-power-solutions/esp-now
[xtensa-lx and xtensa-lx-rt]: https://github.com/esp-rs/esp-hal/tree/main/xtensa-lx-rt
[esp-generate]: https://github.com/esp-rs/esp-generate
[book]: https://github.com/esp-rs/book
[esp-config]: https://crates.io/crates/esp-config

[@reitermarkus]: https://github.com/reitermarkus
[@ivmarkov]: https://github.com/ivmarkov
[@jessebraham]: https://github.com/jessebraham
[@BjoernQ]: https://github.com/BjoernQ
[@arjanmels]: https://github.com/arjanmels
[@t-moe]: https://github.com/t-moe
[@bugadani]: https://github.com/bugadani