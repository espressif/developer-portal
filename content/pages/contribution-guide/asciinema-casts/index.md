---
title: "asciinema casts"
date: 2024-03-18T10:55:37+01:00
tags: ["Contribute"]
showTableOfContents: true
showAuthor: false
authors:
  - "kirill-chalov"
---

## Overview

[asciinema](https://asciinema.org/) allows you to record terminal sessions using a lightweight text-based format. You can easily embed asciinema casts on the Developer Portal.

### Notable features

- Copy text and commands directly from the video
- Add [Markers](https://docs.asciinema.org/manual/cli/markers/) similar to Youtube chapters
- Edit casts by manipulating the [file contents](https://docs.asciinema.org/manual/asciicast/v2/#m-marker) or using [asciinema-edit](https://github.com/cirocosta/asciinema-edit)

### Word of caution

Use asciinema casts for output logs or to demonstrate things in action. Avoid using asciinema casts for interactive guides as many users [prefer](https://news.ycombinator.com/item?id=38137005) scrolling through commands and copying them from code snippets instead of fishing the commands out of an asciinema cast.


## Usage

### How to upload and embed a cast

1. Install asciinema and record a terminal session following the [Quick start](https://docs.asciinema.org/manual/cli/quick-start/) guide.
2. Edit the `.cast` file if required.
3. Add the .cast file in the same directory as your article.
4. Embed a Hugo shortcode in your article.<br>
    For example, the shortcode below embeds the file `demo.cast` and adjusts some [asciinema player options](https://docs.asciinema.org/manual/player/options/):
    ```md
    {{</* asciinema
      key="demo"
      idleTimeLimit="2"
      speed="1.5"
      poster="npt:0:09"
    */>}}
    ```

The above shortcode will be rendered as follows:

{{< asciinema
  key="demo"
  idleTimeLimit="2"
  speed="1.5"
  poster="npt:0:09"
>}}

### How to embed a cast from asciinema.org

You can embed a cast hosted on [asciinema.org](https://asciinema.org):

- Under the video, click the Share button
- Copy the code snippet provided under _Embed the player_ and paste where needed, for example<br>
    \<script src="https://asciinema.org/a/342851.js" id="asciicast-342851" async="true"></script\>

The above shortcode will be rendered as follows:

<script src="https://asciinema.org/a/342851.js" id="asciicast-342851" async="true"></script>


## Resources

- [Embedding asciinema cast in your Hugo site](https://jenciso.github.io/blog/embedding-asciinema-cast-in-your-hugo-site/)
