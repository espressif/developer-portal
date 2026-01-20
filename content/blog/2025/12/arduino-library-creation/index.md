---
title: "Creating an Arduino Library for ESP32"
date: 2025-12-15
tags:
  - Arduino
  - beginner
  - tutorial
  - library
showAuthor: false
authors:
  - "lucas-vaz"
summary: "Learn how to create, structure, and publish Arduino libraries for ESP32. This step-by-step guide covers everything from understanding a library structure to submitting your library to the Arduino Library Manager."
---

Creating custom Arduino libraries is an excellent way to organize reusable code, share functionality with others, and make your projects more modular. This article covers the process of creating an Arduino library from scratch, using a simple "Hello World" library as a working example.

## What is an Arduino Library?

An Arduino library is a collection of code that provides additional functionality to your sketches. Libraries encapsulate related functions, classes, and constants into reusable modules that can be easily shared and imported into different projects. Key benefits include:

- **Code Reusability:** Write once, use in multiple projects.
- **Modularity:** Keep your main sketch clean and focused.
- **Shareability:** Easily distribute your code to the community.
- **Maintainability:** Update the library in one place.
- **Encapsulation:** Hide implementation details and expose a clean API.

Arduino libraries can range from simple utility functions to complex drivers for sensors, displays, communication protocols, and more. For ESP32 development, libraries are particularly useful for abstracting hardware-specific features like Wi-Fi, Bluetooth, GPIOs, and peripheral interfaces.

### Library Structure

An Arduino library follows a specific directory structure that the Arduino IDE recognizes. Here's the usual structure of a well-organized library:

```
Library Folder/
├── src/                   # Source code files
│   ├── LibraryName.h
│   └── LibraryName.cpp
├── examples/              # Example sketches showing library usage
│   └── ExampleSketch/
│       └── ExampleSketch.ino
├── library.properties     # Library information and metadata
├── keywords.txt           # Defines syntax highlighting for library’s functions and classes
├── README.md
└── LICENSE
```

## Prerequisites

To create an Arduino library for ESP32, you will need:

- Arduino IDE installed on your computer
- Arduino Core for ESP32 installed
- A text editor or IDE for writing code
- Basic understanding of C++ programming

If you haven't installed the Arduino Core for ESP32 yet, follow the steps in the article [Getting Started with ESP32 Arduino](https://developer.espressif.com/blog/2025/10/arduino-get-started/).

## Creating a "Hello World" Library

Let's create a simple library from scratch. Our `HelloWorldLib` library will demonstrate the core concepts of library development with a minimal example.

First, we must define what the library needs to do. In this case, we want a simple class with a few methods to print "Hello, World!" and "Hello, \<name\>!" to the Serial interface. We will call this class `HelloWorld`.

With the library's purpose defined, we can start the implementation.

### Step 1: Create the Library Folder Structure

First, we need to create the folder structure for our library. The Arduino libraries folder is typically located at:

- **Windows:** `Documents\Arduino\libraries\`
- **macOS:** `~/Documents/Arduino/libraries/`
- **Linux:** `~/Arduino/libraries/`

Navigate to your Arduino libraries folder and create the following structure:

```
HelloWorldLib/
├── src/
│   ├── HelloWorld.h
│   └── HelloWorld.cpp
├── examples/
│   └── BasicUsage/
│       └── BasicUsage.ino
├── library.properties
├── keywords.txt
├── README.md
└── LICENSE
```

### Step 2: Create `HelloWorld.h`

The header file (`.h`) serves as the public interface of our library. It declares the classes, functions, and constants that users will interact with, without exposing implementation details. When users include our library with `#include <HelloWorld.h>`, they're including this file.

For our `HelloWorldLib` library, this file will declare the `HelloWorld` class with its three public methods (`begin`, `sayHello`, `sayHelloTo`) and a constant for demonstration purposes.

Here's our `src/HelloWorld.h`:

```cpp
/*
 * HelloWorldLib for ESP32
 * A simple demonstration library for ESP32 Arduino development.
 */

#pragma once
#include "Arduino.h"

// Example of a constant for syntax highlighting
#define HELLO_WORLD_LIB_STRING "HelloWorldLib for ESP32"

class HelloWorld {
public:
  // Initialize the library with the Serial interface
  void begin(Stream &serial);

  // Print "Hello, World!" to Serial
  void sayHello();

  // Print "Hello, <name>!" to Serial
  void sayHelloTo(const char *name);

private:
  Stream *_serial;
};

```

Key points about the header file:

- **Include Guards:** Use `#pragma once` to avoid multiple inclusions of the header file and prevent errors and warnings during compilation.
- **Arduino.h:** It is recommended to include `Arduino.h` to access Arduino core functions and types.

### Step 3: Create `HelloWorld.cpp`

The implementation file (`.cpp`) contains the actual logic behind the functions and methods declared in the header. This separation keeps implementation details "hidden" from the user and allows changing the internal code without affecting users, as long as the public interface stays the same.

Here we will implement `begin()` to store the Stream reference, and `sayHello()`/`sayHelloTo()` to print messages using that stream.

The `src/HelloWorld.cpp` file:

```cpp
/*
 * HelloWorldLib for ESP32
 * Implementation file.
 */

#include "HelloWorld.h"

// Initialize the library with the Serial interface
void HelloWorld::begin(Stream &serial) {
  _serial = &serial;
}

// Print "Hello, World!" to Serial
void HelloWorld::sayHello() {
  if (_serial) {
    _serial->println("Hello, World!");
  }
}

// Print "Hello, <name>!" to Serial
void HelloWorld::sayHelloTo(const char *name) {
  if (_serial) {
    _serial->print("Hello, ");
    _serial->print(name);
    _serial->println("!");
  }
}
```

### Step 4: Create the Example Sketch

Example sketches demonstrate how to use the library in practice. They appear in the Arduino IDE under **File > Examples > [LibraryName]** and serve as both documentation and a starting point for users. Good examples are often one of the most valuable parts of a library.

Our `BasicUsage` example will show the typical workflow: include the library, create an instance, initialize it with `begin()`, and call the greeting methods.

For our `examples/BasicUsage/BasicUsage.ino`:

```cpp
/*
 * HelloWorldLib - Basic Usage Example
 *
 * This example demonstrates the basic functionality of the HelloWorldLib library.
 *
 * Compatible with all ESP32 variants.
 */

#include <HelloWorld.h>

HelloWorld hello;

void setup() {
  Serial.begin(115200);

  // Initialize the library with Serial
  hello.begin(Serial);

  // Print "Hello, World!"
  hello.sayHello();

  // Print a personalized greeting
  hello.sayHelloTo("ESP32");
}

void loop() {
  // Nothing to do here
}
```

Expected Serial Monitor output:

```
Hello, World!
Hello, ESP32!
```

### Step 5: Create `library.properties`

The `library.properties` file contains metadata that the Arduino IDE and Library Manager use to identify, categorize, and display the library. This file is required for the Arduino IDE to recognize the folder as a valid library.

Here are some of the main fields that you will need to set in the `library.properties` file:

| Field | Description |
|-------|-------------|
| `name` | The library name (must match the folder name) |
| `version` | Semantic versioning (MAJOR.MINOR.PATCH) |
| `author` | Original author(s) of the library |
| `maintainer` | Current maintainer responsible for updates |
| `sentence` | Brief one-line description (shown in Library Manager) |
| `paragraph` | Extended description with more details |
| `category` | Library category (Check the [Arduino Library Specification](https://arduino.github.io/arduino-cli/latest/library-specification/) for the list of categories) |
| `url` | Repository or documentation URL |
| `architectures` | Supported platforms (`*` for all, or specific like `esp32` for the ESP32 series of microcontrollers) |
| `includes` | Header file(s) users should include |

For the first release of your library, choose the version based on its stability:

- **Pre-release versions (0.x.x)**: Use this for initial development when the API may still change. Start with `0.1.0` for your first working version. The 0.x.x range signals to users that the library is still evolving and breaking changes may occur.
- **First stable release (1.0.0)**: Use this when your library has a stable API that you're committed to maintaining. This tells users the library is production-ready and you'll follow semantic versioning for future changes.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
Most new libraries should start with `0.1.0` and increment to `1.0.0` once the API is stable and tested.
{{< /alert >}}

For our example library, let's say that we are still in the initial development phase, it is only compatible with the ESP32 series of microcontrollers, and that the user should include the `HelloWorld.h` header file. We can add the following content to `library.properties` in the root folder:

```properties
name=HelloWorldLib
version=1.0.0
author=Your Name <your.email@example.com>
maintainer=Your Name <your.email@example.com>
sentence=A simple demonstration library for ESP32 Arduino development.
paragraph=This library demonstrates how to create Arduino libraries for Espressif ESP32 microcontrollers.
category=Other
url=https://github.com/yourusername/HelloWorldLib
architectures=esp32
includes=HelloWorld.h
```

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
- If your library is only compatible with the ESP32 series of microcontrollers, you should set the
  `architectures` field to `esp32` no matter the SoC you are using (for example, even if you are using the
  ESP32-C6, the architecture should still be `esp32`).
  
  On the other hand, if your library is independent of the architecture, setting the `architectures` field to `*` will indicate support for all architectures.

- You can also define multiple include files and architectures by separating them with commas.
{{< /alert >}}

For more information about the `library.properties` file, see the [Arduino Library Specification](https://arduino.github.io/arduino-cli/latest/library-specification/).

### Step 6: Create `keywords.txt`

The Arduino IDE uses syntax highlighting to color-code different elements in your sketch, making it easier to read and spot errors. Built-in functions like `digitalWrite` and constants like `HIGH` are automatically highlighted, but the IDE doesn't know about your library's custom classes and methods.

The `keywords.txt` file solves this by mapping your library's identifiers to keyword types. When the IDE loads a library, it reads this file and applies the appropriate colors to matching words in the editor. While optional, it significantly improves the user experience.

The file uses a simple format: each line contains an identifier followed by a TAB character and a keyword type:

- `KEYWORD1` — Used for classes and datatypes (e.g., `HelloWorld`, `String`)
- `KEYWORD2` — Used for methods and functions (e.g., `begin`, `sayHello`)
- `LITERAL1` — Used for constants (e.g., `HELLO_WORLD_LIB_STRING`, `LED_BUILTIN`)

For our library, we will register `HelloWorld` as a `KEYWORD1`, our methods as `KEYWORD2`, and `HELLO_WORLD_LIB_STRING` as a `LITERAL1`.

Our `keywords.txt` will look like this:

```
#######################################
# Syntax Coloring Map for HelloWorldLib Library
#######################################

#######################################
# Datatypes (KEYWORD1)
#######################################

HelloWorld	KEYWORD1

#######################################
# Methods and Functions (KEYWORD2)
#######################################

begin	KEYWORD2
sayHello	KEYWORD2
sayHelloTo	KEYWORD2

#######################################
# Constants (LITERAL1)
#######################################

HELLO_WORLD_LIB_STRING	LITERAL1
```

**Important:** Use actual TAB characters between the keyword and its type, not spaces. The Arduino IDE will not recognize the keywords if spaces are used.

### Step 7: Create `README.md`

The `README.md` file is the first thing users see when they visit the library's repository. It should explain what the library does, how to install it, and provide basic usage examples. A clear README reduces support questions and helps users get started quickly.

Our README will cover installation instructions, a quick usage example, and document the available methods.

Here's a simple `README.md` for our library:

````markdown
# HelloWorldLib for ESP32

A simple demonstration library that prints "Hello, World!" and "Hello, <name>!" to the Serial interface.

## Installation

### Manual Installation

1. Download the library
2. Move the `HelloWorldLib` folder to your Arduino libraries directory:
   - Windows: `Documents\Arduino\libraries\`
   - macOS: `~/Documents/Arduino/libraries/`
   - Linux: `~/Arduino/libraries/`
3. Restart the Arduino IDE

## Usage

```cpp
#include <HelloWorld.h>

HelloWorld hello;

void setup() {
  Serial.begin(115200);
  hello.begin(Serial);
  hello.sayHello();
}

void loop() {}
```

## API Reference

### Methods

- `void begin(Stream &serial)` - Initialize the library with a Serial interface
- `void sayHello()` - Print "Hello, World!"
- `void sayHelloTo(const char *name)` - Print a personalized greeting

## Compatibility

This library is compatible with all ESP32 variants.

## License

This library is released under the MIT License.
````

### Step 8: Create `LICENSE`

The `LICENSE` file is a file that contains the license under which the library is released.
It is used to specify how others can use, modify, and distribute the library.
While the license is optional, it is highly recommended to include it in your library. Without a license, others cannot legally use your code.

Common choices for Arduino libraries include MIT, Apache 2.0, and LGPL. You can easily create a `LICENSE` file using the [Choose a License](https://choosealicense.com/) website.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
For your library to be accepted by the Arduino Library Manager, it must include a valid [OSI-approved license](https://opensource.org/licenses).
{{< /alert >}}

Our `LICENSE` will look like this. Make sure to replace the `[year]` and `[fullname]` with the correct values:

```
MIT License

Copyright (c) [year] [fullname]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Testing the Library

After creating all the files, we can test our library:

1. **Restart the Arduino IDE** to load the new library.
2. Go to **File** > **Examples** > **HelloWorldLib** > **BasicUsage**.
3. Select your ESP32 board from **Tools** > **Board**.
4. Select the correct port from **Tools** > **Port**.
5. Click **Upload** to flash the sketch to the ESP32.
6. Open **Serial Monitor** at 115200 baud to see the output.

Expected output:

```
Hello, World!
Hello, ESP32!
```

## Best Practices for Library Development

When creating Arduino libraries, keep these best practices in mind:

- **Use Meaningful Names:** Choose clear, descriptive names for your library, classes, and methods.
- **Provide a `begin()` Method:** Always provide a `begin()` method that initializes the library (if applicable).
- **Include Examples:** Provide well-commented examples that demonstrate common use cases.
- **Follow Semantic Versioning:** Use semantic versioning (MAJOR.MINOR.PATCH) for releases.
- **Minimize Dependencies:** Keep dependencies to a minimum for easier installation.

## Publishing Your Library

Once your library is ready, you can share it with the community through GitHub and the Arduino Library Manager.

As mentioned before, make sure your library includes an [OSI-approved license](https://opensource.org/licenses) before publishing.

### Increment the Version

Before releasing a new version, we need to decide the new version number and update the version number in your `library.properties` file. The new version number must follow the rules of [Semantic Versioning](https://semver.org/) and be updated based on the changes made to the library since the last release:

- **MAJOR** (1.x.x → 2.0.0): Incompatible API changes
- **MINOR** (1.0.x → 1.1.0): New features, backward compatible
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, backward compatible

### Create a GitHub Release

1. **Create a repository** on GitHub and push your library code. Skip this step if you already have a repository
   for your library.

2. **Update the version** in `library.properties` based on the semantic versioning rules. In this case, we are
   releasing the first stable version of the library, so the new version number is `1.0.0`.

   ```properties
   version=1.0.0
   ```
3. **Commit and tag** the new version:

   ```bash
   git add library.properties
   git commit -m "Release version 1.0.0"
   git tag 1.0.0
   git push origin main --tags
   ```

4. **Create a release** on GitHub from the tag (optional but recommended).

### Submit to the Arduino Library Manager

Now that you have a proper repository and a release, you can submit your library to the Arduino Library Manager.
This is a one-time process that will make your library available to all Arduino users through the Library Manager. New versions of your library will be automatically published to the Library Manager when you release a new version.

To submit your library to the Arduino Library Manager:

1. Ensure your library follows all [Arduino Library Registry requirements](https://github.com/arduino/library-registry/blob/main/FAQ.md#what-are-the-requirements-for-a-library-to-be-added-to-library-manager).

2. Fork the [Arduino Library Registry](https://github.com/arduino/library-registry) repository.

3. Add your library's Git URL to the `repositories.txt` file:

   ```txt
   https://github.com/yourusername/HelloWorldLib
   ```

4. Submit a pull request. An automated bot will verify your library meets the requirements.

5. Once approved and merged, your library will appear in the Arduino Library Manager within a day.

For detailed instructions, see the [Arduino Library Registry documentation](https://github.com/arduino/library-registry#readme).

## Further Improvements

As you become more comfortable with library development, you might explore:

- **Multiple Source Files:** Split large libraries into multiple source files (`.h` and `.cpp`) for better organization.
- **Hardware Abstraction:** Support multiple ESP32 variants with hardware abstraction layers.
- **Unit Testing:** Use frameworks like Unity and [pytest-embedded](https://github.com/espressif/pytest-embedded) for testing your library code.
- **CI/CD:** Set up GitHub Actions to automatically build and test your library on each commit.

## Conclusion

The `HelloWorldLib` we built covers all the essential components of a library: header files, implementation files, examples, metadata, and documentation. These same patterns apply to more complex libraries. The base structure remains the same regardless of complexity.

Once you're comfortable with the basics, consider applying some of the suggestions above to improve your library's quality and maintainability.

---

## Additional Resources

- [Getting Started with ESP32 Arduino](https://developer.espressif.com/blog/2025/10/arduino-get-started/)
- [Arduino Core for ESP32](https://github.com/espressif/arduino-esp32)
- [Arduino Library Specification](https://arduino.github.io/arduino-cli/latest/library-specification/)
- [Arduino Library Registry](https://github.com/arduino/library-registry)
- [Arduino Library Registry FAQ](https://github.com/arduino/library-registry/blob/main/FAQ.md)
- [Choose a License](https://choosealicense.com/)
- [Semantic Versioning](https://semver.org/)
