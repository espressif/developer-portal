---
title: Running Alexa CPP SDK on ESP32
date: 2018-05-18
showAuthor: false
authors: 
  - kedar-sovani
---
[Kedar Sovani](https://kedars.medium.com/?source=post_page-----991051b2ce52--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F1d2175c72923&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Frunning-alexa-cpp-sdk-on-esp32-991051b2ce52&user=Kedar+Sovani&userId=1d2175c72923&source=post_page-1d2175c72923----991051b2ce52---------------------post_header-----------)

--

Back in late 2017, when Amazon launched their C++ SDK for Alexa, we thought it would be fun to port the SDK on ESP32. It not only will showcase the powerful development tools and execution environment that ESP32 currently has, but it will also be a great way to run Alexa on ESP32.

We recently launched a beta preview of this [Alexa on ESP32](https://github.com/espressif/esp-avs-sdk) on github.

The Alexa C++ SDK is targetted for micro-processores, and is quite heavy to be run on micro-controllers. We wanted to see what kind of a load would it generate on ESP32. Thankfully, the hardware (ESP [WROVER](https://www.espressif.com/en/products/hardware/esp-wrover-kit/overview) module) and the software development framework ([IDF](https://github.com/espressif/esp-idf)) were very robust to support such performance intensive use case. Here are some details:

## Threads

In a normal Wi-Fi connected state, the ESP32 typically forks about __13 threads__  for its operation. These include threads for Wi-Fi, the network stack, application threads among other things.

In the normal Alexa operation, the SDK forks a whopping __47 threads__  (inclusive of the 13 threads above) to get the job done. All these threads merrily co-ordinate with each other on the ESP32’s two cores performing audio record, transmit, receive, decode and playback operation.

## Memory

All these threads need to have their stacks in memory. Additionally, we need significantly large ring buffers for audio record and playback. And then there’s 2 TLS connections (one for HTTP2 for the primary Alexa communication, and the other for HTTP1.1 managing OAuth).

The __SPIRAM__  (external SPI memory) is heavily used for many of these buffers and thread stacks. Although being accessed over SPI (and hence relatively slower than the main memory), the caches on the ESP32 ensured that we did not see an end-user visible degradation.

In terms of memory, we try to keep around 15–20KB of free main memory, and the SPIRAM is about half-way (2MB) full.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*6S6yS10RvLk9qTJ69KcbCw.png)

## Footprint

Given the footprint constraints of the platform, and the size of the Alexa CPP SDK, we had to make sure we know what component added how much to the __static memory footprint__ . And then optimize components that added too much. The idf_size.py utility in IDF was a very important tool to identify and check which libraries are adding to the static footprint, and what can be optimized out.

## A bountiful path

Additionally, we made a few minor modifications to better support some of the usecases. Listing them down here, if you find them useful.

Alexa requires an __HTTP/2__  connection with their cloud. So we started with the HTTP/2 client (nghttp2) that is part of IDF. The nghttp2 library is very flexible with its multitude of callbacks. Because of the flexibility though, as you start using it, it is easy to miss the forest for the trees. So we created a tiny layer on top of that called [sh2lib](https://github.com/espressif/esp-idf/tree/master/examples/protocols/http2_request/components/sh2lib) (simple-http2 library). As with any simplifying layer, it does offer simplicity at the cost of flexibility. But by using this simplification we could keep the code more organised, as in this [example](https://github.com/espressif/esp-idf/blob/master/examples/protocols/http2_request/main/http2_request_example_main.c#L124). Maybe that simplicity-flexibility tradeoff is not for everyone, so it’s kept into the IDF’s *examples/ *section for now.

The next stop was __TLS__ . We created a layer [esp-tls](https://github.com/espressif/esp-idf/tree/master/components/esp-tls) on top of mbedTLS. This layer encoded the common tasks of setting up a TLS session and performing data exchange on this session. Apart from simplicity the layer should try to ensure that it chooses the default secure configurations with minimal scope of error. This was to avoid situations like, *Oh I forgot to perform server certificate validation, *or *Oh I didn’t setup CN verification*. This layer is also now a part of IDF.

IDF already includes C++ development support. The Alexa CPP SDK extensively uses features (C++11 included) like threads, shared-locks, smart-pointers, futures and lambda expressions from IDF.

All in all, the hardware and software platforms have been robust and comprehensive to meet these demands thrown at it. We will continue to improve it even further. It’s been an exciting project to work on.
