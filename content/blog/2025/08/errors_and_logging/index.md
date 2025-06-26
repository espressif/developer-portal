---
title: "ESP-IDF tutorial series: Errors"
date: "2025-08-19"
showAuthor: false
summary: "This article explains error handling in FreeRTOS-based embedded systems, highlighting common C practices and their limitations. It introduces ESP-IDF’s `esp_err_t` type and error-checking macros, demonstrating how they help manage errors systematically. It shows practical ways to implement error handling in embedded applications."
authors:
  - "francesco-bez"
tags: ["ESP32C3", "errors"]
---

## Introduction

In microcontroller-based systems running FreeRTOS, developers work within environments that are both constrained and capable. These platforms provide low-level hardware control alongside the benefits of a lightweight real-time operating system.

C continues to be the primary language in this domain, valued for its efficiency, portability, and direct access to hardware. It enables precise control over performance and resource usage, which is an essential requirement for real-time applications.

However, C also has notable shortcomings. It lacks built-in support for structured **error handling** and **object-oriented programming (OOP)**, features that can help manage complexity and improve maintainability in large or safety-critical systems. As embedded software becomes more sophisticated, often involving numerous modules, tasks, and hardware interfaces, developers must adopt robust patterns to handle errors and organize code effectively. These needs are especially critical in FreeRTOS-based development, where tasks may fail independently and resources must be carefully managed.

In this article, we will examine how ESP-IDF handles error management within its codebase and how you can leverage these tools in your code.

## Error handling in C

C provides no built-in exception handling, so error management is a manual, discipline-driven part of embedded development. In systems using FreeRTOS, where multiple tasks may run concurrently and shared resources must be protected, robust error handling becomes even more important to ensure system stability and predictable behavior.


### Common Techniques

Over the years, two common techniques for managing errors have emerged to manage errors.

1. __Return Codes__<br>
   The most widespread method is returning status codes from functions to indicate success or failure. These codes are often:

   * Integers (`0` for success, non-zero for errors or warnings)
   * Enumerations representing different error types
   * `NULL` pointers for memory allocation or resource acquisition failures

   Each calling function is responsible for checking the return value and taking appropriate action, such as retrying, logging, or aborting.

2. __Global `errno` Variable__<br>
   The C standard library defines a global variable `errno` to indicate error conditions set by certain library or system calls (e.g., `fopen`, `malloc`). After a function call, a developer can check `errno` to understand what went wrong. It’s typically used like this:

   ```c
   FILE *fp = fopen("config.txt", "r");
   if (fp == NULL) {
       printf("File open failed, errno = %d\n", errno);
   }
   ```

   However, in embedded systems FreeRTOS, `errno` comes with important caveats:

   * It is often __shared globally__, which makes it __unsafe__ in multi-tasking environments.
   * Some implementations (like `newlib` with thread-safety enabled) provide __thread-local `errno`__, but this increases memory usage.
   * It is rarely used in embedded systems due to its "implicit" nature.

In FreeRTOS-based applications, the use of return code is typically followed approach.

In embedded system design, development frameworks often also define:

1. __Custom error types__<br>
   Many embedded projects define their own error handling systems, which typically include a consistent error type definitions across modules (e.g., `typedef int err_t;`)

2. __Macros for error checking__<br>
   To reduce repetitive boilerplate code, macros are often used to check errors and handle cleanup in a consistent way:

   ```c
   #define CHECK(expr) do { if (!(expr)) return ERR_FAIL; } while (0)
   ```

   These can help standardize behavior across tasks and improve code readability.

In conclusion, in RTOS-based embedded systems where robustness and reliability are critical, manual error handling must be systematic and consistent. While `errno` exists and can be used cautiously, most embedded applications benefit more from explicit well-defined error enums and structured reporting mechanisms.

### ESP-IDF approach

ESP-IDF defines its error codes as `esp_err_t` type and provides a couple of error checking macros.

* __`esp_err_t` -- Structured error codes__<br>
   Espressif’s ESP-IDF framework introduces a standardized error handling approach through the use of the `esp_err_t` type. This is a 32-bit integer used to represent both generic and module-specific error codes. The framework defines a wide range of constants, such as:

   ```c
   #define ESP_OK          0       // Success
   #define ESP_FAIL        0x101   // Generic failure
   #define ESP_ERR_NO_MEM  0x103   // Out of memory
   #define ESP_ERR_INVALID_ARG 0x102 // Invalid argument
   ```
   The full list is available on the [error codes documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/error-codes.html) page.

   Developers typically write functions that return `esp_err_t`, and use these codes to control program flow or report diagnostics. `ESP_OK` is zero and errors can be easily checked like this:

   ```c
   esp_err_t ret = i2c_driver_install(...);
   if (ret != ESP_OK) {
       printf("I2C driver install failed: %s", esp_err_to_name(ret));
       return ret;
   }
   ```

   ESP-IDF also provides utilities like `esp_err_to_name()` and `esp_err_to_name_r()` to convert error codes into readable strings for logging, which is particularly helpful for debugging.

* __`ESP_ERROR_CHECK` -- Error checking macro__<br>
   To reduce repetitive error checking code in testing and examples, ESP-IDF includes macros like `ESP_ERROR_CHECK()`. This macro evaluates an expression (typically a function call returning `esp_err_t`), logs a detailed error message if the result is not `ESP_OK`, and aborts the program. You will find this macro repeatedly used in ESP-IDF examples:

   ```c
   ESP_ERROR_CHECK(i2c_driver_install(...));
   ```
   There is also `ESP_ERROR_CHECK_WITHOUT_ABORT` version of this macro which doesn't stop execution if an error is returned.

