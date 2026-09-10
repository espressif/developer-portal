---
title: "USB-CAN with ESP: A Candlelight / gs_usb TWAI Adapter"
date: 2026-09-07
authors:
  - "Wan Lei"
summary: "Walk through the ESP-IDF usb_twai_adapter example: how Candlelight/gs_usb compatibility works, how USB and TWAI paths move frames, and how to use it on Linux (and what Windows looks like today)."
tags:
  - TWAI
  - CAN
  - USB
  - Candlelight
---

<!-- Draft built section by section against docs/superpowers/specs/2026-09-07-usb-twai-candlelight-blog-design.md -->

An ESP chip with native USB Device and TWAI can act as a compact USB-CAN adapter without a separate bridge MCU. Here, TWAI is Espressif's CAN-compatible controller, so the ESP-IDF example [`usb_twai_adapter`](https://github.com/espressif/esp-idf/tree/master/examples/peripherals/twai/usb_twai_adapter) can present the device as a Candlelight / `gs_usb` compatible adapter to the host, then bridge frames between USB and the TWAI bus.

This article walks through the example from the host view inward. First, it places Candlelight and `gs_usb` in the host ecosystem. Then it follows how control requests and CAN or CAN FD frames move through the firmware. Finally, it covers how to wire, flash, and use the adapter on Linux, plus what to expect on Windows today.

## Candlelight, gs_usb, and the host ecosystem

**gs_usb** is the device protocol used by Geschwister Schneider USB/CAN adapters and the open [candleLight](https://github.com/candle-usb/candleLight_fw) firmware. Linux also ships an in-tree driver with the same name. People often call the dongles **CANable** or **Candlelight**; on the wire and in the kernel, the name that matters is **gs_usb**.

On Linux it is simple: the device enumerates as OpenMoko Candlelight (`0x1D50:0x606F`), the in-tree `gs_usb` driver binds, and you get a SocketCAN interface such as `can0`. After that, the usual tools work — `ip link`, `cansend` / `candump`, Wireshark, and anything else that already speaks this class of adapter.

That host-facing USB contract is what matters. Many existing dongles used STM32-class parts; the ESP-IDF example implements the same host-visible behavior with on-chip USB Device and TWAI.

## How frames move through the example

At a high level the adapter is a bridge with two sides and a small amount of buffering in the middle:

```
Host (SocketCAN / tools)
    ↕  USB vendor control + bulk (`gs_host_frame`)
ESP TinyUSB vendor IF          ← `gs_usb.c`
    ↕  TX / RX frame pools
TWAI driver                    ← `candlelight_twai.c`
    ↕  transceiver
CAN / CAN FD bus
```

**Control** and **data** are separate on USB. Control transfers set capabilities, bit timing, and start/stop. Bulk endpoints carry a stream of fixed-layout `gs_host_frame` structures.

Two pools keep the directions independent: USB→TWAI (`tx_pool`) and TWAI→USB (`rx_pool`). Meanwhile, gs_usb requires a **TX echo** after the controller finishes sending a host-originated frame: the device must send that same `gs_host_frame` back on USB so the host can treat it as TX confirmation. Frames that originated on the bus use `echo_id = UINT32_MAX`.

The next two sections look at the USB side and the TWAI side in turn.

## USB side

On the ESP, the USB side has one job: look like a Candlelight device and answer the host the way `gs_usb` expects. TinyUSB presents the familiar OpenMoko VID/PID and a vendor interface, while `gs_usb.h` defines the wire types shared with the Linux `gs_usb` driver. In `gs_usb.c`:

- `tud_vendor_control_xfer_cb()` handles the host's vendor control requests.
- `tud_vendor_rx_cb()` handles the bulk OUT data stream carrying host-originated `gs_host_frame` records.

Until the host starts the channel, TWAI is not running. During bring-up, the host first probes device configuration and timing capabilities. Later, when the host configures bitrate or brings the interface up or down, those USB control requests drive the TWAI application's state transitions.

The mapping is easier to see in one place — host stage or command on the left, `bRequest` on the right, roughly in bring-up order:

```
Host stage / command                         tud_vendor_control_xfer_cb
-----------------------------------------    ----------------------------------
Write byte-order probe (0xbeef)           -> HOST_FORMAT
Read channel count & versions             -> DEVICE_CONFIG
Query bit-timing limits                   -> GET_BT_CONST
                                          -> GET_BT_CONST_EXT   (FD capable)
ip link … bitrate …                       -> SET_BITTIMING
ip link … dbitrate … fd on                -> SET_DATA_BITTIMING (FD)
ip link set canX up                       -> MODE(start)
                                             create & start TWAI
ip link set canX down                     -> MODE(stop/reset)
                                             stop & delete TWAI

  (while up)  ip -d link show canX
              (berr / can state)          -> GET_STATE
  (while up)  Sync HW timestamp clock     -> TIMESTAMP
```

First, `GET_BT_CONST_EXT` and `SET_DATA_BITTIMING` only appear when the device advertised CAN FD — this example does that on TWAI FD capable chips.

What `MODE(start)` actually starts is the TWAI side. That is next.

## TWAI side

At a high level, the TWAI side does three jobs: apply the bus timing requested by the host, send host-originated frames onto the bus, and turn bus activity back into the `gs_usb` format that the host expects.

In practice, that means converting `gs_host_frame` records into TWAI frames on the way out, converting TWAI RX and state changes back into `gs_host_frame` records on the way back, and generating the TX echo that `gs_usb` uses as transmit confirmation. The separate `tx_pool` and `rx_pool` buffers keep those two directions decoupled, so traffic flowing from USB to the bus does not block frames and state notifications flowing back to the host.

## Hardware setup and flashing

To try the example, you need an ESP target with both USB Device and TWAI support, plus a TWAI transceiver such as SN65HVD230 or TJA1050. CAN FD also requires a TWAI FD capable chip.

The example defaults to `GPIO4` for TWAI TX and `GPIO5` for TWAI RX. Connect those pins to the transceiver, then connect the transceiver to the CAN bus. If your board needs different pins, change them in `candlelight_internal.h`.

Build and flash as usual with ESP-IDF:

```bash
idf.py -p PORT flash monitor
```

One detail matters here: use the chip's native USB device port for the `gs_usb` interface. A USB-to-UART bridge can still be useful for logs, but it is not the USB path that the host will enumerate as a Candlelight-compatible adapter.

## Using it on Linux

On Linux, the happy path is straightforward: plug the board into the host through its native USB device port, let the in-tree `gs_usb` driver bind, bring the CAN interface up, and then use normal SocketCAN tools.

First, confirm that the device enumerates with the expected Candlelight VID/PID:

```bash
lsusb
# ... ID 1d50:606f OpenMoko, Inc. Geschwister Schneider CAN adapter
```

Then check that Linux created a CAN network interface, typically `can0`:

```bash
ip link show
```

For a CAN FD capable target, bring the interface up with both arbitration and data-phase bitrates:

```bash
sudo ip link set can0 up type can bitrate 500000 dbitrate 2000000 fd on
```

At that point, standard SocketCAN tools should work. In one terminal, start a dump:

```bash
candump can0 -ex
```

In another, send a test frame:

```bash
cansend can0 123##1DEADBEEF
```

If you only need classic CAN, omit the FD options:

```bash
sudo ip link set can0 up type can bitrate 500000
```

When you are done, bring the interface down again:

```bash
sudo ip link set can0 down
```
