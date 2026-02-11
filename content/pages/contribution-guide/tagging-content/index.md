---
title: "Tagging content"
date: 2026-01-13
tags: ["Contribute"]
showTableOfContents: true
showAuthor: false
authors:
  - "kirill-chalov"
---

This article is split into the following parts:

- **Guidelines for assigning tags** -- gives you some background information
- **How to assign tags** -- instructs you on how to and what tags to assign


## Guidelines for assigning tags

In this section, you will find the following guidelines:

<!-- no toc -->
- [Choosing tags](#choosing-tags)
- [Spelling tags](#spelling-tags)

Once you familiarize yourself with these guidelines, go to [How to assign tags](#how-to-assign-tags).

### Choosing tags

1. **Choose tags that clearly indicate who the article is for and what it covers**, following _How to assign tags_.
2. **Choose the correct abstraction level**.
    - Avoid overly generic or umbrella tags:
      - Tags such as `Espressif` or `IoT` don't add value in highlighting key topics.
      - If a suggested higher-level term is too broad and multiple articles share a distinct topic, introduce a more specific tag. For example, if several articles focus on face recognition, introduce `face recognition` instead of using only `machine vision`.
    - Avoid overly narrow tags when the content applies to a broader category
      - For content applicable to both `Zephyr` and `NuttX`, consider using the broader tag `RTOS`.
      - For content applicable to multiple Espressif SoCs, don't add specific tags, such as `ESP32` or `ESP32-C3`.
3. **Keep the taxonomy sustainable**.
    - Avoid creating tags that will only apply to one or two articles.
      - If `ESP32-C3-DevKit-RUST-1` is a key topic but no additional articles are expected, use the broader tag `DevKit`.
      - If an article covers the `ESP-Audio-Effects` component and no further articles are planned, use `ESP-IDF component`.
    - If important topics are not represented in the current tagging system, provide feedback for improvement.

### Spelling tags

- Use lower case letters.<br>
  **Exceptions**: Capitalize proper nouns and established terms, such as:
  - Product names: `ESP32-P4`, `ESP-IDF`, `NuttX`
  - Terms, protocols, and features: `SoC`, `Ethernet`, `WebRTC`
  - Abbreviations: `IDE`, `LED`, `LLVM`
- Use tags in singular.<br>
  **Exceptions**: Singular (uncountable) words that end in `s`:
  - Mass nouns: `graphics`, `robotics`
  - Established terms: `ESP Insights`, `DevOps`
- Use spaces to separate words.<br>
  **Exceptions**: Use hyphens only in established terms:
  - Compound terms: `ESP32-C3`, `esp-idf-kconfig`, `Wi-Fi`


{{< dynamic-block contentPath="persist/maintenance/contribution/how-to-assign-tags.json" jsonKey="how_to_assign_tags" >}}
