---
title: "OTA Firmware Upgrades with ESP RainMaker"
date: 2020-05-24
showAuthor: false
featureAsset: "img/featured/featured-rainmaker.webp"
authors:
  - piyush-shah
tags:
  - Esp32
  - Esp32 Programming
  - Rainmaker
  - Esp32 S2

---
{{< figure
    default=true
    src="img/ota-1.webp"
    >}}

Any Internet of Things (IoT) system is incomplete if it does not have a facility of upgrading the firmware remotely (also called Over The Air firmware upgrades). The [ESP IDF](https://github.com/espressif/esp-idf) offers a very simple interface for [OTA upgrade using a secure HTTP connection](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/system/esp_https_ota.html). However, the following things still remain unaddressed, as they are out of scope of the firmware development framework and require some infrastructural support:

Setting up the infrastructure could be a challenge, especially for Makers. The recently launched [ESP RainMaker](https://rainmaker.espressif.com/) just added a facility to address all these concerns.

## Introducing Services

Similar to the concept of “devices”, a new concept of “services” has been introduced. They are very similar to devices but are meant for features like OTA, diagnostics, system information, etc. which do not really fall in the category of any device.

## The OTA Service

The OTA Service is the first standard service added. It has 3 string parameters: URL, Status and Info, which are accessible in the same way as any other device parameters. Applications can send the firmware upgrade url by writing to the URL parameter and then monitor the status by reading the Status and Info. The firmware side code has been abstracted out completely and applications need to call this single API:

Check the [ESP RainMaker Switch example](https://github.com/espressif/esp-rainmaker/tree/master/examples/switch) for sample usage .

This takes care of points 2 and 3 above, but point 1 could still be a pain point. To make it even easier, ESP RainMaker now also offers an image hosting service which makers can use for temporary storage of their firmware images. This facility is exposed via the ESP RainMaker CLI.

## Using OTA Upgrades with RainMaker CLI

To use it, set up the CLI as per the instructions [here](https://rainmaker.espressif.com/docs/cli-setup.html). Once done, ensure that your node is linked to your account and is also online. Then, follow these steps:

```
$ cd /path/to/esp-rainmaker/cli
$ ./rainmaker.py login # Use the same credentials used in phone app for setting up the node
$ ./rainmaker.py getnodes # Just to verify that you see the node that you want to upgrade
$ ./rainmaker.py otaupgrade <node_id> <path_to_ota_fw_image>
```

The otaupgrade command uploads the firmware image to the RainMaker server and gets back a temporary URL in return. It then sends this URL to the node using the OTA URL parameter mentioned above and then checks for the status using the Status and Info parameters. It will print the progress as below:

```
$ ./rainmaker.py otaupgrade 7CDFA1XXXXXX ../examples/switch/switch-2.0.bin
Uploading OTA Firmware Image...
Checking esp.service.ota in node config...
Setting the OTA URL parameter...
OTA Upgrade Started. This may take time.
Getting OTA Status...
[19:49:50] in-progress : Downloading Firmware Image
[19:49:58] in-progress : Downloading Firmware Image
[19:50:07] in-progress : Downloading Firmware Image
[19:50:16] in-progress : Downloading Firmware Image
[19:50:25] in-progress : Downloading Firmware Image
[19:50:34] in-progress : Downloading Firmware Image
[19:50:43] success : OTA Upgrade finished successfully
```

Once the OTA Upgrade is successful, the node reboots into the new firmware and you are done. Additional configuration and technical details can be found [here](https://rainmaker.espressif.com/docs/ota.html).

So, get going with ESP RainMaker. Let your devices be anywhere, in the garage, in the water tank, out on the lawn, in the home or the office; you can continue playing around with the firmware by using this new OTA service.
