---
title: "Content writing workflow"
date: 2024-04-29T14:25:01+08:00
draft: false
tags: ["Contribute"]
---

## Before you start writing

There are the following prerequisites before you start writing content:

- Decide how you want to contribute by choosing the [content contribution workflow](../content-contrib-workflow "Content contribution workflow") and get a copy of the [espressif / developer-portal][] repo
- To view the built version of the website, [install](https://gohugo.io/installation/) Hugo in your environment and go through [Getting started](https://gohugo.io/getting-started/) if required

[espressif / developer-portal]: https://github.com/espressif/developer-portal "Espressif Developer Portal"


### Create and view an article

See also the official [docs](https://gohugo.io/getting-started/quick-start/#add-content).

- To create a new article, determine the path and run
  ```sh
  hugo new content <path/index.md>
  # Example
  hugo new content blog/contribution_guide/index.md
  ```
  This assumes that you want to organize the content as a leaf bundle (the usual way). You can also use the [branch bundle](https://gohugo.io/content-management/page-bundles/#comparison).
- In the created file, change `draft: true` to `draft: false` to make the article visible in the build.
- To view the changes, in your project folder run
  ```sh
  hugo server
  ```

## Write the content

This is totally up to you how you write the content as long as it is valuable for the community.

For writing and formatting conventions, the contributors at Espressif usually follow the [Espressif Manual of Style](https://mos.espressif.com/) and the *Chicago Manual of Style*. You might find these guidelines useful, but you are not required to follow them.

### Use additional content types

Apart from the usual content types supported by markdown, such as visuals or code snippets, you can also include:

- [Diagrams as code](https://gohugo.io/content-management/diagrams/)
  - Mermaid diagrams are supported, for an example see the raw version of [this page](../content-contrib-workflow "Content contribution workflow")
- Youtube videos using [Hugo shortcodes](https://gohugo.io/content-management/shortcodes/#youtube)
- [asciinema casts](../asciinema_casts "asciinema casts")

If you need other types of content, either create a discussion on GitHub or offer a PR with the required functionality. It will be very much appreciated!


## Ask for review

To publish your content on the Espressif Developer Portal, please create a discussion in [espressif / developer-portal][] invite reviewers from Espressif so that they can make sure your content is in-line with Espressif's writing conventions.

After the review is done, create a PR following the [content contribution workflow](../content-contrib-workflow "Content contribution workflow").