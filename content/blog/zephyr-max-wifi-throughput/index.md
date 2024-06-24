---
title: "Maximizing Wi-Fi Throughput: Fine-Tuning Zephyr for Peak Performance with ESP32 SoCs in IoT Applications"
date: 2024-06-24T14:29:12+08:00
---

A common need for all developers of IoT applications based on Zephyr OS is to measure the performance achieved by a certain configuration made in the parameters of the Wi-Fi network stack. This article aims to show how to install, configure and use the zperf and iperf tools to quantify this performance.

## 1. Testing Environment

To evaluate the communication performance, a setup featuring an ESP32-S3_DevKitC-1, a Wi-Fi home router, and a Linux-based computer running Ubuntu 22.04 was used.

![](./img/setup.webp)

To ease packet generation and consumption on the Wi-Fi network, we employed iperf tool on the computer side. On esp32-s3_devkitc we used zperf application, included in the standard Zephyr distribution. This structured testing approach allows to systematically analyze the impact of Zephyr parameter adjustments on Wi-Fi communication in various real-world scenarios:


### 1.1. ESP32 Sending UDP Packets to PC:

![](./img/send-upd-packets-esp32-pc.webp)


### 1.2. PC Sending UDP Packets to ESP32:

![](./img/send-upd-packets-pc-esp32.webp)


### 1.3. ESP32 Sending TCP Packets to PC:

![](./img/send-tcp-packets-esp32-pc.webp)


### 1.4. PC sending TCP Packets to ESP32:

![](./img/send-tcp-packets-pc-esp32.webp)


## 2. Installing iperf on PC side

On a terminal window, execute the following command:

```sh
sudo apt-get install iperf
```

Please note that administrator privileges are required to successfully complete this installation.


## 3. Installing Zephyr OS

To setup Zephyr OS and its dependencies, follow these step-by-step instructions:


### 3.1. Installing Dependencies:

On a terminal window, execute the following command:

```sh
sudo apt install --no-install-recommends \
  git cmake ninja-build gperf ccache dfu-util device-tree-compiler wget \
  python3-dev python3-pip python3-setuptools python3-tk python3-wheel \
  xz-utils file make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1
```


### 3.2. Installing West:

To install the Python script that manages the Zephyr OS build system, execute the following command:

```sh
pip install west
```


### 3.3. Initializing Zephyr:

Now, initialize Zephyr on your machine using the following commands:

```sh
west init ~/zephyrproject
cd ~/zephyrproject
west update
```


### 3.4. Installing Python Dependencies:

After initializing Zephyr, install additional Python dependencies by typing:

```sh
pip install -r ~/zephyrproject/zephyr/scripts/requirements.txt
```


### 3.5. Downloading and Installing Zephyr SDK:

For cross-compiling zperf, download and install the Zephyr SDK using the following commands:

```sh
cd ~
wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.4/zephyr-sdk-0.16.4_linux-x86_64.tar.xz
wget -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.4/sha256.sum | shasum --check --ignore-missing
tar xvf zephyr-sdk-0.16.4_linux-x86_64.tar.xz
cd zephyr-sdk-0.16.4

./setup.sh
```


### 3.6. Installing Espressif binary blobs:

To successfully build your ESP32-S3 Wi-Fi application on Zephyr, install the hal_espressif binary blobs:

```sh
west blobs fetch hal_espressif
```


### 3.7. Installing udev Rules:

Additionally, install udev rules to allow flashing ESP32-S3 as a regular user:

```sh
sudo cp /opt/zephyr-sdk-0.16.4/sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d
sudo udevadm control --reload
```


## 4. Getting zperf Running on ESP32-S3_DevKitC-1

To enable zperf functionality on the ESP32-S3_DevKitC-1, follow these steps to configure the necessary files:


## 4.1. Create the Overlay File:

Create the **zephyr/samples/net/zperf/boards/esp32s3_devkitc.overlay** with the following content:

```sh
/*
 * Copyright (c) 2024 Espressif Systems (Shanghai) Co., Ltd.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
&wifi {
    status = "okay";
};
```

**Update prj.conf File**: Modify the content of the file **zephyr/samples/net/zperf/prj.conf** to include the following configurations:

