---
title: "C++26 on ESP-IDF v6.1: Reflection and Contracts Arrive on the Device"
date: 2026-10-12
draft: true
tags:
  - ESP-IDF
  - C++
  - C++26
  - reflection
  - contracts
  - GCC
authors:
  - "david-cermak"
featureAsset: "img/featured/featured-announcement.webp"
summary: "ESP-IDF v6.1 ships GCC 16.1 with usable C++26 reflection and contracts on Espressif chips. This opener shows how to turn the features on, runs two tiny demos, and reports flash cost so you can decide whether to dig into the follow-up deep dives."
---

ESP-IDF now carries a toolchain that can compile **C++26** features people used to treat as desktop-only: **static reflection** and **contracts**. That matters on a microcontroller for two practical reasons:

- Reflection: keep the **same headers on host and device**, and let the compiler police wire types and API catalogs.
- Contracts: express HAL assumptions at the API boundary, and react to violations with a **safe-state handler** instead of `abort()` to stderr.

This post is the map. It covers the toolchain snapshot, how to enable the flags in an IDF component, two copy-pasteable "hello" demos, and a small flash/RAM table. The deep dives — wire-safe RPC with reflection, and fail-safe contract handlers for drivers — come in the next two articles.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
**Short version:** On ESP-IDF v6.1 with GCC 16.1, `-std=gnu++26` plus `-freflection` gives you compile-time type inspection at **zero flash cost when unused**. Contracts let you write `pre(...)` on driver APIs and install a custom violation handler that fits bare-metal firmware. Neither feature asks you to rewrite your C drivers tomorrow.
{{< /alert >}}

## At a glance

| Topic | Detail |
| --- | --- |
| ESP-IDF | v6.1+ (verified on latest / GCC 16.1 toolchain) |
| Language mode | `-std=c++26` or `-std=gnu++26` |
| Reflection flag | `-freflection` (accepted **only** with C++26) |
| Header | `<meta>` for reflection; contracts via `pre` / `post` and `std::contracts` |
| Flash when unused | Reflection flag alone: **0** code / **0** data / **0** RAM |
| Not in this post | Full wire-safe RPC, catalog generation, build-mode menus for contracts |

## Toolchain snapshot

What you need in practice:

