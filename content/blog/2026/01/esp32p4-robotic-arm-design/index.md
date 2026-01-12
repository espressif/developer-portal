---
title: "Intelligent Robotic Arm Design Based on ESP32-P4 for Industrial Applications"
date: 2026-01-12
summary: "This article demonstrates how to implement an independently controllable robotic arm project based on the ESP32-P4 high-performance MCU. It covers complete kinematics, visual detection, and remote control, showcasing the great potential of ESP32-P4 in industrial applications."
authors:
  - yan-ke
tags: ["Robotic Arm", "Visual Detection", "Kinematics", "AI", "ESP DL"]
---

With the advancement of AI technology in recent years, the robotics field has entered the era of embodied intelligence, enabling robots to learn and perceive their environment. The ESP32-P4 high-performance MCU, with its powerful computing capabilities and rich peripheral interfaces, provides an ideal platform for building intelligent robotic arm control solutions. Specifically, this article presents the robotic arm solution with the following advantages:

* **Onboard Kinematics**: The onboard kinematics library implements forward and inverse kinematics using an iterative method based on the robotic arm's [D-H parameters](https://en.wikipedia.org/wiki/Denavit%E2%80%93Hartenberg_parameters), eliminating the need for external computing platforms. 
* **Onboard Vision**: With USB camera and [color-detect](https://github.com/espressif/esp-dl/tree/master/models/color_detect) model, combined with a calibration matrix, the robotic arm can accurately grasp colored blocks. Additionally, `esp-dl` provides lightweight models such as [yolo11n](https://github.com/espressif/esp-dl/tree/master/models/coco_detect) and [esp-detection](https://github.com/espressif/esp-detection), enabling custom object grasping.
* **Remote Control**: By operating a small robotic arm of the same configuration, joint data is wirelessly forwarded to the ESP32-P4 via ESP-NOW (using the onboard ESP32-C6 chip on the ESP32-P4-Function-EV-Board), enabling remote control.

This article provides a detailed guide covering mechanical assembly, motor control, vision calibration, and system integration for both the leader arm and follower arm. It covers the fundamental principles of robotics and visual applications. Additionally, leveraging the powerful performance of the ESP32-P4, the robotic arm can be extended to various application scenarios.

{{< alert >}}
To prevent personal injury or property damage caused by unexpected movement of the robotic arm during operation, please verify all motion parameters before formal operation and keep the emergency stop button within easy reach so that the equipment can be immediately shut down in an emergency.
{{< /alert >}}

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/leader_and_follower.jpg"
    alt="Leader and Follower"
    caption="Leader and Follower"
    >}}

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/system_architecture.png"
    alt="Robotic Arm System Architecture"
    caption="Robotic Arm System Architecture"
    >}}

## Leader Robotic Arm (TRLC DK1)

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5" >}}
The leader robotic arm is used only for remote control of the follower robotic arm and does not involve any robotics kinematics-related functionality. The follower robotic arm can operate independently with onboard kinematics and vision-based grasping capabilities. If remote control functionality is not needed, you can start reading directly from the [Follower Robotic Arm (Ragtime Panthera)](#follower-robotic-arm-ragtime-panthera) section.
{{< /alert >}}

The leader robotic arm is derived from the leader section of [trlc-dk1](https://github.com/robot-learning-co/trlc-dk1). It should be noted that the leader has been updated to v0.2.0 structure, but this article uses the initial version structure. You can download the initial version 3D files [here](https://dl.espressif.com/AE/esp-iot-solution/leader_parts_3d_model.zip).

The full leader project is available [here](https://github.com/espressif/esp-iot-solution/tree/master/examples/robot/ragtime_panthera/leader), which primarily implements position control and torque‑switching for the [XL330_M077](https://emanual.robotis.com/docs/en/dxl/x/xl330-m077/) bus servo.

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/trkc-dk1-leader.png"
    alt="trlc-dk1-leader"
    caption="TRLC DK1 Leader"
    >}}

### Mechanical Assembly

#### XL330_M077 Bus Servo Configuration

Before the formal assembly, configure the 7 XL330_M077 bus servos using [DYNAMIXEL Protocol 2.0](https://emanual.robotis.com/docs/en/dxl/protocol2/). Prepare the bus servo driver board in advance (which converts the standard serial signals into the DATA signals for the bus servos). Refer to the following circuit or the [official debugging circuit](https://emanual.robotis.com/docs/en/dxl/x/xl330-m077/#communication-circuit) for the XL330-M077.

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/bus_servo_circuit.png"
    alt="bus_servo_circuit"
    caption="Bus Servo Circuit"
    >}}

{{< alert >}}
If using the above circuit, connect the TX of the USB-to-TTL converter to the TX of the driver board, and the RX to the RX of the driver board. **Ensure the connections are not reversed**.
{{< /alert >}}

After connecting the bus servos, driver board, and USB-to-TTL converter, click the `Scan` button in the menu bar of the DYNAMIXEL Protocol 2.0 application to search for the servos on the bus:

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/leader_servo_scan.jpg"
    alt="leader_servo_scan"
    caption="Bus Servo Scan"
    >}}

In order to ensure consistency with the servo parameters in the leader project, configure the servos according to the following requirements:

* ID: Set the servo IDs from 1 to 7
* Baud rate: Set the baud rate of all servos to 115200
* Operating mode: Set the mode of all servos to position control
* Initial angle: Set the starting angle of all servos to 180 degrees (2045)

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/leader_servo_setting.jpg"
    alt="leader_servo_setting"
    caption="Leader Servo Setting"
    >}}

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/leader_servo_id.jpg"
    alt="leader_servo_id"
    caption="Leader Servo ID"
    >}}

{{< alert >}}
The choice of 180 degrees as the initial angle is because if the angle is set to 0 degrees as the starting point, there is a possibility that the angle may become 360 degrees at power-up, which could affect subsequent position reading and control.
{{< /alert >}}

#### Structural Assembly

After printing all the structures, assemble all XL330_M077 servos at the initial angle of 180 degrees. The screws required for the structure are provided in the XL330_M077 packaging box.

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/leader_assembly.png"
    alt="leader_assembly"
    caption="Leader Assembly"
    >}}


#### ESP32-C3 Driver Board Installation and Debugging

The ESP32-C3 driver board integrates the ESP32-C3 with the bus-servo circuitry into a complete driver module. It supports powering both the XL330_M077 and the ESP32-C3 from an external 5 V supply; ensure the external 5 V source can deliver at least 1 A. In addition, by connecting to the onboard Micro-USB port, the ESP32-C3 can be directly flashed and debugged. Download the PCB Gerber files for PCB prototyping [here](https://dl.espressif.com/AE/esp-iot-solution/LEADER_ESP32C3_DRIVER_BOARD.zip).

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/leader_esp32c3_driver_board.jpg"
    alt="ESP32-C3 Driver Board"
    caption="ESP32-C3 Driver Board"
    >}}

Before building the leader project, set up the [ESP-IDF Release v5.5](https://github.com/espressif/esp-idf/tree/release/v5.5) environment. Refer to [Get Started](https://docs.espressif.com/projects/esp-idf/en/release-v5.5/esp32/get-started/index.html#installation) to install and configure ESP-IDF v5.5.

Next, clone `esp-iot-solution` locally, activate the ESP-IDF v5.5 environment, and enter the `leader` directory to build, flash, and monitor:

```shell
git clone git@github.com:espressif/esp-iot-solution.git
cd esp-iot-solution/examples/robot/ragtime_panthera/leader
idf.py set-target esp32c3
# Replace /dev/ttyACM0 with your actual port
# Enter `ls /dev/ttyACM*` to view available ports
idf.py -p /dev/ttyACM0 build flash monitor
```

For additional configuration, run `idf.py menuconfig` and navigate to `(Top) → Example Configuration`:

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/leader_menuconfig.png"
    alt="leader_menuconfig"
    caption="Leader Menuconfig"
    >}}

**Hardware Configuration** includes the basic configuration for XL330_M077 bus servos, including baud rate, TX/RX pins, initial position, and angle tolerance:

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/leader_hardware_config.png"
    alt="leader_hardware_config"
    caption="Leader Hardware Config"
    >}}

The configurations required are as follows:

* **XL330_M077 Configuration**: To change the UART settings or communication pins, modify `XL330_M077 communication speed`, `XL330_M077 RXD pin number`, and `XL330_M077 init position`.
* **Initial angle**: By default, the program defines the zero position as the current angle minus the configured initial angle; this depends on the angles set during mechanical assembly.
* **Angle tolerance**: After power-on, the program commands all servos to return to their initial positions. Due to inertia, multiple position-write cycles may be required to reach the target. When the difference between the target angle and the current angle is less than the angle tolerance, the program considers the servo to have reached the target.

**ESP-NOW Configuration** includes configuration for channel, primary master key, and slave MAC address:

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/leader_espnow_config.png"
    alt="leader_espnow_config"
    caption="Leader ESP-NOW Config"
    >}}

The configurations required are as follows:

* **Channel**: Defaults to 1; no change needed unless required.
* **Primary master key**: Defaults to `bot12345678901234`; no change needed unless required.
* **Slave MAC address**: Defaults to `9c:9e:6e:52:f8:b8`; update it to the receiver's MAC address used in the follower project.