```sh
CONFIG_NET_BUF_DATA_SIZE=1500
CONFIG_NET_IF_UNICAST_IPV4_ADDR_COUNT=1
CONFIG_NET_MAX_CONTEXTS=5
CONFIG_NET_TC_TX_COUNT=1
CONFIG_NET_SOCKETS=y
CONFIG_NET_SOCKETS_POSIX_NAMES=y
CONFIG_NET_SOCKETS_POLL_MAX=4
CONFIG_POSIX_MAX_FDS=8
CONFIG_INIT_STACKS=y
CONFIG_TEST_RANDOM_GENERATOR=y
CONFIG_NET_L2_ETHERNET=y
CONFIG_NET_SHELL=y
CONFIG_NET_L2_WIFI_SHELL=y
CONFIG_NET_CONFIG_SETTINGS=y
CONFIG_LOG=y
CONFIG_SHELL_CMDS_RESIZE=n
CONFIG_NET_IPV6=n
CONFIG_NET_DHCPV4=n
CONFIG_NET_CONFIG_MY_IPV4_ADDR="<STATION IP ADDRESS>"
CONFIG_NET_CONFIG_MY_IPV4_GW="<GATEWAY IP ADDRESS>"
CONFIG_NET_CONFIG_MY_IPV4_NETMASK="255.255.255.0"
CONFIG_NET_TCP_MAX_RECV_WINDOW_SIZE=50000
```

Make sure to replace `<STATION IP ADDRESS>` and `<GATEWAY IP ADDRESS>` with the actual IP addresses relevant to your network configuration.


### 4.2. Build and Flash zperf:

After each modification done on the file **zephyr/samples/net/zperf/prj.conf** with the propose of setting new configuration parameters values, build zperf and flash it onto the ESP32-S3_DevKitC-1 before starting a testing sequence using the following west commands:

```sh
west build -b esp32s3_devkitc zephyr/samples/net/zperf --pristine
west flash
west espressif monitor
```

Ensure that the ESP32-S3_DevKitC-1 is connected to the PC via USB during the flashing process.


## 5. Running Tests

Before starting the test sequence, always remember build and flash zperf on ESP32-S3_DevKitC-1:

```sh
west build -b esp32s3_devkitc zephyr/samples/net/zperf --pristine
west flash
west espressif monitor
```

After entering this command line, you will access the zperf terminal. Follow these steps to connect the ESP32-S3_DevKitC-1 to the Wi-Fi router:

```sh
wifi connect <SSID> <PASSWORD>
net ping <PC_IP>
```

Testing run output:

```sh
*** Booting Zephyr OS build zephyr-v3.5.0-2714-g031c842ecb76 ***
[00:00:00.387,000] <inf> net_config: Initializing network
[00:00:00.387,000] <inf> net_config: Waiting interface 1 (0x3fcc8810) to be up...
[00:00:00.388,000] <inf> net_config: Interface 1 (0x3fcc8810) coming up
[00:00:00.388,000] <inf> net_config: IPv4 address: 192.168.15.2
uart:~$ wifi connect <SSID> <PASSWORD>
Connection requested
Connected
uart:~$ net ping 192.168.15.8
PING 192.168.15.8
28 bytes from 192.168.15.8 to 192.168.15.2: icmp_seq=1 ttl=64 time=219 ms
28 bytes from 192.168.15.8 to 192.168.15.2: icmp_seq=2 ttl=64 time=434 ms
28 bytes from 192.168.15.8 to 192.168.15.2: icmp_seq=3 ttl=64 time=356 ms
uart:~$
```

Now, open a second terminal where you will run iperf.


## 5.1. ESP32 Sending UDP Packets to PC:

On the iperf terminal, type:

```sh
iperf -s -l 1K -u -B 192.168.15.8
```

On the zperf terminal, type:

```sh
zperf udp upload 192.168.15.6 5001 10 1K 5M
```


### 5.2. PC Sending UDP Packets to ESP32:

On the zperf terminal, type:

```sh
zperf udp download 5001
```

On the iperf terminal, type:

```sh
zperf udp download 5001
```


