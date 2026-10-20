---
title: "Appendix: Provision a Real Board (Permanent)"
date: 2026-10-06
showTableOfContents: true
showAuthor: false
---

## Purpose

In Assignments 2 to 4 you ran production firmware in the [ESP32 emulator](https://espressif.github.io/esp-emulator/). The emulator runs the real ESP32-S31 ROM and the ESP-IDF bootloader, so every eFuse burn you saw in the logs really happened, but only in the emulator's memory. Reloading the page gave you a blank chip again.

This appendix takes the **same Assignment 4 image** and runs it on a real ESP32-S31-Function-CoreBoard-1. Nothing changes in the firmware. The only difference is that the eFuses are now in silicon:

| | Emulator (Assignments 2 to 4) | Real board (this appendix) |
|---|---|---|
| eFuse burns | Lost when you reload the page | **Permanent** |
| Flash after first boot | Encrypted, discarded on reload | Encrypted, readable only by this chip |
| Serial flashing after first boot | Not needed | **Disabled for good**: ROM download mode is off |
| Firmware updates | Load a new image | Signed OTA only ([Assignment 5](../assignment-5)) |
| Recovery from a mistake | Reload the page | None. The board is locked to your signing key |

> [!WARNING]
> **This step is optional and cannot be undone.** After the first boot, the board accepts only firmware signed with your `secure_boot_signing_key.pem`, can no longer be flashed over serial, and `espefuse` can no longer read its eFuses. If you lose the signing key, the board can never run new firmware. Use a board you are ready to dedicate to this firmware, for example an instructor demo board. Never run this on a borrowed or shared workshop board.

## Before you burn anything

- Finish [Assignment 4](../assignment-4) and confirm in the emulator that the image boots twice with the expected logs.
- Back up `secure_boot_signing_key.pem` outside the repository. Never commit it.
- Plan how the board receives updates. With ROM download mode disabled, the only path is signed OTA, so build OTA into the firmware first ([Assignment 5](../assignment-5)) if you want to update this board later.
- Read [Security Features Enablement Workflows (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html).

## eFuse key block plan

On the first boot, the bootloader writes keys into the first free key blocks, in this order:

| Key block | Purpose | Written by |
|-----------|---------|------------|
| `BLOCK_KEY0` | `SECURE_BOOT_DIGEST0`: SHA-256 of your Secure Boot public key | Bootloader, Secure Boot V2 |
| `BLOCK_KEY1` | `XTS_AES_128_KEY`: flash encryption key, generated on the chip | Bootloader, flash encryption |
| `BLOCK_KEY2` to `BLOCK_KEY5` | Free | Reserved for your product |

The NVS keys are not in eFuse. With the flash encryption-based scheme, they live in the `nvs_keys` partition, which flash encryption protects.

> [!NOTE]
> If your product uses **HMAC-based NVS encryption** (Assignment 2) together with Secure Boot or flash encryption, the HMAC key must be burned **before** the first boot of the secure firmware. Secure Boot and flash encryption both write-protect the eFuse read-protection bits, and after that the application can no longer burn a read-protected HMAC key: `nvs_flash_init()` fails with `Failed to write the HMAC key to eFuse: [0x103] (ESP_ERR_INVALID_STATE)`. Burn it from the host first, for example with `espefuse burn-key BLOCK_KEY0 hmac_key.bin HMAC_UP`, then let the bootloader put the Secure Boot digest and flash encryption key into the next free blocks. See [Enable NVS encryption based on HMAC](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-nvs-encryption-based-on-hmac).

## Step 1: Check that the board is blank

Goal: make sure no security eFuse has been burned yet.

Run:

```bash
idf.py -p PORT efuse-summary
```

Check that:

- `SECURE_BOOT_EN` is `False`
- `SPI_BOOT_CRYPT_CNT` is `Disable`
- `KEY_PURPOSE_0` and `KEY_PURPOSE_1` are `USER`, and `BLOCK_KEY0` and `BLOCK_KEY1` are empty

If any of these are already set, stop: the board was provisioned before, and the first boot would not follow the flow below.

Save this output with your provisioning record. It is the last time `espefuse` can read this board.

## Step 2: Check the configuration

Goal: confirm that you are flashing the production configuration from Assignment 4, and nothing else.

In the Assignment 4 project, run:

```bash
grep -E '^CONFIG_(SECURE_BOOT|SECURE_BOOT_V2_ENABLED|SECURE_DISABLE_ROM_DL_MODE|SECURE_FLASH_ENC_ENABLED|SECURE_FLASH_ENCRYPTION_MODE_RELEASE|NVS_ENCRYPTION|NVS_SEC_KEY_PROTECT_USING_FLASH_ENC)=' sdkconfig
grep -E '^CONFIG_EFUSE_VIRTUAL=' sdkconfig
```

The first command must print all seven options set to `y`. The second must print nothing.

Then run `idf.py build` so the images in `build/` match this configuration.

## Step 3: Flash all images in one command

Goal: write the bootloader, partition table, OTA data, and app before the chip boots for the first time.

With Secure Boot enabled, `idf.py flash` does not write the bootloader, and `idf.py bootloader-flash` resets the chip when it finishes. A reset with only the new bootloader in flash would start the first-boot flow before the app is in place. Write everything in one `esptool` call and keep the chip in reset:

```bash
python -m esptool --chip esp32s31 -p PORT --after no-reset write-flash \
  --flash-mode dio --flash-size 4MB \
  0x2000  build/bootloader/bootloader.bin \
  0x10000 build/partition_table/partition-table.bin \
  0x17000 build/ota_data_initial.bin \
  0x20000 build/<project-name>.bin
```

These are the same offsets you used for the emulator image. The images are plaintext; the bootloader encrypts them in place on the first boot.

## Step 4: Run the first boot

Goal: let the bootloader burn the eFuses and encrypt the flash.

Start the monitor. It resets the chip, which starts the first boot:

```bash
idf.py -p PORT monitor
```

Do **not** unplug the board or press **RST** until the app is running. The first boot burns the Secure Boot digest, encrypts the flash, and resets once. You should see the same sequence as in the emulator:

```text
I (...) secure_boot_v2: Burning public key hash to eFuse
I (...) efuse: Writing EFUSE_BLK_KEY0 with purpose 9
I (...) secure_boot: Disable ROM Download mode...
I (...) secure_boot: Disable hardware & software JTAG...
I (...) secure_boot_v2: Secure boot permanently enabled
I (...) flash_encrypt: Generating new flash encryption key...
I (...) efuse: Writing EFUSE_BLK_KEY1 with purpose 4
I (...) flash_encrypt: Encrypting partition 4 at offset 0x1b000 (length 0x1000)...
I (...) flash_encrypt: Flash encryption completed
I (...) boot: Resetting with flash encryption enabled...
```

After the reset, the app starts:

```text
I (...) flash_encrypt: flash encryption is enabled (0 plaintext flashes left)
I (...) flash_encrypt: Flash encryption mode is RELEASE
I (...) nvs_sec_provider: NVS Encryption - Registering Flash encryption-based scheme...
I (...) nvs: Generating NVS encr-keys...
I (...) nvs: NVS partition "nvs" is encrypted.
I (...) example: Secure Boot enabled: yes
I (...) example: SECURE_BOOT_DIGEST0 in BLOCK_KEY0
I (...) example: XTS_AES_128_KEY in BLOCK_KEY1
I (...) example: esp_flash_read (raw): does not match test string (ciphertext)
```

Unlike in the emulator, the board has internet access, so the TLS request to `www.howsmyssl.com` completes as in [Assignment 1](../assignment-1).

`E (...) esp_image: image at 0x1e0000 has invalid magic byte` during the first boot is expected: `ota_1` is empty until the first OTA update.

## Step 5: Record the evidence

Goal: keep proof of what the board now enforces.

1. Save the complete first-boot log. It is the only record of the eFuse writes, because the next check fails by design.
2. Run `idf.py -p PORT efuse-summary` again. It cannot connect, because ROM download mode is disabled. That failure is part of the evidence.
3. Reset the board and confirm that the second boot shows `secure boot v2 is already enabled` and no new `Generating NVS encr-keys...` line.
4. Record in your provisioning record: board serial number, firmware version, the SHA-256 of `build/<project-name>.bin`, the Step 1 eFuse summary, and both boot logs. Do not record any key material.

## From this board to a production line

The firmware you just provisioned has production settings, but a production line adds steps the workshop does not cover:

- **Credentials.** The workshop firmware stores the lab Wi-Fi credentials compiled into the app from menuconfig. A product writes per-device credentials into NVS during provisioning or at commissioning, and never builds them into the firmware.
- **Host-side provisioning.** On a line, keys are often generated and burned by the provisioning station instead of on first boot, so they can be recorded and the first boot is fast. See [Enable Flash Encryption externally](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-flash-encryption-externally) and [Enable Secure Boot V2 externally](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-secure-boot-v2-externally).
- **Download mode policy.** This firmware disables ROM download mode completely. [Secure download mode](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-uart-rom-dl-mode) is an alternative that keeps a restricted serial path for provisioning tools while blocking flash reads.
- **Signing key custody.** Production signing keys belong in an HSM or a signing service, with access control and a documented revocation plan. Secure Boot V2 supports up to three key digests; this firmware revoked the two unused slots.
- **Anti-rollback.** Decide the secure version policy before the first release; every confirmed increase burns an eFuse bit. See the anti-rollback section in [Assignment 5](../assignment-5/#anti-rollback-what-it-adds).
- **Records.** Keep the eFuse plan, firmware versions, and test results per device in the product technical file.

## Bootloader OTA

The workshop does not cover bootloader OTA. Updating the bootloader on a board with Secure Boot V2 is possible, but a failed update can leave the device unable to boot. See [Secure Boot v2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html) and the ESP-IDF OTA documentation before you plan it.

## If a classroom board was provisioned by mistake

The workshop labs never burn eFuses on a real board. If a production image was flashed to a classroom board and booted, the board is now locked to the instructor's or participant's signing key. Stop, swap the board, and label the locked one so it is not reused in later sessions.

## Related documentation

- [ESP-IDF: eFuse Manager (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/efuse.html)
- [ESP-IDF: Secure Boot v2 (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html)
- [ESP-IDF: Flash encryption (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/flash-encryption.html)
- [ESP-IDF: NVS Encryption (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/storage/nvs_encryption.html)
- [ESP Product Security](https://docs.espressif.com/projects/esp-product-security/en/latest/)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