> **Note:** [ESP-NOW](https://www.espressif.com/en/solutions/low-power-solutions/esp-now) is a wireless communication protocol defined by Espressif, which enables the direct, quick and low-power control of smart devices, without the need for a router. ESP-NOW can work with Wi-Fi and Bluetooth LE, and supports the ESP8266, ESP32, ESP32-S and ESP32-C series of SoCs. It's widely used in smart-home appliances, remote controlling, sensors, etc.

## Follower Robotic Arm (Ragtime Panthera)

The [follower robotic arm project](https://github.com/espressif/esp-iot-solution/tree/master/examples/robot/ragtime_panthera/follower) originates from the [Ragtime_Panthera](https://github.com/Ragtime-LAB/Ragtime_Panthera) project, which uses [DM joint motors](https://www.mdmbot.com/index.php?c=category&id=22) to drive the arm and provides complete ROS and Python codebases. In addition, the follower arm is structurally identical to the leader arm, so the follower can be directly teleoperated via the leader.

{{< alert >}}
To avoid structural differences between this project and the Ragtime_Panthera project due to updates, refer to the [forked version](https://github.com/YanKE01/Ragtime_Panthera).
{{< /alert >}}

### Kinematics

In the Ragtime_Panthera project, the robotic arm is described using URDF (an XML-based robot description format). However, on MCU platforms there is no support for URDF and kinematics libraries. Therefore, on the ESP32-P4 we describe the Ragtime_Panthera arm with Denavit–Hartenberg (D-H) parameters and implement inverse kinematics using an iterative method.

Before debugging, use [robotics-toolbox-python](https://github.com/petercorke/robotics-toolbox-python) to pre‑validate the Denavit–Hartenberg (D-H) parameters and study the basics of forward and inverse kinematics (it is the Python version of the MATLAB Robotics Toolbox):

```shell
pip3 install roboticstoolbox-python
```

Next, view the follower robotic arm in the simulation environment:

```python
import numpy as np
from roboticstoolbox import DHRobot, RevoluteDH

robot = DHRobot(
    [
        RevoluteDH(a=0.0, d=0.1005, alpha=-np.pi / 2, offset=0.0),
        RevoluteDH(a=0.18, d=0.0, alpha=0.0, offset=np.deg2rad(180)),
        RevoluteDH(a=0.188809, d=0.0, alpha=0.0, offset=np.deg2rad(162.429)),
        RevoluteDH(a=0.08, d=0.0, alpha=-np.pi / 2, offset=np.deg2rad(17.5715)),
        RevoluteDH(a=0.0, d=0.0, alpha=np.pi / 2, offset=np.deg2rad(90)),
        RevoluteDH(a=0.0, d=0.184, alpha=np.pi / 2, offset=np.deg2rad(-90)),
    ],
    name="Ragtime_Panthera"
)

robot.teach(np.array([0, 0, 0, 0, 0, 0]))
```

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/follower_roboticstoolbox_initial_position.jpg"
    alt="follower_roboticstoolbox_initial_position"
    caption="Follower Roboticstoolbox Initial Position"
    >}}

#### Forward Kinematics

Forward kinematics refers to calculating the end-effector's position and orientation from input joint angles. Use the following code to test the forward kinematics:

```python
import matplotlib.pyplot as plt
import numpy as np
from roboticstoolbox import DHRobot, RevoluteDH

robot = DHRobot(
    [
        RevoluteDH(a=0.0, d=0.1005, alpha=-np.pi / 2, offset=0.0),
        RevoluteDH(a=0.18, d=0.0, alpha=0.0, offset=np.deg2rad(180)),
        RevoluteDH(a=0.188809, d=0.0, alpha=0.0, offset=np.deg2rad(162.429)),
        RevoluteDH(a=0.08, d=0.0, alpha=-np.pi / 2, offset=np.deg2rad(17.5715)),
        RevoluteDH(a=0.0, d=0.0, alpha=np.pi / 2, offset=np.deg2rad(90)),
        RevoluteDH(a=0.0, d=0.184, alpha=np.pi / 2, offset=np.deg2rad(-90)),
    ],
    name="Ragtime_Panthera"
)

state = np.deg2rad([0, 30, -36, 65, 0, 0])
T1 = robot.fkine(state)
print("T1:\n{}".format(T1))

robot.plot(state, jointaxes=True, eeframe=True, block=True)
plt.show()
```

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/follower_roboticstoolbox_forward.jpg"
    alt="follower_roboticstoolbox_forward"
    caption="Follower Roboticstoolbox Forward Test"
    >}}

```shell
T1:
   0.8572    0.515     0         0.1531    
   0         0         1         0         
   0.515    -0.8572    0         0.03971   
   0         0         0         1         
```

Using the `fkine` function, the end-effector's position and orientation at the current joint angles can be quickly calculated.

#### Inverse Kinematics

Inverse kinematics refers to calculating the required rotation angle for each joint from the input end-effector position and orientation. Use the following code to test inverse kinematics:

```python
import matplotlib.pyplot as plt
import numpy as np
from roboticstoolbox import DHRobot, RevoluteDH

robot = DHRobot(
    [
        RevoluteDH(a=0.0, d=0.1005, alpha=-np.pi / 2, offset=0.0),
        RevoluteDH(a=0.18, d=0.0, alpha=0.0, offset=np.deg2rad(180)),
        RevoluteDH(a=0.188809, d=0.0, alpha=0.0, offset=np.deg2rad(162.429)),
        RevoluteDH(a=0.08, d=0.0, alpha=-np.pi / 2, offset=np.deg2rad(17.5715)),
        RevoluteDH(a=0.0, d=0.0, alpha=np.pi / 2, offset=np.deg2rad(90)),
        RevoluteDH(a=0.0, d=0.184, alpha=np.pi / 2, offset=np.deg2rad(-90)),
    ],
    name="Ragtime_Panthera"
)

state = np.deg2rad([0, 30, -36, 65, 0, 0])
T1 = robot.fkine(state)
print("T1:\n{}".format(T1))

T2 = np.array(T1)
T2[0, 3] = T2[0, 3] + 0.1
print("T2:\n{}".format(T2))

sol = robot.ikine_LM(T2, q0=state, ilimit=100, mask=[1, 1, 1, 1, 1, 0], joint_limits=True)
print(sol)

T3 = robot.fkine(sol.q)
print("T3:\n{}".format(T3))

robot.plot(sol.q, jointaxes=True, eeframe=True, block=True)
plt.show()
```
{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/follower_roboticstoolbox_inverse.jpg"
    alt="follower_roboticstoolbox_inverse"
    caption="Follower Roboticstoolbox Inverse Test"
    >}}

