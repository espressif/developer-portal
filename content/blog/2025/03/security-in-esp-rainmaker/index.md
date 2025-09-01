---
title: "Security in ESP RainMaker"
date: 2025-03-20
authors:
  - piyush-shah
tags:
  - Esp32
  - Esp Rainmaker
  - Espressif
  - IoT
  - Rainmaker
summary: This article provides a high level overview of the security architecture of the ESP RainMaker IoT platform, covering all aspects like device hardware and network security, client network security, authentication and access control, user-device mapping, cloud data security and certifications.
---

While choosing an IoT platform, users are always concerned about its security. Security in IoT encompasses several aspects since multiple entities are involved. In this blogpost, we will go over all the relevant aspects of ESP RainMaker starting from the device hardware and network security, to client network security, authentication and access control, cloud data storage security, and finally, some relevant certifications.

## Device Hardware Security

### Secure Boot

The Secure Boot (or trusted boot) feature ensures that only authenticated software can execute on the device. The Secure Boot process forms a chain of trust by verifying all mutable software entities involved in the Application Startup Flow. Signature verification happens during both boot-up as well as in OTA updates.

Please refer to [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/security/secure-boot-v2.html) for detailed documentation about this feature.

#### Secure Signing

Enabling secure boot and pushing signed OTA upgrades has been made much simpler using the [Secure signing](https://rainmaker.espressif.com/docs/secure-signing) feature in ESP RainMaker. For managing the signing keys, ESP RainMaker uses a FIPS-compliant cloud HSM for added security.


### Flash Encryption

The Flash Encryption feature helps to encrypt the contents on the off-chip flash memory and thus provides the confidentiality aspect to the software or data stored in the flash memory.

Please refer to [Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/security/flash-encryption.html) for detailed information about this feature.

### Secure Storage

Secure storage refers to the application-specific data that can be stored in a secure manner on the device, i.e., off-chip flash memory. This is typically a read-write flash partition and holds device-specific user configuration data. The ESP RainMaker agent uses this secure storage to store the Wi-Fi credentials of the user's home and other such sensitive configuration data.

ESP-IDF provides the NVS (Non-Volatile Storage) management component which allows encrypted data partitions. This feature is tied with the platform Flash Encryption feature described earlier.

Please refer to [NVS Encryption](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/storage/nvs_flash.html#nvs-encryption) for detailed documentation on the working and instructions to enable this feature.

In the ESP RainMaker context, each device has a unique key-certificate pair that helps the device identify itself to the ESP RainMaker cloud. We utilize the encrypted storage to store this information, to protect it from getting cloned across devices.

---

## Device Network Security

### Network Provisioning

Secure Provisioning refers to a process of secure on-boarding of the RainMaker device onto the user's Wi-Fi/Thread network.

ESP RainMaker uses ESP-IDF's [Wi-Fi Provisioning](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/provisioning/wifi_provisioning.html) which ensures that the credentials are sent over an authenticated and encrypted channel, either using security 1 or security 2 as the [security scheme](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/provisioning/provisioning.html#security-schemes).

The provisioning mechanism uses a Proof of Possession (PoP) pin, a unique secret per device, which is typically pasted on the device in plaintext as well via a QR code. A provisioning client, typically a phone app, will scan this QR code to begin secure communication with the device. This ensures that only a user who is physically in possession of the device can successfully onboard a device.

ESP RainMaker supports an augmented password-authenticated key exchange (PAKE) protocol (SRP6a) to securely authenticate a phone app with the device. All session communication between the phone app and the device is over an encrypted channel.

### Cloud Communication (MQTT)

The device-to-cloud communication for ESP RainMaker uses a TLS1.2 encrypted channel with mutual authentication using X.509 certificates.

Each device has a unique private key and certificate. These are flashed onto the device at the time of manufacturing. The ESP RainMaker cloud backend authenticates and only allows communication with devices that are registered with the cloud, and that can be identified using these certificates. This allows the cloud to authenticate the device.

Additionally, the device should also authenticate the cloud (or any other remote service that it accesses). A certificate bundle (a list of most common trusted root CAs) is maintained on the device. This list is used for server authentication to ensure that the device connects to a genuine server and does not get affected even if the server certificate changes. This is the same mechanism that browsers use to authenticate websites that you access through them.

### (Over-The-Air) Updates

The ESP RainMaker also manages and delivers OTA upgrades to connected devices.

The OTA update image URL is provided to ESP RainMaker devices over an encrypted MQTT channel. The devices then fetch the image over a secure HTTP (HTTPS) channel, ensuring that the update happens securely.

Before finalizing the images on the device, the devices perform a signature verification (refer to the Secure Boot section above) to ensure that the images are truly released by an entity that they trust. The private keys that are used to sign these devices are maintained in ESP RainMaker in a FIPS-compliant cloud HSM.

#### Secure Signing

As mentioned earlier in the section for [Secure Boot](#secure-boot), ESP RainMaker makes it easier to manage OTA for devices with secure boot enabled. You can select appropriate signing key while creating an OTA Job. With the "Auto select key" option as mentioned [here](https://docs.rainmaker.espressif.com/docs/dev/firmware/fw_usage_guides/secure-signing#ota-upgrades), even selecting the key is not required as the cloud backend can automatically choose the correct key as per the information reported in the node config and send a signed image during OTA.

#### Application Rollback

The OTA application rollback feature that is enabled by default ensures that the device can roll back to the older working firmware in case the newer one has issues causing it to either crash or not be able to connect to the server. Check [here](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/ota.html#ota-rollback) for more details.

#### Anti-Rollback Protection

The anti-rollback protection feature ensures that the device only executes the application that meets the security version criteria as stored in its eFuse. Even though the application is trusted and signed by a legitimate key, it may contain some revoked security feature or credential. Hence, the device must reject any such application.

ESP-IDF allows this feature for the application only, and it is managed through the 2nd stage bootloader. The security version is stored in the device eFuse and it is compared against the application image header during both bootup and over-the-air updates. Check [here](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/ota.html#anti-rollback) for more details.

### Local Control

Local Control in ESP RainMaker is built on top of ESP IDF's local control feature, which ensures security similar to the one mentioned for Network provisioning above, using security 1 or 2 as the security scheme. The Proof of Possession (PoP) pin is randomly generated on the device and communicated to authorized end users via the cloud using RainMaker parameters. The pin changes if the device is reset to factory defaults.

---

## Client (User) Network Security

Clients in this context mean phone apps and dashboards that are accessed by admin or end users to talk to the ESP RainMaker backend server. All such communication uses HTTPS, ensuring that the data is encrypted.

---

## Authentication and Access Control

### Device

As mentioned earlier, each ESP RainMaker device has a unique private key and public certificate. The public certificate is registered with the cloud backend. This ensures that devices only with valid private key and certificate can connect to the cloud. The node ID (used as MQTT client ID) is also embedded into the certificate and validated during connection.

The cloud security policy ensures that a node can only publish and subscribe to its own topics, which are under `node/<node_id>/*`, or, if AWS basic ingest is enabled, under `$aws/rules/*/node/<node_id>/*`. This prevents nodes from accessing or modifying data from other nodes.

### Client (User)

Users can access ESP RainMaker APIs only when they have logged in and have received valid access and refresh tokens. The access token is to be passed under the "Authorization" header in all subsequent API calls. This token expires after one hour, but a new one can be fetched using the refresh token. For every user-authenticated call, the cloud backend extracts the user ID from the token to validate against application layer rules.

---

## User-Device Mapping

ESP RainMaker has an elaborate method of user-device mapping which requires the user as well as the device to send the same information (exchanged between them on the local network during provisioning) to the cloud, within a window of 1 minute. This ensures that only the authorized user can access the node. More information can be found in the [RainMaker Specifications](https://rainmaker.espressif.com/docs/user-node-mapping).

This user can subsequently share the node with other users by sending them requests which the secondary users can accept or decline. This mechanism ensures that random spam devices do not get added to the account just because some malicious user shared them with the user.

---

## Cloud Data Security

ESP RainMaker is built on AWS serverless architecture, and the data is stored in DynamoDB, S3, and Timestream. All these are encrypted by default. You can read more about this here:

- DynamoDB: [Encryption at rest](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/encryption.howitworks.html)
- S3: [Protecting data with encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingEncryption.html)
- Timestream: [Encryption at rest](https://docs.aws.amazon.com/timestream/latest/developerguide/EncryptionAtRest.html)

---

## Certifications

ESP RainMaker is currently undergoing ETSI EN 303 645 (Cybersecurity Standard for Consumer IoT Devices) and ongoing 3rd-party penetration testing (for Cloud backend APIs).

---

The security measures taken for all components of ESP RainMaker ensure that the overall solution is highly secure and robust. With the added privacy measures of GDPR compliance, it makes for a perfect platform for your IoT devices. If you are interested in commercial deployments of ESP RainMaker, please reach out to `sales@espressif.com` or `esp-rainmaker-admin@espressif.com`.
