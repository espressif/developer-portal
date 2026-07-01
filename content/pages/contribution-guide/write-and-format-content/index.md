---
title: "Write and format content"
date: 2024-04-29T14:25:01+08:00
lastmod: 2026-05-14
featureAsset: "img/featured/featured-contrib-guide.webp"
tags: ["Contribute"]
showTableOfContents: true
showAuthor: false
authors:
  - "kirill-chalov"
---

This guide consists of the following parts:

- **Publication essentials** -- prepare the article summary, tags, and a feature image
- **Guidelines for structuring content** -- suggestions for creating and structuring content
- **Supported media and content types** -- Overview of shortcodes extending markdown syntax


## Create publication essentials

The essentials include an article summary, tags, and a feature image.

You don't need to create those at the beginning, but:

- Attempting to **write an article summary early on** can help you better understand how to structure your content and which mode of writing to choose, such as an overview, tutorial, or a how-to guide, etc.
- Trying to **think about tags in advance** can help you understand the key topics around which to structure your content.


### Write an article summary

Before you begin writing your article, it is a good exercise to summarize in one paragraph:

1. The **main topic** of your article (1 or 2 sentences).
2. What **value** it brings to the reader (1 or 2 sentences).

{{< alert icon="eye" >}}
Don't include links in summaries as they are not supported by design. Also, avoid formatting text as it doesn't look good in general.
{{< /alert >}}

In addition to helping you better understand how to write your content, it will also help readers decide if they want to read your article as well as to set their expectations.

After you finish writing, revisit your summary to see if it needs any adjustments. You might be surprised by how the focus of your writing can shift during the process without you realizing it.


### Tag the content

Assign tags to your content following the guidelines in [Tagging content](../tagging-content/).


### Prepare a featured image

A featured image appears above the article's title. A nice and relevant image attracts readers like a magnet, that is why consider giving more thought to it.

Here are the guidelines for preparing the featured image:

- Image size should be 1200 x 600 pixels
- This image will be cropped in 2 different sizes as seen in the template below
- You can place the template over your image with transparency to ensure the following:
  - If you use text in your image, it should be within the text safe space
  - Any important elements should be clearly seen in both cropping sizes
