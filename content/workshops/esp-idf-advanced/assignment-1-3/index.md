---
title: "ESP-IDF Adv. - Assign.  1.3"
date: "2025-08-05"
series: ["WS00B"]
series_order: 5
showAuthor: false
summary: "Support multiple configurations via sdkconfigs"
---

In this assignment, you will create two versions of `sdkconfig` (production and debug).
The only difference between the two is the logging: Debug will display all logs, while production has all the logs suppressed.

### Assignment Detail

You project must have the following configuration files:

1. `sdkconfig.defaults`: containing the `esp32-c3` target
2. `sdkconfig.prod`: containing the logging suppression configuration (both app log and bootloader log)
3. `sdkconfig.debug`: containing the logging enable configuration
4. `profile` files to simplify the build command


The final project folder tree is
```bash
.
|-- main
|   |-- CMakeLists.txt
|   |-- app_main.c
|   `-- idf_component.yml
|-- profiles
|   |-- debug
|   `-- prod
|-- sdkconfig
|-- sdkconfig.debug
|-- sdkconfig.defaults
|-- sdkconfig.old
`-- sdkconfig.prod
```

## Assignment steps

We will:

1. Create the production sdkconfig version (guided)
2. Create a profile file (guided)
3. Create the debug sdkconfig version

### Create production version (guided)

To create the debug configuration, we first need to find the log configuration.

#### Changing the configuration in menuconfig

* `ESP-IDF: SDK Configuration Editor (menuconfig)`<br>
   * Search for `log`
   * Uncheck the fields<br>
      * Bootloader Config &rarr; Bootloader log verbosity
      * Log &rarr; Log Lever &rarr; Default log verbosity

#### Create `sdkconfig.prod` file

The easiest way to find the configuration names that we changed is to run the `save-defconfig` tool, which will generate a `sdkconfig.defaults` file with only the changed parameters.

* `ESP-IDF: Save Default Config File (save-defconfig)`

Looking at the new `sdkconfig.defaults`, we can see two new configurations:

```bash
CONFIG_LOG_DEFAULT_LEVEL_NONE=y
CONFIG_BOOTLOADER_LOG_LEVEL_NONE=y
```

* Cut these configs and paste them into a `sdkconfig.prod` file

#### Build and flash

To build the project use

```bash
idf.py -B build-production -DSDKCONFIG=build-production/sdkconfig -DSDKCONFIG_DEFAULTS="sdkconfig.defaults;sdkconfig.prod" build
```

It will create a `build-production` folder for this version.

To flash the project, you just need to specify the build folder, which already contains all the required information

```bash
idf.py -B build-debug -p <YOUR_PORT> flash monitor
```

### Create Profile files

To simplify the process we will create a _profile_ file.

* Create a `profile` folder
* Create a `prod` file inside the folder
* Add the CLI parameters<br>
   ```bash
   -B build-production -DSDKCONFIG=build-production/sdkconfig -DSDKCONFIG_DEFAULTS="sdkconfig.defaults;sdkconfig.prod"
   ```

We can now build the production version using

```bash
idf.py @profiles/prod build
```

### Debug version

Now you can do the same for the debugging setup.
For this assignment step, you need to create and fill:

1. `sdkconfig.debug`
2. `profile/debug`



## Assignment solution code

<details>
<summary>Show solution code</summary>

__`skdconfig.defaults`__
```bash
# This file was generated using idf.py save-defconfig. It can be edited manually.
# Espressif IoT Development Framework (ESP-IDF) 5.4.2 Project Minimal Configuration
#
CONFIG_IDF_TARGET="esp32c3"
```

__`skdconfig.prod`__
```bash
CONFIG_LOG_DEFAULT_LEVEL_NONE=y
CONFIG_BOOTLOADER_LOG_LEVEL_NONE=y
```

__`skdconfig.prod`__
```bash
CONFIG_LOG_DEFAULT_LEVEL_INFO=y
```
</details>


You can find the whole solution project in the [assignment_1_3](https://github.com/FBEZ-docs-and-templates/devrel-advanced-workshop-code/tree/main/assignment_1_3)  folder in the GitHub repo.

> Next step: [Lecture 2](../lecture-2/)
