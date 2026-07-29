---
title: "ESP-IDF C5 - Assign. 3.2 (Optional)"
date: "2026-07-29"
lastmod: "2026-07-29"
series: ["WS00C"]
series_order: 10
showAuthor: false
summary: "Extend the OTA application from the previous assignment with rollback support, so that a newly updated firmware must confirm it works before it is trusted, and is otherwise automatically reverted to the previous working image."
---

In Assignment 3.1 you performed a one way OTA update: once the new image was written and the board rebooted, there was no automatic way back. In this assignment you'll close that gap by enabling __app rollback__, so a faulty update can recover on its own.

This assignment builds directly on the code you wrote previously. Start from that project and add to it.

## Assignment steps

1. Enable rollback support in `menuconfig`.
2. Declare the new component dependencies.
3. Add the includes.
4. Add a self-test and the validation logic.
5. Call the validation from `app_main()`.
6. Build, flash, and test the rollback.

## Enable rollback support in menuconfig

1. Open `menuconfig` (`> ESP-IDF: SDK Configuration Editor (menuconfig)`) and go to `Bootloader config` &rarr; `Application Rollback` &rarr; `Enable app rollback support` (`CONFIG_BOOTLOADER_APP_ROLLBACK_ENABLE`).

2. Save the configuration and close `menuconfig`.

   Without this option set, the bootloader never puts an app in the `ESP_OTA_IMG_PENDING_VERIFY` state, and the rollback functions become optional no-ops.

## Declare the new component dependencies

The rollback functions live in the `app_update` component, and reading the partition state uses the `esp_partition` component. Add both to the `REQUIRES` list in your `CMakeLists.txt`:

```cmake
idf_component_register(SRCS "main.c"
                    INCLUDE_DIRS "."
                    REQUIRES esp_wifi esp_event esp_netif nvs_flash esp_http_client esp_https_ota bootloader_support mbedtls app_update esp_partition)
```

If you skip this step, the build fails with `fatal error: esp_ota_ops.h: No such file or directory`, because the header is not on the include path until its component is declared as a dependency.

## Add the includes

1. Add the OTA ops and partition headers alongside the includes from the previous assignment:

   ```c
   #include "esp_ota_ops.h"
   #include "esp_partition.h"
   ```

## Add a self-test and the validation logic

On the first boot after an update, the app needs to check itself and then either confirm or reject the new firmware.

1. Add a `run_diagnostics()` helper. In a real product this is where you verify the things that matter for your device, such as peripherals initializing, sensors responding, or a server connection succeeding. For now it always reports success:

   ```c
   static bool run_diagnostics(void)
   {
       // Replace with real self-tests (peripherals, connectivity, etc.).
       return true;
   }
   ```

2. Add a `validate_running_app()` helper. It reads the running partition's OTA state and only acts when the state is `ESP_OTA_IMG_PENDING_VERIFY`, meaning this is the first boot after an update and confirmation is still pending:

   ```c
   static void validate_running_app(void)
   {
       const esp_partition_t *running = esp_ota_get_running_partition();
       esp_ota_img_states_t ota_state;

       if (esp_ota_get_state_partition(running, &ota_state) != ESP_OK) {
           return;
       }

       if (ota_state == ESP_OTA_IMG_PENDING_VERIFY) {
           ESP_LOGI(TAG, "First boot after OTA, running diagnostics...");
           if (run_diagnostics()) {
               ESP_LOGI(TAG, "Diagnostics passed, marking app as valid");
               esp_ota_mark_app_valid_cancel_rollback();
           } else {
               ESP_LOGE(TAG, "Diagnostics failed, rolling back to previous app");
               esp_ota_mark_app_invalid_rollback_and_reboot();
           }
       }
   }
   ```

   Guarding on `ESP_OTA_IMG_PENDING_VERIFY` matters. On a normal boot the running app is already `ESP_OTA_IMG_VALID`, so the function does nothing and skips the diagnostics. The check only runs when there is actually a pending update to confirm.

## Call the validation from app_main()

1. Call `validate_running_app()` early in `app_main()`, right after NVS is initialized and before anything else runs. Confirming or rejecting the current image is the first thing the firmware should decide on startup:

   ```c
   void app_main(void)
   {
       ESP_ERROR_CHECK(nvs_flash_init());
       validate_running_app();
       wifi_connect();
       do_firmware_update();
   }
   ```

   On a normal boot this call returns immediately. Only after an OTA update does it run the diagnostics and decide whether to keep or reject the new image.

## Build, flash, and test the rollback

1. Build and flash the project: `> ESP-IDF: Build, Flash and Start a Monitor on your Device`.

2. Watch the monitor output. After the OTA update and reboot, the new image reports that it is on its first boot, runs the self-test, and confirms itself:

   ```
   I (298) ota_example: First boot after OTA, running diagnostics...
   I (301) ota_example: Diagnostics passed, marking app as valid
   ```

   Once you see `Diagnostics passed, marking app as valid`, the updated firmware is marked `ESP_OTA_IMG_VALID` and will boot normally from now on.