## 6. Results

To illustrate the tangible impact of adjusting network-sensitive parameters on ESP32-S3 Wi-Fi throughput, we conducted a series of tests, each time modifying the CONFIG_NET_TCP_MAX_RECV_WINDOW_SIZE parameter. The result highlights the performance progression before and after parameter changes:


### 6.1. Initial Configuration:

CONFIG_NET_TCP_MAX_RECV_WINDOW_SIZE commented.

<table>
<thead>
  <tr>
    <th>DEVICE </th>
    <th>PROTOCOL  </th>
    <th>ROLE </th>
    <th>DIRECTION </th>
    <th>RATE </th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="4"> ESP32-S3 </td>
    <td rowspan="2">UDP </td>
    <td>SERVER </td>
    <td>DOWNLOAD </td>
    <td>10.05 Mbps </td>
  </tr>
  <tr>
    <td>CLIENT </td>
    <td>UPLOAD </td>
    <td>4.78 Mbps </td>
  </tr>
  <tr>
    <td rowspan="2">TCP </td>
    <td>SERVER </td>
    <td>DOWNLOAD </td>
    <td>2.83 Mbps </td>
  </tr>
  <tr>
    <td>CLIENT </td>
    <td>UPLOAD </td>
    <td>4.22 Mbps </td>
  </tr>
</tbody>
</table>

### 6.2. Modified Configuration (Increased Window Size):

CONFIG_NET_TCP_MAX_RECV_WINDOW_SIZE=20000

<table>
<thead>
  <tr>
    <th>DEVICE </th>
    <th>PROTOCOL  </th>
    <th>ROLE </th>
    <th>DIRECTION </th>
    <th>RATE </th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="4"> ESP32-S3 </td>
    <td rowspan="2">UDP </td>
    <td>SERVER </td>
    <td>DOWNLOAD </td>
    <td>10.05 Mbps </td>
  </tr>
  <tr>
    <td>CLIENT </td>
    <td>UPLOAD </td>
    <td>4.78 Mbps </td>
  </tr>
  <tr>
    <td rowspan="2">TCP </td>
    <td>SERVER </td>
    <td>DOWNLOAD </td>
    <td>3.62 Mbps </td>
  </tr>
  <tr>
    <td>CLIENT </td>
    <td>UPLOAD </td>
    <td>4.22 Mbps </td>
  </tr>
</tbody>
</table>

### 6.3. Further Modified Configuration (Increased Window Size):

CONFIG_NET_TCP_MAX_RECV_WINDOW_SIZE=50000

<table>
<thead>
  <tr>
    <th>DEVICE </th>
    <th>PROTOCOL  </th>
    <th>ROLE </th>
    <th>DIRECTION </th>
    <th>RATE </th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="4"> ESP32-S3 </td>
    <td rowspan="2">UDP </td>
    <td>SERVER </td>
    <td>DOWNLOAD </td>
    <td>10.05 Mbps </td>
  </tr>
  <tr>
    <td>CLIENT </td>
    <td>UPLOAD </td>
    <td>4.78 Mbps </td>
  </tr>
  <tr>
    <td rowspan="2">TCP </td>
    <td>SERVER </td>
    <td>DOWNLOAD </td>
    <td>4.07 Mbps </td>
  </tr>
  <tr>
    <td>CLIENT </td>
    <td>UPLOAD </td>
    <td>4.22 Mbps </td>
  </tr>
</tbody>
</table>

### 6.4. Comparative results chart:

![](./img/compare-results-chart.webp)

These results provide valuable insights into the dynamic relationship between network parameters and ESP32-S3 Wi-Fi throughput. Developers can leverage this information to fine-tune their applications for optimal performance in diverse network scenarios. Adjust parameters based on specific requirements and network conditions to achieve the desired outcome.

## 7. Conclusion

The issue of measuring the evolution of communication performance in response to changes in the values of the Zephyr OS Wi-Fi network stack configuration parameter using the ESP32-S3_devkitM development board was presented. By installing, configuring, and utilizing the iperf and zperf tools, and following the procedure outlined in this article, it was possible to tangibly observe the performance evolution as the configuration parameters were modified.
