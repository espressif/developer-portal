---
title: "Workshop: ESP-IDF a ESP32-C6 - Úkol 6"
date: 2024-09-30T00:00:00+01:00
showTableOfContents: false
series: ["WS001CZ"]
series_order: 7
showAuthor: false
---

## Úkol 6: Protokoly

V současné chvíli ESP-IDF podporuje hromadu porotokolů, jako například:

- HTTP and HTTPS
- ICMP
- CoAP
- MQTT and MQTT5
- PPP (Point-to-Point Protocol) včetně PPPoS
- Sockets
- Modbus
- SMTP
- SNTP
- ...a mnoho dalších

Můžete prozkoumat, jak se s protokoly pracuje přímo na základě příkladů ve složkách [ESP-IDF examples](https://github.com/espressif/esp-idf/tree/master/examples), [esp-protocols](https://github.com/espressif/esp-protocols), nebo v [ESP Registry](https://components.espressif.com).

### Praktický příklad s protokoly

V tomhle příkladu budeme používat *ESP x509 Certificate Bundle*, abychom si trochu zjednodušili práci s některými protokoly, které vyžadují certifikáty, jako trřeba HTTPS.

[ESP x509 Certificate Bundle API](https://docs.espressif.com/projects/esp-idf/en/release-v5.2/esp32/api-reference/protocols/esp_crt_bundle.html?highlight=bundle#esp-x509-certificate-bundle) poskytuje kolekci certifikátů pro ověření na TLS serveru, které jsou automaticky generované z [kořenových NSS certifikátů Mozilly](https://wiki.mozilla.org/CA/Included_Certificates). Tento balík obsahuje víc než 130 certifikátů a je konstantně aktualizován.

Díky využití tohoto balíku nemusíme pro bezpečné HTTPS spojení s využitím TLS (ESP-TLS) ručně nahrávat žádné kořenové certifikáty, ani je nemusíme v případě jejich expirace obnovovat.

1. **Ověření, že předchozí kroky fungují, jak mají**

V tomto úkolu budeme dále upravovat projekt, na kterém jsme pracovali doteď. Je proto dobré ověřit, že v tuhle chvíli jde projekt sestavit, nahrát a že se deska úspěšně připojí k Wi-Fi.

> Během tohoto úkolu budeme potřebovat připojení k Internetu.

2. **Úprava konfigurace**

Otevřete si konfigurační menu (Ctrl + Shift + P a vyhledat *SDK Configuration Editor*) a v konfiguračním menu přejděte do `Component config` -> `mbedTLS` -> `Certificate Bundle`. Tam zkontroluje, že:

- `Enable trusted root certificate bundle` je zaškrtnuté
- V nabídce `Default certificate bundle options` je vybraná možnost `Use the full default certificate bundle` 

3. **Kód pro TLS spojení**

Přidáme nezbytné `#include`s...

```c
#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include "lwip/netdb.h"
#include "lwip/dns.h"
#include "esp_tls.h"
#include "esp_crt_bundle.h"
```

...a definice URL odkazů, ke kterým se zkusíme pomocí certifikátu připojit:
```c
#define MAX_URLS    4

static const char *web_urls[MAX_URLS] = {
    "https://www.github.com",
    "https://espressif.com",
    "https://youtube.com",
    "https://seznam.cz",
};
```

Pokud chcete, můžete seznam změnit a umístit tam i vlastní stránky.

4. **Vytvoření tasku, který se pokusí připojit k URL z předchozího kroku**

Tento task se pokusí připojit ke každé z URL ze seznamu výše.

```c
static void event_handler(void* arg, esp_event_base_t event_base,
                                int32_t event_id, void* event_data)
{
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        if (s_retry_num < 100) {
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

Task vytvoříme po zavolání funkce `wifi_init_sta`:

```c
xTaskCreate(&https_get_task, "https_get_task", 8192, NULL, 5, NULL);
```

#### Kompletní kód

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
#include "nvs.h"
#include "nvs_flash.h"
#include "lwip/err.h"
#include "lwip/sys.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include "lwip/netdb.h"
#include "lwip/dns.h"

#include "esp_tls.h"
#include "esp_crt_bundle.h"

#define WIFI_CONNECTED_BIT BIT0
#define WIFI_FAIL_BIT      BIT1

#define MAX_URLS    4

static const char *web_urls[MAX_URLS] = {
    "https://www.github.com",
    "https://espressif.com",
    "https://youtube.com",
    "https://acesso.gov.br",
};

char ssid[32];
char password[64];

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
        if (s_retry_num < 100) {
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
            .ssid = "",
            .password = "",
            .threshold.authmode = WIFI_AUTH_WPA2_WPA3_PSK,
            .sae_pwe_h2e = WPA3_SAE_PWE_BOTH,
            .sae_h2e_identifier = "",
        },
    };

    strncpy((char*)wifi_config.sta.ssid, ssid, sizeof(wifi_config.sta.ssid));
    strncpy((char*)wifi_config.sta.password, password, sizeof(wifi_config.sta.password));

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

esp_err_t get_wifi_credentials(void){

	esp_err_t err;

	ESP_LOGI(TAG, "Opening Non-Volatile Storage (NVS) handle");
    nvs_handle_t nvs_mem_handle;
    err = nvs_open_from_partition("nvs", "storage", NVS_READWRITE, &nvs_mem_handle);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Error (%s) opening NVS handle!\n", esp_err_to_name(err));
        return err;
    }

    ESP_LOGI(TAG, "The NVS handle successfully opened");

	size_t ssid_len = sizeof(ssid);
	size_t pass_len = sizeof(password);

    err = nvs_get_str(nvs_mem_handle, "ssid", ssid, &ssid_len);
    ESP_ERROR_CHECK(err);

    err = nvs_get_str(nvs_mem_handle, "password", password, &pass_len);
    ESP_ERROR_CHECK(err);

    nvs_close(nvs_mem_handle);
    return ESP_OK;
}

static void https_get_task(void *pvParameters)
{
    while (1) {
        int conn_count = 0;
        ESP_LOGI(TAG, "Connecting to %d URLs", MAX_URLS);

        for (int i = 0; i < MAX_URLS; i++) {
            esp_tls_cfg_t cfg = {
                .crt_bundle_attach = esp_crt_bundle_attach,
            };

            esp_tls_t *tls = esp_tls_init();
            if (!tls) {
                ESP_LOGE(TAG, "Failed to allocate esp_tls handle!");
                goto end;
            }

            if (esp_tls_conn_http_new_sync(web_urls[i], &cfg, tls) == 1) {
                ESP_LOGI(TAG, "Connection established to %s", web_urls[i]);
                conn_count++;
            } else {
                ESP_LOGE(TAG, "Could not connect to %s", web_urls[i]);
            }

            esp_tls_conn_destroy(tls);
end:
            vTaskDelay(1000 / portTICK_PERIOD_MS);
        }

        ESP_LOGI(TAG, "Completed %d connections", conn_count);
        ESP_LOGI(TAG, "Starting over again...");
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

	ESP_ERROR_CHECK(get_wifi_credentials());

    wifi_init_sta();

    xTaskCreate(&https_get_task, "https_get_task", 8192, NULL, 5, NULL);
}
```

## Další krok

Už jste vyčerpali všechnu energii? Tak ji pojďme trošku uspořit!

[Úkol 7: Low Power Core](../assignment-7)
