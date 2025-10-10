---
title: "Extending idf.py: Create custom commands for your ESP-IDF workflow"
date: "2025-10-10"
showAuthor: false
authors:
  - "marek-fiala"
tags: ["ESP-IDF", "idf.py", "CLI", "Extensions", "Development Tools"]
summary: "Learn how to extend idf.py with custom commands for your development workflow. This guide covers both component-based extensions for project-specific tools and Python package extensions for reusable commands, with practical examples and best practices for seamless integration."
---

<!-- TODO[Remove after ESP-IDF v6.0 release]
Note: This article mentions ESP-IDF v6.0. Once it is released, remove the note below about development status.
Context: Developer Portal's GitLab MR `88#note_2327272`
ReviewDate: 2026-01-15
Tags: ESP-IDF v6.0, obsolete
-->

What if you could extend `idf.py` with your own custom commands tailored to your specific workflow? With the ESP-IDF v6.0 and newer (to be released soon), you can do exactly that through a powerful extension system that lets you add project-specific tools or distribute reusable commands across your projects.

Before we dive into extensions, let’s recall what `idf.py` gives you out of the box. It’s the central command-line tool for ESP-IDF that allows you to:

- Set the target chip using `idf.py set-target` (like esp32)
- Tweak your project settings using `idf.py menuconfig`
- Build your application using `idf.py build`
- Flash it using `idf.py -p PORT flash`
- Watch the logs in real time using `idf.py monitor`

For most developers, the daily cycle is simply **build → flash → monitor** — all streamlined under one command.

## Why extend idf.py?

Sometimes, though, the built-in commands aren’t enough. Maybe you need a custom deployment command that packages your firmware with metadata, or perhaps you want to integrate with your CI/CD pipeline through specialized build targets. Rather than maintaining separate scripts, you can now integrate these directly into `idf.py`, giving you:

- **Unified interface**: All your tools accessible through the familiar `idf.py` command
- **Consistent help system**: Your commands appear in `idf.py --help` with proper documentation
- **Shared options**: Leverage existing global options like `--port` and `--build-dir`
- **Dependency management**: Ensure commands run in the right order automatically

## Two ways to extend idf.py

ESP-IDF supports two extension mechanisms, each suited for different use cases:

- Component-based extensions
- Python package extensions

### Component-based extensions

This is the case for project-specific commands that should only be available when working with a particular project or component.

**How it works**: Place a file named `idf_ext.py` in your component directory. ESP-IDF automatically discovers and loads extensions from this file **after the project is configured** with `idf.py reconfigure` or `idf.py build`. Within the component-based extension, the name of the file is important, as `idf.py` searches exactly for `idf_ext.py`. 

**Note**: You may also place `idf_ext.py` in the project root instead of a component. This option has existed in earlier ESP-IDF versions and works the same way, but using a dedicated component is recommended for clarity and reusability.

#### Step 1: Create the extension file

- Create a new component (or use an existing one).
- Inside the component, add a file named `idf_ext.py`.
- This file must implement an `action_extensions` function returning a dictionary that describes your new commands, options, and callbacks.

**Example (sensor manager)**:
In this example, we’ll add a new command sensor-info that prints configuration details about sensors in your project. Start by creating a component called `sensor_manager`:

```bash
# Create the component using idf.py
idf.py create-component -C components sensor_manager
```

Then, inside your component directory `components/sensor_manager/`, create `idf_ext.py` Python file and place the following code:

```python
from typing import Any
import click

def action_extensions(base_actions: dict, project_path: str) -> dict:
    def sensor_info(subcommand_name: str, ctx: click.Context, global_args: dict, **action_args: Any) -> None:
        sensor_type = action_args.get('type', 'all')
        verbose = getattr(global_args, 'detail', False)
        
        print(f"Running {subcommand_name} for sensor type: {sensor_type}")
        if verbose:
            print(f"Project path: {project_path}")
            print("Detailed sensor configuration would be displayed here...")

    def global_callback_detail(ctx: click.Context, global_args: dict, tasks: list) -> None:
        if getattr(global_args, 'detail', False):
            print(f"About to execute {len(tasks)} task(s): {[t.name for t in tasks]}")

    return {
        "version": "1",
        "global_options": [
            {
                "names": ["--detail", "-d"],
                "is_flag": True,
                "help": "Enable detailed output for all commands",
            }
        ],
        "global_action_callbacks": [global_callback_detail],
        "actions": {
            "sensor-info": {
                "callback": sensor_info,
                "short_help": "Display sensor configuration",
                "help": "Show detailed information about sensor configuration and status",
                "options": [
                    {
                        "names": ["--type", "-t"],
                        "help": "Sensor type to query (temperature, humidity, pressure, or all)",
                        "default": "all",
                        "type": click.Choice(['temperature', 'humidity', 'pressure', 'all']),
                    }
                ]
            },
        },
    }
```

#### Step 2: Register the component