In this example, based on the initial pose, we attempt to move the end-effector 0.1 m in the positive X direction and solve for the joint angles `sol.q` at the current pose. We then verify the result by applying forward kinematics:

```shell
T1:
   0.8572    0.515     0         0.1531    
   0         0         1         0         
   0.515    -0.8572    0         0.03971   
   0         0         0         1         

T2:
[[ 8.57171795e-01  5.15030595e-01  1.04973270e-16  2.53139272e-01]
 [-1.54001208e-16  5.24866348e-17  1.00000000e+00  1.49891524e-17]
 [ 5.15030595e-01 -8.57171795e-01  1.24305397e-16  3.97085648e-02]
 [ 0.00000000e+00  0.00000000e+00  0.00000000e+00  1.00000000e+00]]
IKSolution: q=[0, 1.161, -0.8568, 0.725, 0, 0], success=True, iterations=4, searches=1, residual=4.59e-10

T3:
   0.8572    0.515     0         0.2531    
   0         0         1         0         
   0.515    -0.8572    0         0.03971   
   0         0         0         1         

```

From the test results, the inverse kinematics calculation is valid, and the forward kinematics result from the inverse solution matches the expected pose.

#### Workspace Testing Based on Forward and Inverse Kinematics

Since the current project does not support pose estimation, we need to consider changing the end-effector position at a fixed orientation to determine the robotic arm's workspace boundaries and avoid moving the arm to regions where inverse kinematics cannot be solved:

```python
import numpy as np
from roboticstoolbox import DHRobot, RevoluteDH

robot = DHRobot(
    [
        RevoluteDH(a=0.0, d=0.1005, alpha=-np.pi / 2, offset=0.0),
        RevoluteDH(a=0.18, d=0.0, alpha=0.0, offset=np.deg2rad(180)),
        RevoluteDH(a=0.188809, d=0.0, alpha=0.0, offset=np.deg2rad(162.429)),
        RevoluteDH(a=0.08, d=0.0, alpha=-np.pi / 2, offset=np.deg2rad(17.5715)),
        RevoluteDH(a=0.0, d=0.0, alpha=np.pi / 2, offset=np.deg2rad(90)),
        RevoluteDH(a=0.0, d=0.184, alpha=np.pi / 2, offset=np.deg2rad(-90)),
    ],
    name="Ragtime_Panthera"
)

state = np.deg2rad([0, 30, -36, 65, 0, 0])
T1 = robot.fkine(state)
print("T1:\n{}".format(T1))

x_range = np.linspace(0, 23, 30)
y_range = np.linspace(-15, 15, 30)

for dx in x_range:
    for dy in y_range:
        T_test = np.array(T1).copy()
        T_test[0, 3] += dx / 100
        T_test[1, 3] += dy / 100

        sol = robot.ikine_LM(T_test, q0=state)
        if sol.success:
            pass
        else:
            print(f"Failed in dx: {dx:.4f} cm, dy: {dy:.4f} cm")

print("Test Done")
```

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/follower_workspace.gif"
    alt="follower_workspace"
    caption="Follower Roboticstoolbox Workspace Test"
    >}}

In this example, based on the initial pose, we attempt to solve inverse kinematics at a fixed orientation within a 23 cm × 30 cm region. From the test results, all points within this region can be successfully solved using inverse kinematics.

{{< alert >}}
The current project does not support pose estimation. Therefore, workspace testing is performed with a fixed end-effector pose.
{{< /alert >}}

#### ESP32-P4 Onboard Kinematics Testing

