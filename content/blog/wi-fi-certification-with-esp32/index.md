---
title: Wi-Fi Certification with ESP32
date: 2018-08-11
showAuthor: false
authors: 
  - kedar-sovani
---
[Kedar Sovani](https://kedars.medium.com/?source=post_page-----311e09dd06ff--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F1d2175c72923&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fwi-fi-certification-with-esp32-311e09dd06ff&user=Kedar+Sovani&userId=1d2175c72923&source=post_page-1d2175c72923----311e09dd06ff---------------------post_header-----------)

--

A fair number of questions come up regarding Wi-Fi certification for Wi-Fi enabled IoT products. Here is an attempt to answer some of the relevant ones.

Wi-Fi certification is a program by Wi-Fi Alliance that ensures that products that pass certification adhere to the interoperability and security requirements as laid out in the standard. It tests for *protocol* compliance.

This is different from regulatory certification (like FCC in the US) which is mandatory since it tests that the electromagnetic emissions from a product are under safe limits.

## Is Wi-Fi certification mandatory for all?

Wi-Fi certification is mandatory if your product will use ‘Wi-Fi certified’ or the ‘Wi-Fi logo’ on the product branding or marketing campaigns. Certain ecosystem programs, like Apple HomeKit, also have Wi-Fi certification as a mandatory requirement. Your organisation must be a member of the Wi-Fi Alliance to have your product tested for Wi-Fi certification.

## Derivative Certification using ESP32

If you have identified that you require Wi-Fi certification, the quickest path is to use the __derivative certification__ . This certification is applicable if you are using an already certified Wi-Fi module into your product, without any modifications. In such a case, the certification of that Wi-Fi module (called the source), can be directly applied to your product.

> The benefit of derivative certification is that you won’t have to perform all the Wi-Fi certification tests on your product. You just carry forward the results from the source Wi-Fi module to your product. This saves money and importantly, time, for getting the product certified.

For additional details about the derivative certification please refer to the [Certifications Overview - Derivative Certificate](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&cd=1&cad=rja&uact=8&ved=2ahUKEwj--t_q_ObcAhWKso8KHRmeBCwQFjAAegQIChAB&url=https%3A%2F%2Fwww.wi-fi.org%2Ffile%2Fcertification-overview-derivative-certifications&usg=AOvVaw0EQuZMH38UR39eYLnP_PX3) document on the Wi-Fi Alliance website.

The modules ESP32-WROVER and ESP32-WROOM-32D are already certified with Wi-Fi Alliance (Certificates in PDF form: [ESP32-WROVER](http://certifications.prod.wi-fi.org/pdf/certificate/public/download?cid=WFA77915), [ESP32-WROOM-32D](http://certifications.prod.wi-fi.org/pdf/certificate/public/download?cid=WFA77387)). If you are using these modules in your product you can use derivative certification for certifying your products. If you are using an ESP32 module from another vendor, please check with them for that module’s Wi-Fi Alliance certification status.

## Steps for Derivative Certification

- For any certification, you have to first be a member of Wi-Fi Alliance. Details about membership levels, cost and benefits is available [here](https://www.wi-fi.org/membership).
- Once you are a member, login to the certification system and click on __New Derivative Product Certification.__ 

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*q1E76PDptDJrfJTcfgSx3A.png)

- Choose the *Source Company* as Espressif Inc (If you are using Espressif’s WFA certified modules). Choose your organisation’s name as the *Target Company*.
- Choose the* Product* that you are deriving from. If you are using Espressif’s WFA certified module, you may use __WFA77915 for ESP32-WROVER__ , or __WFA77387 for ESP32-WROOM__ .
- Go to the next page:__Product Information__ 

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*u4sG02sDeRDWUDbx93XWQw.png)

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*0zV0k1VNzcTK0EroiB0mDA.png)

- Mention any changes you may have done to the subsystems as indicated in the page.
- Go to the next page: __Product Designators__ 

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*1tXJ_Y9iqvs-ctCKskZ_GA.png)

- Fill in the appropriate designators for your product. Select the closest matching *Primary Product Category*. For example, if your product is a refrigerator, select Refrigerator from the list. If applicable, also select the *Secondary Product Category*.
- Go to the next page: __Review Application__ 

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*rIYgiaIslHPlK25Jhjat1Q.png)

- Make sure everything is in order, make the payment and submit the application.
- The WFA staff will review the submission and if everything is in order, will grant you the Wi-Fi certification.

## Full Wi-Fi Certification

If you cannot use the derivative certification as mentioned above, you will have to perform the full Wi-Fi certification.

## Steps for Wi-Fi Certification
