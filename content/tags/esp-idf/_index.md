---
title: "ESP-IDF"
draft: false
featureimage: "img/featured/featured-espressif.webp"
summary: "Explore ESP-IDF, Espressif's official development framework for building production-ready applications across the full range of Espressif SoCs."
showDate: false
showDateUpdated: false
showHeadingAnchors: false
showPagination: false
showReadingTime: false
showTaxonomies: false
showWordCount: false
showSummary: false
showAuthor: false
disableComments: true
showZenMode: true
aliases:
  - /esp-idf/
  - /espidf/
---

*Also available in [中文]({{< relref "zh-cn.md" >}}).*

{{< figure
    default=true
    src="img/esp-idf.webp"
    nozoom=true
    class="esp-idf-landing-hero"
>}}

## Welcome to ESP-IDF

[ESP-IDF](https://github.com/espressif/esp-idf) — the **Espressif IoT Development Framework** — is our official, production-grade SDK for every Espressif SoC. Whether you are prototyping a sensor node, shipping a Matter-certified product, or building an edge device with AI, ESP-IDF gives you drivers, networking stacks, security features, and build tooling in one place so you can focus on your application.

## Why ESP-IDF

**One framework, many chips.** Use the same APIs, build system, and workflow across all Espressif SoC series. Switch to a newly-released chip to get the latest features, or to a cost-effective one to meet your BOM budget — all without changing your application code.

**Built for real products.** ESP-IDF powers applications running on over a billion ESP chips shipped worldwide. Our [release roadmap](https://github.com/espressif/esp-idf/blob/master/ROADMAP.md) includes regular feature and bugfix releases.

**Open source on GitHub.** Inspect the code and tap into a global community of contributors and commercial partners.

<div id="idf-github-stats" class="flex gap-4 my-4">
  <a id="idf-stat-stars" href="https://github.com/espressif/esp-idf/stargazers" target="_blank" rel="noopener"
    class="flex-1 rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-5 text-center shadow hover:shadow-md transition-shadow no-underline">
    <div class="text-4xl font-bold text-primary-600 dark:text-primary-400">—</div>
    <div class="mt-1 text-sm text-neutral-600 dark:text-neutral-400">GitHub stars</div>
  </a>
  <a id="idf-stat-forks" href="https://github.com/espressif/esp-idf/forks" target="_blank" rel="noopener"
    class="flex-1 rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-5 text-center shadow hover:shadow-md transition-shadow no-underline">
    <div class="text-4xl font-bold text-primary-600 dark:text-primary-400">—</div>
    <div class="mt-1 text-sm text-neutral-600 dark:text-neutral-400">Forks</div>
  </a>
</div>

<script>
  fetch("https://api.github.com/repos/espressif/esp-idf")
    .then(r => r.json())
    .then(data => {
      document.querySelector("#idf-stat-stars div").textContent = data.stargazers_count.toLocaleString();
      document.querySelector("#idf-stat-forks div").textContent = data.forks_count.toLocaleString();
    })
    .catch(() => {
      document.getElementById("idf-github-stats").style.display = "none";
    });
</script>

## SoCs in the latest release

The **latest ESP-IDF release <a id="idf-latest-version-link" href="https://github.com/espressif/esp-idf/releases/latest">—</a>** supports the full Espressif lineup below—pick the radio, performance, and peripherals that fit your design, and stay on one framework as your product evolves.

<script>
  fetch("https://api.github.com/repos/espressif/esp-idf/releases/latest")
    .then(r => r.json())
    .then(data => {
      const el = document.getElementById("idf-latest-version-link");
      el.textContent = data.tag_name;
      el.href = data.html_url;
    });
</script>

<div class="grid grid-cols-1 gap-4 my-4 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi & Bluetooth Classic & BLE</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-S2</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-S3</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi & BLE</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-C2</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi & BLE</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-C3</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi & BLE</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-C5</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi & BLE</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-C6</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi, BLE & IEEE 802.15.4</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-C61</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi & BLE</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-H2</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">BLE & IEEE 802.15.4</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-P4</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">High-performance</div>
  </div>
</div>

For the authoritative, up-to-date list (including new chips and targets), see the [ESP-IDF Compatibility — Detailed ESP-IDF Support for Chip Revisions](https://github.com/espressif/esp-idf/blob/master/COMPATIBILITY.md).

## New chip support status

Track the support status of newly introduced Espressif chips in ESP-IDF and related frameworks, with links to detailed per-chip status pages and rollout updates.

{{< article link="/hardware/" showSummary=true compactSummary=true >}}

## Install ESP-IDF

The fastest path on Windows, macOS, and Linux is the **ESP-IDF Installer Manager (EIM)**. It installs the toolchains, Python environment, and ESP-IDF itself so you can run `idf.py build` without manual dependency hunting.

### Download

Get GUI installers, portable binaries, and release bundles from the [EIM downloads page](https://dl.espressif.com/dl/eim/), or install EIM with your platform package manager:

{{< tabs groupId="eim-download" >}}
{{% tab name="Windows" %}}
**Package manager (recommended)**

```powershell
# Install GUI version
winget install Espressif.EIM
# Install CLI version only
winget install Espressif.EIM-CLI
```

**Manual download:** use the [EIM downloads page](https://dl.espressif.com/dl/eim/) for Windows installers or portable builds.
{{% /tab %}}
{{% tab name="macOS" %}}
**Package manager (recommended)**

```bash
# First add the EIM tap
brew tap espressif/eim
# Install GUI version
brew install --cask eim-gui
# Or install CLI version only
brew install eim
```

**Manual download:** use the [EIM downloads page](https://dl.espressif.com/dl/eim/) for macOS builds.
{{% /tab %}}
{{% tab name="Linux (deb)" %}}
**Package manager (recommended)**

```bash
# Add the EIM APT repository
echo "deb [trusted=yes] https://dl.espressif.com/dl/eim/apt/ stable main" | \
    sudo tee /etc/apt/sources.list.d/espressif.list
# Update package lists
sudo apt update
# Install CLI version
sudo apt install eim-cli
# Or install GUI version
sudo apt install eim
```

**Manual download:** use the [EIM downloads page](https://dl.espressif.com/dl/eim/) for `.deb` packages or portable Linux binaries.
{{% /tab %}}
{{% tab name="Linux (rpm)" %}}
**Package manager (recommended)**

```bash
# Download and install the RPM repository configuration
sudo dnf install https://dl.espressif.com/dl/eim/rpm/eim-repo-latest.noarch.rpm
# Install CLI version
sudo dnf install eim-cli
# Or install GUI version
sudo dnf install eim
```

**Manual download:** use the [EIM downloads page](https://dl.espressif.com/dl/eim/) for RPM packages or portable Linux binaries.
{{% /tab %}}
{{< /tabs >}}

After EIM finishes, you have CMake-based projects, Xtensa and RISC-V toolchains, and the same `idf.py` workflow on every supported OS.

## IDEs and editors

Use the tools you already know. ESP-IDF is CMake-first, so any editor with solid CMake and C/C++ support works well. For the most integrated experience, start here:

- **[Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension)** — Official ESP-IDF extension: setup, flash, monitor, and SDK configuration from the editor
- **[Eclipse](https://github.com/espressif/idf-eclipse-plugin)** — ESP-IDF plug-in for Eclipse users
- **[CLion](https://www.jetbrains.com/clion/)** — Open the project as a CMake profile and use CLion’s navigation and debugging

## To know more about: Documentation

Everything you need to go from “blink” to production:

- **[ESP-IDF Programming Guide](https://docs.espressif.com/projects/esp-idf/en/latest/)** — Getting started, API reference, and guides
- **[ESP-IDF on GitHub](https://github.com/espressif/esp-idf)** — Source, issues, and contributions
- **[Release notes](https://release-notes.espressif.tools/)** — What changed in each version
- **[Espressif SoCs](https://www.espressif.com/en/products/socs)** — Browse the full SoC portfolio and compare families
- **[Espressif Documentation](https://documentation.espressif.com/en/home)** — Central hub for Espressif technical documentation across products
- **[Espressif Products](https://products.espressif.com)** — Modules, dev kits, and product-level information

## AI-assisted development (MCP)

Connect ESP-IDF to assistants and automation through **Model Context Protocol (MCP)** servers:

- **ESP-IDF Tools Local MCP Server** (ESP-IDF v6.0+) — Exposes your project to compatible assistants; run with `eim run "idf.py mcp-server"` (e.g. VS Code Copilot, Cursor)
- **[Espressif Documentation MCP Server](https://mcp.espressif.com/)** — Lets tools query current Espressif documentation, including ESP-IDF, for answers grounded in published docs

## ESP Component Registry

<style>
  section.prose > .min-w-0 { max-width: 100%; }
  .esp-idf-landing-hero img {
    max-width: 60%;
    height: auto;
    margin-inline: auto;
    display: block;
  }
</style>

{{< figure
    default=true
    src="img/registry.webp"
    nozoom=true
    class="esp-idf-landing-hero"
>}}

Skip boilerplate and pull in maintained, versioned building blocks from the official **[ESP Component Registry](https://components.espressif.com/)**—drivers, protocols, UI helpers, cloud connectors, and more. Add a dependency without vendoring entire trees:

```bash
idf.py add-dependency "namespace/component_name"
```

Browse the full catalog at [components.espressif.com](https://components.espressif.com/).

<div id="esp-registry-stats" class="flex gap-4 my-4">
  <div class="flex-1 rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-5 text-center shadow">
    <div id="stat-components" class="text-4xl font-bold text-primary-600 dark:text-primary-400">—</div>
    <div class="mt-1 text-sm text-neutral-600 dark:text-neutral-400">Published components</div>
  </div>
  <div class="flex-1 rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-5 text-center shadow">
    <div id="stat-downloads" class="text-4xl font-bold text-primary-600 dark:text-primary-400">—</div>
    <div class="mt-1 text-sm text-neutral-600 dark:text-neutral-400">Registry downloads (all time)</div>
  </div>
</div>

<script>
  fetch("https://components.espressif.com/api/stats")
    .then(r => r.json())
    .then(data => {
      document.getElementById("stat-components").textContent =
        data.components.total.toLocaleString();
      document.getElementById("stat-downloads").textContent =
        data.downloads.total.toLocaleString();
    })
    .catch(() => {
      document.getElementById("esp-registry-stats").style.display = "none";
    });
</script>

### Popular right now

A snapshot of widely used components from the registry:

<div id="esp-popular-components" class="grid grid-cols-1 gap-4 my-4 sm:grid-cols-2">
  <div class="text-neutral-400 dark:text-neutral-500 col-span-full text-sm">Loading…</div>
</div>

<script>
  fetch("https://components.espressif.com/api/components?sort_by=total&per_page=4")
    .then(r => r.json())
    .then(components => {
      const grid = document.getElementById("esp-popular-components");
      grid.innerHTML = components.map(c => {
        const desc = c.latest_version.description || "";
        const url = `https://components.espressif.com/components/${c.namespace}/${c.name}`;
        const downloads = c.latest_version.downloads_total.toLocaleString();
        return `
          <a href="${url}" target="_blank" rel="noopener"
            class="flex flex-col justify-between rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow hover:shadow-md transition-shadow no-underline">
            <div>
              <div class="text-xs text-neutral-400 dark:text-neutral-500 mb-1">${c.namespace}</div>
              <div class="font-semibold text-neutral-800 dark:text-neutral-200">${c.name}</div>
              <p class="mt-1 text-sm text-neutral-600 dark:text-neutral-400 line-clamp-2">${desc}</p>
            </div>
            <div class="mt-3 text-xs text-neutral-400 dark:text-neutral-500">⬇ ${downloads} downloads</div>
          </a>`;
      }).join("");
    })
    .catch(() => {
      document.getElementById("esp-popular-components").style.display = "none";
    });
</script>

## Frameworks for specialized stacks

When your product needs more than “vanilla” firmware, these Espressif frameworks sit on top of ESP-IDF and accelerate common domains:

- **[ESP-BROOKESIA](https://github.com/espressif/esp-brookesia)** — UI toolkit for HMIs and products with displays
- **[ESP-DSP](https://github.com/espressif/esp-dsp)** — Optimized digital signal processing for audio, control, and analytics on-chip
- **[ESP-WHO](https://github.com/espressif/esp-who)** — Vision pipeline building blocks for ESP32-class devices with a camera
- **[ESP-Matter](https://github.com/espressif/esp-matter)** — Matter connectivity aligned with Espressif silicon and certification paths
- **[ESP-Zigbee-SDK](https://github.com/espressif/esp-zigbee-sdk)** — Zigbee stack for IEEE 802.15.4–capable chips such as ESP32-C6 and ESP32-H2

## Follow us on the community side

Join other ESP32 and ESP-IDF developers for questions, project showcases, and informal support:

- **[ESP32.com forum](https://esp32.com/index.php)** — Official Espressif community forum
- **[r/esp32 on Reddit](https://www.reddit.com/r/esp32/)** — News, builds, and discussion
- **[Espressif Discord](https://discord.com/invite/XqnZPbF)** — Real-time chat with the community

## Related
