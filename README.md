# Portable C++ Project Template

This template includes a simple `main.cpp` that utilizes a function from another file, along with a *res* folder containing the executable icon.

Currently, it supports only Windows compilations.

## Visual Studio Code

### Tested with

- **make.exe** from **w64devkit-x64-2.0.0**.
- **mingw32-make.exe** from **TDM-GCC-64**

### Included

- Compiler path and executable names in *settings.json*.
- Compilation with make and g++, and debugging with gdb.
- Release, debug, and clean configurations in *launch.json*.

### Steps

1. In *settings.json*, verify the *make* name and path.
2. Ensure the project name in *settings.json* matches the project name in the Makefile.
