---
title: "Getting started with esp-hal: Assignment 2"
date: 2026-11-13
showTableOfContents: true
series: ["WS-RUST-ESP-HAL"]
series_order: 4
showAuthor: false
---

In this assignment, your board will connect to Wi-Fi and join a shared "room" in a web app over WebRTC. Everyone's board shows up in the web app, and anyone in the room can change the color of its RGB LED.

<!-- TODO: write the assignment once the example code is ready. Planned outline:

1. Regenerate the project with -o unstable-hal -o embassy -o alloc -o wifi (board tabs)
2. What changes with Embassy: #[esp_rtos::main], async fn main(spawner), esp_rtos::start(timg0.timer0), tasks
3. The RGB LED in async mode: Rmt::new(...).into_async(), channel.transmit(&pulses).await
4. Wi-Fi: heap for esp-radio, WifiController, station config from WIFI_SSID / WIFI_PASSWORD env vars, connect + reconnect task, DHCP with embassy-net
5. Join the room: WebRTC signaling with the room server, data channel, color messages -> LED task
6. Build, flash, open the web app, find your board, change colors
7. Complete solution (board tabs, collapsible) + link to the solutions repository
8. What you learned / Next step

Reading for the instructor: https://docs.espressif.com/projects/rust/no_std-training/application/wifi-connectivity.html
-->

{{< alert >}}
This assignment is in preparation.
{{< /alert >}}

## Learn more

- [Wi-Fi Connectivity](https://docs.espressif.com/projects/rust/no_std-training/application/wifi-connectivity.html) chapter of the Embedded Rust Training
- [esp-radio Wi-Fi examples](https://github.com/esp-rs/esp-hal/tree/main/examples/wifi)

## Next step

[Assignment 3: ESP-NOW chat room](../assignment-3/)

[Return to the workshop main page](/workshops/rust-esp-hal-intro/)
