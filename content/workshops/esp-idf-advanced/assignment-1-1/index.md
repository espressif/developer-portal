---
title: "ESP-IDF Adv. - Assign.  1.1"
date: "2025-08-05"
series: ["WS00B"]
series_order: 3
showAuthor: false
summary: "Create the `alarm` component and refactor the code to use it. (Guided)"
---

<!-- ## Alarm component -->

## Assignment steps

You will:

1. Run the example (to make sure that everything is working)
2. Create an `alarm` component
2. Add the component configuration

### Run the example

To test that everything it's working, first you need to just run the example.

* Clone the repo with the starting code<br>
   ```bash
    git clone https://github.com/FBEZ-docs-and-templates/devrel-advanced-workshop-code
   ```
* Open the folder `assignment_1_1_base` with VSCode<br>
   _Note: `assigment_1_1_base` and `assignment_3_2_base` are starting code. All other folders contain the solution for the assignments_
* Set the target: `> ESP-IDF: Set Espressif Device Target`
* Select the port: `> ESP-IDF: Select Port to Use (COM, tty, usbserial)`
* Set the AP data:<br>
   * Open menuconfig: `> ESP-IDF: SDK Configuration Editor (menuconfig)`<br>
        &rarr; `WiFi SSID` &rarr; Set your ssid<br>
        &rarr; `WiFi Password` &rarr; Set your password<br>
