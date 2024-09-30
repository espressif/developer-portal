---
title: "Testing applications with Pytest and NuttX"
date: 2024-10-04
tags: ["NuttX", "Apache", "ESP32", "Pytest", "Testing"]
showAuthor: false
authors:
    - "filipe-cavalcanti"
---

## Introduction

Testing should be a primary focus in the development process of any embedded system. It significantly reduces the chances of failure, ensures long-term stability—especially in a continuous integration (CI) environment—and can drive development by promoting testable features. This is where test-driven development (TDD) and its many variations come into play.

In my experience, testing can be easy to maintain and improve, provided you have a solid test setup.

Testing software for an embedded product can, to some extent, be done without a target. Unit tests running on the developer's machine can validate parts of the software that do not require hardware interaction. This is often true for tasks like mathematical computations, video and image processing, data parsing, and more. In such cases, tools like CppTest or GoogleTest can handle the job. Even when hardware is involved, interfaces and peripherals can be mocked to simulate some parts of the system.

While this covers a significant portion of testing, at some point, on-target testing becomes essential. With the internal components already tested through unit tests, we focus on testing the overall application while communicating with the device. The most common way to achieve this is through the serial port or JTAG.

In this article, I’ll discuss high-level testing using Pytest with the NuttX RTOS.

## Pytest

There are several high-level testing tools available today, but we are going to focus on Python, specifically the pytest framework.

Pytest allows us to set up a test environment and scale tests easily, using fixtures to manage test resources (such as serial communication) and parametrization to run multiple test cases efficiently.

Pytest integrates with argparse, enabling us to pass arguments to tests via the command line or by specifying them in an .ini file. These arguments can be accessed by any test case when needed.

