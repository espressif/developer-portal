---
title: "ESP-IDF C5 - Lecture 4"
date: "2026-07-29"
lastmod: "2026-07-29"
series: ["WS00C"]
series_order: 11
showAuthor: false
summary: "Discover how the ESP32-C5 saves power through its sleep modes and the Ultra Low Power (ULP) LP core coprocessor, including how to program the LP core, enter sleep, and wake the main CPU."
---

## Introduction

Battery-powered and energy-sensitive products spend most of their life waiting: waiting for a sensor to cross a threshold, a button to be pressed, or a timer to expire. During those idle periods, keeping the main CPU fully awake wastes energy. The ESP32-C5 addresses this with a set of power modes and a dedicated Ultra Low Power (ULP) coprocessor that can keep working while the rest of the chip sleeps.

In this lecture we look at two closely related topics:

* The __sleep modes__ that let you trade performance for lower power consumption.
* The __ULP LP core coprocessor__, a small RISC-V processor that stays awake to monitor peripherals while the main CPU is powered down.

Together, these features let you build applications that run for months on a small battery while still reacting quickly to real-world events.

>[!TIP]
> For a deeper dive, check the developer portal article [Building low power applications on Espressif chips: Ultra-Low-Power (ULP) coprocessor](https://developer.espressif.com/blog/2025/04/ulp-lp-core-get-started/).

## Power Modes on the ESP32-C5

The ESP32-C5 includes an advanced Power Management Unit (PMU) that can power up different domains of the chip independently. This lets the system balance performance, power consumption, and wake-up latency.

Rather than configuring the PMU by hand, ESP-IDF exposes a set of predefined power modes:

* __Active mode:__ The high-performance (HP) CPU, radio, and all peripherals are on. The chip can process data and communicate over Wi-Fi or Bluetooth LE.
* __Modem-sleep mode:__ The HP CPU stays on, but its clock frequency can be reduced. The radio is switched on periodically to keep wireless connections alive.
* __Light-sleep mode:__ The HP CPU is clock-gated and its supply voltage is reduced. RAM, peripherals, and CPU state are preserved, so execution resumes exactly where it left off after wakeup.
* __Deep-sleep mode:__ Only the low-power (LP) system stays powered. The CPUs, most of the RAM, and the digital peripherals are turned off, which gives the lowest power consumption.

For more details about predefined power modes, see ESP32-C5 [datasheet](https://documentation.espressif.com/esp32-c5_datasheet_en.html#[43,%22XYZ%22,56.69,254.84,null]) > _Functional Description_ > _System Components_ > _Power Management Unit_.

### Light sleep vs deep sleep

The main practical difference between the two sleep modes is what survives the sleep period.

In __light sleep__, the digital peripherals, most of the RAM, and the CPUs are clock-gated but keep their state. When the chip wakes up, the CPU continues from the same instruction, and peripherals resume their previous operation. This makes light sleep ideal when you need to sleep briefly and react quickly, for example while maintaining a Wi-Fi connection.

In __deep sleep__, almost everything is powered off. The only parts that remain on are:

* The RTC controller
* The ULP coprocessor
* The RTC FAST memory

Because the CPU context is lost, waking from deep sleep restarts the boot process and your application runs again from the beginning. Any data you want to preserve across a deep sleep cycle must be stored in RTC FAST memory using the `RTC_DATA_ATTR` attribute.


## The ULP LP Core Coprocessor

The ULP (Ultra Low Power) coprocessor performs tasks while the main CPU is asleep. It can monitor sensors, control peripherals, and wake the main CPU only when something interesting happens, such as a sensor reading crossing a threshold.

On the ESP32-C5, the ULP is implemented as the __LP core__: a small RISC-V processor that stays powered while the HP system sleeps. It can run C code and reach the LP peripherals during sleep, which makes it well suited to lightweight jobs like polling a GPIO, reading an I2C sensor, or counting pulses while the rest of the chip stays powered down.

At a high level, working with the LP core involves a few steps:

* __Enable it__ in menuconfig (`CONFIG_ULP_COPROC_ENABLED` with the LP core type) and embed its source as a separate binary in your build.
* __Start it__ from the main application, choosing a wakeup source such as the LP timer, an LP IO, or the LP UART.
* __Let it run its cycle__: the LP core wakes up, runs your code, optionally wakes the main CPU with `ulp_lp_core_wakeup_main_processor()`, then goes back to sleep.

The assignments in this section walk through the details of building and running an LP core program.

## Entering Sleep and Waking Up

To put the main CPU to sleep, you configure one or more wakeup sources and then call a start function:

* `esp_light_sleep_start()` enters light sleep and returns once a wakeup source triggers.
* `esp_deep_sleep_start()` enters deep sleep and does not return: the chip reboots on wakeup.

The ESP32-C5 offers several wakeup sources that you can combine, including an RTC timer, LP (RTC-capable) GPIOs, and the LP core itself. After waking, the application can check what triggered the wakeup and react accordingly.

> [!TIP]
> A common low-power design keeps the main CPU in deep sleep while the LP core watches a sensor. When the LP core detects a meaningful change, it calls `ulp_lp_core_wakeup_main_processor()` to bring the HP CPU back online only when there is real work to do.

The first assignment guides you through a minimal sleep-and-wake cycle so you can see these APIs in action.

## Conclusion

The ESP32-C5 gives you a spectrum of options for reducing power consumption, from Dynamic Frequency Scaling and Modem-sleep down to deep sleep, where nearly the entire chip is switched off. Choosing the right mode is a matter of balancing how quickly you need to respond against how little energy you can afford to spend.

The ULP LP core makes that trade-off far more flexible. By offloading simple monitoring tasks to a low-power RISC-V processor that keeps running during sleep, your application can stay responsive to sensors and inputs while the main CPU rests. Waking the HP CPU only when needed is often the difference between a device that lasts days and one that lasts months on the same battery.

### Next Step
> Next assignment &rarr; __[assignment 4.1](assignment-4-1)__

> Or [go back to navigation menu](.#agenda)
