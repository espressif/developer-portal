---
title: "Dynamic content"
date: 2025-09-09
tags: ["Contribute"]
showTableOfContents: true
showAuthor: false
authors:
  - "kirill-chalov"
---

For pages that change frequently, it is useful to bypass git and inject the updated content dynamically instead of creating PRs every time. As of now, this is helpful for hardware and software product support pages that can update weekly. This article will provide a workflow for injecting dynamic content focusing on the product support pages.


## Plan your page

First of all, the content on a product support page should be classified into the following types:

- **Static**: Rarely changing content
  - Committed to the git repo
  - Stored under
    `content/{hardware|software}/product-x/index.md`
- **Dymanic**: Frequently changing content
  - Dynamically injected into HTML pages using the [dynamic-block](https://github.com/espressif/developer-portal/blob/main/layouts/shortcodes/dynamic-block.html) shortcode
  - Stored in the root of the web server under
    `./persist/{hardware|software}/product-x/product-x.json`
  - Updated either manually or using CI
  - For uploading to the web server, talk to the project maintainers

The dynamic content must be stored in the root of the web server under `persist`. All other folders are fully overwritten daily.


## Arrange your content

Example files:

- Git repo: `content/software/product-x/index.md`
  ```
  ---
  title: "Product X"
  date: 2025-08-28
  ---

  **Last updated:** {{</* dynamic-block contentPath="persist/software/product-x/product-x.json" jsonKey="timestamp" */>}}

  This is a product status page for Product X.

  The following features are supported as of now:

  {{</* dynamic-block contentPath="persist/software/product-x/product-x.json" jsonKey="feature_table" */>}}

  ## Peripheral support table

  {{</* dynamic-block contentPath="persist/software/product-x/product-x.json" jsonKey="periph_support_table" */>}}
  ```
- Web server: `persist/software/product-x/product-x.json`
  ```json
  {
    "timestamp": "2025-08-28T00:07:19.716630Z",
    "feature_list": "- Supported SDKs\n  - ✅ [ESP-IDF](https://github.com/espressif/esp-idf/)\n  - ⏳ SDK 2",
    "periph_support_table": "| Peripheral | ESP32 |\n| :--- | :---: |\n| UART | ✅ |\n| LCD | ❌ |"
  }
  ```

The final page with the dynamic content should look somewhat like this:

---

<span style="font-size:2em; font-weight:bold;">Product X</span>

**Last updated:** 28 Aug 2025, 8:07 am

This is a product status page for Product X.

The following features are supported as of now:

- Supported SDKs
  - ✅ [ESP-IDF](https://github.com/espressif/esp-idf/)
  - ⏳ SDK 2

<span style="font-size:1.5em; font-weight:bold;">Peripheral support table</span>

| Peripheral | ESP32 |
| :--- | :---: |
| UART | ✅ |
| LCD | ❌ |

---


## Test dynamic content

Test your `.json` file locally before uploading to the web server:

- In your git repo, place your `.json` file at the same path as on the server:
  ```sh
  📂 content/software/
  ├── 📝 _index.md
  └── 📂 product-x/
      ├── 📝 index.md
      └── 🧩 persist/software/product-x/product-x.json # remove after testing
  ```
- In your git repo's `layouts/shortcodes/dynamic-block.html`, adjust the toggle for testing:
  ```javascript
  {{ $localMode := true }}  <!-- change to true for local -->
  ```

After you run `hugo server` locally, the JSON content should be injected dynamically on your page.

**If you update JSON**, do this for the changes to show up:

- Restart `hugo server`
- Refresh your browser tab
- If no effect: clear the page cache
