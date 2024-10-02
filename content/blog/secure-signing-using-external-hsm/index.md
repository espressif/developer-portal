---
title: "Secure Signing Using External HSM"
date: 2023-02-09
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - mahavir-jain
tags:
  - Esp32
  - Security
  - IoT
  - Esptool

---
## Overview

ESP32 series of chips supports secure boot scheme to allow only trusted firmware to execute from its flash storage. However, this requires careful management of the secure signing key, it must be generated and stored in a secure manner by the signing entity.

External [HSM](https://en.wikipedia.org/wiki/Hardware_security_module) (Hardware Security Module) is specially designed cryptographic device that safeguards and manages secrets. HSM also provides specialised cryptographic services like encryption, digital signing etc. Now a days, there are cloud services being offered that provide cloud HSM based solutions.

## External HSM Signing

{{< figure
    default=true
    src="img/secure-1.webp"
    >}}

External HSM offers a standard [PKCS #11](https://en.wikipedia.org/wiki/PKCS_11) based cryptographic interface for availing various services like signing the firmware. With PKCS #11 interface, external HSM could also be a remote cloud HSM based service over the network.

- Espsecure.py script (part of [Esptool](https://github.com/espressif/esptool) project) has been integrated with standard PKCS #11 interface and thus ensures interoperability with any external HSM for getting the ESP32's firmware signed.
- Please note that, as shown in the above diagram path of the vendor specific PKCS #11 library must be provided in the Espsecure.py configuration to use HSM mode.
- The initial support allows to generate signed application as per our Secure Boot V2 scheme with either RSA-PSS 3072 or ESDSA NISTP256 algorithm.

## Signing Using YubiKey

We will be using [YubiKey](https://www.yubico.com/products/yubikey-5-overview/) 5 Series as an external HSM for demonstration here.

## Installation

Please find detailed setup guide for YubiKey host tool and PKCS #11 library setup [here](https://developers.yubico.com/yubico-piv-tool/).

Note: Following are verified steps for Ubuntu 22.10 OS

```shell
# Install esptool 4.5 release along with HSM dependencies
pip install esptool[hsm]==4.5.dev3

# Install tools and PKCS#11 interface library
sudo apt install yubico-piv-tool ykcs11

# Generate ECC P256 private key in the 9c (digital signature) slot
yubico-piv-tool -a generate -s 9c -A ECCP256
```

## HSM config file

Following is a HSM config file that we shall pass to espsecure.py

```shell
$ cat hsm_cfg.ini

# Config file for the external YubiKey based Hardware Security Module
[hsm_config]
# PKCS11 shared object/library
pkcs11_lib = /usr/lib/x86_64-linux-gnu/libykcs11.so
# HSM login credentials (default YubiKey pin)
credentials = 123456
# Slot number to be used (default YubiKey slot)
slot = 0
# Label of the object used to store the private key (default)
label = Private key for Digital Signature
# Label of the object used to store corresponding public key (default)
label_pubkey = Public key for Digital Signature
```

*Please check directory where **libykcs11.so** is installed on your system and update the path accordingly.*

## Generate signature

Following command helps to sign the binary using configuration supplied in the hsm_cfg.ini file

```shell
$ espsecure.py sign_data --version 2 --hsm --hsm-config hsm_cfg.ini --output signed.bin unsigned.bin

espsecure.py v4.5-dev
Trying to establish a session with the HSM.
Session creation successful with HSM slot 0.
Trying to extract public key from the HSM.
Got public key with label Public key for Digital Signature.
Connection closed successfully
Trying to establish a session with the HSM.
Session creation successful with HSM slot 0.
Got private key metadata with label Private key for Digital Signature.
Signing payload using the HSM.
Signature generation successful.
Connection closed successfully
Pre-calculated signatures found
1 signing key(s) found.
Signed 65536 bytes of data from unsigned.bin. Signature sector now has 1 signature blocks.
```

## Verify signature

For sanity purpose, we can verify the signature using public key from the external HSM

```shell
$ espsecure.py verify_signature --version 2 --hsm --hsm-config hsm_cfg.ini signed.bin

espsecure.py v4.5-dev
Trying to establish a session with the HSM.
Session creation successful with HSM slot 0.
Trying to extract public key from the HSM.
Got public key with label Public key for Digital Signature.
Connection closed successfully
Signature block 0 is valid (ECDSA).
Signature block 0 verification successful using the supplied key (ECDSA).
```

## Documentation

Please refer to the Esptool documentation [here](https://docs.espressif.com/projects/esptool/en/latest/esp32/espsecure/index.html#remote-signing-using-an-external-hsm) for more details.

Please note that this feature shall be available in Esptool v4.5 release. For now, you may use Esptool dev release using pip install esptool[hsm]==4.5.dev3to try out this feature.