To enable the ESP32-P4 to independently control the robotic arm, onboard kinematics is essential. Inspired by [Matrix_and_Robotics_on_STM32](https://github.com/SJTU-RoboMaster-Team/Matrix_and_Robotics_on_STM32), we attempted to port and deploy it on the ESP32 platform. The kinematic component can be introduced in a separate project and tested. Note that this project only ports the kinematics part and does not yet support dynamics.

Taking [Inverse Kinematics](#inverse-kinematics) as an example, after setting up the ESP-IDF v5.5 environment, test it in the `examples/robot/ragtime_panthera/follower` project. The project has already added `kinematic` as a component:

```c++
#include <stdio.h>
#include <iostream>
#include "kinematic.h"

extern "C" void app_main(void)
{
    Kinematic kinematic;
    Joint j1 = Joint(0.0, DEG2RAD(30.0), DEG2RAD(-36.0), DEG2RAD(65.0), 0.0, 0.0);
    TransformMatrix t1;
    kinematic.solve_forward_kinematics(j1, t1);
    std::cout << "t1: " << std::endl;
    t1.print();

    TransformMatrix t2 = t1;
    t2(0, 3) += 0.1f;
    std::cout << "t2: " << std::endl;
    t2.print();

    Joint j2 = j1;
    kinematic.solve_inverse_kinematics(t2, j2);
    std::cout << "j2: " << std::endl;
    for (int i = 0; i < 6; i++) {
        std::cout << j2[i] << " ";
    }
    std::cout << std::endl;

    TransformMatrix t3;
    kinematic.solve_forward_kinematics(j2, t3);
    std::cout << "t3: " << std::endl;
    t3.print();
}
```

```shell
t1: 
Transform Matrix:
[  0.8572,   0.5150,  -0.0000,   0.1531]
[  0.0000,  -0.0000,   1.0000,  -0.0000]
[  0.5150,  -0.8572,  -0.0000,   0.0397]
[  0.0000,   0.0000,   0.0000,   1.0000]
t2: 
Transform Matrix:
[  0.8572,   0.5150,  -0.0000,   0.2531]
[  0.0000,  -0.0000,   1.0000,  -0.0000]
[  0.5150,  -0.8572,  -0.0000,   0.0397]
[  0.0000,   0.0000,   0.0000,   1.0000]
j2: 
-4.71993e-13 1.1615 -0.856673 0.724918 -2.53619e-13 -4.4205e-13 
t3: 
Transform Matrix:
[  0.8572,   0.5150,  -0.0000,   0.2531]
[  0.0000,  -0.0000,   1.0000,  -0.0000]
[  0.5150,  -0.8572,  -0.0000,   0.0397]
[  0.0000,   0.0000,   0.0000,   1.0000]
```

From the test results, the ESP32-P4 Onboard Kinematics results are consistent with the [Inverse Kinematics](#inverse-kinematics) test results.

#### URDFly (Optional)

URDF (Unified Robot Description Format) is an XML-based standard for describing a robot’s kinematic structure and basic dynamic properties. It is used to define links, joints, inertial parameters, joint limits, as well as collision and visual geometries. URDF is widely adopted in robotics as the common model format in the ROS ecosystem, and is natively supported by mainstream simulation and motion-planning tools such as Gazebo, RViz, and MoveIt.

However, URDF is relatively complex on MCU platforms, and it is more suitable to use D-H parameters to describe the robotic arm and perform forward and inverse kinematics. Use [URDFly](https://github.com/Democratizing-Dexterous/URDFly) or other similar tools to parse URDF into D-H parameters.

Taking `Ragtime_Panthera` as an example, after cloning URDFly and installing all dependencies according to the README, follow these steps to visualize and convert the `Ragtime_Panthera` [URDF](https://github.com/YanKE01/Ragtime_Panthera/blob/master/1_3D_Model/1_URDF/panther_description/urdf/panther_description.urdf):

1. Replace `package://panther_description` in the URDF file with `../`

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/follower_urdf_modify.png"
    alt="Ragtime Panthera URDF Modify"
    caption="Ragtime Panthera URDF Modify"
    >}}

2. Open URDFly and load the modified URDF file

```shell
(urdfly) PS D:\project\github\URDFly> python .\main.py
```

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/urdfly_open_urdf.jpg"
    alt="Open URDF"
    caption="Open URDF"
    >}}

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/urdfly_mainwindow.jpg"
    alt="URDFly Main Window"
    caption="URDFly Main Window"
    >}}

Drag the sliders on the right to move each joint. Click the buttons on the left to obtain MDH parameters and other information.

### Joint Motor Debugging

Before officially starting to debug [DM motors](https://github.com/dmBots/dmBot), refer to the [DM Motor Getting Started Guide](https://gl1po2nscb.feishu.cn/wiki/LjOXwEqNCiqThpk1IIycHoranlb) to understand the DM motor control process. Download the [DM Debug Tool v.1.6.8.6](https://dl.espressif.com/AE/esp-iot-solution/DM调试工具v.1.6.8.6.exe) here.

When opening the DM motor kit (using DM4310-24V as an example), the following components are included:

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/dm_motor_kit.jpg"
    alt="DM Motor kit"
    caption="DM Motor kit"
    >}}

Connect all components in the kit according to the wiring diagram below, provide 24 V power to the power adapter board, and connect the PC to the USB-to-CAN module via a USB Type-C cable:

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/dm_motor_connect.jpg"
    alt="DM Motor Connect"
    caption="DM Motor Connect"
    >}}

Next, open the DM debug tool and test it. Select the correct serial port and try to read parameters in the `Parameter Settings` tab:

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/dm_debug_tool.jpg"
    alt="DM Debug Tool"
    caption="DM Debug Tool"
    >}}

When the parameters are successfully read, it indicates that the motor connection is successful. Try position mode testing in the `Debug` tab:

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/dm_debug_tool_position_ctrl.jpg"
    alt="DM Position Control"
    caption="DM Position Control"
    >}}

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/dm_motor_operation.gif"
    alt="DM Motor Operation"
    caption="DM Motor Operation"
    >}}

### Mechanical Assembly

After gaining a preliminary understanding of the kinematics and DM motors mentioned above, follow the steps below to assemble the follower robotic arm. Before that, prepare the following materials:

* **ESP32-P4-Function-EV-Board**: Consists of the ESP32-P4 development board and a 7-inch MIPI DSI capacitive touchscreen (1024 × 600)
* **CAN module**: Used to connect the ESP32-P4 with DM motors
* **USB camera**: The resolution selected for this project is 640 × 480. Confirm that the selected USB camera supports this resolution
* **XT30 2+2 dual-end cables**: Used to connect the motors together. Prepare at least 6 cables
* **Various CNC and sheet metal structural components**: This will be detailed in the structural assembly section
* **24 V power supply**: Used to power the DM motors
* **DM motors**: 4x DM4340, 2x DM4310, and 1x DMH3510

> **Note:** In the original Ragtime_Panthera project, a combination of 3x DM4310, 3x DM4340, and 1x DMH3510 was used, where DM4310 was used for base_link rotation. However, during actual operation, due to the large inertia of the robotic arm when extended, the base_link DM4310 was eventually replaced with DM4340. No additional structural modifications are required.

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/follower_actual_installation.png"
    alt="Overall View"
    caption="Overall View"
    >}}

#### DM Motor Configuration

Before installing the motors into the mechanical structure, use the DM debug tool to preset the Master ID and CAN ID for each motor:

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/follower_id_setting.jpg"
    alt="ID Setting"
    caption="ID Setting"
    >}}


#### Structural Assembly

Before assembly, refer to the [BOM](https://github.com/YanKE01/Ragtime_Panthera/tree/master/1_3D_Model/3_BOM) to prepare the required materials in advance, such as screws, nuts, fixing plates, sliders, rails, wires, etc. In addition, due to the variety of materials involved, they need to be processed using different manufacturing methods:

* **Sheet Metal Fabrication**
  * **Joint 1-2 connector**: The machining holes require threads. See [here](https://github.com/YanKE01/Ragtime_Panthera/blob/master/1_3D_Model/2_JLC_metalplate/304_stanless_steel/%E6%94%BB%E7%89%99%E5%9B%BE/%E4%B8%80%E4%BA%8C%E8%BD%B4.png). Choose stainless steel 304 material
  * **Joint 2-3 link**: The machining holes require threads. See [here](https://github.com/YanKE01/Ragtime_Panthera/blob/master/1_3D_Model/2_JLC_metalplate/304_stanless_steel/%E6%94%BB%E7%89%99%E5%9B%BE/%E4%BA%8C%E4%B8%89%E8%BD%B4.png). Choose stainless steel 304 material
  * **Joint 3-4 link**: The machining holes require threads. See [here](https://github.com/YanKE01/Ragtime_Panthera/blob/master/1_3D_Model/2_JLC_metalplate/304_stanless_steel/%E6%94%BB%E7%89%99%E5%9B%BE/%E4%B8%89%E5%9B%9B%E8%BD%B4.png). Choose stainless steel 304 material
  * **Joint 4-5 connector**: No thread requirement. Choose aluminum alloy 5052 material
  * **Joint 5-6 connector**: No thread requirement. Choose aluminum alloy 5052 material

* **CNC Machining**
  * **Base plate**: No thread requirement. Choose aluminum alloy 6061 material

You can use online machining suppliers such as JLC for processing. In addition, the remaining materials can be 3D printed.

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/follower_all_assembly_components.png"
    alt="All Assembly Components"
    caption="All Assembly Components"
    >}}

### ESP32-P4-Function-EV-Board Installation and Debugging

Since the follower project uses the ESP32-P4-Function-EV-Board kit, install the LCD screen on the ESP32-P4-Function-EV in advance. Refer to the [User Guide](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32p4/esp32-p4-function-ev-board/user_guide.html#) for initial hardware and software testing:

| LCD Adapter Board | ESP32-P4-Function-EV |
|-------------------|----------------------|
| J3 header | MIPI DSI connector |
| RST_LCD pin of J6 header | GPIO27 pin of J1 header |
| PWM pin of J6 header | GPIO26 pin of J1 header |
| 5 V pin of J6 header | 5 V pin of J1 header |
| GND pin of J6 header | GND pin of J1 header |


#### Hardware Connection and Project Compilation

After cloning the follower project, use `idf.py menuconfig` to enter `(Top) → Panthera Follower Configuration` to configure the project, such as CAN TX/RX pins, C6 firmware flashing pins, etc.

```shell
git clone git@github.com:espressif/esp-iot-solution.git
cd esp-iot-solution/examples/robot/ragtime_panthera/follower
idf.py set-target esp32p4
idf.py menuconfig
idf.py build
```

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/follower_menuconfig.png"
    alt="Follower Menuconfig"
    caption="Follower Menuconfig"
    >}}

* **Direct control robot arm via console:** Enable this option. When using `idf.py monitor`, the follower can be directly controlled in the terminal using commands
* **Hardware Configuration:** Used to configure the connection between ESP32-P4 and the CAN module. By default, TX is GPIO24 and RX is GPIO25
* **Leader and Follower Gripper Mapping:** Used to configure the gripper angle mapping relationship between the leader and follower robotic arms. By default, it uses radians and is multiplied by 100
* **Leader and Follower Angle Inversion:** Used to configure whether the angles between the leader and follower robotic arms need to be inverted. Due to differences in mechanical structure installation, the positive direction of joint rotation may differ. Use the right-hand rule to determine the positive rotation direction of each joint and set whether the corresponding joint needs to be inverted
* **Receiver Serial Flash Config:** Used to configure the ESP-NOW receiver for the follower. Since the current [esp-hosted-mcu](https://github.com/espressif/esp-hosted-mcu) does not support ESP-NOW, the project independently implements ESP-NOW packet reception on the ESP32-C6 side and uses [esp-serial-flasher](https://github.com/espressif/esp-serial-flasher) to download the firmware to ESP32-C6. By default, the ESP32-C6 RX, TX, Reset, and Boot pins are connected to GPIO6, GPIO5, GPIO54, and GPIO53, respectively:

| ESP32-P4 Pin | Connection Description |
|--------------|------------------------|
| GPIO24 | Connect to CAN module TX |
| GPIO25 | Connect to CAN module RX |
| GPIO6 | Connect to ESP32-C6 U0RXD |
| GPIO5 | Connect to ESP32-C6 U0TXD |
| GPIO54 | Connect to ESP32-C6 EN |
| GPIO53 | Connect to ESP32-C6 BOOT |

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/follower_hardware_connect.jpg"
    alt="ESP32-P4-Function-EV-Board Hardware Connection"
    caption="ESP32-P4-Function-EV-Board Hardware Connection"
    >}}