1. An ESP-IDF tree that ships **GCC 16.1** (v6.1+).
2. A component compiled as C++26.
3. For reflection: `-freflection` on that component’s CXX flags.
4. A target you already build for — the demos below were exercised on ESP32-class chips (including ESP32-H2 in the [zigbee-remote](https://github.com/david-cermak/zigbee-remote) lab setup).

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
`-freflection` is rejected unless the translation unit is already in C++26 / gnu++26 mode. Detect the flag with `check_cxx_compiler_flag` only after you inject `-std=gnu++26` into `CMAKE_REQUIRED_FLAGS`, or the check always fails.
{{< /alert >}}

## Enablement in an IDF component

Drop something like this into the component’s `CMakeLists.txt` after `idf_component_register(...)`:

```cmake
include(CheckCXXCompilerFlag)

set(_saved "${CMAKE_REQUIRED_FLAGS}")
set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} -std=gnu++26")
check_cxx_compiler_flag(-freflection HAS_FREFLECTION)
set(CMAKE_REQUIRED_FLAGS "${_saved}")

if(HAS_FREFLECTION)
  target_compile_options(${COMPONENT_LIB} PRIVATE
    $<$<COMPILE_LANGUAGE:CXX>:-std=gnu++26>
    $<$<COMPILE_LANGUAGE:CXX>:-freflection>)
  target_compile_definitions(${COMPONENT_LIB} PRIVATE HAS_FREFLECTION=1)
endif()
```

Contracts ride on the same C++26 language mode; you do not need `-freflection` for `pre` / `post`. Keep reflection gated so components still build on older toolchains — define `HAS_FREFLECTION` and `#ifdef` the `<meta>` code paths.

## Hello, reflection: walk members, print names

Static reflection inspects types at compile time and splices results back into code. There is no runtime RTTI walk. You pay only for the specializations you instantiate — similar to a template library.

The smallest useful demo is a generic pretty-printer: walk non-static data members, print identifiers from the program, values from the object. No X-macros, no per-type printer, no attributes on the struct.

```cpp
#include <meta>
#include <sstream>
#include <string>

template <typename T>
std::string to_string(const T& obj) {
  constexpr auto ctx = std::meta::access_context::current();
  std::ostringstream os;
  os << std::meta::identifier_of(^^T) << " { ";
  bool first = true;
  template for (constexpr auto m :
      [: std::meta::reflect_constant_array(
          std::meta::nonstatic_data_members_of(^^T, ctx)) :])
  {
    if (!first) os << ", ";
    os << std::meta::identifier_of(m) << " = " << obj.[:m:];
    first = false;
  }
  os << " }";
  return os.str();
}

struct Point { int x; int y; };

// to_string(Point{3, 7}) → "Point { x = 3, y = 7 }"
```

The two operators to remember: `^^T` reflects a type (or function), and `[: info :]` splices the reflection back into C++. Almost every larger pattern — wire-safe checks, name-locked dispatch, API catalogs — is those verbs plus a `template for` loop.

Try it on Godbolt: [pretty-print](https://godbolt.org/z/ToWhjYh8j).

The product-shaped use case (same headers on host and ESP32, no IDL codegen) is the subject of the next post. This opener stops at "the compiler can see your struct."

## Hello, contracts: HAL `pre` + a non-console handler

Contracts attach assumptions to an API. On a driver boundary that is more useful than a comment, and cleaner than scattering `if` checks that you hope someone strips for release:

```cpp
void set_pwm_frequency(uint32_t channel, uint32_t hz)
  pre(channel < 4)
  pre(hz >= 10 && hz <= 100000)
{
  // write the timer register for this channel
}
```

In debug-oriented builds, a bad call is caught at the boundary. In release, contracts can be ignored so the HAL stays free of that runtime cost while the requirements remain visible in the signature.

The embedded twist is the **violation handler**. Unlike classic `assert()`, a contract failure does not have to print to stderr and abort. You install a handler that matches the product:

```cpp
#include <contracts>

void handle_contract_violation(
    const std::contracts::contract_violation& v)
{
  disable_all_motor_outputs();
  display_write_bsod();
  display_write(v.location().line(), v.comment());
}
```

No console. No OS. Put outputs in a safe state, log somewhere the device actually has, then recover the way your product requires.

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
Treat contracts as **API-boundary assumptions**, not as a replacement for every runtime check. ISR hot paths, untrusted network parsers, and anything that must degrade gracefully in production still need an explicit strategy — contracts help document and enforce the happy-path contract of *your* code.
{{< /alert >}}

## Footprint: what you actually pay

Measured on ESP32 for progressive reflection demos (flag only → pretty-print → nested type → small runtime dispatch). Contracts are orthogonal; their cost depends on the chosen evaluation semantic (enforce / observe / ignore), which the contracts deep dive covers.

| Step | Flash code Δ | Flash data Δ | RAM |
| --- | ---: | ---: | ---: |
| `-freflection` / `<meta>` unused | **0** | **0** | **0** |
| `to_string` / `print_object` (flat structs) | **+492** | **+144** | **0** |
| + nested struct | **+176** | **+64** | **0** |
| + runtime dispatch (4 commands) | **+544** | **+240** | **0** |

Enable the flag alone and the image does not grow. Cost shows up when you instantiate reflection-driven templates — plus whatever debug info your build keeps. That is the same economic model as heavy template use elsewhere in C++.

## What this post is not

- Not a tour of every C++26 language feature.
- Not a suggestion to rewrite mature C drivers "because reflection exists."
- Not the full wire-safe + dispatch + catalog story (that is post 2).
- Not a complete contracts build-mode / menuconfig guide (that is post 3).

If your production firmware is still on C++17 or C++20, you can still use GCC 16 on a **slice** of types as a policy checker — encode project rules as `consteval` predicates and fail the build when someone sneaks a host `uint16_t` onto the wire. That hybrid workflow is often the lowest-friction way in.

## What’s next

1. **Reflection on embedded** — police wire-safe payloads, lock handler names to `api_id` enumerators, bake an API catalog at compile time, and keep host and device on the same headers ([zigbee-remote](https://github.com/david-cermak/zigbee-remote)).
2. **Contracts for embedded HAL** — more driver-shaped APIs, enforce/observe/ignore modes in an IDF project, and when a plain check is still clearer than a contract.

If you only try one thing from this post: turn on `gnu++26`, add the CMake detection snippet, and break a `static_assert` on purpose once reflection is wired. The interesting part starts when the compiler refuses a payload your comments claimed was fine.
