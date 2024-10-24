---
title: "Wi-Fi Certification with ESP32"
date: 2018-08-11
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - kedar-sovani
tags:
  - Wifi
  - Building Products
  - Esp32

---
A fair number of questions come up regarding Wi-Fi certification for Wi-Fi enabled IoT products. Here is an attempt to answer some of the relevant ones.

Wi-Fi certification is a program by Wi-Fi Alliance that ensures that products that pass certification adhere to the interoperability and security requirements as laid out in the standard. It tests for *protocol* compliance.

This is different from regulatory certification (like FCC in the US) which is mandatory since it tests that the electromagnetic emissions from a product are under safe limits.

## Is Wi-Fi certification mandatory for all?

Wi-Fi certification is mandatory if your product will use ‘Wi-Fi certified’ or the ‘Wi-Fi logo’ on the product branding or marketing campaigns. Certain ecosystem programs, like Apple HomeKit, also have Wi-Fi certification as a mandatory requirement. Your organisation must be a member of the Wi-Fi Alliance to have your product tested for Wi-Fi certification.

## Derivative Certification using ESP32

If you have identified that you require Wi-Fi certification, the quickest path is to use the __derivative certification__ . This certification is applicable if you are using an already certified Wi-Fi module into your product, without any modifications. In such a case, the certification of that Wi-Fi module (called the source), can be directly applied to your product.

> The benefit of derivative certification is that you won’t have to perform all the Wi-Fi certification tests on your product. You just carry forward the results from the source Wi-Fi module to your product. This saves money and importantly, time, for getting the product certified.

For additional details about the derivative certification please refer to the [Certifications Overview - Derivative Certificate](https://www.wi-fi.org/system/files/Wi-Fi_CERTIFIED_Derivative_Certifications_Overview_v3.3.pdf) document on the Wi-Fi Alliance website.

The modules ESP32-WROVER and ESP32-WROOM-32D are already certified with Wi-Fi Alliance. If you are using these modules in your product you can use derivative certification for certifying your products. If you are using an ESP32 module from another vendor, please check with them for that module’s Wi-Fi Alliance certification status.

## Steps for Derivative Certification

- For any certification, you have to first be a member of Wi-Fi Alliance. Details about membership levels, cost and benefits is available [here](https://www.wi-fi.org/membership).
- Once you are a member, login to the certification system and click on __New Derivative Product Certification.__

{{< figure
    default=true
    src="img/wifi-1.webp"
    >}}

- Choose the *Source Company* as Espressif Inc (If you are using Espressif’s WFA certified modules). Choose your organisation’s name as the *Target Company*.
- Choose the* Product* that you are deriving from. If you are using Espressif’s WFA certified module, you may use __WFA77915 for ESP32-WROVER__ , or __WFA77387 for ESP32-WROOM__ .
- Go to the next page:__Product Information__

{{< figure
    default=true
    src="img/wifi-2.webp"
    >}}

{{< figure
    default=true
    src="img/wifi-3.webp"
    >}}

- Mention any changes you may have done to the subsystems as indicated in the page.
- Go to the next page: __Product Designators__

{{< figure
    default=true
    src="img/wifi-4.webp"
    >}}

- Fill in the appropriate designators for your product. Select the closest matching *Primary Product Category*. For example, if your product is a refrigerator, select Refrigerator from the list. If applicable, also select the *Secondary Product Category*.
- Go to the next page: __Review Application__

{{< figure
    default=true
    src="img/wifi-5.webp"
    >}}

- Make sure everything is in order, make the payment and submit the application.
- The WFA staff will review the submission and if everything is in order, will grant you the Wi-Fi certification.

## Full Wi-Fi Certification

If you cannot use the derivative certification as mentioned above, you will have to perform the full Wi-Fi certification.

## Steps for Wi-Fi Certification