> **IMPORTANT:** For the first firmware compilation, enable the `Direct control robot arm via console` and `Enable update C6 Flash` options, and complete the wiring according to the default configuration.

#### Flashing and Running

Taking Linux as an example, after completing the compilation, connect the ESP32-P4 to the PC. The system will automatically generate a serial port device node (e.g., `/dev/ttyUSB0`), which can then be used for firmware download and serial port log debugging:

```shell
idf.py -p /dev/ttyUSB0 flash monitor
```

After flashing is complete, test console commands in the terminal. The following commands are currently supported:

| Command | Description | Usage |
|---------|-------------|-------|
| `panthera_enable` | Enable or disable all motors | `panthera_enable <on\|off>` |
| `panthera_goto_zero` | Move all joints to zero position | `panthera_goto_zero` |
| `panthera_set_zero` | Set current position as zero for all motors | `panthera_set_zero` |
| `panthera_goto_position` | Move end-effector to specified Cartesian coordinates | `panthera_goto_position -x <x> -y <y> -z <z>` |
| `panthera_set_vision_matrix` | Set the vision calibration matrix | `panthera_set_vision_matrix -1 <m1> -2 <m2> ... -9 <m9>` |
| `panthera_get_vision_matrix` | Read and display the current calibration matrix | `panthera_get_vision_matrix` |
| `panthera_read_position` | Read all joints position info | `panthera_read_position` |

After flashing the firmware for the first time, execute the `panthera_read_position` command to verify whether motor communication is normal. Under normal circumstances, the angle information of all added motors should be obtained. When executing `panthera_enable on`, all motors should light up with green LEDs, and when executing `panthera_enable off`, all motors will return to red LEDs. Additionally, adjust the follower robotic arm to the structural zero position and enter `panthera_set_zero` to align the structural zero with the motor zero.

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/follower_screen.png"
    alt="Follower Screen"
    caption="Follower Screen"
    >}}

You can directly start all motors, execute grasping actions (provided that the vision calibration matrix has been calibrated), return to zero, and set zero on the screen.

{{< alert >}}
For the DMH3510 motor, set the DMH3510 zero point in the closed state after installing the clamping structure. In addition, before powering on the DMH3510, ensure that its angle range is between 0 and 360°. If the DMH3510 angle is moved beyond 360° while powered off, the DMH3510 zero point will change. Therefore, ensure that the DMH3510 remains near the zero point before powering on.
{{< /alert >}}

#### Vision Calibration

For vision calibration, this article adopts an eye-to-hand configuration, where both the camera and robotic arm positions are fixed, which is much simpler compared to eye-in-hand configurations. Before formal calibration, move the robotic arm to specific positions and record the corresponding pixel coordinates at those positions. To simplify the calibration process, create a separate calibration board and place AprilTag markers at specific positions, which can then be recognized by a PC to directly generate the calibration matrix:

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/follower_apriltag.jpg"
    alt="Follower Apriltag Vision Calibration"
    caption="Follower Apriltag Vision Calibration"
    >}}

Refer to the approach shown in the figure above: place the robotic arm on a 300 mm × 300 mm plate, fix the camera on one side of a 300 mm × 600 mm plate, and use the following script for calibration:

```python
import numpy as np

A = np.array([[170, 250, 331, 332, 246, 247],
              [232, 227, 228, 375, 377, 291]])
B = np.array([[0.4431, 0.4431, 0.4431, 0.17, 0.17, 0.3277],
              [0.15, 0, -0.15, -0.15, 0, -0.1],
              [0.0397, 0.0397, 0.0397, 0.0397, 0.0397, 0.0397]])


A_hom = np.vstack([A, np.ones(A.shape[1])])

M = np.zeros((3, 3))

for i in range(3):
    m_i, _, _, _ = np.linalg.lstsq(A_hom.T, B[i, :], rcond=None)
    M[i, :] = m_i

print(repr(M))

flat = M.flatten()
print_str = 'panthera_set_vision_matrix'
for idx, val in enumerate(flat, start=1):
    print_str += f' -{idx} {val:.6f}'
print(print_str)

for i in range(A.shape[1]):
    a = np.array([0, 0, 1])
    a[0] = A[0][i]
    a[1] = A[1][i]
    b = M @ a
    print(repr(b))
```