Out of curiosity, let's look at the macro definition
```c
#define ESP_ERROR_CHECK(x) do {                                         \
     esp_err_t err_rc_ = (x);                                        \
     if (unlikely(err_rc_ != ESP_OK)) {                              \
         abort();                                                    \
     }                                                               \
 } while(0)
```

At its core, this macro simply checks whether the given value equals `ESP_OK` and halts execution if it does not. However, there are two elements that might seem confusing if you're not familiar with C macros:

1. **The `do { } while (0)` wrapper**<br>
   This is a common best practice when writing multi-line macros. It ensures the macro behaves like a single statement in all contexts, helping avoid unexpected behavior during compilation. If you're curious about the reasoning behind this pattern, [this article](https://vcstutoring.ca/wrapping-multiline-macros-in-c-with-do-while/) offers a good explanation.

2. **The `unlikely` function**<br>
   This is used as a compiler optimization hint. It tells the compiler that the condition `err_rc_ != ESP_OK` is expected to be false most of the time—i.e., errors are rare—so it can optimize for the more common case where `ESP_OK` is returned. While it doesn't change the program's behavior, it can improve performance by guiding branch prediction and code layout.


## Examples

In this section, we’ll start with a simple, self-contained example to demonstrate how error codes and macros work in practice. Then, we’ll examine how these concepts are applied in an actual ESP-IDF example by reviewing its source code.

### Basic Example: Division

To demonstrate the use of the error codes, we will implement a division function.

<!-- #### Create a new project

First, we need to create a new project using the `template-app` template. In VS Code, this can be done through the command palette (indicated here as `>`):

* `> ESP-IDF: Create Project from Extension Template`
  &rarr; Select a container directory
  &rarr; Choose `template-app` -->

<!--
#### Implementation -->

Unlike other basic operations, division can result in an error if the second argument is zero, which is not allowed. To handle this case, we use an `esp_err_t` return type for error reporting.

<!-- Add the following code to your `main.c` file: -->
The division function is implemented as follows:

```c
esp_err_t division(float * result, float a, float b){

    if(b==0 || result == NULL){
        return ESP_ERR_INVALID_ARG;
    }

    *result = a/b;
    return ESP_OK;
}
```

As you can see, since the function’s return type is `esp_err_t`, we need an alternative way to return the division result. The standard approach is to pass a pointer to a result variable as an argument. While this may seem cumbersome for a simple application, its advantages become increasingly clear when applying object-oriented programming (OOP) principles in C.

In the `app_main` function, we first check for errors before printing the result.

```c
void app_main(void)
{
    printf("\n\n*** Testing Errors ***!\n\n");
    float division_result = 0;
    float a = 10.5;
    float b = 3.3;

    if(division(&division_result,a,b)==ESP_OK){
        printf("Working division: %f\n", division_result);
    }else{
        printf("Division Error!\n");
    }

    b = 0;

    if(division(&division_result,a,b)==ESP_OK){
        printf("Working division: %f\n", division_result);
    }else{
        printf("Division Error!\n");
    }

}
```

And the result is as expected

```bash
*** Testing Errors ***!

Working division: 3.181818
Division Error!
```

We can also use `ESP_ERROR_CHECK_WITHOUT_ABORT(division(&division_result,a,b))` instead of the if/else block.
It results is a silent pass for the first function call and in the following message for the second.

```bash
ESP_ERROR_CHECK_WITHOUT_ABORT failed: esp_err_t 0x102 (ESP_ERR_INVALID_ARG) at 0x4200995a
--- 0x4200995a: app_main at <folder_path>/error-example/main/main.c:37

file: "./main/main.c" line 37
func: app_main
expression: division(&division_result, a, b)
```

Using `ESP_ERROR_CHECK` makes the system reboot after the error is found.


### ESP-IDF example

Let’s examine a more complete example taken directly from the ESP-IDF example folder. The following code is from the [HTTPS request example](https://github.com/espressif/esp-idf/blob/v5.4.2/examples/protocols/https_request/main/https_request_example_main.c).

The `app_main` function code is as follows
```c
void app_main(void)
{
    ESP_ERROR_CHECK(nvs_flash_init());
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    //[...]
    ESP_ERROR_CHECK(example_connect());

    if (esp_reset_reason() == ESP_RST_POWERON) {
        ESP_ERROR_CHECK(update_time_from_nvs());
    }

    const esp_timer_create_args_t nvs_update_timer_args = {
            .callback = (void *)&fetch_and_store_time_in_nvs,
    };

    esp_timer_handle_t nvs_update_timer;
    ESP_ERROR_CHECK(esp_timer_create(&nvs_update_timer_args, &nvs_update_timer));
    ESP_ERROR_CHECK(esp_timer_start_periodic(nvs_update_timer, TIME_PERIOD));

    xTaskCreate(&https_request_task, "https_get_task", 8192, NULL, 5, NULL);
}
```

As you can see, almost all function calls are surrounded by the `ESP_ERROR_CHECK` macro.

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
`ESP_ERROR_CHECK` is used only in examples and prototypes because it aborts execution on error. It should not be used in production code, where a properly designed error-handling mechanism is preferred.
{{< /alert >}}


## Conclusion

In this article, we examined error handling in FreeRTOS-based embedded systems, focusing on the ESP-IDF framework. We covered common C techniques, the importance of systematic error management, and how ESP-IDF uses `esp_err_t` and macros to simplify error checking. Through both a simple example and a real-world ESP-IDF example, we saw practical applications of these concepts to improve code robustness and reliability.
