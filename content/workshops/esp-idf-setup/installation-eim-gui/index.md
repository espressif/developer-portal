---
title: "Installation EIM GUI"
date: "2026-05-29"
lastmod: "2026-05-29"
summary: "This guide shows how to install EIM via GUI"
---

Once the ESP-IDF extension is installed, install the toolchain using the Installation Manager.

### Opening the Installation Manager via VS Code

After installation, you should see the configuration tab.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
If the tab doesn't show up, open the _Command Palette_ (`F1`) and type
```bash
> ESP-IDF: Open ESP-IDF Installation Manager
```
{{< /alert >}}


### Installation via EIM

* When asked to choose a mirror, select `Github`<br>
  ![](../assets/setup/6-choose-mirror.webp)

* After a few seconds, the Installation Manager GUI will appear

* You'll be presented with a welcome screen. Click on `Start Installation`
   ![](../assets/setup/8-installation-manager-screen.webp)

* Click on `Easy Installation`<br>
   ![](../assets/setup/7-easy-installation.webp)

* Choose the latest stable release (v6.0.1 as of today)
  ![](../assets/setup/9-latest-stable-release.webp)

* Wait for the installation to finish. This will take some time. You can monitor the progress using the progress bar.
  ![](../assets/setup/10-installation-progress-bar.webp)

* Once finished, click on `Go to Dashboard` to verify the installation
  ![](../assets/setup/11-installation-complete.webp)

* You should see `v6.0.1` among the installed versions
  ![](../assets/setup/12-go-to-dashboard.webp)

* You can now close the Espressif Installation Manager GUI

### Next steps
> Continue with the [next step](../#4-building-the-first-project).
