---
title: "ESP-IDF tutorial series: Object oriented programming in C"
date: "2025-10-03"
summary: "This article explains how ESP-IDF brings object-oriented programming principles into C by using `structs`, opaque pointers, and handles to enforce encapsulation and modularity. It shows how components like HTTP servers and I²C buses are managed through handles that represent distinct objects for configuration and operation, and compares this approach to Python and C++."
authors:
  - "francesco-bez"
tags: ["ESP32C3", "OOP", "ESP-IDF"]
---

## Introduction

When working with the ESP-IDF framework, you may noticed that much of its design feels object-oriented, even though it’s written in C. This is because ESP-IDF makes use of object-oriented programming (__OOP__) principles implemented in plain C, giving developers the benefits of structured, modular code without relying on C++.

Of course, C by itself does not provide built-in OOP features such as classes, inheritance, or polymorphism. However, developers can emulate OOP patterns in C effectively through well-established techniques, like encapsulation using `structs`, function pointers to mimic polymorphism, and modular design.

Applying OOP concepts in embedded C development brings several advantages:

* __Encapsulation__: Keeps implementation details hidden while exposing clean, minimal interfaces.
* __Reusability__: Encourages building reusable components rather than rewriting code.
* __Maintainability__: Makes large projects easier to extend and modify without breaking existing functionality.
* __Scalability__: Provides a clear structure for organizing complex systems.

In this article, we’ll explore how ESP-IDF applies OOP concepts in C, look at the techniques it uses under the hood, and check a few API functions with these concepts in action.

In a later article, we'll put these concept into practice and we'll write our first object in C.

<!-- TODO[Link to an article once written]
Owner: Francesco Bez
Note: Write an article about creating an object in C
Context: Developer Portal's GitLab MR `26#note_1948368`
Tags: ESP32
-->


## What is OOP

Object-Oriented Programming (OOP) is a design paradigm that organizes software around __objects__ rather than just separate functions and data. Each object represents a self-contained unit with its own state (data) and behavior (methods), making it easier to reason about complex systems as a collection of interacting parts.

The origins of OOP trace back to the 1960s, when Ole-Johan Dahl and Kristen Nygaard introduced the Simula language to model real-world entities for simulations. This approach was later popularized by languages like Smalltalk and eventually adopted in mainstream programming through C++ and Java.

## OOP in C

C is not an object-oriented language by design, yet it provides enough building blocks to emulate many of the same principles. By carefully combining `structs`, pointers, and modular design with header files, developers can achieve encapsulation, modularity, and even a form of polymorphism.

### Basic OOP in C

At the core, C offers:

* __Structures (`struct`)__ to group related data together.
* __Header files__ to define public interfaces while hiding implementation details in `.c` files.
* __Pointers__ to reference data, enable dynamic allocation, and pass around objects efficiently.

With these tools, you can emulate classes in C.

__Conceptually__, a “class” in C consists of:

* An __object type__ defined as a private `struct`, with its details hidden from the user.
* __Methods__ implemented as functions, each taking a pointer to the object (`my_object_t *`) as the first argument.

__In practice__, this is implemented as:

* A __header file (`.h`)__ that declares the object type as an [opaque pointer](https://en.wikipedia.org/wiki/Opaque_pointer) and its public functions (the interface).
* A __source file (`.c`)__ that defines the private `struct` representing the object type and implements the functions (the implementation).

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
An *opaque pointer* is a pointer to a type whose contents are hidden from the user. In the header file, you only declare `typedef struct my_object_t my_object_t;` without revealing the fields. This way, code using your “object” cannot directly access or modify its internal state: It must go through your provided functions. This enforces __encapsulation__, just like private members in a class.
{{< /alert >}}

#### Error Handling
Before looking deeper at how methods are structured in C, it’s important to touch on __error handling__. While not strictly part of object-oriented programming, it directly affects the design of function signatures in OOP-style APIs: many “methods” return status codes instead of the actual result, leaving the caller to check and handle errors explicitly. This convention is widely used in ESP-IDF and is key to understanding how its APIs are meant to be used. For a deeper dive, see the article [ESP-IDF tutorial series: Errors](/blog/2025/09/espressif_logging/).

#### Implementation example

Let’s look at a few snippets showing how to implement an object in C. The public interface is declared in the header file:

```c
// my_object.h
typedef struct my_object_t my_object_t;  // Opaque type

typedef enum {
    MY_OBJECT_OK = 0,
    MY_OBJECT_ERR_NULL,
    MY_OBJECT_ERR_INVALID
} my_object_error_t; // enum for errors

my_object_t * my_object_create(int value);
my_object_error_t my_object_set(my_object_t* obj, int value);
int  my_object_get(const my_object_t* obj);
void my_object_destroy(my_object_t* obj);
```

The corresponding implementation defines the private `struct` and includes error handling in the methods:

```c
// my_object.c
#include "my_object.h"
#include <stdlib.h>

struct my_object_t {
    int value;  // private member
};

my_object_t* my_object_create(int value) {
    my_object_t* obj = malloc(sizeof(my_object_t));
    if (obj) {
        obj->value = value;
    }
    return obj;
}

my_object_error_t my_object_set(my_object_t* obj, int value) {
    if (!obj) return MY_OBJECT_ERR_NULL;
    if (value < 0) return MY_OBJECT_ERR_INVALID;
    obj->value = value;
    return MY_OBJECT_OK;
}

int my_object_get(const my_object_t* obj) {
    return obj ? obj->value : -1;
}

void my_object_destroy(my_object_t* obj) {
    free(obj);
}
```

Using the “class” in `main.c` then looks like this:

```c
#include "my_object.h"
#include <stdio.h>

int main(void) {
    my_object_t* obj = my_object_create(10);

    printf("Initial value: %d\n", my_object_get(obj));

    if (my_object_set(obj, 42) == MY_OBJECT_OK) {
        printf("Updated value: %d\n", my_object_get(obj));
    }

    my_object_destroy(obj);  // must be freed manually!
    return 0;
}
```

Here the workflow is simple: create the object with `my_object_create`, call its “methods” by passing the object pointer, handle errors through return codes, and explicitly destroy the object with `my_object_destroy`.

#### Note on `create` method

When designing a `create` method in C, there are two common approaches.

1. Return the object pointer directly, using `NULL` to signal allocation failure.<br>
   _This keeps the call site simple but limits the ability to report detailed errors._
2. Return an error code (e.g., `my_object_error_t`, `esp_err_t`) and pass the pointer as an output argument.<br>
   _Allows you to distinguish between multiple failure conditions._

ESP-IDF consistently uses the second approach, as it integrates with its global error handling conventions, while in plain C libraries you’ll often see the simpler `NULL`-on-error pattern.

#### Handles in ESP-IDF

Instead of exposing raw pointers, ESP-IDF returns __handles__, which are opaque types that internally are pointers. This hides implementation details and enforces safe access:

```c
spi_device_handle_t handle;
spi_bus_add_device(VSPI_HOST, &devcfg, &handle);
spi_device_transmit(handle, &trans);
```

* `spi_device_handle_t` is a handle representing a device.
* Internally, it’s a pointer to a structure  but that's hidden by the API. It's definition is:<br>
   ```c
     typedef struct spi_device_t * spi_device_handle_t;,
   ```
* You interact __only via functions__, not by dereferencing the pointer.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
A handle is essentially an opaque pointer: it references an internal object, but the structure is hidden. This design enforces __encapsulation__ and allows the framework to safely manage memory and state, which is critical in embedded programming.
{{< /alert >}}

### Advanced OOP in C

Beyond the basics, it’s also possible to mimic __inheritance__ (by embedding one `struct` inside another) and even a form of __polymorphism__ (using function pointers stored in `structs`).

<!-- These patterns are widely used in systems programming and frameworks like ESP-IDF, though they require more careful design to avoid complexity.

For example, a minimal polymorphism setup might look like this:

```c
typedef struct shape_t {
    void (*draw)(struct shape_t* self);  // polymorphic method
} shape_t;

typedef struct circle_t {
    shape_t base;  // "inheritance"
    int radius;
} circle_t;

void circle_draw(shape_t* self) {
    circle_t* circle = (circle_t*)self;
    printf("Drawing circle with radius %d\n", circle->radius);
}
```

Here, `shape_t` defines a __virtual function table entry__, and `circle_t` implements it by assigning `circle_draw` to the base’s function pointer. -->

In this article, we’ll stay focused on the fundamentals of OOP in C, while acknowledging that advanced features like inheritance and polymorphism are also within reach if needed.

### Comparison with Python and C++

After exploring object-oriented patterns in C, it’s helpful to see how this compares with higher-level languages. In C, you manage both object references and memory manually, which is essential in embedded systems. Python and C++ handle these tasks automatically.

__Python__

```python
class MyObject:
    def __init__(self, value):
        self.value = value

    def set(self, value):
        self.value = value

    def get(self):
        return self.value

obj = MyObject(10)
print(obj.get())
obj.set(42)
print(obj.get())
```

* You explicitly declare `self` in methods, but Python automatically passes it when you call a method.
* Memory is managed by the garbage collector; you don’t control allocation or deallocation.

__C++__

```cpp
class MyObject {
    int value;
public:
    MyObject(int v) : value(v) {}
    void set(int v) { value = v; }
    int get() { return value; }
};

int main() {
    MyObject obj(10);
    std::cout << obj.get() << std::endl;
    obj.set(42);
    std::cout << obj.get() << std::endl;
}
```

* The compiler automatically provides the hidden `this` pointer; you neither declare nor pass it.
* Memory management is manual, but higher-level features like constructors and destructors help automate initialization and cleanup.

__C (our example)__

```c
my_object_t* obj = my_object_create(10);
printf("%d\n", my_object_get(obj));
my_object_set(obj, 42);
printf("%d\n", my_object_get(obj));
my_object_destroy(obj);  // manual cleanup
```

* You must declare and explicitly pass the object pointer for every function call.
* Memory management is fully manual with `malloc` and `free`, giving full control over resource usage.

**Recap**

| Language | Object reference handling                       | Memory management             |
| -------- | ----------------------------------------------- | ----------------------------- |
| Python   | Write `self`, automatically passed at call time | Automatic (garbage collected) |
| C++      | `this` automatically injected by the compiler   | Manual, aided by constructors |
| C        | Must write and pass pointer explicitly          | Fully manual, precise control |

By explicitly managing object pointers and memory, C requires more boilerplate and careful handling than higher-level languages, but in embedded systems this fine-grained control pays off, which is less critical in high-resource environments like laptops or desktops.

## Examples of OOP in ESP-IDF

Let’s look at a practical example of how ESP-IDF applies this approach.

### Protocol: `httpd_handle_t`

To manage an HTTP server instance, ESP-IDF provides the `httpd_handle_t` type. Server initialization begins with defining configuration parameters in an `httpd_config_t` structure, which simplifies setup.

A typical workflow looks like this:

```c
httpd_config_t config = [...];
httpd_handle_t server = NULL;
esp_err_t result = httpd_start(&server, &config);
```

Here, the `server` handle is initialized as `NULL` and then populated by `httpd_start`, so it follows the second approach mentioned in [Note on `create` method](#note-on-create-method) above. The function also returns an error code, allowing you to verify success by checking `result==ESP_OK`. While `httpd_start` could have been designed to return the handle directly, this pattern ensures that __error handling__ remains explicit.

Although `server` is not formally a pointer type, its definition
```c
typedef void * httpd_handle_t;
```
This reveals that `server` is essentially a pointer under the hood. Once created, this handle is used for all server operations, such as:

* Registering a URI handler: `httpd_register_uri_handler(server, &hello_world_uri);`
* Stopping the server: `httpd_stop(server);`

### Peripheral: `i2c_master_bus_handle_t` and `i2c_master_dev_handle_t`

In Espressif’s communication bus components (like `i2c_bus` and `spi_bus`), a bus and a device are treated as separate objects. The bus defines the shared interface, while each device holds specific settings, such as an address or chip select.

To transmit data, you first create and configure the bus, then you attach devices, and finally use the device handle for read/write operations. Proper creation and deletion of both objects are essential for stable and efficient communication.

Creating the bus typically looks like this:

```c
// Define the bus handle
i2c_master_bus_handle_t bus_handle;

// Configure the I2C master bus
i2c_master_bus_config_t i2c_mst_config = [...];

// Create the I2C master bus and get the handle
esp_err_t new_master_bus_error = i2c_new_master_bus(&i2c_mst_config, &bus_handle);
```

As with server handles, the bus handle is first declared and then populated via `i2c_new_master_bus`.

Similarly, a device is created and attached to the bus in a single step:

```c
// Define the device handle
i2c_master_dev_handle_t dev_handle;

// Configure the I2C device
i2c_device_config_t dev_cfg = [...];

// Add the device to the bus and get the device handle
esp_err_t bus_add_device_error = i2c_master_bus_add_device(bus_handle, &dev_cfg, &dev_handle);
```

Once set up, the device handle is used for communication:

```c
// Use the device handle to transmit data
i2c_master_transmit(dev_handle, data_wr, DATA_LENGTH, -1);
```

Finally, proper cleanup involves removing the device and deleting the bus:

```c
// Remove the device from the bus
esp_err_t rm_device_error = i2c_master_bus_rm_device(dev_handle);

// Delete the I2C master bus
esp_err_t del_master_error = i2c_del_master_bus(bus_handle);
```

These examples clearly demonstrate how ESP-IDF applies OOP concepts in practice. In a later article, we’ll implement a simple object to explore these standard methods in action.

## Conclusion

In this article, we explored how object-oriented programming principles can be applied in C, particularly within the ESP-IDF framework. We examined techniques such as opaque pointers, encapsulation, and manual memory management, highlighting how C can emulate classes and methods despite lacking native OOP support. The article also showed how ESP-IDF uses these OOP patterns in practice to structure its APIs and manage resources efficiently.
