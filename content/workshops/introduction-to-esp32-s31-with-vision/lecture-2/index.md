---
title: "Introduction to the ESP32-S31 with Vision: Lecture 2"
date: 2026-09-28
showTableOfContents: true
series: ["ESP32-S31-VISION"]
series_order: 8
showAuthor: false
---

## Lecture 2: Available models for ESP-Vision

ESP-Vision uses the [ESP-DL](https://github.com/espressif/esp-dl) `.espdl` format for optimized neural networks. A model file contains a quantized graph, parameters, and metadata that ESP-DL can load on the device.

Models do not all solve the same problem:

- **Classification** answers "what is in this image?"
- **Object detection** answers "what is present, and where is it?"
- **Pose estimation** returns semantic keypoints such as shoulders, elbows, and knees
- **Segmentation** labels pixels or object masks

The final workshop application needs the location of each hand, so it uses object detection.

## Object detection models

ESP-Vision supports dedicated wrappers for two detector families:

| Family | Typical use | Characteristics |
|--------|-------------|-----------------|
| ESPDet Pico | Face, hand, cat, dog, hardhat, or another small custom class set | Small model, fixed task, suitable for responsive embedded applications |
| YOLO11 | General COCO object detection | Detects many classes but needs more memory and inference time |

Common ESPDet Pico models in the ESP-Vision model collection include:

| Model | Task | Input |
|-------|------|-------|
| ESPDet Pico Face | Face detection | 224 × 224 RGB |
| ESPDet Pico Hand | Hand detection | 224 × 224 RGB |
| ESPDet Pico Cat | Cat detection | 224 × 224 RGB |
| ESPDet Pico Dog | Dog detection | 224 × 224 RGB |
| ESPDet Pico Cat & Dog | Two-class animal detection | 224 × 224 RGB |
| ESPDet Pico Hardhat | Safety-helmet detection | 320 × 320 RGB |

YOLO11n COCO detects [80 everyday object categories](https://docs.ultralytics.com/datasets/detect/coco/#dataset-yaml), including person, bottle, chair, laptop, and cell phone. The linked COCO dataset definition lists every category. It is useful when the application needs broad coverage, but using it only to locate hands would waste compute and does not provide a hand class.

## Classification, pose, and other models

ESP-Vision also provides examples for:

- **Image classification:** the current public model catalog includes a TensorFlow Lite Micro person-presence classifier
- **YOLO11n Pose:** detects people and returns 17 COCO body keypoints
- **TensorFlow Lite Micro:** runs compatible `.tflite` models through the `tflite` module
- **Generic ESP-DL graphs:** exposes raw tensor inputs and outputs when a model-specific Python decoder is needed

The presence of an API does not guarantee that every model fits every board. Check the model's target, memory use, input size, and operator support before choosing it.

## ESP-Vision model APIs

| API | Use |
|-----|-----|
| `espdl.ESPDet(path, score=..., nms=...)` | Run an ESPDet object detector |
| `espdl.YOLO11(path, score=..., nms=..., topk=...)` | Run YOLO11 object detection |
| `espdl.YOLO11nPose(path, score=..., nms=..., topk=...)` | Run YOLO11 pose estimation |
| `espdl.Model(path, mean=..., std=..., letterbox=...)` | Run a generic model and receive raw tensors |
| `espdl.load_model(path, profile=False)` | Preload a model file |

The task-specific wrappers perform preprocessing and decode model output. For example:

```python
detector = espdl.ESPDet(
    "/sdcard/espdet_pico_224_224_hand.espdl",
    score=0.5,
    nms=0.7,
)

results = detector.detect(frame)
```

Each ESPDet result is:

```text
(x, y, width, height, score, category)
```

### Score and NMS thresholds

The `score` and `nms` arguments control which candidate detections are returned:

| Parameter | Purpose | Effect of increasing it |
|-----------|---------|-------------------------|
| `score` | Minimum confidence score accepted from the model | Returns fewer detections and reduces weak false positives, but may miss difficult objects |
| `nms` | Intersection over union (IoU) threshold used by non-maximum suppression | Keeps more overlapping boxes; a lower value suppresses overlaps more aggressively |

The confidence score indicates how strongly a detection matches a learned category. It is useful for ranking and filtering results, but it should not be interpreted as a precisely calibrated probability. With `score=0.5`, detections below 0.5 are discarded.

A detector often proposes several boxes around the same object. **Non-maximum suppression (NMS)** keeps the highest-scoring box and compares it with competing boxes. IoU measures their overlap:

```text
IoU = intersection area / union area
```

With `nms=0.7`, a lower-scoring box is suppressed when its IoU with the selected box exceeds 0.7. Lowering the NMS threshold removes more overlapping boxes, while raising it can preserve nearby objects but may leave duplicate detections.

The values `score=0.5` and `nms=0.7` are starting points, not universal settings. Test them with the actual camera position, lighting, backgrounds, hand sizes, and number of simultaneous hands:

- Lower `score` if real hands are frequently missed.
- Raise `score` if background objects are frequently reported as hands.
- Lower `nms` if one hand receives several overlapping boxes.
- Raise `nms` if boxes for two nearby hands suppress each other.

`espdl.Model` is lower-level. Its `predict()` method returns named raw tensors, so the application must implement model-specific box decoding and non-maximum suppression.

## Choosing a model

Consider these factors:

| Factor | Question |
|--------|----------|
| Task | Does the model return a class, box, keypoint, or mask? |
| Classes | Does its training set contain the object you need? |
| Input size | Can the camera pipeline produce or resize to this input efficiently? |
| Latency | How often must the application make a decision? |
| Accuracy | What false positive and false negative rates are acceptable? |
| Memory | Do model parameters, activations, camera frames, and display buffers fit together? |
| Storage | Will the model live in flash, a model partition, or on microSD? |
| Target | Was the `.espdl` file exported for ESP32-S31? |

For the safety-zone application:

- The task is hand localization, not gesture classification.
- One class is sufficient.
- A 224 × 224 ESPDet Pico model has a better size/speed trade-off than a general detector.
- A confidence threshold of 0.5 is a reasonable starting point, but it must be evaluated in the real scene.

## Model storage and loading

The remaining assignments expect:

```text
/sdcard/espdet_pico_224_224_hand.espdl
```

Copy the ESP32-S31-compatible hand model from the ESP-Vision model collection to the root of the FAT32 microSD card. Keep the filename unchanged so the examples match.

Create the detector once, outside the frame loop:

```python
detector = espdl.ESPDet(MODEL_PATH, score=0.5, nms=0.7)
```

Release it when the application stops:

```python
try:
    # Capture and inference loop
    pass
finally:
    detector.deinit()
```

Repeatedly constructing a detector inside the loop increases latency and can fragment memory.

> [!IMPORTANT]
> `.espdl` files can be target-specific. Use a model distributed for ESP32-S31 or export it with the ESP32-S31 target. Do not assume that a file built for another SoC produces correct results.

## What you learned

In this lecture, you learned:

- The differences between classification, detection, pose, and segmentation
- When to choose ESPDet Pico instead of a general YOLO model
- Which ESP-Vision classes load common ESP-DL models
- How model input, latency, memory, storage, and target affect selection
- Why the hand-detection model is appropriate for the final application

## Next step

[Assignment 6: Hand detection with ESPDet](../assignment-6)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-with-vision/)
