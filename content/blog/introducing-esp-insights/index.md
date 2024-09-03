---
title: Introducing ESP Insights
date: 2021-07-05
showAuthor: false
authors: 
  - kedar-sovani
---
[Kedar Sovani](https://kedars.medium.com/?source=post_page-----7d85a1383d21--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F1d2175c72923&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fintroducing-esp-insights-7d85a1383d21&user=Kedar+Sovani&userId=1d2175c72923&source=post_page-1d2175c72923----7d85a1383d21---------------------post_header-----------)

--

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*0yDrXc-NOcErMch8VHpNVQ.jpeg)

Today we are announcing ESP Insights.

ESP Insights is a device observability framework that allows developers to remotely peek into their firmware to get rich information about the firmware execution; and analyse this to pin-point issues and bottlenecks. This observability should help organisations save valuable engineering resources, allowing them to speed up firmware development and fix issues within a shorter turn-around time.

In the preview release that we launched today:

- You can observe the __critical logs__ , or errors that the firmware has generated during its execution.
- If the firmware crashed, you can observe the __register dump__  and the __backtrace__ , to help you understand what may have been going on with the device.
- You can look at a __device timeline__ that shows the events of interest.
- You can add your __custom events__  to show up on this timeline.
- You can observe __firmware metrics__  like the amount of free heap over a timeline.
- You can view the current values of certain __variables__ of interest.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*BCn70FfJ088P5xByDpXJYg.png)

The *Insights agent* in the firmware leverages the Wi-Fi connectivity, and allows devices to post this information to the *Insights cloud*. The Insights cloud collects this information, from all the deployed devices, and compiles them into meaningful representations. Firmware developers can view this information through a web-based dashboard, the *Insights dashboard*.

## Why ESP Insights?

In multiple discussions with our customers, we noticed a pattern. As software development progresses and gets closer to the initial alpha, or beta runs, the observability into the firmware diminishes. What was easily visible as console logs and through CLIs to the developer, is now hidden when the firmware is packaged into the final ID. The trial or beta runs, indicate there may be issues, but there is no faster way to recreate them in a dev/QA environment.

## 1. Launch Products Faster

- __Beta test runs__  expose the product to a real-life uncontrolled environment: the development board is packaged into an industrial design and actually deployed in user’s home. The idea of these runs is to get information to your engineering team about firmware stability and issues as might be observed with the user’s environments. ESP Insights allows developers, sitting on their desks, to view stack back-traces and register dumps for firmware running on devices in these runs.
- __Turn-around time__  for fixing issues is much shorter for developers that have rich information about issues. Most teams spend enormous amounts of time recreating issues based on the scanty user-visible symptoms reported to them. ESP Insights captures and reports details about errors or warnings as observed on the device firmware. Of particular interest are events generated just before a crash. ESP Insights preserves these events across a device reset, so that it is reported to the cloud once the device is back up again.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*exymKWHIDK15-cG1vxOscA.png)

## 2. Fix Issues Before they Snowball

- __Monitoring Device Health__  by tracking key metrics such as available free memory, or largest free block, allow developers to understand the kind of stress the device gets under and plan for these better in their upcoming firmware versions.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*J1T4JIRANbh9mwof2dzToA.png)

- __Detailed Crash Backtraces__ on the ESP Insights console allow developers to start working on issues even before customers may notice them.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*o-Rxr4gauQLvxX-NaTBKIw.png)

## Integration with ESP RainMaker

Today, the preview release for ESP Insights works with ESP RainMaker. What this implies is that we leverage the ESP RainMaker platform for device-authentication and device-cloud transport.

We will soon follow-up with another release for customers who wish to use ESP Insights by itself.

## Getting Started

Please refer to the [Getting Started](https://github.com/espressif/esp-insights#getting-started) section for steps on setting up esp-insights for your ESP32.

We are excited to start this journey with ESP Insights. Our release today is but a small step towards, what we believe, will be a rich platform that assists developers in novel ways, to building more robust software faster.

Title image picture credits: pixabay
