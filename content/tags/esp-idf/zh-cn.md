---
title: "ESP-IDF"
draft: false
featureimage: "img/featured/featured-espressif.webp"
summary: "探索 ESP-IDF——乐鑫面向全系列 SoC 的官方开发框架，用于构建可量产的应用。"
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
build:
  list: never
  render: always
---

*[English version]({{< relref "_index.md" >}})*

## 欢迎使用 ESP-IDF

[ESP-IDF](https://github.com/espressif/esp-idf)——**乐鑫物联网开发框架（Espressif IoT Development Framework）**——是我们面向每一款乐鑫 SoC 的官方、可量产级 SDK。无论您在搭建传感器节点原型、交付 Matter 认证产品，还是构建带 AI 的边缘设备，ESP-IDF 都将驱动程序、网络协议栈、安全能力与构建工具集于一处，让您专注于应用本身。

## 为何选择 ESP-IDF

**一套框架，多款芯片。** 在所有乐鑫 SoC 系列上使用相同的 API、构建系统与工作流。可切换到最新发布的芯片以获得新特性，或切换到更具成本优势的芯片以控制 BOM——而无需改动应用代码。

**面向真实产品。** ESP-IDF 驱动着全球已出货逾十亿颗 ESP 芯片上的应用。我们的[发布路线图](https://github.com/espressif/esp-idf/blob/master/ROADMAP_CN.md)包含定期的功能版与修复版。

**GitHub 开源。** 您可以直接阅读源码，并与全球贡献者与商业伙伴共建生态。

<div id="idf-github-stats" class="flex gap-4 my-4">
  <a id="idf-stat-stars" href="https://github.com/espressif/esp-idf/stargazers" target="_blank" rel="noopener"
    class="flex-1 rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-5 text-center shadow hover:shadow-md transition-shadow no-underline">
    <div class="text-4xl font-bold text-primary-600 dark:text-primary-400">—</div>
    <div class="mt-1 text-sm text-neutral-600 dark:text-neutral-400">GitHub Stars</div>
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

## 最新发行版支持的 SoC

**最新 ESP-IDF 发行版 <a id="idf-latest-version-link" href="https://github.com/espressif/esp-idf/releases/latest">—</a>** 支持下列完整乐鑫产品线——按射频、性能与外设选型，并在产品演进过程中沿用同一套框架。

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
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi &amp; Bluetooth Classic &amp; BLE</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-S2</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-S3</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi &amp; BLE</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-C2</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi &amp; BLE</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-C3</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi &amp; BLE</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-C5</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi &amp; BLE</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-C6</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi、BLE 与 IEEE 802.15.4</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-C61</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">Wi-Fi &amp; BLE</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-H2</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">BLE 与 IEEE 802.15.4</div>
  </div>
  <div class="flex flex-col rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-4 shadow">
    <div class="font-semibold text-neutral-800 dark:text-neutral-200">ESP32-P4</div>
    <div class="mt-2 text-sm text-neutral-600 dark:text-neutral-400">高性能</div>
  </div>
</div>

如需查看权威且最新的列表（包括新增的芯片和目标平台），请参阅 [ESP-IDF 兼容性——各芯片版本的详细 ESP-IDF 支持情况](https://github.com/espressif/esp-idf/blob/master/COMPATIBILITY_CN.md)。

## 新芯片支持状态

跟踪乐鑫新芯片在 ESP-IDF 及相关框架中的支持情况，并提供每款芯片的详细状态页面和发布进展更新链接。

{{< article link="/hardware/" showSummary=true compactSummary=true >}}

## 安装 ESP-IDF

在 Windows、macOS 与 Linux 上最快的方式是使用 **ESP-IDF 安装管理器（EIM）**。它会安装工具链、Python 环境与 ESP-IDF 本体，让您无需再手动查找和安装各项依赖，即可运行 `idf.py build`。

### 下载

从 [EIM 下载页](https://dl.espressif.com/dl/eim/) 获取图形安装包、便携压缩包与发行合集，或通过各平台包管理器安装 EIM：

{{< tabs groupId="eim-download" >}}
{{% tab name="Windows" %}}
**包管理器（推荐）**

```powershell
# 安装图形界面版本
winget install Espressif.EIM
# 仅安装 CLI 版本
winget install Espressif.EIM-CLI
```

**手动下载：** 使用 [EIM 下载页](https://dl.espressif.com/dl/eim/) 获取 Windows 安装包或便携构建。
{{% /tab %}}
{{% tab name="macOS" %}}
**包管理器（推荐）**

```bash
# 添加 EIM tap
brew tap espressif/eim
# 安装图形界面版本
brew install --cask eim-gui
# 或仅安装 CLI 版本
brew install eim
```

**手动下载：** 使用 [EIM 下载页](https://dl.espressif.com/dl/eim/) 获取 macOS 构建。
{{% /tab %}}
{{% tab name="Linux (deb)" %}}
**包管理器（推荐）**

```bash
# 添加 EIM APT 软件源
echo "deb [trusted=yes] https://dl.espressif.com/dl/eim/apt/ stable main" | \
    sudo tee /etc/apt/sources.list.d/espressif.list
# 更新软件包索引
sudo apt update
# 安装 CLI 版本
sudo apt install eim-cli
# 或安装图形界面版本
sudo apt install eim
```

**手动下载：** 使用 [EIM 下载页](https://dl.espressif.com/dl/eim/) 获取 `.deb` 包或 Linux 便携二进制。
{{% /tab %}}
{{% tab name="Linux (rpm)" %}}
**包管理器（推荐）**

```bash
# 下载并安装 RPM 仓库配置
sudo dnf install https://dl.espressif.com/dl/eim/rpm/eim-repo-latest.noarch.rpm
# 安装 CLI 版本
sudo dnf install eim-cli
# 或安装图形界面版本
sudo dnf install eim
```

**手动下载：** 使用 [EIM 下载页](https://dl.espressif.com/dl/eim/) 获取 RPM 包或 Linux 便携二进制。
{{% /tab %}}
{{< /tabs >}}

EIM 完成后，您即拥有基于 CMake 的工程、Xtensa 与 RISC-V 工具链，以及在各支持操作系统上一致的 `idf.py` 工作流。

## IDE 与编辑器

继续使用您熟悉的工具即可。ESP-IDF 以 CMake 为先，任何具备良好 CMake 与 C/C++ 支持的编辑器都很合适。若要一体化体验，可从下列入口开始：

- **[Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension)** — 官方 ESP-IDF 扩展：在编辑器内完成配置、烧录、监视与 SDK 配置
- **[Eclipse](https://github.com/espressif/idf-eclipse-plugin)** — 面向 Eclipse 用户的 ESP-IDF 插件
- **[CLion](https://www.jetbrains.com/clion/)** — 以 CMake 配置文件打开工程，利用导航与调试能力

## 延伸阅读：文档

从点亮 LED 到量产所需的资源：

- **[ESP-IDF 编程指南](https://docs.espressif.com/projects/esp-idf/zh_CN/latest/)** — 入门、API 参考与指南
- **[ESP-IDF on GitHub](https://github.com/espressif/esp-idf)** — 源码、Issue 与贡献
- **[Release notes](https://release-notes.espressif.tools/)** — 各版本变更说明
- **[Espressif SoCs](https://www.espressif.com/zh-hans/products/socs)** — 浏览完整 SoC 产品线并对比系列
- **[Espressif Documentation](https://documentation.espressif.com/zh_CN/home)** — 乐鑫技术文档中心入口
- **[Espressif Products](https://products.espressif.com)** — 模组、开发套件与产品级信息

## AI 辅助开发（MCP）

通过 **模型上下文协议（Model Context Protocol，MCP）** 服务器将 ESP-IDF 接入助手与自动化：

- **ESP-IDF Tools Local MCP Server**（ESP-IDF v6.0+）— 向兼容的助手暴露您的工程；使用 `eim run "idf.py mcp-server"` 运行（例如 VS Code Copilot、Cursor）
- **[Espressif Documentation MCP Server](https://mcp.espressif.com/)** — 让工具查询当前乐鑫文档（含 ESP-IDF），获得与已发布文档一致的回答

## ESP 组件仓库

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

跳过样板代码，直接使用来自官方 **[ESP 组件仓库（ESP Component Registry）](https://components.espressif.com/)** 的持续维护、带版本管理的基础组件，包括驱动、协议、UI 辅助工具、云连接器等。你可以添加依赖，而无需将整个代码库复制到项目中：

```bash
idf.py add-dependency "namespace/component_name"
```

在 [components.espressif.com](https://components.espressif.com/) 浏览完整目录。

<div id="esp-registry-stats" class="flex gap-4 my-4">
  <div class="flex-1 rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-5 text-center shadow">
    <div id="stat-components" class="text-4xl font-bold text-primary-600 dark:text-primary-400">—</div>
    <div class="mt-1 text-sm text-neutral-600 dark:text-neutral-400">已发布组件数</div>
  </div>
  <div class="flex-1 rounded-lg border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 p-5 text-center shadow">
    <div id="stat-downloads" class="text-4xl font-bold text-primary-600 dark:text-primary-400">—</div>
    <div class="mt-1 text-sm text-neutral-600 dark:text-neutral-400">仓库累计下载次数</div>
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

### 当前热门

来自组件仓库的高使用量组件快照：

<div id="esp-popular-components" class="grid grid-cols-1 gap-4 my-4 sm:grid-cols-2">
  <div class="text-neutral-400 dark:text-neutral-500 col-span-full text-sm">加载中…</div>
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
            <div class="mt-3 text-xs text-neutral-400 dark:text-neutral-500">⬇ ${downloads} 次下载</div>
          </a>`;
      }).join("");
    })
    .catch(() => {
      document.getElementById("esp-popular-components").style.display = "none";
    });
</script>

## 面向专用技术栈的框架

当产品需要的不仅是「纯固件」时，下列乐鑫框架构建在 ESP-IDF 之上，可加速常见领域：

- **[ESP-BROOKESIA](https://github.com/espressif/esp-brookesia)** — 面向 AIoT 设备的人机交互开发框架
- **[ESP-DSP](https://github.com/espressif/esp-dsp)** — 针对片上音频、控制与分析的数字信号处理优化
- **[ESP-WHO](https://github.com/espressif/esp-who)** — 面向带摄像头 ESP32 级设备的视觉流水线模块
- **[ESP-Matter](https://github.com/espressif/esp-matter)** — 与乐鑫芯片与认证路径对齐的 Matter 连接
- **[ESP-Zigbee-SDK](https://github.com/espressif/esp-zigbee-sdk)** — 适用于 ESP32-C6、ESP32-H2 等支持 IEEE 802.15.4 芯片的 Zigbee 协议栈

## 社区与交流

当您的产品需要的不只是「原生」固件时，下列乐鑫框架构建在 ESP-IDF 之上，可加速常见领域的开发：

- **[ESP32.com 论坛](https://esp32.com/index.php)** — 乐鑫官方社区论坛
- **[Reddit r/esp32](https://www.reddit.com/r/esp32/)** — 资讯、作品与讨论
- **[Espressif Discord](https://discord.com/invite/XqnZPbF)** — 与社区实时聊天

## 文章列表

本页为 ESP-IDF 专题简介与资源汇总；与本标签相关的博客文章列表仅在英文站点维护。请在 [英文版 ESP-IDF 页面]({{< relref "_index.md" >}}) 底部浏览全部文章。
