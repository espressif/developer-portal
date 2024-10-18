---
title: "Workshop: ESP-IDF a ESP32-C6 - Úkol 3"
date: 2024-09-30T00:00:00+01:00
showTableOfContents: false
series: ["WS001CZ"]
series_order: 4
showAuthor: false
---

## Úkol 3: Připojení k Wi-Fi

---

Nyní je konečně čas připojit naši ESP32-C6 k Wi-Fi síti. ESP32-C6 podporuje oba standardy Wi-Fi 4 a Wi-Fi 6 na frekvenci 2.4 GHz.

[Wi-Fi konektivita](https://docs.espressif.com/projects/esp-idf/en/release-v5.2/esp32c6/api-reference/network/esp_wifi.html) je jednou z nejdůležitějších vlastností většiny čipů z rodiny ESP32 a je to jedna z podstatných součástí jejich úspěchu. Díky Wi-Fi je možné vaše IoT zařízení připojit k internetu a skutečně využít všechny jeho funkce. Tím se nutně nemyslí jen připojení ke cloudovým službám, ale také např. *over-the-air (OTA)* updaty, vzdálené ovládání a monitoring a mnohem víc.

ESP32 podporuje dva módy: *Station* a *SoftAP*:

* *Station mode*: ESP se připojuje k existující síti (třeba k domácímu routeru).
* *SoftAP mode*: Ostatní zařízení (třeba laptop nebo mobil) se připojují přímo na ESP, kde může běžet např. webový server s ovládáním.

Pro tento úkol znovupoužijeme projekt, se kterým jsme pracovali při minulém úkolu, konkrétně jeho druhou verzi za použití BSP a připojíme se k existující Wi-Fi 4/Wi-Fi 6 síti (budeme tedy používat *station mode*). 

#### Připojení k Wi-Fi

Abychom mohli začít Wi-Fi používat, potřebujeme nastavit ovladač Wi-Fi: musíme zadat **SSID** a **heslo**.

1. **Zkopírujeme si kostru**

```c
#include <stdio.h>
#include "bsp/esp-bsp.h"
#include "led_indicator_blink_default.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "lwip/err.h"
#include "lwip/sys.h"

#define WIFI_SSID "network-ssid"
#define WIFI_PASS "network-pass"

#define WIFI_CONNECTED_BIT BIT0
#define WIFI_FAIL_BIT      BIT1

static led_indicator_handle_t leds[BSP_LED_NUM];

static EventGroupHandle_t s_wifi_event_group;
static int s_retry_num = 0;

static const char *TAG = "workshop";

// TODO handler

void wifi_init_sta(void)
{WS001
    s_wifi_event_group = xEventGroupCreate();
   //TODO
}

void app_main(void)
{

    esp_err_t ret = nvs_flash_init();

    //TODO

    ESP_ERROR_CHECK(bsp_led_indicator_create(leds, NULL, BSP_LED_NUM));
    led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x20, 0x0, 0x0));

    wifi_init_sta();
}
```

2. **Inicializace Wi-Fi**

Inicializace Wi-Fi se skládá z těchto kroků, kteeré doplníme do funkce `wifi_init_sta()`:

- Inicializace TCP/IP stacku:

```c
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    esp_netif_create_default_wifi_sta();
```

- Vytvoření defaultní konfigurace pro Wi-Fi inicializaci a samotná inicializace:

```c
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));
```

- Registrace *event handlerů* pro události `WIFI_EVENT` a `IP_EVENT`:

```c
    esp_event_handler_instance_t instance_any_id;
    esp_event_handler_instance_t instance_got_ip;
    esp_event_handler_instance_register(WIFI_EVENT,
            ESP_EVENT_ANY_ID,
            &event_handler,
            NULL,
            &instance_any_id);
    esp_event_handler_instance_register(IP_EVENT,
            IP_EVENT_STA_GOT_IP,
            &event_handler,
            NULL,
            &instance_got_ip);
```

- Nastavení Wi-Fi módu na *station* pomocí `WIFI_MODE_STA`:

```c
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
```

- Nastavení samotných parametrů připojení pomocí struktury `wifi_config_t`:

```c
    wifi_config_t wifi_config = {
        .sta = {
            // Set the newtork name
            .ssid = WIFI_SSID,
            // Set the network pass key
            .password = WIFI_PASS,
            // Set WPA as the authentication mode
            .threshold.authmode = WIFI_AUTH_WPA_PSK,
            // Set Simultaneous Authentication (SAE) and Password Element (PWE) derivation method
            .sae_pwe_h2e = WPA3_SAE_PWE_BOTH,
            // Set the password identifier for H2E (Hash-to-Element)
            .sae_h2e_identifier = "",
        },
    };
```

- Teď můžeme zavolat funkci `esp_wifi_set_config`.

```c
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config));
```

- Nyní jsou už jak Wi-Fi řadič, tak samotné spojení nastavené, můžeme tak zapnout Wi-Fi:

```c
    ESP_ERROR_CHECK(esp_wifi_start());
```

- Teď už stačí počkat na `WIFI_CONNECTED_BIT` nebo `WIFI_FAIL_BIT` a ujistit se, že se všechno zdařilo:

```c
    EventBits_t bits = xEventGroupWaitBits(s_wifi_event_group,
            WIFI_CONNECTED_BIT | WIFI_FAIL_BIT,
            pdFALSE,
            pdFALSE,
            portMAX_DELAY);

    if (bits & WIFI_CONNECTED_BIT) {
        ESP_LOGI(TAG, "Connected!");
    } else if (bits & WIFI_FAIL_BIT) {
        ESP_LOGE(TAG, "Failed to connect!");
    }
```

Další části nejsou nutné, ale jsou užitečné.

3. **Vytvoření Wi-Fi event handler-u**
 
Ten nebude součástí ani `app_main` ani `wifi_init_sta`, ale bude na stejné úrovni jako tyto dvě funkce:

```c
static void event_handler(void* arg, esp_event_base_t event_base,
                                int32_t event_id, void* event_data)
{
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        if (s_retry_num < 30) {
            esp_wifi_connect();
            s_retry_num++;
            ESP_LOGW(TAG, "Trying to connect to WiFi");
			led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x0, 0x0, 0x20));
        } else {
            xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
        }
        ESP_LOGE(TAG, "Failed to connect to WiFi");
		led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x20, 0x0, 0x0));
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t* event = (ip_event_got_ip_t*) event_data;
        ESP_LOGI(TAG, "got ip:" IPSTR, IP2STR(&event->ip_info.ip));
		led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x0, 0x20, 0x0));
        s_retry_num = 0;
        xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
    }
}
```

4. **Kontrola inicializace NVS**

O NVS bude řeč v příštím úkolu, nyní to tedy bude trochu *blackbox*. Tneto kód doplníme do `app_main`.

```c
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
      ESP_ERROR_CHECK(nvs_flash_erase());
      ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);
```

5. **Inicializace Wi-Fi**

Posledním krokem je zavolání naší funkce:

```c
wifi_init_sta();
```

Funkce `ESP_LOGI` a `ESP_LOGE` vypisují data do seriové linky. Poté, co nahrajeme program do vývojové desky, můžeme otevřít komunikaci s deskou pomocí příkazu *Monitor* v ESP-IDF Exploreru nebo pomocí *ESP-IDF: Monitor Device* přes *Command Pallete*.

Nyní už můžete svůj kód sestavit a nahrát. Pokud budete mít problém s překladem, kdy vám bude systém hlásit `fatal error: esp_wifi.h: No such file or directory`, přidejte následující text do `main/CMakeLists.txt`, specificky do funkce `idf_component_register`:

```text
REQUIRES esp_wifi esp_netif esp_event nvs_flash
```


#### Kompletní kód

Níže můžete najít kompletní kód pro tento úkol:

```c
#include <stdio.h>
#include "bsp/esp-bsp.h"
#include "led_indicator_blink_default.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "lwip/err.h"
#include "lwip/sys.h"

#define WIFI_SSID "network-ssid"
#define WIFI_PASS "network-pass"

#define WIFI_CONNECTED_BIT BIT0
#define WIFI_FAIL_BIT      BIT1

static led_indicator_handle_t leds[BSP_LED_NUM];

static EventGroupHandle_t s_wifi_event_group;
static int s_retry_num = 0;

static const char *TAG = "workshop";

static void event_handler(void* arg, esp_event_base_t event_base,
                                int32_t event_id, void* event_data)
{
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        if (s_retry_num < 30) {
            esp_wifi_connect();
            s_retry_num++;
            ESP_LOGW(TAG, "Trying to connect to WiFi");
			led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x0, 0x0, 0x20));
        } else {
            xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
        }
        ESP_LOGE(TAG, "Failed to connect to WiFi");
		led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x20, 0x0, 0x0));
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t* event = (ip_event_got_ip_t*) event_data;
        ESP_LOGI(TAG, "got ip:" IPSTR, IP2STR(&event->ip_info.ip));
		led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x0, 0x20, 0x0));
        s_retry_num = 0;
        xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
    }
}

void wifi_init_sta(void)
{
    s_wifi_event_group = xEventGroupCreate();

    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    esp_netif_create_default_wifi_sta();

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    esp_event_handler_instance_t instance_any_id;
    esp_event_handler_instance_t instance_got_ip;
    ESP_ERROR_CHECK(esp_event_handler_instance_register(WIFI_EVENT,
            ESP_EVENT_ANY_ID,
            &event_handler,
            NULL,
            &instance_any_id));
    ESP_ERROR_CHECK(esp_event_handler_instance_register(IP_EVENT,
            IP_EVENT_STA_GOT_IP,
            &event_handler,
            NULL,
            &instance_got_ip));

    wifi_config_t wifi_config = {
        .sta = {
            .ssid = WIFI_SSID,
            .password = WIFI_PASS,
            .threshold.authmode = WIFI_AUTH_WPA_PSK,
            .sae_pwe_h2e = WPA3_SAE_PWE_BOTH,
            .sae_h2e_identifier = "",
        },
    };

    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA) );
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config) );
    ESP_ERROR_CHECK(esp_wifi_start() );

    EventBits_t bits = xEventGroupWaitBits(s_wifi_event_group,
            WIFI_CONNECTED_BIT | WIFI_FAIL_BIT,
            pdFALSE,
            pdFALSE,
            portMAX_DELAY);

    if (bits & WIFI_CONNECTED_BIT) {
        ESP_LOGI(TAG, "Connected!");
    } else if (bits & WIFI_FAIL_BIT) {
        ESP_LOGE(TAG, "Failed to connect!");
    }
}

void app_main(void)
{

    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
      ESP_ERROR_CHECK(nvs_flash_erase());
      ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    ESP_ERROR_CHECK(bsp_led_indicator_create(leds, NULL, BSP_LED_NUM));
    led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x0, 0x0, 0x20));

    wifi_init_sta();
}
```

### Extra

1. Pokud budete chtít, můžete si například doma vyzkoušet připojení k Wi-Fi i pomocí komponenty [common_components/protocol_examples_common](https://github.com/espressif/esp-idf/tree/release/v5.2/examples/common_components/protocol_examples_common).


## Next step

Když už jsme se úspěšně připojili na Wi-Fi, přesuneme se na práci s pamětí!

[Úkol 4: NVS](../assignment-4)
