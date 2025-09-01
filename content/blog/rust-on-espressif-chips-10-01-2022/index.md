---
title: "Rust on Espressif chips — 18-10-2021"
date: 2021-10-17
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - scott-mabin
tags:
  - Esp32
  - Rust
  - Xtensa

---
This article was written by Scott Mabin and originally posted [on his blog](https://mabez.dev/).

Now I am working at Espressif I plan on publishing updates roughly every quarter just to keep the community in the loop around the esp rust effort.

## Documentation & Planning

One of the hardest parts in any community project is onboarding new developers, especially in the early stages of a project where API’s, processes and tooling is changing rapidly; it can be frustrating to work on something one week, and in the next you’re fighting to get it compiling again. We began work on [a book](https://docs.espressif.com/projects/rust/book/) in which we will try to keep as a source of truth for the Rust esp effort. This will include install instructions, tooling guides, ecosystem overviews and much more.

We have also put together a [road map project](https://github.com/orgs/esp-rs/projects/2) on github, with the aim of managing the project from Espressif’s point of view, but also to allow new contributors to pick up backlog items. Simply comment in the issue if there is something you’d like to take a stab at, we’re more than happy to assist and review. We also host bi-weekly meetings which anyone is welcome to attend, just drop a comment [in the latest discussion thread](https://github.com/esp-rs/rust/discussions).

## Using the Rust standard library on Espressif chips

In [the last post](https://mabez.dev/blog/posts/esp-rust-espressif/), I mentioned that was possible to use the Rust standard library thanks to [@ivmarkov](https://github.com/ivmarkov)’s hard work; well, he’s been at it again! He pushed forward and managed to upstream the standard library changes required to build std on top of esp-idf. From Rust 1.56 it the changes will be stable, meaning it's possible to use the upstream Rust toolchain to build the std platform for any RISC-V Espressif chip! Currently, that only includes the esp32c3 but there are more to come. This change also applies to Xtensa chips, however they still require a custom toolchain due to the lack of a backend for Xtensa in upstream LLVM. For more info in the std effort, please see [the book](https://docs.espressif.com/projects/rust/book/). I'd also like to take this time to thank the upstream Rust developers for the prompt and helpful reviews, in particular [@Amanieu](https://github.com/Amanieu) for helping us push this over the finish line.

## Compiler

The custom toolchain is a hindrance to developer onboarding, especially if developers have to build it themselves. We now offer a prebuilt toolchains for all common OS’s under the [esp-rs/rust-build](https://github.com/esp-rs/rust-build) repository. A few days after a new Rust release we typically have the new compiler ready, unless we run into any issues; speaking of, we now test the compiler with a few projects in CI so hopefully we don’t ship a broken compiler. Note that this extra compiler step is only required when targeting Espressif’s Xtensa based chips.

There have been a couple of improvements to the compiler fork since the last post, for one the patch set we have to manage has reduced in size thanks to the std library changes being upstreamed. There is now asm! support for the Xtensa architecture, which also means we have removed the old llvm_asm! macros from the xtensa crates and ported them to the new syntax.

## Tooling

## SVDs

SVDs have been coming along very nicely, we now [have official SVDs](https://github.com/espressif/svd/tree/main/svd) for the esp32c3, esp32s2 and the esp32. If you have been following this effort for a while, you may be thinking we already had an esp32 SVD, well you would be correct! However, it was very hacky, missed a lot of peripherals and was all around horrible to work with. The new SVD aims to be more complete and importantly more consistent. One thing that has been missing from the official SVDs is interrupt information, however this has recently changed and interrupt information for each peripheral is now available. Overall the SVDs available now are in a great spot to feed into svd2rust and other tooling, ready for HAL creation.

## espflash

[espflash](https://github.com/esp-rs/espflash) is a rewrite of Espressif's [esptool.py](https://github.com/espressif/esptool), but also has cargo integration. It's been under heavy development and now has a 1.0 release! Including:

- Support for flashing:
- esp32
- esp32c3
- esp32s2
- esp8266
- Compression for faster flashing.
- Support for the esp-idf partition table format.
- Support for flashing a stock esp-idf bootloader.
- Removed support xargo & cargo xbuild, now focusing support on build-std.
- Reading back flash info.
- Reading some EFUSE values.
- elf2image functionality, for writing the formatted image to a file.
- Beautiful & helpful error messages with miette.

Big thanks to all the contributors in this release, especially [@icewind1991](https://github.com/icewind1991).

## probe-rs

We have also started adding support for flashing and debugging Espressif chips with probe-rs. As the RISC-V architecture is already supported in probe-rs, we set out to add support for the esp32c3 initially. We are happy to report that probe-rs master now has a flash algorithm capable of flashing the esp32c3! The [esp-flash-loader](https://github.com/esp-rs/esp-flash-loader) repository contains the code for the esp32c3 flash loader, but thanks for Espressif's ROM API it should be very easy to port the algorithm to the other chips. Xtensa support for probe-rs is planned eventually, but will take some time to implement. A big thank you to the probe-rs folks, in particular [@Yatekii](https://github.com/Yatekii), [@Tiwalun](https://github.com/Tiwalun) and [@Dirbaio](https://github.com/Dirbaio) for the reviews and assistance.

Having probe-rs support gives us easy access to [RTT](https://www.segger.com/products/debug-probes/j-link/technology/about-real-time-transfer/) for fast, low overhead logging. We have the esp32c3 using RTT with probe-rs locally, however a few patches are required due to the esp32c3's lack of atomics. Whilst we have contributed to crates such as [atomic-polyfill](https://github.com/embassy-rs/atomic-polyfill/pull/6) these crates are quite intrusive and require other ecosystem crates to depend on them instead of core::sync::atomic. To combat this, we are in the process of writing an atomic emulation trap handler. This works by treating the esp32c3 like it has atomic support (build as riscv32imac-unknown-none-elf), and when we trap on the atomic instructions, we decode them and emulate them in software transparently. There is a performance penalty that it is roughly 2-4x slower than native instructions based on our testing, but having an atomic story is important in the embedded Rust ecosystem.

## What’s next?

Continue to improve the tooling around Rust with Espressif chips, until we have out of the box solutions for most stories. Continue to build and polish standard library use with Espressif chips, as well as the #![no_std] story. We would also like to explore using [rustc_codegen_gcc](https://github.com/rust-lang/rustc_codegen_gcc) to try and target Espressif's Xtensa chips. The end goal will still be to upstream the Xtensa backend to LLVM, but rustc_codegen_gcc may allow targeting Xtensa chips faster as GCC already has a stable Xtensa backend.

Expect another update early next year!