- Ensure the new component is registered in your project’s CMakeLists.txt.
- Further information on how to register commponents can be found in [Espressif documentation](https://docs.espressif.com/projects/esp-idf/en/stable/api-guides/build-system.html#component-requirements).

<!-- Now you need to make sure your component is registered in your project's main `CMakeLists.txt`: -->

**Example (sensor manager)**:
Update your project's main `CMakeLists.txt`
```cmake
idf_component_register(
    SRCS "main.c"
    INCLUDE_DIRS "."
    REQUIRES "sensor_manager"  # This makes the extension available
)
```

#### Step 3: Load and test
- Reconfigure or build the project to let ESP-IDF discover the extension.
- Run idf.py help to check that your new command appears.
- Test the new command with its options.

**Example (sensor manager)**: In our case, the extension adds the `sensor-info` command:

```bash
# Configure the project to discover the extension
idf.py reconfigure

# Check that your command appears in help
idf.py --help

# Try your new command
idf.py sensor-info --type temperature
idf.py --detail sensor-info --type all
```

### Python package extensions

This is ideal for reusable tools that you want to share across multiple projects or distribute to your team.

**How it works**: Create a Python package with an entry point in the `idf_extension` group. Once installed, the extension is available globally for all projects.

#### Step 1: Create the package structure

- Create a new folder for your tool.
- Add a `pyproject.toml` file to describe the package.
- Inside the folder, create a subfolder with the same name, which will contain your Python code.
- Inside that subfolder, add `__init__.py` and a Python file for the extension (e.g., `esp_ext.py`). 
  - Unlike the fixed `idf_ext.py` in component-based extensions, the filename here is flexible because it is explicitly referenced in `pyproject.toml`. 
  - For clarity and consistency, it’s recommended to prefix it with your tool name and suffix it with `_ext.py`. 

The resulting structure should look like this:

```bash
my_sensor_tools/
├── pyproject.toml  # describe the package here
├── my_sensor_tools/ # place your Python code here
│   ├── __init__.py
│   └── esp_ext.py
```

#### Step 2: Fill the extension file

- Implement the `action_extensions` function inside your package’s Python file.

**Example (sensor manager)**:

Here we simply copy the `action_extensions` function from the component example into `my_sensor_tools/esp_ext.py`.

#### Step 3: Configure and install

- Define the Python entry-point in your `pyproject.toml` under `[project.entry-points.idf_extension]`.
  - Use the format name: `package.module:function`.
- Install the package (for development, use `pip install -e .`).
- The new command will now be globally available in any ESP-IDF project.

<!-- On the final step, you will need to create the `pyproject.toml` file: -->
**Example (sensor manager)**:

The `pyproject.toml` file for our example could look like this:

```toml
[project]
name = "my-sensor-tools"
version = "1.0.0"

# Register the extension under the `idf_extension` group,
# so ESP-IDF can automatically discover it
[project.entry-points.idf_extension]
my_sensor_tools = "my_sensor_tools.esp_ext:action_extensions"
```

Install and use:

```bash
# Install in development mode
cd my_sensor_tools
pip install -e .

# Your command is now available in any ESP-IDF project
cd my_sensor_tools/
idf.py sensor-info --type temperature
idf.py --detail sensor-info --type all
```

## Naming conventions

- **Avoid conflicts**: Your commands cannot override built-in `idf.py` commands like `build`, `flash`, or `monitor`
- **Use descriptive names**: Prefer `sensor-info` over `info` to avoid ambiguity
- **Package prefixes**: For Python package extensions, consider prefixing commands with your tool name

## Advanced features

Do you need something extra? Beyond simple commands, the extension system also gives you ways to define global options, control execution order, and build richer command-line interfaces. These features let you create tools that feel fully integrated with the rest of `idf.py`.

### Global options and callbacks

The extension system supports sophisticated features for power users:

**Global options**: Define options that work across all commands. Can be exposed under `global_args` parameter.

**Global callbacks**: Functions that run before any tasks execute, perfect for validation, logging, or injecting additional tasks based on global options.

### Dependencies and order management

Ensure your commands run in the correct sequence:

```python
"actions": {
    "deploy": {
        "callback": deploy_firmware,
        "dependencies": ["all"],  # Always build before deploying
        "order_dependencies": ["flash"],  # If flash is requested, run it before deploy
        "help": "Deploy firmware to production servers"
    }
}
```

### Rich argument support

Support complex command-line interfaces:

```python
"options": [
    {
        "names": ["--config-file", "-c"],
        "type": click.Path(exists=True),
        "help": "Configuration file path"
    },
    {
        "names": ["--verbose", "-v"],
        "count": True,  # -v, -vv, -vvv for different verbosity levels
        "help": "Increase verbosity (use multiple times)"
    }
],
"arguments": [
    {
        "names": ["targets"],
        "nargs": -1,  # Accept multiple targets
        "required": True
    }
]
```

For more details on the extension API and additional features, see the [Click documentation](https://click.palletsprojects.com/) for argument types and the [ESP-IDF documentation](https://docs.espressif.com/projects/esp-idf/en/latest/api-guides/tools/idf-py.html#extending-idf-py) for the complete extension reference.

## Conclusion

The `idf.py` extension system opens up powerful possibilities for customizing your ESP-IDF development workflow. Whether you're adding simple project-specific helpers or building sophisticated development tools, extensions let you integrate seamlessly with the existing ESP-IDF ecosystem.

Start small with a component-based extension for your current project, then graduate to distributable packages as your tools mature.

## What's next?

- Explore the [full extension API documentation](https://docs.espressif.com/projects/esp-idf/en/latest/api-guides/tools/idf-py.html#extending-idf-py) for advanced features
- Check out existing extensions in the ESP-IDF codebase for inspiration

Happy extending!
