---
title: "Introduction to the ESP32-S31 with Vision: Assignment 7"
date: 2026-09-28
showTableOfContents: true
series: ["ESP32-S31-VISION"]
series_order: 10
showAuthor: false
---

## Assignment 7: Add a safety zone

A safety zone is a region in the camera image that a detected hand should not enter. It could represent a cutting area, a hot surface, a robot workspace, or a protected control panel.

In this assignment, you will extend the hand detector from Assignment 6 with a simple centroid tracker and a rectangular safety zone. The application calculates how much of each tracked hand overlaps the zone. The hand box, zone, and warning text turn red when the overlap exceeds a threshold.

> [!TIP]
> Continue with the ESP-Vision Web IDE, or use the ESP-Vision extension for [Visual Studio Code](https://code.visualstudio.com/) available from the [ESP-Vision website](https://vision.espressif.com/en) to edit and run `safety_zone.py`. The IDE manages the script and logs; `lcd.write(frame)` renders the annotated image on the board LCD.

## Regions of interest

An image rectangle is represented as `(x, y, width, height)`, where `(x, y)` is its top-left corner. The origin `(0, 0)` is at the top left of the image.

Hardcoded pixels work only at one frame size. Define the zone as a fraction of the frame instead:

```text
left   = 60% of frame width
top    = 15% of frame height
width  = 30% of frame width
height = 70% of frame height
```

This places a vertical protected region on the right side and scales it when the frame resolution changes.

Two rectangles overlap when their intersection has positive width and height:

```text
intersection_left   = max(hand_left, zone_left)
intersection_top    = max(hand_top, zone_top)
intersection_right  = min(hand_right, zone_right)
intersection_bottom = min(hand_bottom, zone_bottom)
```

This workshop divides the intersection area by the detected hand-box area. Requiring 15% overlap is more stable than triggering on a single boundary pixel.

## Step 1: Define the safety zone

Copy `hand_detection.py` from Assignment 6 to a new file named `safety_zone.py`. Add these constants:

```python
ZONE_X = 0.60
ZONE_Y = 0.15
ZONE_WIDTH = 0.30
ZONE_HEIGHT = 0.70
MIN_OVERLAP = 0.15
```

Add a function that converts the normalized values to pixels:

```python
def make_zone(frame):
    return (
        int(frame.width() * ZONE_X),
        int(frame.height() * ZONE_Y),
        int(frame.width() * ZONE_WIDTH),
        int(frame.height() * ZONE_HEIGHT),
    )
```

Draw the zone after capturing a frame:

```python
zone = make_zone(frame)
zx, zy, zw, zh = zone
frame.draw_rectangle(
    zx, zy, zw, zh, color=(0, 255, 0), thickness=3)
```

## Step 2: Detect an intrusion

Add the overlap calculation:

```python
def overlap_ratio(hand, zone):
    hx, hy, hw, hh, score, category = hand
    zx, zy, zw, zh = zone

    left = max(hx, zx)
    top = max(hy, zy)
    right = min(hx + hw, zx + zw)
    bottom = min(hy + hh, zy + zh)

    intersection_width = max(0, right - left)
    intersection_height = max(0, bottom - top)
    intersection = intersection_width * intersection_height
    hand_area = max(1, hw * hh)
    return intersection / hand_area
```

For every detection:

```python
ratio = overlap_ratio(detection, zone)
inside = ratio >= MIN_OVERLAP
```

Using the hand box as the denominator answers: "How much of this detected hand is inside the zone?" A different application might divide by the zone area or use intersection over union.

## Step 3: Add centroid tracking

The detector returns independent results for every frame. Add a small tracker so the application can associate nearby detections over time:

```python
MAX_DISTANCE_SQ = 80 * 80
MAX_MISSED = 3


def center(detection):
    x, y, w, h, score, category = detection
    return x + w // 2, y + h // 2


def update_tracks(detections, tracks, next_id):
    updated = {}
    used_ids = set()
    output = []

    for detection in detections:
        cx, cy = center(detection)
        best_id = None
        best_distance = MAX_DISTANCE_SQ + 1

        for track_id, state in tracks.items():
            if track_id in used_ids:
                continue
            previous_x, previous_y, missed = state
            dx = cx - previous_x
            dy = cy - previous_y
            distance = dx * dx + dy * dy
            if distance < best_distance:
                best_id = track_id
                best_distance = distance

        if best_id is None or best_distance > MAX_DISTANCE_SQ:
            best_id = next_id
            next_id += 1

        used_ids.add(best_id)
        updated[best_id] = (cx, cy, 0)
        output.append((best_id, detection))

    for track_id, state in tracks.items():
        if track_id in used_ids:
            continue
        previous_x, previous_y, missed = state
        if missed < MAX_MISSED:
            updated[track_id] = (
                previous_x, previous_y, missed + 1)

    return output, updated, next_id
```

Initialize the tracker once before the frame loop:

```python
tracks = {}
next_id = 1
```

After detecting hands in each frame, update the tracks:

```python
detections = detector.detect(frame)
tracked, tracks, next_id = update_tracks(
    detections, tracks, next_id)
```

The tracker compares squared distances between bounding-box centers. A detection keeps an existing ID when its nearest unused track is within 80 pixels. `MAX_MISSED` retains a track for up to three missed frames. This lightweight method is suitable for the exercise, but IDs can change when hands move quickly, overlap, or cross.

## Step 4: Combine the zone with tracking

Replace the drawing section from Assignment 6 with:

```python
intrusion_ids = []

for track_id, detection in tracked:
    x, y, w, h, score, category = detection
    ratio = overlap_ratio(detection, zone)
    inside = ratio >= MIN_OVERLAP
    color = (255, 0, 0) if inside else (0, 255, 0)

    if inside:
        intrusion_ids.append(track_id)

    frame.draw_rectangle(
        x, y, w, h, color=color, thickness=2)
    frame.draw_string(
        x, max(0, y - 12),
        "hand %d %.0f%%" % (track_id, ratio * 100),
        color=color)

zone_color = (255, 0, 0) if intrusion_ids else (0, 255, 0)
zx, zy, zw, zh = zone
frame.draw_rectangle(
    zx, zy, zw, zh, color=zone_color, thickness=3)

frame.draw_string(
    8, 8,
    "KEEP HANDS OFF!" if intrusion_ids else "ZONE CLEAR",
    color=zone_color)
```

The track ID in the label makes it possible to see which hand caused an intrusion when multiple hands are visible.

## Step 5: Run and test the safety zone

{{< tabs group="esp-vision-ide" >}}
  {{< tab label="Web IDE" >}}

1. Connect the ESP-Vision Web IDE to the board.
2. Create `safety_zone.py`.
3. Paste the complete code and save it to the device.
4. Select **Run**.
5. Observe the safety zone, hand boxes, and labels on the board LCD.

  {{< /tab >}}
  {{< tab label="Visual Studio Code" >}}

1. Connect with **ESP-VISION: Connect**.
2. Create and open `safety_zone.py`.
3. Paste and save the complete code.
4. Run **ESP-VISION: Run Current File**.
5. Observe the safety zone, hand boxes, and labels on the board LCD.

  {{< /tab >}}
{{< /tabs >}}

Run these tests:

| Scenario | Expected result |
|----------|-----------------|
| No hand | Green zone |
| Hand outside zone | Green hand box and green zone |
| Less than 15% hand overlap | No warning |
| At least 15% hand overlap | Red hand box, red zone, and warning text |
| Two hands, one inside | Only the intruding box is red; zone is red |
| Intruding hand disappears | Warning clears on the next processed result |

Move the camera or change its resolution and confirm that the normalized zone remains on the right side.

### Tune the threshold

Try `MIN_OVERLAP` values of 0.05, 0.15, and 0.50.

- A low value reacts early but is sensitive near the border.
- A high value waits until most of the hand is inside.
- The correct value depends on camera placement and the cost of a missed warning.

This geometric check cannot determine real-world depth. A hand can appear inside the 2D region while physically being in front of or behind the protected object. A safety-certified product requires a risk assessment and appropriate sensors and controls.

## Complete working code

<details><summary>Show the complete safety_zone.py</summary>

```python
import display
import espdl
import sensor
import time


MODEL = "/sdcard/espdet_pico_224_224_hand.espdl"
SCORE = 0.5
NMS = 0.7

ZONE_X = 0.60
ZONE_Y = 0.15
ZONE_WIDTH = 0.30
ZONE_HEIGHT = 0.70
MIN_OVERLAP = 0.15

MAX_DISTANCE_SQ = 80 * 80
MAX_MISSED = 3


def make_zone(frame):
    return (
        int(frame.width() * ZONE_X),
        int(frame.height() * ZONE_Y),
        int(frame.width() * ZONE_WIDTH),
        int(frame.height() * ZONE_HEIGHT),
    )


def center(detection):
    x, y, w, h, score, category = detection
    return x + w // 2, y + h // 2


def update_tracks(detections, tracks, next_id):
    updated = {}
    used_ids = set()
    output = []

    for detection in detections:
        cx, cy = center(detection)
        best_id = None
        best_distance = MAX_DISTANCE_SQ + 1

        for track_id, state in tracks.items():
            if track_id in used_ids:
                continue
            previous_x, previous_y, missed = state
            dx = cx - previous_x
            dy = cy - previous_y
            distance = dx * dx + dy * dy
            if distance < best_distance:
                best_id = track_id
                best_distance = distance

        if best_id is None or best_distance > MAX_DISTANCE_SQ:
            best_id = next_id
            next_id += 1

        used_ids.add(best_id)
        updated[best_id] = (cx, cy, 0)
        output.append((best_id, detection))

    for track_id, state in tracks.items():
        if track_id in used_ids:
            continue
        previous_x, previous_y, missed = state
        if missed < MAX_MISSED:
            updated[track_id] = (
                previous_x, previous_y, missed + 1)

    return output, updated, next_id


def overlap_ratio(hand, zone):
    hx, hy, hw, hh, score, category = hand
    zx, zy, zw, zh = zone

    left = max(hx, zx)
    top = max(hy, zy)
    right = min(hx + hw, zx + zw)
    bottom = min(hy + hh, zy + zh)

    intersection_width = max(0, right - left)
    intersection_height = max(0, bottom - top)
    intersection = intersection_width * intersection_height
    hand_area = max(1, hw * hh)
    return intersection / hand_area


def main():
    detector = None
    lcd = None
    tracks = {}
    next_id = 1

    sensor.reset()
    try:
        lcd = display.Display()
        sensor.set_pixformat(sensor.RGB565)
        sensor.set_framesize(sensor.QVGA)
        sensor.skip_frames(time=1000)
        detector = espdl.ESPDet(MODEL, score=SCORE, nms=NMS)

        while True:
            frame = sensor.snapshot()
            zone = make_zone(frame)
            detections = detector.detect(frame)
            tracked, tracks, next_id = update_tracks(
                detections, tracks, next_id)

            intrusion_ids = []
            for track_id, detection in tracked:
                x, y, w, h, score, category = detection
                ratio = overlap_ratio(detection, zone)
                inside = ratio >= MIN_OVERLAP
                color = (255, 0, 0) if inside else (0, 255, 0)

                if inside:
                    intrusion_ids.append(track_id)

                frame.draw_rectangle(
                    x, y, w, h, color=color, thickness=2)
                frame.draw_string(
                    x, max(0, y - 12),
                    "hand %d %.0f%%" % (track_id, ratio * 100),
                    color=color)

            zone_color = (
                (255, 0, 0) if intrusion_ids else (0, 255, 0))
            zx, zy, zw, zh = zone
            frame.draw_rectangle(
                zx, zy, zw, zh, color=zone_color, thickness=3)

            frame.draw_string(
                8, 8,
                "KEEP HANDS OFF!" if intrusion_ids else "ZONE CLEAR",
                color=zone_color)

            lcd.write(frame)
            time.sleep_ms(20)
    finally:
        if detector is not None:
            detector.deinit()
        sensor.shutdown()
        if lcd is not None:
            lcd.deinit()


main()

```

</details>

## What you will see

- A live 320 × 240 camera image on the ESP32-S31-Korvo-1 LCD
- A vertical safety zone on the right side of the image
- A stable numeric ID and overlap percentage for each tracked hand
- Green hand boxes and a green zone while no intrusion is detected
- A `ZONE CLEAR` message while all detected hands remain outside the zone
- A red hand box, red zone, and `KEEP HANDS OFF!` warning when overlap reaches 15%

### Expected output

{{< figure
    src="assets/zone-clear.webp"
    alt="LCD camera image showing a green safety zone, green hand box, and ZONE CLEAR message"
    caption="Zone clear: the detected hand remains outside the protected area."
>}}

{{< figure
    src="assets/zone-danger.webp"
    alt="LCD camera image showing a red safety zone, red hand box, and KEEP HANDS OFF warning"
    caption="Zone intrusion: the detected hand overlaps the protected area and triggers the warning."
>}}

## What you learned

In this assignment, you:

- Defined a resolution-independent region of interest
- Calculated rectangle intersection and hand-overlap ratio
- Added centroid-based tracking and persistent hand IDs
- Associated intrusion state with tracked hand IDs
- Added visual status through box, zone, and text colors
- Evaluated threshold and 2D-camera limitations

## Next step

[Assignment 8: Keep hands off!](../assignment-8)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-with-vision/)
