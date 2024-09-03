---
title: ESP32 Device Provisioning: Configuring Custom Data
date: 2019-10-11
showAuthor: false
authors: 
  - kedar-sovani
---
[Kedar Sovani](https://kedars.medium.com/?source=post_page-----2e9c17aa4d51--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F1d2175c72923&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fesp32-device-provisioning-configuring-custom-data-2e9c17aa4d51&user=Kedar+Sovani&userId=1d2175c72923&source=post_page-1d2175c72923----2e9c17aa4d51---------------------post_header-----------)

--

One of the common requirements I have seen is, during the initial device provisioning, configuring some device specific custom data on the device. This could be something as easy as assigning a user-friendly name to the device, or something like initialising the Alexa credentials on the device.

The unified provisioning infrastructure within the ESP-IDF/ESP-Jumpstart allows for this mechanism with ease.

## Conceptual Overview

The communication mechanism for the unified provisioning is depicted in the following block diagram:

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*95b9M0k_3LTNgTy-JYVUIg.png)

This is the protocol stack that is used during the initial provisioning of the device. From the bottom to the top:

- __Transport:__  The client (typically a phone app) will use either of the two available transport mechanism, HTTP (generally over softAP) or BLE, to establish a connection with the device.
- __Protocomm:__ The protocomm layer provides a secure abstraction for the higher level APIs. The protocomm layer takes care of registering the API as a HTTPd service API, or a GATT-level API. Additionally, the protocomm layer ensures that data exchange that happens over the API happens over a secure channel.
- __API implementation:__  At the highest level, the Wi-Fi Provisioning module implements its own APIs: Scan(), SetConfig(), ApplyConfig() and GetStatus(). These are the APIs that the phone application will call while performing the initial device provisioning.

The Protocomm layer allows you to install your own custom API. This API can handle the additional configuration such as the user-friendly device name, or the Alexa credentials, that we discussed in the beginning.

The provisioning implementation uses [Protocol Buffers](https://developers.google.com/protocol-buffers) to exchange data over its API. Your API implementation is free to choose any data representation for exchanging data.

## Sample Code

Let’s say you have to create your own custom API, MyCustomAPI() that allows the phone application to configure a user-friendly device name into the device.

We can take the example of ESP-Jumpstart application for this discussion. In the ESP-Jumpstart application, in any application after the [4_network_config/](https://github.com/espressif/esp-jumpstart/blob/master/4_network_config/) application, go to the line that makes the call to [wifi_prov_mgr_start_provisioning()](https://github.com/espressif/esp-jumpstart/blob/master/4_network_config/main/app_main.c#L215).

You can modify this call to look like the following:

```
wifi_prov_mgr_endpoint_create("my-custom-api");     
wifi_prov_mgr_start_provisioning(security, pop, service_name, 
                                 service_key));wifi_prov_mgr_endpoint_register("my-custom-api", 
                     custom_prov_config_data_handler, NULL);
```

So we use the *wifi_prov_mgr_endpoint_create()* to create a new endpoint, and then setup a callback handler that needs to be invoked using the *wifi_prov_mgr_endpoint_register()*. And now you can implement the function *custom_prov_config_data_handler(). *This callback handler will get called whenever the client makes a call to the my-custom-api endpoint.

```
esp_err_t custom_prov_config_data_handler(uint32_t session_id, const 
                    uint8_t *inbuf, ssize_t inlen, uint8_t **outbuf, 
                    ssize_t *outlen, void *priv_data)
{/* The 'inbuf' contains the input data to this API. The function 
 * should allocated and populate the 'outbuf' that should contain
 * the response.
 */
    if (inbuf) {
        ESP_LOGI(TAG, "Received data: %.*s", inlen, (char *)inbuf);
    }    char response[] = "SUCCESS";
    *outbuf = (uint8_t *)strdup(response);
    if (*outbuf == NULL) {
        ESP_LOGE(TAG, "System out of memory");
        return ESP_ERR_NO_MEM;
    } 
    /* +1 for NULL terminating byte */
    *outlen = strlen(response) + 1; 

    return ESP_OK;}
```

## Phone Application

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*yAeKjHOJPjUQuXzTxAztmg.png)

This API can now be called from any client like a phone application. The client will make calls to this API, just like it makes to the other APIs of the network configuration infrastructure.

The source code for the provisioning phone applications is available for [iOS](https://github.com/espressif/esp-idf-provisioning-ios) and [Android](https://github.com/espressif/esp-idf-provisioning-android).

The phone application can be modified to make the call to the *my-custom-api* that we defined in the firmware above. Please note any calls to custom APIs should be made *before* the phone application executes the *ApplyConfig *API. The *ApplyConfig *call indicates to the firmware that the provisioning is now complete.

And that way, we have easily added a custom configuration API to our device’s initial provisioning workflow.