The results from the above script cannot be directly used as the calibration results for the project, as they depend on the position and angle of the camera installation. Use the `panthera_set_vision_matrix` command to move the robotic arm end-effector to each point in `B`, record the pixel coordinates of these points, and replace `A`. Alternatively, attach AprilTag markers at these points to facilitate PC recognition of pixel positions.

After calibration is complete, directly input the output command into the idf monitor terminal, and the calibration data will be automatically saved to NVS.

#### Object Detection

This article uses the [color_detect](https://github.com/espressif/esp-dl/tree/master/models/color_detect) model by default to detect green blocks as targets for the robotic arm to grasp:

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/color_detect.gif"
    alt="Ragtime Panthera Follower Color Detect"
    caption="Ragtime Panthera Follower Color Detect"
    >}}

Additionally, `esp-dl` provides many other AI models. Visit [esp-dl](https://github.com/espressif/esp-dl/tree/master/models) to access more on-board AI models.

#### Target Grasping

After completing the calibration, correctly saving the parameters to NVS, and properly inserting the USB camera into the high-speed USB port of the ESP32-P4-Function-EV-Board, the LCD screen will display the camera feed. Place a green block to check whether it is correctly detected on the screen, and click the `Grasp` button to attempt grasping.

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/ragtime_panthera_grasp.gif"
    alt="Ragtime Panthera Follower Grasp"
    caption="Ragtime Panthera Follower Grasp"
    >}}

> **Note:** The current follower project only integrates green color detection. In future maintenance, we will attempt to support recognition of more objects.

#### Leader and Follower Robotic Arm Synchronization

The leader and follower robotic arms communicate via ESP-NOW (currently only supporting one-way transmission from leader to follower). Use the leader robotic arm to synchronize joint angle information to the follower robotic arm via ESP-NOW to achieve remote control. Click the `Sync` and `Enable` switches on the screen to enable synchronization.

The data packet for the leader's servo angles is structured as follows: a header (2 bytes), 7 servo joint data items (7*2 bytes), and a CRC check (2 bytes):

| Field  | Size (bytes) | Description | Notes / Encoding |
| ------ | ------------ | ----------- |----------------- |
| Header     | 2        | Fixed header indicating start of packet | Always `0xFF 0xFF` |
| Joint Data | 14 (7×2) | Seven servo joint angles | Each angle in radians × 100, converted to `uint16`; stored as low byte then high |
| CRC        | 2        | CRC check over the entire packet (excluding CRC field itself) | CRC16, little-endian output, initial value `UINT16_MAX` |

If synchronization issues are encountered, check for the following problems:

* ESP32-C6 firmware issue: Check whether the ESP32-C6 firmware for the `follower` has been downloaded. Open the `follower` project, run `idf.py menuconfig`, then navigate to `(Top) → Panthera Follower Configuration → Receiver Serial Flash Config`, and enable `Enable update C6 Flash` to complete the initial firmware download. After the download is complete, disable `Enable update C6 Flash` to save startup time.
* ESP-NOW communication issue: Check whether the receiver MAC address configured in the `leader` project is correct. Enter the MAC address of the ESP32-C6 in the ESP32-P4-Function-EV-Board.

{{< figure
    src="https://dl.espressif.com/AE/esp-iot-solution/ragtime_panthera_remote_control.gif"
    alt="Leader and Follower Synchronization"
    caption="Leader and Follower Synchronization"
    >}}

## Summary

This article introduces the complete process of implementing a robotic arm project on ESP32-P4, including the fundamentals of kinematics, vision calibration, and remote communication, demonstrating the feasibility of ESP32-P4 in industrial robotic arm applications. Based on this article, you can explore the application boundaries of ESP32-P4.

Feel free to try these examples, implement your own applications, and share your experience!

## Resources

* [Follower_Project](https://github.com/espressif/esp-iot-solution/tree/master/examples/robot/ragtime_panthera/follower): A complete grasping project including DM motor control, kinematics, and vision.
* [Leader_Project](https://github.com/espressif/esp-iot-solution/tree/master/examples/robot/ragtime_panthera/leader): XL330_M077 bus servo control and ESP-NOW communication.
* [Ragtime_Panthera](https://github.com/Ragtime-LAB/Ragtime_Panthera): Original follower robotic arm project
* [Trlc_Dk1](https://github.com/robot-learning-co/trlc-dk1): Original leader robotic arm project
* [Matrix_and_Robotics_on_STM32](https://github.com/SJTU-RoboMaster-Team/Matrix_and_Robotics_on_STM32): Reference implementation of kinematics for the follower robotic arm.
* [URDFly](https://github.com/Democratizing-Dexterous/URDFly): Convert URDF parameters to MDH parameters.
* [Robotics-Toolbox-Python](https://github.com/petercorke/robotics-toolbox-python): Python version of the MATLAB Robotics Toolbox.
* [ESP_DL](https://github.com/espressif/esp-dl): Includes models such as color detection, YOLO, and face detection.
