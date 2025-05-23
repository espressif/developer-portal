---
title: "ESP Insights: In-depth device metrics"
date: 2022-04-28
showAuthor: false
featureAsset: "img/featured/featured-insights.webp"
authors:
  - adwait-patankar
tags:
  - Esp32
  - IoT
  - Espinsights

---
{{< figure
    default=true
    src="img/esp-1.webp"
    >}}

In the earlier version of the ESP Insights Dashboard users could check and analyse device reported metrics, for only up to the past 3 hours.

We received developer feedback that they would like to look at the metrics within a particular time frame and most importantly in the time frame around an all important event being investigated viz. a crash or a reboot.

In the latest version of ESP Insights Dashboard, a user can play around the metrics data and analyse the issue in more depth using more granular date and time. Using the zoom in feature, zero-in to a very narrow window. Any impacting events that may have an effect on the metrics data are also highlighted viz. a reboot event or a crash.

## Date & Time Selector Widget

Users can now select a particular day with a date picker widget and using the slider select the time span for which metrics are to be investigated. Data correlation with the event logs and the associated device metrics at that given point of time can be achieved in a much better way now.

{{< figure
    default=true
    src="img/esp-2.webp"
    >}}

## Event Metric Correlation

It is always better to check how a certain event occurrence impacts the metrics values reported by the device or vice-versa. For e.g. after an out of memory situation causing a crash or on reboot, the free heap size memory gets back to the expected baseline state

{{< figure
    default=true
    src="img/esp-3.webp"
    >}}

Also on clicking on the vertical event bar, the details of the event (viz. timestamp and the reason and where the crash occurred) are now displayed.

## Zoom In

The plotted time series graph now also has the zoom-in capabilities to zero-in on the particular data points in the given time window.

You may also use the time range selector at the top to fine-tune the timeframe.

{{< figure
    default=true
    src="img/esp-4.webp"
    >}}

Try out the new detailed metrics insights by accessing and analysing the device metrics data on the [ESP Insights Dashboard](https://dashboard.insights.espressif.com).
