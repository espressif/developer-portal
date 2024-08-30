---
title: ESP32: TLS (Transport Layer Security) And IoT Devices
date: 2018-10-24
showAuthor: false
authors: 
  - kedar-sovani
---
[Kedar Sovani](https://kedars.medium.com/?source=post_page-----3ac93511f6d8--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F1d2175c72923&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fesp32-tls-transport-layer-security-and-iot-devices-3ac93511f6d8&user=Kedar+Sovani&userId=1d2175c72923&source=post_page-1d2175c72923----3ac93511f6d8---------------------post_header-----------)

--

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*ihcefbmq3r38UKcps5kw-Q.png)

TLS is the security component in the familiar *https *protocol,* *that we rely on for security on the Internet. A TLS connection between a device and the server ensures that the data exchange between them is secured from the multiple threats possible over an untrusted medium. The TLS connection typically includes mutual authentication of the communicating parties, secure key exchange, symmetric encryption and message integrity checks.

As a recommendation, all the communication between a device and a remote server (cloud) *must* use TLS. Although the TLS layer will take care of all the components involved in the secure communication, as a device maker, you have to be aware of a few things while you are using the TLS session. Let’s quickly look at these:

## CA Certificates (Server Validation)

The TLS layer uses a CA certificate to validate that the server is really who it claims to be. Say your device needs to talk to *aws.amazon.com.* The CA certificate ensures that you are really talking to *aws.amazon.com* and not somebody who is impersonating (DNS Spoofing) them.

During a TLS session establishment, the server presents a certificate to the device. One of the pieces of information encoded in this certificate is the server’s domain name (aws.amazon.com). This server’s certificate is signed by a CA (Certifying Authority). A CA certificate (different from the server’s certificate) present on the device helps validate this signature. If the signature is valid, then the server’s certificate is valid, and hence the domain name encoded in the certificate is valid. The TLS layer then ensures that this domain name in the certificate matches the domain name that we have connected to.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*oFhjn3U4_8FgLp7vZsrixg.png)

A TLS connection typically expects a CA certificate to be passed to it as a session establishment parameter. For example in the ESP-IDF, this is the *cacert_pem_buf* parameter in the *esp_tls_cfg_t *structure.

```
esp_tls_cfg_t cfg = {
    .cacert_pem_buf  = server_root_cert_pem_start,
    .cacert_pem_bytes = server_root_cert_pem_end - 
                              server_root_cert_pem_start,
};struct esp_tls *tls= esp_tls_conn_http_new("https://aws.amazon.com",
                              &cfg);
```

In the code above, the server_root_cert_pem_start points to the start of the CA certificate that is embedded in the device’s firmware.

Not specifying the certificate here implies that the server certificate validation check will be skipped.

## Obtaining a CA Certificate

If your server is hosted on a cloud infrastructure, your https endpoint will likely already have a certificate signed by some CA. In this case, you could fetch the CA certificate for your server’s endpoint using the following command:

```
$ openssl s_client -showcerts -connect hostname:443 < /dev/null
```

This prints out a list of certificates. The last certificate is the CA certificate that can be embedded in the device’s firmware.

## Self-Signed Certificates

Typically server certificates are signed by a CA like Verisign. But you also have the option of using your own key-certificate pair to sign the server’s certificate. This is the self-signed certificate.

You may have your reasons to do this (your cloud provider charges you for certificates with your own domain name, you want to have more control your infrastructure etc). The following two things need to be noted in this context:

- The onus of protecting the private key is now on you
- Self-signed certificates work as long as the client (in this case your device) is under control and you have a means of installing your certificate as a CA certificate on the client. For example, most web browsers will flag a server with self-signed certificate as a security-risk, since the browsers don’t have your certificate installed as a trusted CA certificate.

## Updating Certificates on your Device

Once you have the CA certificate embedded in your firmware, you have to make sure you update it when required. Typically, you may have to update the CA certificate

- if you happen to change cloud service providers or your domain names or
- if your cloud service provider migrates to another CA or
- if the CA certificate’s time validity is going to expire

If your CA certificate is embedded in the device firmware, you can update the CA certificates by doing an OTA firmware upgrade. The new firmware can contain the updated CA certificate to be used.

Since devices in the field may come and go online based on their usage, it may not be guaranteed that all devices see the firmware upgrade just in time for you to make the switch. It is usually helpful to maintain a period of transition where devices can continue to support multiple CA certificates the old and the new.

In the ESP-TLS API above, the *cacert_pem_buf *can point to a buffer that contains multiple CA certificates one after the other. The TLS module will then try to validate the server’s certificate using any of the trusted CA certificates in that buffer.

## Debugging TLS Problems

## 1. Memory Requirement

The TLS session takes quite a bit of memory. You should have enough free heap memory while running TLS. Typically one TLS session requires about 5–6KB of additional stack and about 33–35KB of additional heap memory. Please make sure you have enough room in your heap while running the TLS session.

## 2. Cipher Suites

During the TLS session establishment the client and server negotiate the best possible cipher suite to be used for the session. Most of the typical cipher-suites supported by the servers these days are already enabled in IDF. But it may happen that some servers use a different combination of ciphers.

If your TLS connection fails because of mismatched ciphers you may have to select those specific ciphers in the SDK configuration. This can be done by:

```
make menuconfig --> Component configuration --> mbedTLS --> And then selecting the appropriate ciphers that are missing
```

Note that enabling/disabling cipher suites from the SDK configuration will have a static and dynamic memory footprint impact.

## 3. Identifying Certificate Validation Issues

It is likely that once you deploy a CA certificate for verification, the TLS handshake may fail. This typically implies that there is some problem in certificate validation. Usually this may happen if you select the wrong CA certificate for validation. Additional information about the exact reason for failure can be known by using the following calls:

```
int flags = mbedtls_ssl_get_verify_result(&tls->ssl);char buf[100] = { 0, };
mbedtls_x509_crt_verify_info(buf, sizeof(buf), " ! ",  flags);
printf("Certificate Verification Failure Reason: %s\n", buf);
```
