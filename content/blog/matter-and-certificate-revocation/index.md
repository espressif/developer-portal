---
title: Matter and Certificate Revocation
date: 2023-10-23
showAuthor: false
authors: 
  - deepakumar-v-u
---
[Deepakumar V U](https://medium.com/@deepakumarvu?source=post_page-----e8d5d29fef94--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F43f454c48747&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fmatter-and-certificate-revocation-e8d5d29fef94&user=Deepakumar+V+U&userId=43f454c48747&source=post_page-43f454c48747----e8d5d29fef94---------------------post_header-----------)

--

[Espressif Matter Series](/matter-38ccf1d60bcd) #10

In the previous blogs, we discussed various aspects of Matter. One of which was the Matter Security Model. Matter’s Security Model is based on PKI infrastructure, a widely used security model for securing communications and establishing trust and identity in the digital world. (To know more about Matter’s Security Model you can read this [blog](/matter-security-model-37f806d3b0b2)).

## __Why is Revocation required?__ 

In Matter, every device has its own unique identity in the form of a DAC (Device Attestation Certificate), which is used to identify itself as a valid Matter device. What if this identity gets stolen, compromised, or is no longer valid? That’s where revocation comes into play. Certificate revocation helps us mark a certificate as revoked before its scheduled expiration.

In the PKI world, there are various ways to maintain and circulate the status of the certificate. One such mechanism is the [CRL (Certificate Revocation List)](https://en.wikipedia.org/wiki/Certificate_revocation_list), which CSA has decided to go ahead with for managing revoked certificates in Matter. A CRL will maintain a list of certificates that have been revoked per Certificate Authority. And pointers to these CRLs are maintained in DCL.

## __Effect of certificate revocation__ 

When a certificate is revoked, all the certificate’s issued under it, including itself, will be revoked, i.e., if a PAI is revoked, then the PAI and all the DACs issued under it will stand revoked irrespective of their scheduled expiry.

Matter will support the revocation of PAI and DACs via CRLs.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*n4o7gcH4c7L82-dL8N4jAQ.png)

## __The User Experience__ 

Each device that is being commissioned will be checked for its revocation status during the commissioning stage. The commissioner may also carry out periodic checks to ensure the device’s revocation status if it has already been commissioned.

Upon discovering the revoked status of the device, the commissioner can notify the user. It is then the user’s responsibility to make a conscious decision regarding whether to allow the device to operate with limited functionality or not. Ultimately, the problem can be resolved by the vendor, who has the ability to replace the device’s DAC.

## __The Trust__ 

Without revocation, counterfeiters may exploit compromised keys and certificates to create convincing imitations of genuine products. These unauthorised devices often employ low-quality components, compromising performance and security. Customers, lacking a means to distinguish between fake and real products, may unwittingly purchase counterfeits, thus leading to an increased presence of fake devices on the market and eroding trust.

Effective revocation mechanisms can disable devices misusing compromised keys, ensuring customers receive only genuine, reliable products. This maintains trust in product authenticity and Matter as a whole.

## Espressif’s Matter Pre-Provisioning Service

Espressif’s [Matter Pre-Provisioning Service](/accelerating-matter-device-manufacturing-2fcce0a0592a) allows you to order modules from Espressif that are securely pre-programmed with the unique details (DAC) that every Matter device needs to have. To ensure trust and reliability, our solution will soon support PAI and DAC revocation too.

Now that we understand how revocation can help every stakeholder in the Matter Ecosystem, let’s deep-dive into some technical details.

## __What is CRL?__ 

A CRL is a signed blob that has a list of certificates that are issued by the CA but are not to be trusted anymore. These CRLs are signed by the issuing certificate authority or by a dedicated CRL signer for that CA. In the case of DACs, it will be the PAI (Product Attestation Intermediate) that will be issuing the CRL. These CRLs will be further hosted by the CA vendors for easy access.

Below is an example of what a CRL will have.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*of3F7hyt2zYB6iXkrU9kJg.png)

In the above CRL, the certificate with serial number “*490B5C02EAF6285B60D5344076AA7204*” is revoked because of “*Key Compromise*”, where the serial number acts as a unique identifier for the certificate the CA issued.

## __DCL in Revocation__ 

With Matter being adopted widely, there are a large number of PAAs and PAIs, and that number has been growing continuously. And each of these CAs will have their own CRL published and maintained, respectively. Now the consumers of the CRL, i.e., commissioners, need a single source of truth to get the CRL of all the CAs, so that the commissioner can determine if the device is to be trusted or not.

To construct this single source of truth, CSA has decided to go ahead with [DCL (Distributed Compliance Ledger)](/matter-distributed-compliance-ledger-dcl-4013c2376e7), where each CA will have URLs pointing to their CRL, and the onus is on the CA administrators to keep the CRL updated. To learn more about DCL, you can read this [blog](/matter-distributed-compliance-ledger-dcl-4013c2376e7).

Given the large number of CRLs, commissioners are advised to maintain a revocation set that is constructed by combining all the available CRLs in the DCL so that the commissioners can easily identify the revocation status for a given certificate without the need to process all the CRLs in real time. This will ensure the smooth commissioning and functioning of the device. This revocation set can exist in the commissioner’s cloud or locally in the commissioner’s application.

## __Inclusion in Matter Specification__ 

The Certificate Revocation has been included in Matter Specification version 1.2 (released in Fall 2023), which mandates the CAs to publish and maintain the CRLs in DCL, effective September 1st, 2024. Given the benefits it brings to the table, this is a pivotal inclusion.
