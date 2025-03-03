# Portable C++ Project Template

This template includes a simple `main.cpp` that utilizes a function from another file, along with a *res* folder containing the executable icon.

Requisites: make, g++, gdb, gcc

Currently, it supports only **Windows x64** compilations on **Visual Studio Code**.

## Visual Studio Code

The compilation process will generate object files in the `obj/debug` or `obj/release` directories, depending on the selected configuration. The final executable will be placed in the `bin/debug` or `bin/release` folder accordingly.

The project has been tested with the following extensions installed:

- **C/C++** by Microsoft
- **C/C++ Extension Pack** by Microsoft
- **Makefile Tools** by Microsoft

The following compilers have been tested and confirmed to work with this project:

- **w64devkit-x64-2.0.0** with **make.exe**, **g++** and **gdb.exe**.
- **TDM-GCC-64** with **mingw32-make.exe**, **g++** and **gdb.exe**.

Follow these steps to compile and run your project in Visual Studio Code:

1. **Verify Compiler Path and Executable Names**: Ensure that the paths and executable names for `make` are correctly set in *settings.json*. The `g++.exe` and `gdb.exe` executables should be in the same directory.
2. **Compilation and Debugging**: 
    - Press `Ctrl+Shift+B` to compile the project using `make` and `g++`.
    - Press `F5` to start the program. Note that the debug configuration is optimized for `gdb`, and debugging is not possible with the release configuration.
3. **Build Configurations**: Use the `F5` shortcut to access release, debug, and clean configurations from *launch.json*.
4. **Clean the Project**: It is recommended to clean the project using the clean configuration to delete the `obj` and `bin/debug` folders.