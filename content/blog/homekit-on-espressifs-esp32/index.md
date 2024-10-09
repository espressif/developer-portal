---
title: "HomeKit on Espressif’s ESP32"
date: 2019-02-10
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - kedar-sovani
tags:
  - Internet Of Things
  - Esp32

---
IoT is not one thing, it means different things to different people. So also, there are so many ways of building connected products. And that means there are so many questions for every aspect of your connected product:

- What communication protocols do we use?
- Which network configuration mechanism should we use?
- What do we use for remote communication?
- What’s the most secure method for doing this?
- Do we offer low-latency control options through local network access?
- How do we expose this in the app so that it offers the smoothest user experience?
- How do we participate in the broader smart-home ecosystem?

Every question is additional time spent researching about a topic and identifying the best (and secure) solution for the problem.

When the Apple HomeKit ecosystem came along, it came with a set of defined solutions for most of these questions, such that they are secure, easy to use and part of a larger ecosystem.

In the same spirit, we decided to build a HomeKit SDK that is extremely easy and intuitive to build with. And at the same time make it quite extensible, for developers that want to do off-beat things with it.

So far, we have a large number of customers developing with our HomeKit SDK (HomeKit requires developers to have Apple’s MFi license), and given the feedback that I have seen, the SDK has helped them shave off significant development time, reaching to production faster. The SDK has been a significant product management win. Let’s look at some key highlights.

## API

Let’s say, I have been a manufacturer of electric switches. I think this consumer interest in the smart-home is exciting and I want to build a smart electric switch. What I really want to do is enable the on/off toggle of this switch through a phone or tablet. All I want is a way to say that these are the __attributes__  I have (in this case: *the power state*), and this is what happens when I __read__  the attributes or __update__  them (in this case: assert/deassert a GPIO that controls a relay). All these questions above, about network configuration, discovery, cloud servers and interoperability are a needless hindrance. Should I really have to answer all these questions, and if so who do I seek out for a more informed decision?

For the HomeKit SDK, we have spent a significant amount of time on the API design, keeping this in mind. We have structured the API in such a way that for all the common scenarios, customers only have to do the bare minimal things. They declare what the device __attributes__ are (heating/cooling state and temperature for the thermostat), and how to __read/update__  them (perform a SPI transaction that sets the temperature). Everything else about connectivity, comformance, state management, is handled by the SDK.

And by creating the right layers of advanced APIs underneath these simplified APIs, we can also accommodate the diverging use cases that don’t necessarily fit in this simplified model. This allows us to support a wide range of end-product scenarios.

## End-Product Features

We keep putting ourselves into our customers’ shoes, trying to understand the typical additional features that developers would want to have in their product. And try to provide better support for these up-front.

For example, developers building HomeKit-enabled products, may also want to have support for Android-initiated configuration or Android/Cloud initiated access. The SDK includes software components that let you do this without affecting the HomeKit workflows. And it is structured so that it is an optional component, (a) you could use it in your product, (b) you could completely not have it, or (c) use a completely different method for supporting Android access.

Similar is the case for supporting common features such as over-the-air (OTA) firmware upgrades, using secure storage, or handling per-device unique manufacturing data. Appropriate abstractions ensure that these common tasks are made as smooth as possible, at the same time, provide flexibility to diverge.

## Developer Workflows

For an SDK, optimising for developer workflows directly implies getting faster to that production-ready firmware. As developers start using the HomeKit SDK, they are at various stages of HomeKit expertise. Some have done it before, some are just starting anew. Some may have all the hardware components required for building HomeKit products, while others may have to wait for the hardware lead time before they get started.

The SDK provides multiple start points such that evaluation or development doesn’t have to block on one particular aspect. As you progress through the stages of evaluation to manufacturing, you can incrementally move components into the final production-ready state.

## Fix-only-once

Our mantra for support is *Fix only once*. What that means is that once a customer issue is reported, it should either lead to a documentation update, or a code commit. This ensures that that issue, or those class of issues, should never be reported again by any customer.

Our SDK continues to evolve with every new customer that uses the SDK, and every new feature that they implement. We are excited about this journey and continue to look forward to making it even easier to build connected devices.

## References

- Register for HomeKit SDK access (MFi Account Number Mandatory): [https://www.espressif.com/en/company/contact/pre-sale-questions-crm?js-from=homekit](https://www.espressif.com/en/company/contact/pre-sale-questions-crm?js-from=homekit)
- Mass Manufacturing Utility: [https://docs.espressif.com/projects/esp-idf/en/latest/api-reference/storage/mass_mfg.html](https://docs.espressif.com/projects/esp-idf/en/latest/api-reference/storage/mass_mfg.html)
- Manufacturing Data Partitions: [https://medium.com/the-esp-journal/building-products-creating-unique-factory-data-images-3f642832a7a3](/blog/building-products-creating-unique-factory-data-images)

All product names, trademarks and registered trademarks are property of their respective owners.