* Build, flash and monitor the device<br>
   * `> ESP-IDF: Build, Flash, and Start a Monitor on Your Device`<br>
      _(or hit the flame icon (&#128293;) located in the bottom bar)_

You should now see the example running and connecting to your WiFi network and to the `mqtt://test.mosquitto.org` server.

<details>
<summary>Show terminal output</summary>

```bash
I (30) boot: ESP-IDF v5.4.2-dirty 2nd stage bootloader
I (30) boot: compile time Jul 22 2025 10:52:56
I (30) boot: chip revision: v0.1
I (31) boot: efuse block revision: v1.0
I (34) boot.esp32c3: SPI Speed      : 80MHz
I (38) boot.esp32c3: SPI Mode       : DIO
I (42) boot.esp32c3: SPI Flash Size : 2MB
I (46) boot: Enabling RNG early entropy source...
I (50) boot: Partition Table:
I (53) boot: ## Label            Usage          Type ST Offset   Length
I (59) boot:  0 nvs              WiFi data        01 02 00009000 00006000
I (66) boot:  1 phy_init         RF data          01 01 0000f000 00001000
I (72) boot:  2 factory          factory app      00 00 00010000 00100000
I (79) boot: End of partition table
I (82) esp_image: segment 0: paddr=00010020 vaddr=3c0c0020 size=1e7ech (124908) map
I (109) esp_image: segment 1: paddr=0002e814 vaddr=3fc93c00 size=01804h (  6148) load
I (111) esp_image: segment 2: paddr=00030020 vaddr=42000020 size=b1fd4h (729044) map
I (229) esp_image: segment 3: paddr=000e1ffc vaddr=3fc95404 size=01620h (  5664) load
I (231) esp_image: segment 4: paddr=000e3624 vaddr=40380000 size=13b38h ( 80696) load
I (248) esp_image: segment 5: paddr=000f7164 vaddr=50000000 size=0001ch (    28) load
I (254) boot: Loaded app from partition at offset 0x10000
I (254) boot: Disabling RNG early entropy source...
I (265) cpu_start: Unicore app
I (274) cpu_start: Pro cpu start user code
I (274) cpu_start: cpu freq: 160000000 Hz
I (274) app_init: Application information:
I (274) app_init: Project name:     mqtt_tcp
I (278) app_init: App version:      1
I (281) app_init: Compile time:     Jul 22 2025 10:53:00
I (286) app_init: ELF file SHA256:  b10017352...
I (291) app_init: ESP-IDF:          v5.4.2-dirty
I (295) efuse_init: Min chip rev:     v0.1
I (299) efuse_init: Max chip rev:     v1.99
I (303) efuse_init: Chip rev:         v0.1
I (307) heap_init: Initializing. RAM available for dynamic allocation:
I (313) heap_init: At 3FC9B2E0 len 00024D20 (147 KiB): RAM
I (318) heap_init: At 3FCC0000 len 0001C710 (113 KiB): Retention RAM
I (324) heap_init: At 3FCDC710 len 00002B50 (10 KiB): Retention RAM
I (330) heap_init: At 5000001C len 00001FCC (7 KiB): RTCRAM
I (336) spi_flash: detected chip: generic
I (339) spi_flash: flash io: dio
W (342) spi_flash: Detected size(4096k) larger than the size in the binary image header(2048k). Using the size in the binary image header.
I (355) sleep_gpio: Configure to isolate all GPIO pins in sleep state
I (361) sleep_gpio: Enable automatic switching of GPIO sleep configuration
I (367) main_task: Started on CPU0
I (377) main_task: Calling app_main()
I (377) mqtt_example: [APP] Startup..
I (377) mqtt_example: [APP] Free memory: 270780 bytes
I (377) mqtt_example: [APP] IDF version: v5.4.2-dirty
I (397) temperature_sensor: Range [-10°C ~ 80°C], error < 1°C
I (397) example_connect: Start example_connect.
I (397) pp: pp rom version: 8459080
I (397) net80211: net80211 rom version: 8459080
I (417) wifi:wifi driver task: 3fca3b0c, prio:23, stack:6656, core=0
I (417) wifi:wifi firmware version: bea31f3
I (417) wifi:wifi certification version: v7.0
I (417) wifi:config NVS flash: enabled
I (417) wifi:config nano formatting: disabled
I (427) wifi:Init data frame dynamic rx buffer num: 32
I (427) wifi:Init static rx mgmt buffer num: 5
I (437) wifi:Init management short buffer num: 32
I (437) wifi:Init dynamic tx buffer num: 32
I (447) wifi:Init static tx FG buffer num: 2
I (447) wifi:Init static rx buffer size: 1600
I (447) wifi:Init static rx buffer num: 10
I (457) wifi:Init dynamic rx buffer num: 32
I (457) wifi_init: rx ba win: 6
I (457) wifi_init: accept mbox: 6
I (467) wifi_init: tcpip mbox: 32
I (467) wifi_init: udp mbox: 6
I (467) wifi_init: tcp mbox: 6
I (477) wifi_init: tcp tx win: 5760
I (477) wifi_init: tcp rx win: 5760
I (477) wifi_init: tcp mss: 1440
I (487) wifi_init: WiFi IRAM OP enabled
I (487) wifi_init: WiFi RX IRAM OP enabled
I (487) phy_init: phy_version 1201,bae5dd99,Mar  3 2025,15:36:21
I (527) wifi:mode : sta (7c:df:a1:42:64:70)
I (527) wifi:enable tsf
I (527) example_connect: Connecting to SamsungFrancesco...
W (527) wifi:Password length matches WPA2 standards, authmode threshold changes from OPEN to WPA2
I (537) example_connect: Waiting for IP(s)
I (3057) wifi:new:<1,0>, old:<1,0>, ap:<255,255>, sta:<1,0>, prof:1, snd_ch_cfg:0x0
I (3057) wifi:state: init -> auth (0xb0)
I (4057) wifi:state: auth -> init (0x200)
I (4057) wifi:new:<1,0>, old:<1,0>, ap:<255,255>, sta:<1,0>, prof:1, snd_ch_cfg:0x0
I (4057) example_connect: Wi-Fi disconnected 2, trying to reconnect...
I (6477) example_connect: Wi-Fi disconnected 205, trying to reconnect...
I (8887) wifi:new:<1,0>, old:<1,0>, ap:<255,255>, sta:<1,0>, prof:1, snd_ch_cfg:0x0
I (8887) wifi:state: init -> auth (0xb0)
I (8967) wifi:state: auth -> assoc (0x0)
I (9017) wifi:state: assoc -> run (0x10)
I (9087) wifi:connected with SamsungFrancesco, aid = 1, channel 1, BW20, bssid = ce:db:d8:a6:6b:2a
I (9087) wifi:security: WPA2-PSK, phy: bgn, rssi: -50
I (9087) wifi:pm start, type: 1

I (9097) wifi:dp: 1, bi: 102400, li: 3, scale listen interval from 307200 us to 307200 us
I (9107) wifi:set rx beacon pti, rx_bcn_pti: 0, bcn_timeout: 25000, mt_pti: 0, mt_time: 10000
I (9147) wifi:<ba-add>idx:0 (ifx:0, ce:db:d8:a6:6b:2a), tid:0, ssn:1, winSize:64
I (9177) wifi:dp: 2, bi: 102400, li: 4, scale listen interval from 307200 us to 409600 us
I (9177) wifi:AP's beacon interval = 102400 us, DTIM period = 2
I (10157) esp_netif_handlers: example_netif_sta ip: 10.75.149.18, mask: 255.255.255.0, gw: 10.75.149.225
I (10157) example_connect: Got IPv4 event: Interface "example_netif_sta" address: 10.75.149.18
I (10397) example_connect: Got IPv6 event: Interface "example_netif_sta" address: fe80:0000:0000:0000:7edf:a1ff:fe42:6470, type: ESP_IP6_ADDR_IS_LINK_LOCAL
I (10397) example_common: Connected to example_netif_sta
I (10397) example_common: - IPv4 address: 10.75.149.18,
I (10407) example_common: - IPv6 address: fe80:0000:0000:0000:7edf:a1ff:fe42:6470, type: ESP_IP6_ADDR_IS_LINK_LOCAL
I (10417) mqtt_example: Other event id:7
I (15517) mqtt_example: Temperature: 37.60 °C
E (19627) transport_base: tcp_read error, errno=Connection reset by peer
E (19627) mqtt_client: esp_mqtt_handle_transport_read_error: transport_read() error: errno=104
I (19637) mqtt_example: MQTT_EVENT_ERROR
E (19637) mqtt_example: Last error captured as transport's socket errno: 0x68
I (19647) mqtt_example: Last errno string (Connection reset by peer)
E (19647) mqtt_client: esp_mqtt_connect: mqtt_message_receive() returned -2
E (19657) mqtt_client: MQTT connect failed
I (19657) mqtt_example: MQTT_EVENT_DISCONNECTED
I (20567) mqtt_example: Temperature: 36.60 °C
I (25667) mqtt_example: Temperature: 36.60 °C
I (29667) mqtt_example: Other event id:7
I (30667) mqtt_example: Temperature: 36.60 °C
```
</details>

### Create the alarm component

To create the alarm component, you need to

1. `> ESP-IDF: Create New ESP-IDF Component`<br>
   &rarr; `alarm`<br>
   A new `components/alarm` folder is crated.
2. Move the files into the component folder<br>
   `alarm.c` &rarr; `components/alarm/alarm.c`<br>
   `alarm.h` &rarr; `components/alarm/include/alarm.h`
3. Add the `esp_timer` requirement to the component `CMakeLists.txt`<br>

    ```bash
    idf_component_register(SRCS "alarm.c"
                        REQUIRES esp_timer
                        INCLUDE_DIRS "include")
    ```


{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
You didn't need to add `REQUIRES esp_timer` in the main component, because it inherited dependencies from the main application's build configuration
{{< /alert >}}

### Add the component configuration

In `alarm.c` file, you can see two hardcoded values
```c
#define ALARM_THRESHOLD_PERCENT     2     // 2% chance
#define ALARM_REFRESH_INTERVAL_MS   1000   // reevaluate every 1000 ms
```

We will replace these values with component configurations.

1. Create a `Kconfig` file in the root directory of the `alarm` component
2. Add the following to `Kconfig`<br>
   ```bash
   menu "Alarm Component Configuration"

    config ALARM_THRESHOLD_PERCENT
        int "Alarm threshold percent"
        default 2
        range 0 100
        help
            Set the threshold percent for the alarm (e.g., 2 for 2% chance).

    config ALARM_REFRESH_INTERVAL_MS
        int "Alarm refresh interval (ms)"
        default 1000
        range 1 60000
        help
            Set the interval in milliseconds to reevaluate the alarm.

   endmenu
   ```
3. Comment out the defines<br>
   ```c
   //#define ALARM_THRESHOLD_PERCENT     2     // 2% chance
   //#define ALARM_REFRESH_INTERVAL_MS   1000   // reevaluate every 1000 ms
   ```
4. Replace the macro name in the rest of the code<br>
   * `ALARM_THRESHOLD_PERCENT` &rarr; `CONFIG_ALARM_THRESHOLD_PERCENT`
   * `ALARM_REFRESH_INTERVAL_MS` &rarr; `CONFIG_ALARM_REFRESH_INTERVAL_MS`
5. Clean the project: `ESP-IDF: Full Clean Project`
6. Rebuild and flash: `ESP-IDF: Build, Flash and Start Monitor on Your Device`

## Assignment solution code

<details>
<summary>Show full assignment code</summary>

__`alarm.c`__
```c
#include <stdlib.h>
#include "alarm.h"
#include "esp_random.h"
#include "esp_timer.h" // for esp_timer_get_time()

// Define internal behavior constants
// #define ALARM_THRESHOLD_PERCENT     2     // 2% chance
// #define ALARM_REFRESH_INTERVAL_MS   1000   // reevaluate every 1000 ms

// Internal alarm structure (hidden from user)
struct alarm_t {
    int64_t last_check_time_us;
    bool last_state;
};

alarm_t* alarm_create(void)
{
    alarm_t *alarm = malloc(sizeof(alarm_t));
    if (!alarm) return NULL;

    alarm->last_check_time_us = 0;
    alarm->last_state = false;

    return alarm;
}

bool is_alarm_set(alarm_t *alarm)
{
    if (!alarm) return false;

    int64_t now_us = esp_timer_get_time();
    int64_t elapsed_us = now_us - alarm->last_check_time_us;

    if (elapsed_us >= CONFIG_ALARM_REFRESH_INTERVAL_MS * 1000) {
        uint32_t rand_val = esp_random() % 100;
        alarm->last_state = rand_val < CONFIG_ALARM_THRESHOLD_PERCENT;
        alarm->last_check_time_us = now_us;
    }

    return alarm->last_state;
}

void alarm_delete(alarm_t *alarm)
{
    if (alarm) {
        free(alarm);
    }
}
```

__`Kconfig`__

```bash
   menu "Alarm Component Configuration"

    config ALARM_THRESHOLD_PERCENT
        int "Alarm threshold percent"
        default 2
        range 0 100
        help
            Set the threshold percent for the alarm (e.g., 2 for 2% chance).

    config ALARM_REFRESH_INTERVAL_MS
        int "Alarm refresh interval (ms)"
        default 1000
        range 1 60000
        help
            Set the interval in milliseconds to reevaluate the alarm.

```
</details>

You can find the whole solution project on the [assignment_1_1](https://github.com/FBEZ-docs-and-templates/devrel-advanced-workshop-code/tree/main/assignment_1_1) folder on the github repo.

> Next step: [assignment_1_2](../assignment-1-2/)
