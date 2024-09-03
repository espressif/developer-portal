---
title: ESP Insights — What’s new
date: 2022-01-26
showAuthor: false
authors: 
  - adwait-patankar
---
[Adwait Patankar](https://medium.com/@adwaitpatankar?source=post_page-----abecaff2f8c8--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2Fb31acf34f5e6&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fesp-insights-whats-new-abecaff2f8c8&user=Adwait+Patankar&userId=b31acf34f5e6&source=post_page-b31acf34f5e6----abecaff2f8c8---------------------post_header-----------)

--

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*DB1MVfoKvRaanJaa9Vikpw.png)

ESP Insights was released in its Beta in July 2021 and is being actively used by the ESP developer community. You can read more about it in the blog post [Introducing ESP Insights](/introducing-esp-insights-7d85a1383d21). With this new version of the ESP Insights service, we introduce following new features, plus a few UI enhancements and stability fixes.

- Support for HTTPs/REST API based device communication
- Group Analytics

Let’s look at these new features in more detail.

## HTTPS Transport

When we launched ESP Insights, we borrowed some concepts from ESP RainMaker, especially the concept of “Claiming” and used MQTT as the transport so that we could leverage a single connection for RainMaker and Insights. However, for applications that only want to use ESP Insights without ESP RainMaker, the claiming concept is an unnecessary step.

We now support HTTPs/REST API based Insights communication as well. Instead of using unique X.509 key-certificate pairs, a single HTTP API key can now be used by multiple nodes , thereby simplifying the setup and management of devices.

(Note that given the always-on connectivity of MQTT, some of the features that we introduce in the future may be more optimised for MQTT based transport)

## Enabling Insights with HTTPS

Enabling ESP Insights in your firmware is now as easy as adding the following lines of code in your application:

This code should get your started, and your application can start reporting ESP Insights data to the Insights cloud. As you may have noticed, all you will need is the unique ESP_INSIGHTS_AUTH_KEY to be embedded in your firmware. Here is how you can obtain the ESP Insights Auth Key:

- Sign up or Sign in on [ESP Insights Dashboard](https://dashboard.insights.espressif.com/)
- Visit [Manage Auth Keys](https://dashboard.insights.espressif.com/home/manage-auth-keys) and generate an Auth Key
- Copy the Auth Key to your firmware

Once device boots up look for following logs that contains the Node ID. You may use this node id for monitoring node logs, crashes, reboots, metrics, and variables through the ESP Insights Dashboard.

```
I (4161) esp_insights: =========================================
I (4171) esp_insights: Insights enabled for Node ID 246F2880371C
I (4181) esp_insights: =========================================
```

For more details please check our [getting started guide](https://github.com/espressif/esp-insights/tree/main/examples).

## Group Analytics

So far ESP Insights supported diagnostics at a node level, reporting any abnormal events as well as metrics and point in time variable values for individual nodes.

The latest version of ESP Insights introduces group analytics, that provides insights into how groups of your devices are performing. You may group devices based on the Project, Project Versions or Event categories.

- Compare the firmware insights across different versions of a project
- A very high-level insights starting at a project level and can be drilled down to an event category

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*CmsgjXy5jUabgYbxI6V4Qg.png)

A few examples of group based data that you can observe:

- Counts grouped by events (for e.g., Errors) for a particular project and version, in a selected time interval. You can change the interval to hour or aggregate to week or a month interval

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*ayV33yuy4--ell1bgoVHYA.png)

- Distribution of event counts (for e.g., crash counts) for a group in a selected time interval.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*yywKFAYu4tlIsSGqFX7FtA.png)

- Distribution of event (for e.g. Reboot reason) counts for a group in a selected time interval. You can drill down further on the reboot reason and get to the nodes which are reporting the particular event.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*cpdsBL6ZXg2krYRAOCYP5g.png)

- Count of unique nodes which are reporting certain events (reboots / errors / warnings) in a selected time interval

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*4TOm67stGH2YAUX61i3qBw.png)

- List of top nodes having the most number of events and can be drilled down to category level

We are working on some more exciting features on top of ESP Insights, stay tuned to hear more!
