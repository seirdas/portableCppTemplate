# Portable C++ Project Template

This template includes a simple `main.cpp` that utilizes a function from another file, along with a *res* folder containing the executable icon.

Requisites: make, g++, gdb, gcc

Currently, it supports only **Windows** compilations on **Visual Studio Code**.

## Visual Studio Code

The compilation process will generate object files in the `obj/debug` or `obj/release` directories, depending on the selected configuration. The final executable will be placed in the `bin/debug` or `bin/release` folder accordingly.

The project has been tested with the following extensions installed:

- **C/C++** by Microsoft
- **C/C++ Extension Pack** by Microsoft
- **Makefile Tools** by Microsoft

The following compilers have been tested and confirmed to work with this project:

- **w64devkit-x64-2.0.0** with **make.exe**, **g++** and **gdb.exe**.
- **TDM-GCC-64** with **mingw32-make.exe**, **g++** and **gdb.exe**.

The project includes specific steps for compiling in Visual Studio Code:

- **Compiler Path and Executable Names**: Verify that the paths and executable name for `make` are correctly set in *settings.json*. Ensure that `g++.exe` and `gdb.exe` executables are located in the same directory.
- **Compilation and Debugging**: Use the shortcut `Ctrl+Shift+B` to compile the project with `make` and `g++`. Press `F5` to start the program. Note that the debug configuration is optimized for debugging using `gbd`, and debugging is not possible with the release configuration.
- **Build Configurations**: You can use release, debug, and clean configurations from *launch.json* by `F5` shortcut.
- **Clean the project**: It's recommended to clean the proyect by the clean configuration to delete obj and bin/debug folders.
