---
title: "Preparing Video for ESP32 Displays with FFmpeg, Tested in QEMU"
date: "2026-11-20"
summary: "How to turn a video into MJPEG frames sized for an ESP32-driven display, pack them into a flash data partition, and play them back with ESP_NEW_JPEG. Every step is checked in Espressif's QEMU without hardware by comparing decoded frames against FFmpeg's output. The article covers the FFmpeg, decoder, and QEMU issues encountered along the way."
authors:
  - "mark-santos"
tags:
  - Multimedia
  - JPEG
  - ESP32-S3
  - QEMU
  - community contribution
---

A boot animation, a product demo loop or a short clip on a status screen all
come down to the same job: get video into a form a microcontroller can decode
fast and store cheaply. On an ESP32, a sequence of JPEG frames (MJPEG) is the
usual answer, because
[ESP_NEW_JPEG](https://components.espressif.com/components/espressif/esp_new_jpeg)
decodes baseline JPEG in software on every chip, and each frame decodes on its
own.

I edit video for a living, so the FFmpeg side of this is familiar ground. This
article covers the whole path: preparing the frames with FFmpeg, packing them
into a data partition, and a small player that memory-maps the partition and
decodes with ESP_NEW_JPEG. Since timing on real hardware varies by chip and
panel, I tested correctness rather than speed, and I did it without a board:
Espressif's QEMU emulates an RGB framebuffer, so the decoded frames can be
captured and compared with FFmpeg's decode of the same files.

The example project uses [ESP-IDF v6.1](https://github.com/espressif/esp-idf) on an ESP32-S3, with ESP_NEW_JPEG 1.0.2 and
[esp_lcd_qemu_rgb](https://components.espressif.com/components/espressif/esp_lcd_qemu_rgb)
1.0.2, run in [QEMU 9.2.2](https://github.com/espressif/qemu) that ships in the
[`espressif/idf:v6.1` Docker image](https://hub.docker.com/r/espressif/idf).
FFmpeg is 9.0.2. The FFmpeg behaviors below were also checked on FFmpeg 7.1.5.

Every script named below (`make_source.sh`, `pack_video.py`, `run_qemu.sh`,
`qemu_screen.py`, `compare_frames.py`) and the player's source are in
[Full listings](#full-listings) at the end of the article.

## Preparing the frames

The test footage comes from FFmpeg itself, so anyone can regenerate it: six
seconds of a Mandelbrot zoom (fine detail, the worst case for JPEG) and four of
`testsrc2` (flat colors and sharp edges, like UI graphics), at 1280x720 and 30
fps.

For a 320x240 panel at 15 fps, one command scales the video until it covers the
panel, crops the middle, drops the frame rate and encodes each frame as a JPEG:

```bash
ffmpeg -i source.mp4 \
  -vf "scale=320:240:force_original_aspect_ratio=increase,crop=320:240,fps=15" \
  -an -c:v mjpeg -q:v 5 -pix_fmt yuv420p -f mjpeg frames.mjpeg
```

`-f mjpeg` writes the JPEGs back to back with no container. `-pix_fmt yuv420p`
gives 4:2:0 chroma; the older `yuvj420p` produces a byte-identical file but
prints a deprecation warning. FFmpeg's MJPEG encoder stores full-range color
either way.

`-q:v` sets the quality, from 2 (best) to 31. For the 10-second test clip at
320x240 and 15 fps, here is what each setting costs in flash, and the luma PSNR
of the decoded frames against the same frames before compression:

| `-q:v` | 150 frames  | Per frame (avg) | PSNR, average | PSNR, worst frame |
| ------ | ----------- | --------------- | ------------- | ----------------- |
| 2      | 2,679,760 B | 17,865 B        | 45.1 dB       | 41.3 dB           |
| 3      | 2,177,344 B | 14,516 B        | 42.2 dB       | 38.1 dB           |
| 5      | 1,648,984 B | 10,993 B        | 38.7 dB       | 34.4 dB           |
| 8      | 1,208,992 B | 8,060 B         | 35.7 dB       | 31.2 dB           |
| 12     | 914,140 B   | 6,094 B         | 33.5 dB       | 29.0 dB           |
| 20     | 630,520 B   | 4,203 B         | 31.1 dB       | 26.6 dB           |
| 31     | 467,872 B   | 3,119 B         | 29.3 dB       | 25.1 dB           |

The Mandelbrot frames are 13% (at `-q:v 31`) to 66% (at `-q:v 2`) larger than the
`testsrc2` frames, so judge quality on the kind of footage you will actually show. For a
3 MB partition, `-q:v 5` fits this clip with room to spare.

## Packing frames into a partition

The player needs to know where each frame starts. Searching the stream for the
JPEG start marker (`FF D8`) is tempting, but those bytes can also appear inside
a header segment, so `pack_video.py` walks the markers properly: it follows
segment lengths up to the start of scan, then skips the entropy-coded data to
the end marker. Inside entropy-coded data, a real `FF` byte is always followed
by `00` or a restart marker, so the end marker can't be mistaken.

It writes a small header, a frame index and the frames, each frame on a 4-byte
boundary:

```text
offset 0   char[4]  "MJV1"
       4   u16      panel width
       6   u16      panel height
       8   u16      fps numerator
      10   u16      fps denominator
      12   u32      frame count (N)
      16   N x {u32 offset, u32 size}
           JPEG frames
```

The partition table gives the video its own data partition, so the video can be
replaced without rebuilding the app:

```csv
# Name,   Type, SubType, Offset,   Size
nvs,      data, nvs,     0x9000,   0x6000
factory,  app,  factory, 0x10000,  0xF0000
video,    data, 0x40,    0x100000, 0x300000
```

## The player

The player maps the whole partition into the address space and hands each
frame to the decoder straight from flash, so no frame is copied into RAM before
decoding:

```c
const esp_partition_t *part =
    esp_partition_find_first(ESP_PARTITION_TYPE_DATA, 0x40, "video");
const void *map;
esp_partition_mmap_handle_t map_handle;
ESP_ERROR_CHECK(esp_partition_mmap(part, 0, part->size, ESP_PARTITION_MMAP_DATA,
                                   &map, &map_handle));
const video_t *v = map;
```

The decoder writes RGB565 into one buffer, which must be 16-byte aligned:

```c
jpeg_dec_config_t config = DEFAULT_JPEG_DEC_CONFIG();
config.output_type = JPEG_PIXEL_FORMAT_RGB565_LE;
jpeg_dec_handle_t dec;
jpeg_dec_open(&config, &dec);
uint8_t *pixels = jpeg_calloc_align(frame_bytes, 16);

for (uint32_t i = 0; i < v->count; i++) {
  jpeg_dec_io_t io = {
      .inbuf = (uint8_t *)map + v->frames[i].offset,
      .inbuf_len = v->frames[i].size,
      .outbuf = pixels,
  };
  jpeg_dec_header_info_t info;
  jpeg_error_t err = jpeg_dec_parse_header(dec, &io, &info);
  if (err == JPEG_ERR_OK) {
    err = jpeg_dec_process(dec, &io);
  }
  // ... draw, then wait for the next frame time
}
```

Each frame is shown for one frame period, timed with [esp_timer](https://docs.espressif.com/projects/esp-idf/en/v6.1/esp32s3/api-reference/system/esp_timer.html). If decoding
falls behind, the player shows the next frame right away and counts it as late,
so the count tells you whether a quality or frame-rate setting is too much for
your chip.

### RGB565 byte order

QEMU's virtual panel takes RGB565 little-endian, hence
`JPEG_PIXEL_FORMAT_RGB565_LE`. Common display controllers, such as the ST7789 and ILI9341, take
each 16-bit pixel high byte first over SPI (see their datasheets), which is
what `JPEG_PIXEL_FORMAT_RGB565_BE` produces. If colors look wrong on a real
panel, check this first.

## Odd panel sizes

Some popular panels have an odd side: the 1.14" ST7789 modules are 135x240. Ask
FFmpeg for a 135x240 crop with 4:2:0 chroma and it silently produces 134x240
frames, because 4:2:0 halves the chroma resolution both ways, so it can only
represent even sizes (4:2:2 has the same limit across). The first version of
the packer recorded 135 in the header while every frame said 134, and the
player rejected all of them.

`pack_video.py` now rounds the frame size up to the next even number, so a
135x240 panel gets 136x240 frames, and the player drops the extra column after
decoding by packing the rows tightly in place:

```c
if (info.width > v->width) {
  for (int row = 1; row < v->height; row++) {
    memmove(pixels + row * v->width * 2, pixels + row * info.width * 2, v->width * 2);
  }
}
```

{{< figure src="img/qemu-frame-135x240.webp" alt="Fig. 1 - The last frame on a 135x240 virtual panel, decoded from a 136x240 JPEG with the extra column dropped" >}}

Avoiding chroma subsampling would avoid the rounding, but that path is closed
too: FFmpeg's 4:4:4 MJPEG uses 1x2 sampling factors on every component, and
ESP_NEW_JPEG 1.0.2 rejects those frames with `JPEG_ERR_UNSUPPORT_FMT`. 4:2:0
decoded at every size I tried: 130, 132, 136, 138, 140 and 144 pixels wide, and
236, 238 and 240 tall.

## Testing without a board

Espressif's QEMU emulates an RGB framebuffer (a virtual device, not a real
peripheral) on the ESP32, ESP32-S3 and ESP32-C3, and `esp_lcd_qemu_rgb` drives
it like any other `esp_lcd` panel. Build, then merge the bootloader, partition
table, app and video into one flash image:

```bash
idf.py build
(cd build && python -m esptool --chip esp32s3 merge-bin --fill-flash-size 4MB \
  -o ../flash.bin @flash_args 0x100000 ../video.bin)
qemu-system-xtensa -nographic -machine esp32s3 \
  -drive file=flash.bin,if=mtd,format=raw
```

Two details kept it from working on the first try.

**Headless, `draw_bitmap` never returns.** The driver hands the frame to the
virtual device and waits until QEMU's display picks it up. With `-nographic`
there is no display, so nothing picks it up, and the player hung after the
first decode. The QEMU monitor's `screendump` command forces that update and
saves the screen to a file, so the example runs QEMU with a monitor socket and
a small script that keeps sending `screendump`:

```bash
qemu-system-xtensa -nographic -machine esp32s3 \
  -drive file=flash.bin,if=mtd,format=raw \
  -monitor unix:/tmp/qemu-mon.sock,server,nowait -serial file:qemu.log
```

This also yields screenshots of exactly the frames you want. The player prints
`SHOT n` after drawing frame `n` and pauses, and the script saves a
`screendump` at that moment. Note that `-monitor` takes the serial console off
standard output, hence `-serial file:`.

**An odd-width virtual panel never refreshes.** QEMU builds its 16-bit screen
with a row stride of width x 2 bytes. At 135 pixels (270 bytes per row) the
virtual panel never refreshed, and `draw_bitmap` hung again; at 136 it worked.
For the 135x240 test, the player gives the virtual panel one spare column and
still draws 135-pixel rows. A real 135-pixel panel has no such
limit; this is purely an emulator detail.

### Checking the frames

For three frames (the first, a Mandelbrot frame and the last, a `testsrc2`
frame), the player prints its decoded pixels over the serial port, and
`compare_frames.py` compares them with FFmpeg's decode of the same JPEG,
reduced to RGB565 the same way:

| Panel   | Frame 0 | Frame 75 | Frame 149 |
| ------- | ------- | -------- | --------- |
| 320x240 | 39.2 dB | 38.2 dB  | 46.0 dB   |
| 135x240 | 38.7 dB | 37.6 dB  | 47.0 dB   |

These are PSNR values between two decoders of the same file. They differ in
rounding, so they don't match exactly, but in all six frames every color
channel of every pixel is within one RGB565 step of FFmpeg's decode. In every case the QEMU screen capture was
identical to the decoded pixels, byte for byte, and all 150 frames played on
both panels.

{{< figure src="img/qemu-frames-320x240.webp" alt="Fig. 2 - Frames 75 and 149 of the test clip on QEMU's virtual 320x240 panel, saved with the monitor's screendump command" >}}

What QEMU can't tell you is speed: the emulator runs at its own pace, so every
frame counted as late there. Measure decode time on your board with the same
player, and pick the quality and frame rate from that.

## Conclusion

FFmpeg does most of the work here, and a few flags decide whether the result
fits the panel and the flash: scale and crop to the exact panel size, drop the
frame rate early, pick `-q:v` from a size table rather than by eye, and keep to
4:2:0. Odd panel sizes need one extra pixel and a few lines of C. Running the
player in QEMU, with the screen captured and compared against FFmpeg, catches
mistakes in all of those steps before any hardware is involved.

The complete code is below: the packer, the player, the QEMU runner and the
comparison script, as they ran for this article.

## Full listings

<details><summary>The test footage (<code>make_source.sh</code>)</summary>

```bash
#!/bin/sh
# 10 s of test footage from ffmpeg's own sources: 6 s of a Mandelbrot zoom
# (fine detail, hard to compress) and 4 s of testsrc2 (flat colours and sharp
# edges, like UI graphics). 1280x720 at 30 fps, so there is something to scale.
set -eu
ffmpeg -v error -y \
  -f lavfi -i "mandelbrot=s=1280x720:rate=30:end_scale=0.002:end_pts=180,trim=duration=6" \
  -f lavfi -i "testsrc2=s=1280x720:r=30:d=4" \
  -filter_complex "[0][1]concat=n=2:v=1:a=0,format=yuv420p" \
  -c:v libx264 -crf 12 -preset fast "${1:-source.mp4}"
```

</details>

<details><summary>The packer (<code>pack_video.py</code>)</summary>

```python
#!/usr/bin/env python3
"""Turn a video into an MJPEG partition image for an ESP32 display.

  pack_video.py input.mp4 video.bin --size 320x240 --fps 15 --quality 5

The image is a small header, a frame index and the JPEG frames, laid out so the
firmware can memory-map the partition and decode frames in place. With 4:2:0
chroma, FFmpeg can only make even widths and heights (it silently rounds an odd
crop down), so frames for a 135x240 panel are encoded at 136x240 and the
firmware drops the extra column:

  offset 0   char[4]  "MJV1"
         4   u16      panel width
         6   u16      panel height
         8   u16      fps numerator
        10   u16      fps denominator
        12   u32      frame count (N)
        16   N x {u32 offset, u32 size}   offsets from the start of the image
             JPEG frames, each starting on a 4-byte boundary
"""
import argparse
import struct
import subprocess
import sys
from fractions import Fraction
from pathlib import Path

HEADER = struct.Struct("<4sHHHHI")
ENTRY = struct.Struct("<II")


def split_jpegs(data):
    """Split a concatenated MJPEG stream into frames by walking JPEG markers.

    Searching for FF D8 is not enough: the same bytes can appear inside an
    APPn or COM segment. Segment lengths are followed until the start of scan,
    then the entropy-coded data is skipped to the EOI marker (inside it, a real
    FF byte is always followed by 00 or a restart marker)."""
    frames, pos = [], 0
    while pos < len(data):
        if data[pos:pos + 2] != b"\xff\xd8":
            sys.exit(f"no SOI marker at byte {pos}")
        start, pos = pos, pos + 2
        while True:
            marker = data[pos + 1]
            if marker in (0xD8, 0x01) or 0xD0 <= marker <= 0xD7:
                pos += 2
                continue
            length = struct.unpack_from(">H", data, pos + 2)[0]
            pos += 2 + length
            if marker == 0xDA:  # start of scan: entropy-coded data follows
                while not (data[pos] == 0xFF and data[pos + 1] not in (0x00, *range(0xD0, 0xD8))):
                    pos += 1
                if data[pos + 1] == 0xD9:
                    pos += 2
                    break
            elif marker == 0xD9:
                break
        frames.append(data[start:pos])
    return frames


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("input", type=Path)
    ap.add_argument("output", type=Path)
    ap.add_argument("--size", default="320x240", help="panel size, WxH")
    ap.add_argument("--fps", type=Fraction, default=Fraction(15))
    ap.add_argument("--quality", type=int, default=5, help="ffmpeg -q:v, 2 (best) to 31")
    ap.add_argument("--chroma", choices=("420", "422", "444"), default="420", help="JPEG chroma subsampling")
    ap.add_argument("--frames-dir", type=Path, help="also write each frame as a .jpg here")
    a = ap.parse_args()
    w, h = map(int, a.size.split("x"))
    # 4:2:0 halves the chroma both ways and 4:2:2 horizontally, so those frame
    # sizes must be even; round up and let the firmware crop the extra pixel
    fw = w + (w & 1) if a.chroma in ("420", "422") else w
    fh = h + (h & 1) if a.chroma == "420" else h

    # Fill the frame (scale up until both sides cover it), then crop the middle
    vf = f"scale={fw}:{fh}:force_original_aspect_ratio=increase,crop={fw}:{fh},fps={a.fps}"
    mjpeg = subprocess.run(["ffmpeg", "-v", "error", "-i", str(a.input), "-vf", vf, "-an",
                            "-c:v", "mjpeg", "-q:v", str(a.quality), "-pix_fmt", f"yuv{a.chroma}p",
                            "-f", "mjpeg", "-"], capture_output=True, check=True).stdout
    frames = split_jpegs(mjpeg)
    sof = frames[0].index(b"\xff\xc0")
    jh, jw = struct.unpack_from(">HH", frames[0], sof + 5)
    if (jw, jh) != (fw, fh):
        sys.exit(f"ffmpeg made {jw}x{jh} frames, expected {fw}x{fh}")

    table_end = HEADER.size + ENTRY.size * len(frames)
    offset, entries, body = (table_end + 3) & ~3, [], bytearray()
    for f in frames:
        entries.append(ENTRY.pack(offset, len(f)))
        pad = (-len(f)) % 4
        body += f + b"\0" * pad
        offset += len(f) + pad
    image = (HEADER.pack(b"MJV1", w, h, a.fps.numerator, a.fps.denominator, len(frames))
             + b"".join(entries))
    image += b"\0" * ((-len(image)) % 4) + body
    a.output.write_bytes(image)
    if a.frames_dir:
        a.frames_dir.mkdir(parents=True, exist_ok=True)
        for i, f in enumerate(frames):
            (a.frames_dir / f"{i:04d}.jpg").write_bytes(f)
    sizes = sorted(len(f) for f in frames)
    print(f"{len(frames)} frames of {fw}x{fh} for a {w}x{h} panel at {float(a.fps):g} fps, q {a.quality}: {len(image)} bytes "
          f"(frames {sizes[0]}-{sizes[-1]} bytes, median {sizes[len(sizes) // 2]})")


if __name__ == "__main__":
    main()
```

</details>

<details><summary>The player (<code>main.c</code>)</summary>

```c
// Play an MJPEG partition image (see pack_video.py) on a display.
// Runs on the QEMU virtual RGB panel; on hardware, swap in your panel driver.
#include <stdio.h>
#include <string.h>
#include "esp_err.h"
#include "esp_log.h"
#include "esp_partition.h"
#include "esp_lcd_panel_ops.h"
#include "esp_lcd_qemu_rgb.h"
#include "esp_rom_crc.h"
#include "esp_timer.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_jpeg_dec.h"

static const char *TAG = "mjpeg";

typedef struct __attribute__((packed)) {
  char magic[4];  // "MJV1"
  uint16_t width, height;  // panel size; frames can be a pixel larger (see pack_video.py)
  uint16_t fps_num, fps_den;
  uint32_t count;
  struct { uint32_t offset, size; } frames[];
} video_t;

// Frames whose pixels are printed for checking on the host (QEMU test only)
#ifndef DUMP_FRAMES
#define DUMP_FRAMES {0, 75, 149}
#endif

static void dump(int index, const uint8_t *px, int len) {
  static const char b64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  printf("DUMP %d %d\n", index, len);
  char line[77];
  int n = 0;
  for (int i = 0; i < len; i += 3) {
    uint32_t v = px[i] << 16 | (i + 1 < len ? px[i + 1] << 8 : 0) | (i + 2 < len ? px[i + 2] : 0);
    line[n++] = b64[v >> 18 & 63];
    line[n++] = b64[v >> 12 & 63];
    line[n++] = i + 1 < len ? b64[v >> 6 & 63] : '=';
    line[n++] = i + 2 < len ? b64[v & 63] : '=';
    if (n == 76 || i + 3 >= len) {
      line[n] = 0;
      puts(line);
      n = 0;
    }
  }
  printf("END %d\n", index);
}

void app_main(void) {
  const esp_partition_t *part =
      esp_partition_find_first(ESP_PARTITION_TYPE_DATA, 0x40, "video");
  ESP_ERROR_CHECK(part ? ESP_OK : ESP_ERR_NOT_FOUND);
  const void *map;
  esp_partition_mmap_handle_t map_handle;
  ESP_ERROR_CHECK(esp_partition_mmap(part, 0, part->size, ESP_PARTITION_MMAP_DATA, &map, &map_handle));
  const video_t *v = map;
  if (memcmp(v->magic, "MJV1", 4) != 0) {
    ESP_LOGE(TAG, "no video in the partition");
    return;
  }
  ESP_LOGI(TAG, "%u frames, %ux%u at %u/%u fps", (unsigned)v->count, v->width, v->height, v->fps_num, v->fps_den);

  esp_lcd_panel_handle_t panel;
  // QEMU builds its 16-bit screen with a stride of width * 2 bytes, which its
  // pixel library needs to be a multiple of 4, so give an odd-width panel one
  // more (unused) column. Frames are still drawn v->width wide.
  esp_lcd_rgb_qemu_config_t panel_config = {
      .width = v->width + (v->width & 1), .height = v->height, .bpp = RGB_QEMU_BPP_16};
  ESP_ERROR_CHECK(esp_lcd_new_rgb_qemu(&panel_config, &panel));
  ESP_ERROR_CHECK(esp_lcd_panel_reset(panel));
  ESP_ERROR_CHECK(esp_lcd_panel_init(panel));

  // QEMU's panel takes little-endian RGB565. Most SPI panels want big-endian
  // (JPEG_PIXEL_FORMAT_RGB565_BE), or colors come out with the bytes swapped.
  jpeg_dec_config_t config = DEFAULT_JPEG_DEC_CONFIG();
  config.output_type = JPEG_PIXEL_FORMAT_RGB565_LE;
  jpeg_dec_handle_t dec;
  if (jpeg_dec_open(&config, &dec) != JPEG_ERR_OK) {
    ESP_LOGE(TAG, "jpeg_dec_open failed");
    return;
  }
  // Room for a frame one pixel wider and taller than the panel
  int frame_bytes = (v->width + 1) * (v->height + 1) * 2;
  int panel_bytes = v->width * v->height * 2;
  uint8_t *pixels = jpeg_calloc_align(frame_bytes, 16);  // the decoder needs 16-byte alignment
  const int dump_list[] = DUMP_FRAMES;

  int64_t period_us = 1000000LL * v->fps_den / v->fps_num;
  int64_t next = esp_timer_get_time();
  int shown = 0, late = 0;
  for (uint32_t i = 0; i < v->count; i++) {
    jpeg_dec_io_t io = {
        .inbuf = (uint8_t *)map + v->frames[i].offset,
        .inbuf_len = v->frames[i].size,
        .outbuf = pixels,
    };
    jpeg_dec_header_info_t info;
    jpeg_error_t err = jpeg_dec_parse_header(dec, &io, &info);
    if (err == JPEG_ERR_OK && (info.width < v->width || info.height < v->height ||
                               info.width * info.height * 2 > frame_bytes)) {
      err = JPEG_ERR_INVALID_PARAM;
    }
    if (err == JPEG_ERR_OK) {
      err = jpeg_dec_process(dec, &io);
    }
    if (err != JPEG_ERR_OK) {
      ESP_LOGE(TAG, "frame %u: error %d", (unsigned)i, err);
      continue;
    }
    if (info.width > v->width) {
      // Frame is wider than the panel (odd panel width, even frame width):
      // pack the rows tightly, dropping the extra column
      for (int row = 1; row < v->height; row++) {
        memmove(pixels + row * v->width * 2, pixels + row * info.width * 2, v->width * 2);
      }
    }
    ESP_ERROR_CHECK(esp_lcd_panel_draw_bitmap(panel, 0, 0, v->width, v->height, pixels));
    shown++;
    printf("FRAME %u crc %08lx\n", (unsigned)i, (unsigned long)esp_rom_crc32_le(0, pixels, panel_bytes));
    for (int d = 0; d < sizeof dump_list / sizeof dump_list[0]; d++) {
      if (dump_list[d] == (int)i) {
        dump(i, pixels, panel_bytes);
        printf("SHOT %u\n", (unsigned)i);  // the QEMU test captures the screen now
        vTaskDelay(pdMS_TO_TICKS(500));
      }
    }
    // Hold each frame for one period; if decoding fell behind, don't wait
    next += period_us;
    int64_t wait = next - esp_timer_get_time();
    if (wait > 0) {
      vTaskDelay(pdMS_TO_TICKS(wait / 1000));
    } else {
      late++;
    }
  }
  ESP_LOGI(TAG, "DONE %d of %u frames shown, %d late", shown, (unsigned)v->count, late);
  jpeg_dec_close(dec);
  jpeg_free_align(pixels);
  esp_partition_munmap(map_handle);
}
```

</details>

<details><summary>Project CMakeLists.txt (<code>CMakeLists.txt</code>)</summary>

```cmake
cmake_minimum_required(VERSION 3.22)
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
idf_build_set_property(MINIMAL_BUILD ON)
project(mjpeg_player)
```

</details>

<details><summary>main/CMakeLists.txt (<code>CMakeLists.txt</code>)</summary>

```cmake
idf_component_register(SRCS "main.c" PRIV_REQUIRES esp_lcd esp_partition esp_timer)
```

</details>
<details><summary>partitions.csv (<code>partitions.csv</code>)</summary>

```csv
# Name,   Type, SubType, Offset,   Size
nvs,      data, nvs,     0x9000,   0x6000
factory,  app,  factory, 0x10000,  0xF0000
video,    data, 0x40,    0x100000, 0x300000
```

</details>

<details><summary>main/idf_component.yml (<code>idf_component.yml</code>)</summary>

```yaml
dependencies:
  espressif/esp_new_jpeg: "^1.0.0"
  espressif/esp_lcd_qemu_rgb: "^1.0.2"
```

</details>

<details><summary>sdkconfig.defaults (<code>sdkconfig.defaults</code>)</summary>

```text
CONFIG_IDF_TARGET="esp32s3"
CONFIG_ESPTOOLPY_FLASHSIZE_4MB=y
CONFIG_PARTITION_TABLE_CUSTOM=y
CONFIG_PARTITION_TABLE_CUSTOM_FILENAME="partitions.csv"
```

</details>

<details><summary>Running it in QEMU (<code>run_qemu.sh</code>)</summary>

```bash
#!/bin/sh
# Build, merge the flash image with the video partition, run in QEMU until DONE.
#   ./run_qemu.sh [timeout_s]   (inside the espressif/idf container, from example/)
set -eu
t=${1:-600}
cd mjpeg_player && idf.py build > /tmp/build.log 2>&1 || { tail -20 /tmp/build.log; exit 1; }
cd build && python -m esptool --chip esp32s3 merge-bin --fill-flash-size 4MB -o ../../flash.bin @flash_args 0x100000 ../../video.bin > /dev/null
cd ../..
rm -rf qemu.log screen && mkdir -p screen
qemu-system-xtensa -nographic -machine esp32s3 -drive file=flash.bin,if=mtd,format=raw \
  -monitor unix:/tmp/qemu-mon.sock,server,nowait -serial file:qemu.log > /dev/null 2>&1 &
pid=$!
python3 qemu_screen.py /tmp/qemu-mon.sock qemu.log screen --timeout "$t"
kill $pid 2>/dev/null || true
```

</details>

<details><summary>Keeping the QEMU panel refreshing (<code>qemu_screen.py</code>)</summary>

```python
#!/usr/bin/env python3
"""Keep QEMU's virtual RGB panel refreshing while running headless, and save its screen.

The esp_lcd_qemu_rgb driver's draw_bitmap waits until QEMU's display picks the
frame up, which never happens without a display. A monitor `screendump` forces
that update and writes the screen to a file, so this sends one every --every
seconds until the firmware prints DONE.
  qemu_screen.py MONITOR_SOCKET SERIAL_LOG OUT_DIR [--every 0.05] [--timeout 600]
"""
import argparse, re, socket, time
from pathlib import Path

ap = argparse.ArgumentParser()
ap.add_argument("sock"); ap.add_argument("log", type=Path); ap.add_argument("out", type=Path)
ap.add_argument("--every", type=float, default=0.05); ap.add_argument("--timeout", type=float, default=600)
a = ap.parse_args()
a.out.mkdir(parents=True, exist_ok=True)
for _ in range(100):
    try:
        s = socket.socket(socket.AF_UNIX); s.connect(a.sock); break
    except OSError:
        time.sleep(0.1)
s.settimeout(5)
s.recv(4096)  # banner
def dump(path):
    s.sendall(f"screendump {path}\n".encode())
    time.sleep(a.every)
    try:
        s.recv(65536)
    except socket.timeout:
        pass


# The firmware prints "SHOT n" after drawing frame n and then pauses, so a
# screendump taken then shows exactly frame n
start, n, saved = time.time(), 0, set()
while time.time() - start < a.timeout:
    dump("/tmp/refresh.ppm")
    n += 1
    log = a.log.read_text(errors="replace") if a.log.exists() else ""
    for shot in re.findall(r"^SHOT (\d+)", log, re.M):
        if shot not in saved:
            dump(f"{a.out}/frame-{int(shot):04d}.ppm")
            saved.add(shot)
    if "DONE" in log:
        break
print(f"{n} refreshes, {len(saved)} frames saved, {time.time() - start:.0f} s")
```

</details>

<details><summary>Comparing the frames (<code>compare_frames.py</code>)</summary>

```python
#!/usr/bin/env python3
"""Check the frames the firmware decoded against ffmpeg's decode of the same JPEGs.

  compare_frames.py qemu.log frames/ [screen/] [--panel=WxH]

qemu.log holds the firmware's DUMP blocks (base64 RGB565 little-endian), frames/
the .jpg files pack_video.py wrote, and screen/ the QEMU screen captures.
"""
import base64
import math
import re
import subprocess
import sys
from pathlib import Path


def rgb565_to_rgb888(px):
    out = bytearray()
    for i in range(0, len(px), 2):
        v = px[i] | px[i + 1] << 8
        r, g, b = v >> 11, v >> 5 & 63, v & 31
        out += bytes((r << 3 | r >> 2, g << 2 | g >> 4, b << 3 | b >> 2))
    return bytes(out)


def ffmpeg_rgb565(jpg, panel):
    """ffmpeg's decode of one JPEG, cropped to the panel and reduced to RGB565 the
    plain way (dropping low bits, no dithering), then expanded back to RGB888."""
    # Convert to RGB inside the filter chain, before the crop: on 4:2:0 frames,
    # ffmpeg's crop rounds an odd width down
    vf = "format=rgb24" + (f",crop={panel.replace('x', ':')}:0:0" if panel else "")
    rgb = subprocess.run(["ffmpeg", "-v", "error", "-i", str(jpg), "-vf", vf,
                          "-f", "rawvideo", "-pix_fmt", "rgb24", "-"], capture_output=True, check=True).stdout
    px = bytearray()
    for i in range(0, len(rgb), 3):
        v = (rgb[i] >> 3) << 11 | (rgb[i + 1] >> 2) << 5 | rgb[i + 2] >> 3
        px += bytes((v & 255, v >> 8))
    return rgb565_to_rgb888(px)


def psnr(a, b):
    mse = sum((x - y) ** 2 for x, y in zip(a, b)) / len(a)
    return float("inf") if mse == 0 else 10 * math.log10(255 ** 2 / mse)


def ppm_pixels(path):
    data = path.read_bytes()
    parts = data.split(maxsplit=4)  # P6, width, height, maxval, pixels
    return parts[4] if parts[0] == b"P6" else None


args = [x for x in sys.argv[1:] if not x.startswith("--panel")]
panel = next((x.split("=", 1)[1] for x in sys.argv[1:] if x.startswith("--panel=")), None)
log = Path(args[0]).read_text(errors="replace")
frames = Path(args[1])
screen = Path(args[2]) if len(args) > 2 else None
dumps = re.findall(r"^DUMP (\d+) (\d+)\n(.*?)^END \1$", log, re.M | re.S)
if not dumps:
    sys.exit("no DUMP blocks in the log")
for idx, size, body in dumps:
    px = base64.b64decode("".join(body.split()))
    assert len(px) == int(size), (len(px), size)
    ours = rgb565_to_rgb888(px)
    ref = ffmpeg_rgb565(frames / f"{int(idx):04d}.jpg", panel)
    line = f"frame {idx}: esp_new_jpeg vs ffmpeg {psnr(ours, ref):.1f} dB PSNR"
    if screen and (screen / f"frame-{int(idx):04d}.ppm").exists():
        shot = ppm_pixels(screen / f"frame-{int(idx):04d}.ppm")
        if panel and len(shot) != len(ours):
            # QEMU's screen can be a column wider than the panel; keep the panel's part
            pw, ph = map(int, panel.split("x"))
            sw = len(shot) // 3 // ph
            shot = b"".join(shot[r * sw * 3:(r * sw + pw) * 3] for r in range(ph))
        same = sum(1 for x, y in zip(ours, shot) if x != y)
        line += f"; QEMU screen vs decoded: {'identical' if same == 0 else f'{same} bytes differ'}"
    print(line)
```

</details>