Another significant advantage of pytest is the large number of available plugins. Pytest provides a standard way to implement [plugins](https://docs.pytest.org/en/stable/reference/plugin_list.html) using its hooks, allowing contributors to share their plugins with the community. 

## Setting Up the Test Environment

If you are running Linux, you probably already have Python installed. If that’s the case, let's create a directory for our tests called `embedded_test`.

```
fdcavalcanti@espubuntu:~$ mkdir embedded_test
fdcavalcanti@espubuntu:~$ cd embedded_test/
```

Inside this directory, we need to create a Python virtual environment. A virtual environment is simply a directory where we install all downloaded packages to avoid conflicts with the system’s default packages.

To create the virtual environment, use Python's venv tool and create an environment called "venv". Then, activate the environment. Notice that (venv) appears to the left of my prompt, indicating that all Python packages will now come from this virtual environment rather than the system.

```
fdcavalcanti@espubuntu:~/embedded_test$ python3 -m venv venv
fdcavalcanti@espubuntu:~/embedded_test$ source venv/bin/activate
(venv) fdcavalcanti@espubuntu:~/embedded_test$ 
```

Next, upgrade pip (Python’s package manager) and install the following packages:
- pytest
- pyserial

Once installed, you can verify the packages with pip3 list.

```
(venv) fdcavalcanti@espubuntu:~/embedded_test$ pip3 install --upgrade pip
(venv) fdcavalcanti@espubuntu:~/embedded_test$ pip3 install pytest
(venv) fdcavalcanti@espubuntu:~/embedded_test$ pip3 install pyserial
(venv) fdcavalcanti@espubuntu:~/embedded_test$ pip3 list
Package         Version
--------------- -------
iniconfig 2.0.0
packaging 24.1
pip       24.0
pluggy    1.5.0
pyserial  3.5
pytest    8.3.3
```

Now, the environment is ready, and we can begin setting up our tests.

## Establishing Communication
    
Before we can test an application, we need to establish working serial communication that we can use in our tests. First, we’ll create a Python class to handle this, and then we’ll explore how pytest can leverage it.

## Serial Communication Class

Let’s create a file called communication.py. The first step is to import `pyserial`, which will assist us with serial communication.

Our class will be called SerialCommunication and will contain the mandatory init method, a write method, and a close method, which are sufficient to get started:
- init: Receives the arguments to instantiate our communication class, such as the serial port, baud rate, and timeout.
- write: Accepts a string argument that represents the data we are sending through the serial port.
- close: Closes the connection.

The following is what our initialization looks like. The timeout argument is important to avoid locking our serial port in case of a failure where the device is unresponsive. It can also be adjusted on the fly for long test cases.

```python
import serial  

class SerialCommunication:
def __init__(self, port: str, baudrate: int=115200, timeout: int=10):
	self.port = port
	self.baudrate = baudrate
	self.timeout = timeout
	self.ser = serial.Serial(self.port,
							 baudrate=self.baudrate,
							 timeout=self.timeout)
```

The SerialCommunication class also allows you to set additional parameters such as byte size, parity, stop bits, and hardware flow control. It raises an exception if a parameter is out of range or if the serial device is invalid.

Next, we have the write method. Since we can’t send a Python string directly to our device, it must be encoded before transmission. Additionally, we need to check for a line break, which corresponds to the "Enter" key press.

When data is transmitted, we naturally expect a response. In the case of NuttX, when using Nuttshell, the Nutshell prompt (nsh> ) appears whenever we write something and the process ends (or keeps running in background, but are simplifying here). This indicates that the shell is ready for the next command, which, in our context, means our previous command has completed. In simple terms, after sending a command, we should read everything until the prompt appears.

```python
def write(self, command: str) -> str:
	if '\n' not in command:
		command += '\n'
	data_send = command.encode()

	self.ser.write(data_send)
	response = self.ser.read_until("nsh> ".encode())

	return response.decode()
```

Finally, we add a simple close method that releases our serial port:

```python
def close(self) -> None:
	self.ser.close()
```

### Testing Communication

I have an [ESP32H2 Devkit](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32h2/esp32-h2-devkitm-1/user_guide.html) connected to my serial port at `/dev/ttyUSB0` and
running the `nsh` firmware configuration.

If you are not familiar with building NuttX, checkout this article on [getting started with NuttX and ESP32](https://developer.espressif.com/blog/nuttx-getting-started/).

Below, we will add a simple main routine to our communication.py file to validate that our communication works by sending the help and uname commands and reading the responses.

```python
if __name__ == "__main__":
	device = SerialCommunication("/dev/ttyUSB0")
	ans = device.write("uname -a")
	print(ans)
	device.close()
```

Output from the routine above:

```console
(venv) fdcavalcanti@espubuntu:~/embedded_test$ python3 communication.py 
uname -a
NuttX 10.4.0 4622e4f996-dirty Sep 27 2024 14:52:14 risc-v esp32h2-devkit
nsh> 
```

So it works. We have the communication basis that allows us to structure our Pytest environment. The same recipe can be followed for communication via telnet, sockets, MQTT, or whatever is needed for the application.

## Structuring the Pytest environment

In pytest, you can run tests using a single file. However, we will be working with tests alongside a conftest.py file. The conftest.py file allows us to dynamically set test case parameters, create fixtures that are shared across all tests, set up community plugins, parse command-line arguments, and more. In this file, we will define a fixture for serial communication that will be used throughout the entire test session.

But before proceeding, we need a brief introduction on fixtures.

### Fixtures

Fixtures in pytest can be thought of as reusable methods. If we had 100 test cases, it would not be good practice to open and close our serial port 100 times. Instead, it’s simpler to use a serial port fixture that opens once at the beginning of the test session and closes when all tests are completed.

In pytest, we signal that a function should be used as a fixture by adding the @pytest.fixture decorator. This decorator can accept several arguments, such as a name and its scope, which can be:

- function: This tells pytest to execute the fixture routine entirely every time a function calls it. In our serial fixture, this would mean that the serial port would be opened and closed for each test.
- module: A module refers to a single test file. If the serial port is initialized in test_uname.py, it would remain open until all tests in that module are complete, at which point it would close.
- session: The test session begins after tests are collected, and the serial port is opened only once at this point. It closes after all tests have finished.
- There are also class and package scopes, which follow the same idea.

See the [documentation](https://docs.pytest.org/en/6.2.x/fixture.html) for fixture usage examples and other use cases.

### Setting up conftest

This first example's conftest.py file will be responsible for one task: creating the serial port fixture.

Create the conftest file:
```
(venv) fdcavalcanti@espubuntu:~/embedded_test$ touch conftest.py 
```

Then, import the SerialCommunication class and create the fixture using session scope, naming it "target".

```python
import pytest
from communication import SerialCommunication

@pytest.fixture(scope="session", name="target")
def serial_comm_fixture():
	serial = SerialCommunication("/dev/ttyUSB0")
	yield serial
	serial.close()
```

### Writing the First Test

Now that conftest.py is ready, we can write our first test to check if the information returned from uname is valid.
First, create the test_uname.py file, and then write the test to verify that "esp32h2-devkit" is returned.

```
(venv) fdcavalcanti@espubuntu:~/embedded_test$ touch test_uname.py
```

```python
def test_uname_board(target):
	board = "esp32h2-devkit"
	ans = target.write("uname -a")
	assert board in ans
```

To execute, call `pytest -v` and the test should pass.

```
(venv) fdcavalcanti@espubuntu:~/embedded_test$ pytest -v
============================== test session starts ==============================

platform linux -- Python 3.12.3, pytest-8.3.3, pluggy-1.5.0 -- /home/fdcavalcanti/embedded_test/venv/bin/python3
cachedir: .pytest_cache
metadata: {'Python': '3.12.3', 'Platform': 'Linux-6.8.0-45-generic-x86_64-with-glibc2.39', 'Packages': {'pytest': '8.3.3', 'pluggy': '1.5.0'}, 'Plugins': {'metadata': '3.1.1', 'html': '4.1.1'}}
rootdir: /home/fdcavalcanti/embedded_test
plugins: metadata-3.1.1, html-4.1.1
collected 1 item

test_uname.py::test_uname_board PASSED [100%] 
============================== 1 passed in 0.14s ==============================
```

This is excellent, our first test executed succesfully. We were able to open the serial port, write a command and verify the results contained the information we expected.

With our own version of Hello World done, we can expand into better tests.

## Improving the Tests

There are several ways to enhance our test. We can use parametrization, additional fixtures, configuration files, command-line arguments, dynamic test cases, and more. For now, let’s focus on two examples: parametrization and general fixture improvements.

### Test Case Parametrization

Pytest's documentation on [parametrization](https://docs.pytest.org/en/stable/how-to/parametrize.html) is an excellent resource for more information. In this example, I’ll focus on the parametrization decorator.

Parametrization of a test allows us to run multiple test cases efficiently. For instance, if we are testing the `mkdir` functionality and want to validate that our file system can create directories with mixed numbers and letters, we can avoid using a large "for loop" or writing many test functions for each name combination. Instead, we can parametrize a single test, enabling us to cover multiple test cases in just a few lines of code.

Let’s create a routine to create a directory, check if it was created, delete it, and verify that it has been deleted.

```python
def test_dir_create_delete(target):
	directory = "testdir"
	target.write(f"mkdir {directory}")
	ans = target.write("ls")
	assert directory in ans
	
	target.write(f"rmdir {directory}")
	ans = target.write("ls")
	assert directory not in ans
```

```
test_directory.py::test_dir_create_delete PASSED   [ 50%]
test_uname.py::test_uname_board PASSED             [100%]
```

This is one way to accomplish the task, and it works. However, it only tests a single directory. To expand our testing, we’ll use pytest's parametrization feature. We simply need to add a "directory" argument to our test function and then apply the parametrize decorator, which will automatically call this test function for all values in the list of directory names.


```python
@pytest.mark.parametrize("directory", ["testdir", "testdir000", "0_testdir_1"])
def test_dir_create_delete(target, directory):
	target.write(f"mkdir {directory}")
	ans = target.write("ls")
	assert directory in ans
	
	target.write(f"rmdir {directory}")
	ans = target.write("ls")
	assert directory not in ans
```

On the output below, we can see that our directory names are treated each as a test case for the `dir_create_delete` test.

```
test_directory.py::test_dir_create_delete[testdir]     PASSED  [ 25%]
test_directory.py::test_dir_create_delete[testdir000]  PASSED  [ 50%]
test_directory.py::test_dir_create_delete[0_testdir_1] PASSED  [ 75%]
test_uname.py::test_uname_board                        PASSED  [100%]
```

### Using Fixtures for Session Parameters

Now that we know how to run a simple parametrized test, we should leverage pytest to expand our testing efficiency even further. We will continue working on the uname_board test but will use a different fixture to eliminate the constant `board = "esp32h2-devkit"`, making our test more generic.

First, we need to understand the purpose of our test. The test description is:

"Run uname -a and assert that it shows the correct board we are using."

Of course, the test won’t know what to expect when we connect a different board, but we, as users, can pass the expected board as a test argument.

The first step is to remove the board string and replace it with a fixture. Delete the line containing the board name and add "board" to the test function arguments, making it look more generic, like this:

```python
def test_uname_board(target, board):
	ans = target.write("uname -a")
	assert board in ans
```

Now go back to `conftest.py` and create a session scoped fixture that yields the board name.

```python
@pytest.fixture(scope="session", name="board")
def board_name():
	yield "esp32h2-devkit"
```

Run the test again and it should pass.

At this point our `conftest` has two magic strings: the board name in the new fixture and the serial port path in the serial port fixture. Let's fix this.

### Adding Command-Line Options

First, create a function called `pytest_addoption`. Pytest uses this hook function automatically to append command line arguments.

We'll add two command-line options:
1. **usbport**: Receive the target USB port. Defaults to `/dev/ttyUSB0`.
2. **board**: Target board name. Must always be passed.

```python
def pytest_addoption(parser):
	parser.addoption("--usbport", action="store", default="/dev/ttyUSB0", help="USB port")
	parser.addoption("--board", action="store", required=True, help="Espressif devkit")
```

Now that our UBS Port and board name are passed from the command-line, we should tell our fixtures to find the values in the
[request fixture](https://docs.pytest.org/en/6.2.x/example/simple.html#request-example).

```python
@pytest.fixture(scope="session", name="target")
def serial_comm_fixture(request):
	serial = SerialCommunication(request.config.getoption("--usbport"))
	yield serial
	serial.close()


@pytest.fixture(scope="session", name="board")
def board_name(request):
	yield request.config.getoption("--board")
```

Time to run the tests again. We know it defaults to `/dev/ttyUSB0` so I'll only pass the board name:

`$ pytest -v --board esp32h2-devkit`

And now using a different port:

`$ pytest -v --board esp32h2-devkit --usbport /dev/ttyUSB1`

And we can see that tests are still passing and the command-line arguments are shown in the test output.

## Conclusion

Pytest allows you to quickly setup a test environment for your projects. It is simple, fast, reliable and can help spot mistakes on the long run. At Espressif, we use automated tests on everything we do, and you should too. Have fun testing your projects!

## Resources

For more information, refer to the links below.

- [Pytest getting started](https://docs.pytest.org/en/stable/getting-started.html)
- [Example repository](https://github.com/fdcavalcanti/pytest-nuttx-testing-sample)
- [Getting Started with NuttX and ESP32](https://developer.espressif.com/blog/nuttx-getting-started/)
- [GoogleTest](http://google.github.io/googletest/)
- [CppTest](https://cpptest.sourceforge.io/)
- [Robot Framework](https://robotframework.org/)