3. To see a rollback happen, temporarily make `run_diagnostics()` return `false`, then trigger an update. On the first boot the self-test fails, the app marks the image invalid, and the board reboots straight back into the previous working firmware:

   ```
   I (298) ota_example: First boot after OTA, running diagnostics...
   E (301) ota_example: Diagnostics failed, rolling back to previous app
   ```

   Remember to restore `run_diagnostics()` to return `true` afterwards.

>[!INFO]
>Rollback also happens without any code path if the new app crashes or hangs before it confirms itself. Since the confirmation is never reached, the next reset reverts to the previous image automatically.

<details>
<summary>
Solution Code
</summary>

```c
#include "freertos/FreeRTOS.h"
#include "freertos/event_groups.h"
#include "esp_event.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "esp_wifi.h"
#include "esp_http_client.h"
#include "esp_https_ota.h"
#include "esp_crt_bundle.h"
#include "esp_ota_ops.h"
#include "esp_partition.h"
#include "nvs_flash.h"

#define WIFI_SSID "SSID"
#define WIFI_PASSWORD "SSID_PASSWORD"

#define FIRMWARE_URL "https://raw.githubusercontent.com/espressif/tree/main/update-workshop-to-c5-code/content/workshops/esp-idf-with-esp32-c5/ota/ota-new-firmware.bin"

static const char *TAG = "ota_example";

static EventGroupHandle_t s_wifi_event_group;
#define WIFI_CONNECTED_BIT BIT0

static void wifi_event_handler(void *arg, esp_event_base_t event_base,
                                int32_t event_id, void *event_data)
{
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        ESP_LOGI(TAG, "Disconnected from AP, retrying...");
        esp_wifi_connect();
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t *event = (ip_event_got_ip_t *) event_data;
        ESP_LOGI(TAG, "Got IP: " IPSTR, IP2STR(&event->ip_info.ip));
        xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
    }
}

static void wifi_connect(void)
{
    s_wifi_event_group = xEventGroupCreate();

    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    esp_netif_create_default_wifi_sta();

    wifi_init_config_t wifi_init_cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&wifi_init_cfg));

    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &wifi_event_handler, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &wifi_event_handler, NULL));

    wifi_config_t wifi_config = {
        .sta = {
            .ssid = WIFI_SSID,
            .password = WIFI_PASSWORD,
        },
    };

    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config));
    ESP_ERROR_CHECK(esp_wifi_start());

    ESP_LOGI(TAG, "Connecting to SSID: %s", WIFI_SSID);
    xEventGroupWaitBits(s_wifi_event_group, WIFI_CONNECTED_BIT, pdFALSE, pdTRUE, portMAX_DELAY);
}

static bool run_diagnostics(void)
{
    // Replace with real self-tests (peripherals, connectivity, etc.).
    return true;
}

static void validate_running_app(void)
{
    const esp_partition_t *running = esp_ota_get_running_partition();
    esp_ota_img_states_t ota_state;

    if (esp_ota_get_state_partition(running, &ota_state) != ESP_OK) {
        return;
    }

    if (ota_state == ESP_OTA_IMG_PENDING_VERIFY) {
        ESP_LOGI(TAG, "First boot after OTA, running diagnostics...");
        if (run_diagnostics()) {
            ESP_LOGI(TAG, "Diagnostics passed, marking app as valid");
            esp_ota_mark_app_valid_cancel_rollback();
        } else {
            ESP_LOGE(TAG, "Diagnostics failed, rolling back to previous app");
            esp_ota_mark_app_invalid_rollback_and_reboot();
        }
    }
}

static void do_firmware_update(void)
{
    ESP_LOGI(TAG, "Starting OTA update from %s", FIRMWARE_URL);

    esp_http_client_config_t http_config = {
        .url = FIRMWARE_URL,
        .crt_bundle_attach = esp_crt_bundle_attach,
    };

    esp_https_ota_config_t ota_config = {
        .http_config = &http_config,
    };

    esp_err_t ret = esp_https_ota(&ota_config);
    if (ret == ESP_OK) {
        ESP_LOGI(TAG, "OTA update successful, rebooting...");
        vTaskDelay(2000);
        esp_restart();
    } else {
        ESP_LOGE(TAG, "OTA update failed: %s", esp_err_to_name(ret));
    }
}

void app_main(void)
{
    ESP_ERROR_CHECK(nvs_flash_init());
    validate_running_app();
    wifi_connect();
    do_firmware_update();
}
```

</details>

## Conclusion

In this assignment, you added rollback support on top of the OTA workflow from the previous one. A newly updated image now boots on probation, runs a self-test, and either confirms itself as valid or reverts to the last working firmware. Combined with the bootloader's automatic rollback on crash, this makes your OTA process safe to run on devices you cannot easily reach.

### Next step
> Next assignment &rarr; [Assignment 3.3](../assignment-3-3/)

> Or [go back to navigation menu](.#agenda)