- Your featured image should be in WebP as requested in [Use WebP for raster images](#use-webp-for-raster-images)

{{< figure
    default=true
    src="image-template.webp"
    alt="Feature imae template"
    caption="Feature image template"
    >}}

A featured image can be added in the following ways from the highest to lowest priority:

- **Article-specific image file**: In the same folder as your article's `index.md`, place your featured image and make sure its file name includes the substring `feature`, for example: `featured-lcd-screen.webp`.
- **Image from a URL**: In the article's front matter, add the parameter `featureimage` and assign a URL to it, for example:
  ```yaml
  featureimage: "https://espressif.com/logo-guidelines/chinese-horizontal-logo.png"
  ```
  This parameter is from Blowfish theme's [Front Matter][blowfish-front-matter].
- **Generic image file**: If you have no chance to create your own image, try to find a generic image in `assets/img/featured` and assign the path to `featureAsset`, for example:
  ```yaml
  featureAsset: "img/featured/image.webp"
  ```

[blowfish-front-matter]: https://blowfish.page/docs/front-matter/


## Follow the guidelines for structuring content

This is totally up to you how you write the content as long as it is valuable for the community.

At the moment, we are systematizing typical patterns of how developer portal articles are usually written. As a result, we will publish recommended article recipes in the near future.

## Review supported media and content types

Apart from the usual content types supported by markdown, such as visuals or code blocks, you can use other content types enabled by Hugo shortcodes. This section briefly introduces the most relevant shortcodes implemented on the Espressif Developer Portal.

In addition to that, you can also use the standard Hugo [embedded shortcodes](https://gohugo.io/content-management/shortcodes/#embedded) and [Blowfish theme shortcodes](https://blowfish.page/docs/shortcodes/). But please note that Hugo and Blowfish versions (see the badges in the [project README](https://github.com/espressif/developer-portal#developer-portal)) might lag behind the latest ones. Make sure that you check the documentation for the respective versions.

If you need other content types or shortcodes implemented, either create a discussion on GitHub or offer a PR with the required functionality. It will be very much appreciated!


### Admonitions

Admonitions are callout boxes for notes, tips, warnings, and similar messages. The Developer Portal supports two ways to add them:

- **[GitHub-style admonitions](#github-style-admonitions)** — standard GFM markdown blockquotes that many editors and platforms (including GitHub) render without extra tooling.
- **[Alerts](#alerts)** — the Blowfish `alert` shortcode, which requires Hugo to build the si

#### GitHub-style admonitions

The Blowfish theme renders [GitHub-style admonitions](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts) from plain markdown. Write a blockquote whose first line starts with an alert type: `NOTE`, `TIP`, `IMPORTANT`, `WARNING`, and `CAUTION` in square brackets:.

```md
> [!NOTE]
> Use admonitions to highlight important information.
```

> [!NOTE]
> Use admonitions to highlight important information.

Blowfish supports [additional features](https://blowfish.page/docs/shortcodes/#admonition), such as the alert sign (`+` or `-`) to control whether the admonition is folded or not:

```sh
> [!TIP]- Custom Title
> A collapsible admonition with custom title.
```

> [!TIP]- Custom Title
> A collapsible admonition with custom title.


#### Alerts

To add an alert, use the following shortcode:

```sh
{{</* alert >}}
  Use alerts only when they are really needed.
{{< /alert */>}}
```

{{< alert >}}
  Use alerts only when they are really needed.
{{< /alert >}}

You can also change its parameters:

```sh
{{</* alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
  Now you see a customized icon, its color, and the alert color.
{{< /alert */>}}
```

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
  Now you see a customized icon, its color, and the alert color.
{{< /alert >}}


### Diagrams as code

Hugo supports a number of [Diagrams as code](https://gohugo.io/content-management/diagrams/) tools, including [Mermaid](https://mermaid.js.org/). The Blowfish theme adds [Chart.js](https://blowfish.page/docs/shortcodes/#chart) to the list.

As an example of how diagrams as code work, see a [rendered Mermaid diagram](../contrib-workflow "Contribution workflow") and its [raw code][contrib-workflow-raw].



[contrib-workflow-raw]: https://github.com/espressif/developer-portal/blob/main/content/pages/contribution-guide/contrib-workflow/index.md?plain=1#L167-L412


### Images

#### Adding images

Please avoid using a standard markdown syntax for adding an image:

```md
![Alt text](path/to/image.webp "Optional tooltip")
```

Instead, use the [figure](https://blowfish.page/docs/shortcodes/#figure) shortcode provided by the Blowfish theme that is used on this website. It offers more control over image display and render. The images are optimized for different device resolutions which reduces website load time. An example of a shortcode is given below, but more parameters are available:

```md
{{</* figure
    src="image.webp"
    alt=""
    caption=""
    */>}}
```


#### Use WebP for raster images

For raster images, please use the WebP format only. The Developer Portal's CI blocks the images in PNG anf JPEG format.

The WebP format was chosen for the following reasons:

- The images in WebP are comparable in quality to PNG and JPEG but are 5-7 times smaller in size
- Smaller image size is important
  - It prevents the git repo from growing out of proportion very fast
  - It allows serving web pages faster

To convert your images to WebP, use one of the following ways:

- Use [imagemagick](https://imagemagick.org/script/download.php):

  ```sh
  convert image.jpg -quality 60 image.webp
  ```
- Use [cwebp](https://developers.google.com/speed/webp/download):

  ```sh
  cwebp -q 60 image.jpg -o image.webp
  ```

The quality value `60` usually yields good results. For very good quality, you can use the value `80`.


### Animated images

Including an animated screenshot of some action done in GUI can sometimes replace a thousand words.

You can do this, but please don't use the GIF format for its bad compression rates. Instead, create a `.mp4` file and further compress it with `FFmpeg` if needed.

After that, include your `.mp4` video using this shortcode:

```sh
{{</* video src="video/my-video.mp4" */>}}
```

You might also find useful [Asciinema casts](#asciinema-casts) and [Video](#video).


### Code block

A code block can be inserted using the standard markdown syntax -- backticks.

Hugo also provides the [highlight shortcode](https://gohugo.io/shortcodes/highlight/) which offers additional features, such as numbering and highlighting lines:

{{< highlight c "linenos=table,hl_lines=3 5" >}}
    led_strip_config_t strip_config = {
        // Set the GPIO8 that the LED is connected
        .strip_gpio_num = 8,
        // Set the number of connected LEDs, 1
        .max_leds = 1,
        // Set the pixel format of your LED strip
        .led_pixel_format = LED_PIXEL_FORMAT_GRB,
        // LED model
        .led_model = LED_MODEL_WS2812,
        // In some cases, the logic is inverted
        .flags.invert_out = false,
    };
{{< /highlight >}}


### Tabs

Tabs look neat:

{{< tabs group="config" >}}
  {{< tab label="Linux" >}}
```md
Linux code block
```
  {{< /tab >}}
  {{< tab label="macOS" >}}
Update homebrew, then run:
```md
macOS code block
```
  {{< /tab >}}
{{< /tabs >}}

At the same time, the markup is very simple:

````md
{{</* tabs group="config" */>}}
  {{</* tab label="Linux" */>}}
```md
Linux code block
```
  {{</* /tab */>}}
  {{</* tab label="macOS" */>}}
Update homebrew, then run:
```md
macOS code block
```
  {{</* /tab */>}}
{{</* /tabs */>}}
````

Some explanations:

- Use the [tabs](https://blowfish.page/docs/shortcodes/#tabs) shortcode to create a tab block
- Use the nested [tab](https://blowfish.page/docs/shortcodes/#tabs) shortcode to create as many tabs as you need
- Within a tab, place any markdown content you want, it will be rendered like any other markdown content
  - Set `md=false` on a `tab` when its content includes other shortcodes (for example `alert` or `video`)
- Use the same `group` value on multiple tab blocks when readers should switch all of them together (for example, OS tabs repeated in several steps of a tutorial).
- On page load, the first tab is selected; use `default="<tab-name>"` to have that tab selected

Example with `default` and `icon`:

{{< tabs group="lang" default="Python" >}}
  {{< tab label="JavaScript" icon="code" >}}
```javascript
console.log("Hello");
```
  {{< /tab >}}
  {{< tab label="Python" icon="sun" >}}
```python
print("Hello")
```
  {{< /tab >}}
{{< /tabs >}}

````md
{{</* tabs group="lang" default="Python" */>}}
  {{</* tab label="JavaScript" icon="code" */>}}
```javascript
console.log("Hello");
```
  {{</* /tab */>}}
  {{</* tab label="Python" icon="sun" */>}}
```python
print("Hello")
```
  {{</* /tab */>}}
{{</* /tabs */>}}
````

You can **indent a tab block** by preceding the `tabs` and `tab` shortcodes with the required number of spaces. But don't indent the tab content.


### Asciinema casts

[Asciinema](https://asciinema.org/) allows you to record terminal sessions using a lightweight text-based format.

If you want to use an asciinema cast in your article, see [asciinema casts](../asciinema-casts "asciinema casts").


### Video

To embed a video in your article, upload it to a video streaming platform such as YouTube and use the [YouTube shortcode](https://gohugo.io/content-management/shortcodes/#youtube) provided by Hugo to include it in your content. If you don't have your own YouTube channel, we can upload your video to ours.

If you give your consent and share the video file with us, we can also upload it to BiliBili to make it accessible in more geographic areas.


### GitHub card

The [Github Card](https://blowfish.page/docs/shortcodes/#github-card) shortcode adds a card with information about the linked GitHub repository.

{{< github repo="espressif/esp-idf" >}}


### Dynamic content

If your page is going to be updated frequently, consider implementing injection of dynamic content. Usually, it is used for product status pages, such as [ESP32-C61 status](../../../hardware/esp32c61 "ESP32-C61 status").

For more information, see [Dynamic content](../dynamic-content "Dynamic content").


## Next step

> Next article &rarr; [Validate and publish content](../validate-and-publish-content/)

> Back to the [Contribution guide](../)
