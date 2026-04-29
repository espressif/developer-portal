---
title: "Building FOFOCA: An Open-Source AI Robot with ESP32, ESP8266, and Edge AI"
date: 2026-04-30
tags:
  - ESP32
  - ESP8266
  - Robotics
  - MQTT
  - Bluetooth
  - Edge AI
  - PWM
showTableOfContents: true
authors:
  - fabio-bastos-thinkneo
summary: "FOFOCA is an open-source reference design for an AI-governed household robot, built around a Raspberry Pi 5 brain, an ESP32 for real-time motor control and sensor polling, and an ESP8266 driving an OLED status display over MQTT. This article walks through the hardware architecture, the firmware running on each Espressif chip, and how all of it connects to a local edge AI server running NVIDIA Nemotron Nano 8B for inference — no cloud dependency required."
---

## The Robot That Runs on Espressif

FOFOCA — *Fully Operational Feline-free Omniscient Companion Assistant* — is an open-source reference design for a household robot I have been developing as the first public study case for [ThinkNEO](https://thinkneo.ai), an AI governance platform. The reference design targets 24/7 operation in a residential environment: the architecture supports patrol routines, delivery reception, pet monitoring, voice command handling, and autonomous emergency calling — implemented end-to-end across the ESP32, Pi 5, and Dell R210 layers.

The project uses two Espressif chips in distinct roles. An **ESP32** handles all real-time physical control — driving the tank treads via PWM, polling ultrasonic and temperature sensors, and maintaining a Bluetooth serial link to the Raspberry Pi 5 brain. An **ESP8266** drives a 0.96-inch OLED panel that displays the robot's current state, active task, battery level, and which AI model is handling decisions at any given moment, all received over MQTT.

This article focuses on the Espressif side of the build: the firmware, the wiring, and the communication protocols that connect the microcontrollers to the rest of the system.

## System Architecture

FOFOCA is a four-tier system. Each tier runs on dedicated hardware chosen for its strengths.

<pre style="line-height: 1.1;">
┌─────────────────────────────────────────────────────────────────┐
│                    ThinkNEO Control Plane                       │
│            AI governance, routing, audit, guardrails            │
└──────────────────────────┬──────────────────────────────────────┘
                           │ HTTPS (API gateway)
┌──────────────────────────▼──────────────────────────────────────┐
│                  Dell R210 — Edge Server                        │
│  Nemotron Nano 8B (Ollama) · ChromaDB · PostgreSQL · MinIO      │
│  FastAPI · Mosquitto (MQTT broker) · Grafana                    │
└────────┬────────────────────────────────────┬───────────────────┘
         │ REST API (FastAPI)                 │ MQTT (Mosquitto)
┌────────▼────────────┐            ┌──────────▼──────────────────┐
│  Raspberry Pi 5     │            │  ESP8266 — Status Display   │
│  Brain: vision,     │            │  OLED 0.96" SSD1306         │
│  speech, decisions, │ Bluetooth  │  Subscribes to robot/status │
│  orchestration      ├────────────┤  Shows: state, task,        │
│  8 GB RAM           │   Serial   │  battery, AI model          │
└────────┬────────────┘            └─────────────────────────────┘
         │ Bluetooth Serial
┌────────▼────────────────────────────────────────────────────────┐
│                  ESP32 — Physical Controller                    │
│  Tank tread motors (PWM via HW130 driver)                       │
│  Ultrasonic sensor (HC-SR04) · Temperature (DHT22)              │
│  PIR motion sensor · Battery voltage (ADC)                      │
│  Telemetry publisher (MQTT)                                     │
└─────────────────────────────────────────────────────────────────┘
</pre>

**Tier 1 — ESP32 (real-time control).** The ESP32 owns everything that needs microsecond-level timing: motor PWM signals, sensor interrupts, and the Bluetooth link to the brain. It does not make decisions — it executes commands and reports telemetry.

**Tier 2 — Raspberry Pi 5 (brain).** Runs computer vision (YOLOv8n, InsightFace), speech processing (faster-whisper, Piper TTS), and orchestrates all task modules. Sends movement commands to the ESP32 over Bluetooth Serial.

**Tier 3 — Dell R210 (edge server).** Runs the AI model (NVIDIA Nemotron Nano 8B via Ollama), vector memory (ChromaDB), relational storage (PostgreSQL), object storage for video (MinIO), and the MQTT broker (Mosquitto). All inference happens here — no cloud latency.

**Tier 4 — ThinkNEO (governance).** Every AI call is routed through the ThinkNEO gateway, which handles model selection, budget enforcement, guardrails, and immutable audit logging. The robot holds a single API key; switching from Nemotron Nano to any other model requires zero firmware changes.

## ESP32 — The Physical Controller

The ESP32 is the muscle of the robot. It runs Arduino framework firmware and handles four responsibilities: motor control, sensor polling, Bluetooth communication, and telemetry publishing.

### Motor Control — Tank Treads via HW130

The robot moves on tank treads driven by two DC motors through an HW130 dual H-bridge driver. The ESP32 generates PWM signals on four GPIO pins — two per motor (direction + speed).

```cpp
#include <BluetoothSerial.h>
#include <WiFi.h>
#include <PubSubClient.h>

// Motor pins — HW130 driver
#define MOTOR_L_PWM  25
#define MOTOR_L_DIR  26
#define MOTOR_R_PWM  27
#define MOTOR_R_DIR  14

// Sensor pins
#define ULTRASONIC_TRIG  32
#define ULTRASONIC_ECHO  33
#define DHT_PIN          4
#define PIR_PIN          15
#define BATTERY_ADC      36

// PWM configuration
#define PWM_FREQ     5000
#define PWM_RES      8
#define PWM_CH_LEFT  0
#define PWM_CH_RIGHT 1

BluetoothSerial btSerial;
WiFiClient wifiClient;
PubSubClient mqtt(wifiClient);

// Network configuration
const char* WIFI_SSID     = "FOFOCA-NET";
const char* WIFI_PASS     = "your-password";
const char* MQTT_BROKER   = "192.168.88.50";  // Dell R210
const int   MQTT_PORT     = 1883;

void setupMotors() {
    pinMode(MOTOR_L_DIR, OUTPUT);
    pinMode(MOTOR_R_DIR, OUTPUT);
    ledcAttach(MOTOR_L_PWM, PWM_FREQ, PWM_RES);
    ledcAttach(MOTOR_R_PWM, PWM_FREQ, PWM_RES);
}

void setMotors(int leftSpeed, int leftDir, int rightSpeed, int rightDir) {
    digitalWrite(MOTOR_L_DIR, leftDir);
    digitalWrite(MOTOR_R_DIR, rightDir);
    ledcWrite(MOTOR_L_PWM, constrain(leftSpeed, 0, 255));
    ledcWrite(MOTOR_R_PWM, constrain(rightSpeed, 0, 255));
}

void stopMotors() {
    setMotors(0, LOW, 0, LOW);
}
```

Commands arrive over Bluetooth Serial from the Raspberry Pi 5 as single-character codes with optional parameters. The protocol is intentionally simple — the brain has already decided what to do; the ESP32 just needs to do it fast.

```cpp
void handleBluetoothCommand() {
    if (!btSerial.available()) return;

    char cmd = btSerial.read();
    switch (cmd) {
        case 'F': setMotors(200, HIGH, 200, HIGH); break;  // forward
        case 'B': setMotors(200, LOW,  200, LOW);  break;  // backward
        case 'L': setMotors(100, LOW,  200, HIGH); break;  // turn left
        case 'R': setMotors(200, HIGH, 100, LOW);  break;  // turn right
        case 'S': stopMotors();                     break;  // stop
        case 'V': {                                         // variable speed
            while (!btSerial.available()) delay(1);
            int speed = btSerial.parseInt();
            setMotors(speed, HIGH, speed, HIGH);
            break;
        }
    }
}
```

### Sensor Polling

The ESP32 polls three sensor types on a fixed schedule and publishes readings over MQTT for the edge server to store and visualize in Grafana.

```cpp
float readUltrasonic() {
    digitalWrite(ULTRASONIC_TRIG, LOW);
    delayMicroseconds(2);
    digitalWrite(ULTRASONIC_TRIG, HIGH);
    delayMicroseconds(10);
    digitalWrite(ULTRASONIC_TRIG, LOW);
    long duration = pulseIn(ULTRASONIC_ECHO, HIGH, 30000);
    return (duration * 0.0343) / 2.0;  // cm
}

float readBatteryVoltage() {
    int raw = analogRead(BATTERY_ADC);
    // Voltage divider: 100k/27k — maps 0-15V to 0-3.3V
    return (raw / 4095.0) * 3.3 * (127.0 / 27.0);
}

void publishTelemetry() {
    float distance = readUltrasonic();
    float battery  = readBatteryVoltage();
    int   motion   = digitalRead(PIR_PIN);

    char payload[256];
    snprintf(payload, sizeof(payload),
        "{\"distance_cm\":%.1f,\"battery_v\":%.2f,\"motion\":%d,\"uptime_ms\":%lu}",
        distance, battery, motion, millis());

    mqtt.publish("fofoca/telemetry", payload);
}
```

### Bluetooth + WiFi Coexistence

The ESP32 runs Bluetooth Classic (SPP) for the Pi 5 link and WiFi for MQTT simultaneously. This is a well-supported configuration on the ESP32, but it requires attention to antenna time-sharing. I keep the MQTT publish interval at 2 seconds to avoid starving the Bluetooth connection, and Bluetooth commands are processed in the main loop with higher priority.

```cpp
void setup() {
    Serial.begin(115200);

    // Motors
    setupMotors();

    // Sensors
    pinMode(ULTRASONIC_TRIG, OUTPUT);
    pinMode(ULTRASONIC_ECHO, INPUT);
    pinMode(PIR_PIN, INPUT);

    // Bluetooth — name visible to Pi 5
    btSerial.begin("FOFOCA-ESP32");
    Serial.println("Bluetooth ready");

    // WiFi + MQTT
    WiFi.begin(WIFI_SSID, WIFI_PASS);
    while (WiFi.status() != WL_CONNECTED) delay(500);
    Serial.println("WiFi connected");

    mqtt.setServer(MQTT_BROKER, MQTT_PORT);
    Serial.println("FOFOCA ESP32 controller ready");
}

unsigned long lastTelemetry = 0;

void loop() {
    // Bluetooth commands — highest priority
    handleBluetoothCommand();

    // MQTT maintenance
    if (!mqtt.connected()) {
        mqtt.connect("fofoca-esp32");
        mqtt.subscribe("fofoca/command");
    }
    mqtt.loop();

    // Telemetry — every 2 seconds
    if (millis() - lastTelemetry > 2000) {
        publishTelemetry();
        lastTelemetry = millis();
    }
}
```

## ESP8266 — The Status Display

The ESP8266 serves a single purpose: it subscribes to MQTT topics on the Mosquitto broker and renders the robot's state on a 0.96-inch SSD1306 OLED display. This gives anyone near the robot an instant read on what it is doing without needing to open a phone app or a dashboard.

The display shows four lines:
1. **State** — `IDLE`, `PATROL`, `DELIVERY`, `EMERGENCY`
2. **Task** — the currently active task module name
3. **Battery** — voltage and estimated percentage
4. **AI Model** — which model is currently handling inference

### Firmware

```cpp
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <Wire.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH  128
#define SCREEN_HEIGHT 64
#define OLED_RESET    -1

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
WiFiClient wifiClient;
PubSubClient mqtt(wifiClient);

const char* WIFI_SSID   = "FOFOCA-NET";
const char* WIFI_PASS   = "your-password";
const char* MQTT_BROKER = "192.168.88.50";

// Current state — updated by MQTT callbacks
char robotState[16]  = "BOOT";
char activeTask[24]  = "initializing";
char batteryStr[16]  = "-- V";
char aiModel[24]     = "---";

void mqttCallback(char* topic, byte* payload, unsigned int length) {
    char msg[128];
    int len = min((unsigned int)127, length);
    memcpy(msg, payload, len);
    msg[len] = '\0';

    if (strcmp(topic, "fofoca/state") == 0) {
        strncpy(robotState, msg, sizeof(robotState) - 1);
    } else if (strcmp(topic, "fofoca/task") == 0) {
        strncpy(activeTask, msg, sizeof(activeTask) - 1);
    } else if (strcmp(topic, "fofoca/battery") == 0) {
        strncpy(batteryStr, msg, sizeof(batteryStr) - 1);
    } else if (strcmp(topic, "fofoca/ai_model") == 0) {
        strncpy(aiModel, msg, sizeof(aiModel) - 1);
    }
}

void updateDisplay() {
    display.clearDisplay();
    display.setTextSize(1);
    display.setTextColor(SSD1306_WHITE);

    // Line 1 — State (larger font)
    display.setTextSize(2);
    display.setCursor(0, 0);
    display.println(robotState);

    // Lines 2-4 — Details
    display.setTextSize(1);
    display.setCursor(0, 24);
    display.print("Task: ");
    display.println(activeTask);

    display.setCursor(0, 38);
    display.print("Batt: ");
    display.println(batteryStr);

    display.setCursor(0, 52);
    display.print("AI: ");
    display.println(aiModel);

    display.display();
}

void setup() {
    Serial.begin(115200);

    // OLED
    Wire.begin(D2, D1);  // SDA=D2, SCL=D1
    display.begin(SSD1306_SWITCHCAPVCC, 0x3C);
    display.clearDisplay();
    display.setTextSize(2);
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(0, 0);
    display.println("FOFOCA");
    display.setTextSize(1);
    display.setCursor(0, 24);
    display.println("Connecting...");
    display.display();

    // WiFi
    WiFi.begin(WIFI_SSID, WIFI_PASS);
    while (WiFi.status() != WL_CONNECTED) delay(500);

    // MQTT
    mqtt.setServer(MQTT_BROKER, 1883);
    mqtt.setCallback(mqttCallback);
}

void loop() {
    if (!mqtt.connected()) {
        if (mqtt.connect("fofoca-display")) {
            mqtt.subscribe("fofoca/state");
            mqtt.subscribe("fofoca/task");
            mqtt.subscribe("fofoca/battery");
            mqtt.subscribe("fofoca/ai_model");
        }
    }
    mqtt.loop();
    updateDisplay();
    delay(100);
}
```

### MQTT Topic Map

The Raspberry Pi 5 publishes state updates to well-defined topics. The ESP8266 subscribes; the edge server also subscribes for logging and Grafana dashboards.

| Topic | Publisher | Payload Example | Subscribers |
| --- | --- | --- | --- |
| `fofoca/telemetry` | ESP32 | `{"distance_cm":42.3,"battery_v":11.8}` | R210 (log + Grafana) |
| `fofoca/state` | Pi 5 | `PATROL` | ESP8266, R210 |
| `fofoca/task` | Pi 5 | `security_sweep` | ESP8266, R210 |
| `fofoca/battery` | ESP32 | `11.8V 85%` | ESP8266, R210 |
| `fofoca/ai_model` | Pi 5 | `nemotron-nano-8b` | ESP8266, R210 |
| `fofoca/command` | Pi 5 | `F` (forward) | ESP32 |
| `fofoca/vision` | Pi 5 | `{"objects":["person","dog"]}` | R210 |

## Bill of Materials

### Compute Modules

| Component | Role | Qty | Est. Price (USD) |
| --- | --- | --- | --- |
| Raspberry Pi 5 (8 GB) | Brain — vision, speech, orchestration | 1 | 80 |
| ESP32 DevKit v1 | Real-time motor control, sensors, BT | 1 | 5 |
| ESP8266 NodeMCU | OLED status display, MQTT subscriber | 1 | 3 |
| RP2040 (Raspberry Pi Pico) | Robotic arm PWM (6 channels) | 1 | 4 |
| Dell PowerEdge R210 (16 GB) | Edge AI server — Nemotron Nano 8B | 1 | 120 (used) |

### Sensors and Peripherals

| Component | Role | Qty | Est. Price (USD) |
| --- | --- | --- | --- |
| HC-SR04 | Ultrasonic distance sensor | 2 | 2 |
| DHT22 | Temperature and humidity | 1 | 3 |
| PIR (HC-SR501) | Motion detection | 1 | 2 |
| Insta360 X3 | 360-degree vision, navigation, security | 1 | 300 |
| SSD1306 OLED 0.96" | Status display (I2C, driven by ESP8266) | 1 | 3 |
| ReSpeaker USB Mic Array | Audio input for voice commands | 1 | 30 |
| Bluetooth speaker (portable) | Voice output via Piper TTS | 1 | 15 |

### Actuators and Power

| Component | Role | Qty | Est. Price (USD) |
| --- | --- | --- | --- |
| DC geared motors + tank treads | Locomotion | 2 | 20 |
| HW130 dual H-bridge | Motor driver for treads | 1 | 3 |
| MG90S micro servo | Robotic arm joints | 6 | 12 |
| Gripper mechanism | Object manipulation | 1 | 8 |
| LM2596 DC-DC buck converter | Per-module voltage regulation (5 V) | 5 | 5 |
| Zircon 12 V 6 Ah battery | Main power | 1 | 25 |
| Keystudio IO Expander v5.0 | GPIO expansion | 1 | 8 |

**Estimated total: ~650 USD** (excluding the Dell R210 and Insta360, which are repurposed equipment).

## Edge AI Server — Dell R210

The Dell PowerEdge R210 sits on the same local network as the robot. It runs Ubuntu Server 24.04 LTS and hosts all the services that the microcontrollers and the Pi 5 depend on.

| Service | Purpose | Port |
| --- | --- | --- |
| Ollama (Nemotron Nano 8B) | Local AI inference — no cloud latency | 11434 |
| FastAPI | REST API bridging Pi 5 and server | 8000 |
| Mosquitto | MQTT broker for all pub/sub traffic | 1883 |
| ChromaDB | Vector memory — semantic long-term recall | 8100 |
| PostgreSQL | Event history, routines, structured logs | 5432 |
| MinIO | Object storage for Insta360 video clips | 9000 |
| Grafana | Dashboards — telemetry, model usage, alerts | 3000 |

Running inference locally means the robot's reaction time to voice commands or vision events is bounded by LAN latency (sub-millisecond) plus model inference time (target latency: ~200 ms for Nemotron Nano 8B on CPU (R210, Ollama)), not by an internet round trip. For a robot that needs to stop before hitting a wall, this matters.

## How the Pieces Talk to Each Other

A typical interaction — the robot detects a person at the front door — flows through the system like this:

1. **ESP32** reads a distance drop on the ultrasonic sensor and publishes to `fofoca/telemetry`.
2. **Pi 5** picks up the telemetry anomaly, activates the Insta360, and runs YOLOv8n. It detects a person.
3. **Pi 5** sends the image context to the **Dell R210** via FastAPI, which forwards it to Nemotron Nano 8B through the **ThinkNEO** gateway. The model decides: "Person at door. Likely delivery. Approach and greet."
4. **Pi 5** sends `F` (forward) over Bluetooth to the **ESP32**, which drives the motors.
5. **Pi 5** publishes `DELIVERY` to `fofoca/state` and `door_greeting` to `fofoca/task`.
6. **ESP8266** picks up the MQTT messages and updates the OLED display.
7. **Pi 5** speaks "Hello, I can receive the package" through Piper TTS over the Bluetooth speaker.
8. The entire interaction is logged: telemetry in PostgreSQL, AI decision in the ThinkNEO audit trail, video clip in MinIO.

## Wiring Reference

### ESP32 Pin Assignments

| GPIO | Function | Connected To |
| --- | --- | --- |
| 25 | PWM (left motor speed) | HW130 ENA |
| 26 | Digital (left motor direction) | HW130 IN1/IN2 |
| 27 | PWM (right motor speed) | HW130 ENB |
| 14 | Digital (right motor direction) | HW130 IN3/IN4 |
| 32 | Digital output (ultrasonic trigger) | HC-SR04 TRIG |
| 33 | Digital input (ultrasonic echo) | HC-SR04 ECHO |
| 4 | Digital (DHT data) | DHT22 DATA |
| 15 | Digital input (PIR) | HC-SR501 OUT |
| 36 | ADC (battery voltage) | Voltage divider (100 k / 27 k) |

### ESP8266 Pin Assignments

| Pin | Function | Connected To |
| --- | --- | --- |
| D1 (GPIO5) | I2C SCL | SSD1306 SCL |
| D2 (GPIO4) | I2C SDA | SSD1306 SDA |
| 3V3 | Power | SSD1306 VCC |
| GND | Ground | SSD1306 GND |

## What Comes Next

The robot is currently in Phase 3 (autonomous locomotion). The immediate next steps on the Espressif side:

- **OTA updates** — using the ESP32's built-in OTA support so firmware updates do not require physical access to the robot.
- **ESP-NOW** — evaluating ESP-NOW as a lower-latency alternative to Bluetooth for the Pi 5 to ESP32 link, using a second ESP32 as a USB-connected bridge on the Pi.
- **Deep sleep telemetry** — when the robot is docked and charging, switching the ESP32 to deep sleep with periodic wake-ups for battery monitoring.
- **GSM module** — adding a SIM800L for emergency calls (SAMU, fire department, police) when WiFi is unavailable.

## Build Status & Roadmap

This article documents the FOFOCA v1 reference architecture — the open hardware design and software stack the project is built around. Physical assembly is being coordinated through a manufacturing partner; the article serves as the design reference, not a finished-build photo essay.

A v2 build is already in motion, pivoting the chassis to a Yahboom ROSMASTER M3 Pro with Jetson Orin onboard, and refreshing the supporting microcontrollers toward the ESP32-C3 family for new builds (per Espressif's [NRND guidance on ESP8266](https://products.espressif.com/#/product-selector?names=&filter={%22Series%22:[%22ESP8266%22]})). v2 will be written up as a follow-up post when running.

## Project Links

- **ThinkNEO** — [thinkneo.ai](https://thinkneo.ai) — AI governance platform powering FOFOCA's model routing and audit trail
- **NVIDIA Inception** — ThinkNEO is a member of the NVIDIA Inception program; FOFOCA uses Nemotron models for inference
- **ESP32 Arduino Core** — [github.com/espressif/arduino-esp32](https://github.com/espressif/arduino-esp32) — the framework running on FOFOCA's ESP32
- **ESP8266 Arduino Core** — [github.com/esp8266/Arduino](https://github.com/esp8266/Arduino) — the framework running on FOFOCA's display module

FOFOCA is an ongoing open-source project. If you are building something similar — a robot, a home automation system, or any physical system that needs local AI inference with governance — I would be happy to share more details. Reach out through the links above.
