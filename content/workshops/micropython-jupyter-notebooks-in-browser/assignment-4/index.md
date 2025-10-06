---
title: "Assignment 4: IMU Sensor and MQTT Communication"
date: 2025-10-17T00:00:00+01:00
showTableOfContents: true
series: ["WS00M"]
series_order : 5

---

Navigate to `workshops/2025-10-17` directory and open Assignment 4 in the MicroPython Jupyter Notebook browser interface.

If prompted with selecting kernel, select `Embedded Kernel`, click on the ESP Control Panel and connect your device.

In this assignment you will read orientation data from an ICM42670 IMU sensor and publish it to an MQTT broker.

## Understanding IMU Sensors
An Inertial Measurement Unit (IMU) combines:

- **Accelerometer**: Measures linear acceleration (including gravity)
- **Gyroscope**: Measures rotational velocity
- **Temperature sensor**: Measures device temperature

The ICM42670 is a 6-axis IMU (3-axis accelerometer + 3-axis gyroscope).

For more information about IMU sensors, visit the [wiki page](https://en.wikipedia.org/wiki/Inertial_measurement_unit).

## Understanding MQTT
MQTT (Message Queuing Telemetry Transport) is a lightweight publish-subscribe messaging protocol ideal for IoT:

- **Broker**: Central server that routes messages
- **Topics**: Hierarchical message channels (e.g., sensors/imu/orientation)
- **QoS**: Quality of Service levels (0, 1, or 2)

For more information about MQTT, visit the [wiki page](https://en.wikipedia.org/wiki/MQTT).


## Subscribing to MQTT Topic

To subscribe to a topic, you will have two options:

### HiveMQ Online MQTT Client

- Navigate to [HiveMQ](https://www.hivemq.com/demos/websocket-client/) and connect to the broker `test.mosquitto.org` on port `8081`.
- Under `Subscriptions` click on the `Add New Topic Subscription`, enter `esp32/orientation` and click on `Subscribe`

### Mosquitto Client

- Subscribe to the topic:
  - On **Linux** or **MacOS** run command `mosquitto_sub -h test.mosquitto.org -t "esp32/orientation"` in your terminal to subscribe to the topic
  - On **Windows** you will need to add mosquitto to your `PATH` environment variable or navigate to the path where the executable is located (usually `C:\Program Files\mosquitto\`) and run `mosquitto_sub.exe -h test.mosquitto.org -t "esp32/orientation"`

## Task 1: Connect to Wi-Fi

In this task, you’ll connect the ESP32 to your Wi-Fi network so it can communicate with the MQTT broker.
The code waits until the connection is established and prints the network configuration.

```python
SSID = "<WIFI_NAME>"
PASSWORD = "<WIFI_PASSWORD>"

sta = network.WLAN(network.STA_IF)
sta.active(True)
sta.connect(SSID, PASSWORD)

while not sta.isconnected():
    time.sleep(1)
    print("Connecting to Wi-Fi...")

print("Connected to Wi-Fi")
print(f"Network config: {sta.ifconfig()}")
```

## Task 2: Initialize MQTT

Here you’ll create an MQTT client and connect it to a broker.
You’ll publish orientation messages to the topic "esp32/orientation".

```python
BROKER = "test.mosquitto.org"
TOPIC = b"esp32/orientation"

client = MQTTClient("esp32client", BROKER)
client.connect()
print("Connected to MQTT broker")
```

## Task 3: Initialize IMU

In this task, you’ll set up the ICM42670 IMU over I2C.
You’ll configure the accelerometer and gyroscope full-scale range, data rate, and power mode for accurate measurements.

```python
i2c = I2C(0, scl=Pin(8), sda=Pin(7), freq=400000)

# Create IMU instance
imu = ICM42670(i2c)

# Configure sensor
imu.configure(
    gyro_fs=GyroFS.FS_500DPS,
    gyro_odr=ODR.ODR_100_HZ,
    accel_fs=AccelFS.FS_4G,
    accel_odr=ODR.ODR_100_HZ
)

# Enable sensors
imu.set_accel_power_mode(PowerMode.LOW_NOISE)
imu.set_gyro_power_mode(PowerMode.LOW_NOISE)
```

## Task 4: Read Orientation and Publish

Finally, you’ll read accelerometer and gyroscope data, compute orientation using a complementary filter, interpret the device’s tilt, and publish it to MQTT.
The main loop prints the orientation locally and continuously sends updates to the broker.

```python
def publish_orientation():
    """Read orientation and publish to MQTT"""

    while True:
        # Read sensor data
        data = imu.get_all_data()
        accel = (data['accel']['x'], data['accel']['y'], data['accel']['z'])
        gyro = (data['gyro']['x'], data['gyro']['y'], data['gyro']['z'])

        # Calculate orientation using complementary filter
        angles = imu.complementary_filter(accel, gyro)
        roll = angles['roll']
        pitch = angles['pitch']

        # Interpret orientation
        if abs(pitch) < 20 and abs(roll) < 20:
            position = "Flat"
        elif pitch > 30:
            position = "Tilted Forward"
        elif pitch < -30:
            position = "Tilted Backward"
        elif roll > 30:
            position = "Tilted Right"
        elif roll < -30:
            position = "Tilted Left"
        else:
            position = "Diagonal"

        # Create message
        message = f"Roll: {roll:.1f}°, Pitch: {pitch:.1f}° -> {position}"
        print(message)

        # Publish to MQTT
        client.publish(TOPIC, position.encode())

        time.sleep(0.5)

publish_orientation()
```

#### Next step

> Congratulations! Proceed to the [Conclusion](../#conclusion).
