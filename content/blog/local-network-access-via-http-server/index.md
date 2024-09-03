---
title: Local Network Access via HTTP Server
date: 2018-10-13
showAuthor: false
authors: 
  - kedar-sovani
---
[Kedar Sovani](https://kedars.medium.com/?source=post_page-----fb7fcfc3d67e--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F1d2175c72923&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Flocal-network-access-via-http-server-fb7fcfc3d67e&user=Kedar+Sovani&userId=1d2175c72923&source=post_page-1d2175c72923----fb7fcfc3d67e---------------------post_header-----------)

--

So you have your smart device on your end-user’s home network. Now you would want your user to access your device over the local network. That’s what we will look at in this post.

Let’s say you are building a smart plug, and you want to toggle the power on or off on your plug. We will create a HTTP URI */power *on your device.

- An HTTP GET on this URI will give us the current state of the output of the plug.
- An HTTP POST on this URI will update the output state of the plug.

We will create this URI with the following code:

```
httpd_uri_t power_get = { 
       .uri     = "/power",
       .method  = HTTP_GET,
       .handler = power_get_handler
};httpd_uri_t power_post = { 
       .uri     = "/power",
       .method  = HTTP_POST,
       .handler = power_post_handler
};
```

The *power_get_handler() *and the *power_post_handler()* are the functions that will get called respectively, whenever an HTTP GET or HTTP POST will happen on the /power URI on the device.

Then in our application, we can start the web server and register these URIs with the web server as:

```
httpd_handle_t server = NULL;
httpd_config_t config = HTTPD_DEFAULT_CONFIG();     // Start the httpd server    
ESP_LOGI(TAG, "Starting server on port: '%d'", config.server_port);    if (httpd_start(&server, &config) == ESP_OK) {
        // Set URI handlers
        httpd_register_uri_handler(server, &power_get);
        httpd_register_uri_handler(server, &power_post);
}
```

Now the power_get_handler() and the power_post_handler() functions could be implemented as:

```
esp_err_t power_get_handler(httpd_req_t *req)
{
          char resp_str[100];
          snprintf(resp_str, sizeof(resp_str), "{\"state\": %s}",
                 driver_get_output_state() ? "true" : "false");          httpd_resp_send(req, resp_str, strlen(resp_str));          return ESP_OK;
}
#define RESP_SUCCESS   "{\"status\": \"success\"}"
#define RESP_FAIL      "{\"status\": \"fail\"}"
esp_err_t power_post_handler(httpd_req_t *req)
{
          char buffer[100];
          char *resp_str = RESP_SUCCESS;
          int remaining = req->content_len;          while (remaining > 0) {
                  /* Read the data for the request */
                  if ((ret = httpd_req_recv(req, buffer,                        
                         MIN(remaining, sizeof(buffer)))) < 0) {
                         return ESP_FAIL;
                  }
                  remaining -= ret;
          }          /* Parse input */
          target_state = my_parse_user_request(buffer);
          if (target_state < 0) {
                  resp_str = RESP_FAIL;
          } else {
                  /* Change the output */
                  driver_set_output_state(target_state);
          }          /* Send back status */        
          httpd_resp_send(req, resp_str, strlen(resp_str));
          return ESP_OK;
}
```

In the *power_get_handler() *routine above, we just fetch the current output state from the driver, and return it in the HTTP GET response.

In the *power_post_handler()* routine above, we fetch the user’s request, and modify the driver’s state as the user requested it.

## Using the API

For my testing purposes, I could use the following *Curl* commands to test this implementation:

```
$ curl http://192.168.1.113/power
{"state": true}
$ curl -d '{"state": false}' http://192.168.1.113/power
{"status": "success"}
```

For my production scenario, my phone app will make these API calls to query/modify the state of my device.

## Security

Using the API as defined above, relies on the Wi-Fi network’s security to secure the data exchange between your phone and the device. So as long as the user has a secured Wi-Fi network, these exchanges will not be visible to entities outside of the user’s network.

In case of Wi-Fi networks with Open security, the data will be exchanged in plain-text. You could also use a security layer for exchanging these commands. That is a topic for another article.
