# JRL CMake Modules v2 API

Generated from _jrl_generate_api_doc() in jrl.cmake

# `jrl_copy_compile_commands_in_source_dir`

```cpp
jrl_copy_compile_commands_in_source_dir()
```

**Type:** function


### Description
  Copy compile_commands.json from the binary dir to the upper source directory for clangd support.
  This is only useful when the build directory is not <source_dir>/build.


### Arguments
  None


### Example
```cmake
jrl_copy_compile_commands_in_source_dir()
```
# `jrl_configure_copy_compile_commands_in_source_dir`

```cpp
jrl_configure_copy_compile_commands_in_source_dir()
```

**Type:** function


### Description
  Configure copy of compile_commands.json to source directory at end of configuration step.


### Arguments
  None


### Example
```cmake
jrl_configure_copy_compile_commands_in_source_dir()
```
# `jrl_include_ctest`

```cpp
jrl_include_ctest()
```

**Type:** macro


### Description
  Include CTest but simply prevent adding a lot of useless targets. Useful for IDEs.


### Arguments
  None


### Example
```cmake
jrl_include_ctest()
```
# `jrl_cmakemodules_get_version`

```cpp
jrl_cmakemodules_get_version(<output_var>)
```

**Type:** function


### Description
  Get the version of the jrl-cmakemodules package (via the jrl-cmakemodules_VERSION variable).


### Arguments
* `output_var`: Variable to store the version string.


### Example
```cmake
jrl_cmakemodules_get_version(v)
message(STATUS "jrl-cmakemodules version: ${v}")
```
# `jrl_cmakemodules_get_commit`

```cpp
jrl_cmakemodules_get_commit(<output_var>)
```

**Type:** function


### Description
  Get the git commit hash of the jrl-cmakemodules repository, if available.


### Arguments
* `output_var`: Variable to store the commit hash.


### Example
```cmake
jrl_cmakemodules_get_commit(commit)
message(STATUS "jrl-cmakemodules commit: ${commit}")
```
# `jrl_print_banner`

```cpp
jrl_print_banner()
```

**Type:** function


### Description
  Print a banner with the jrl-cmakemodules version and some info.


### Arguments
  None


### Example
```cmake
jrl_print_banner()
```
# `jrl_configure_default_build_type`

```cpp
jrl_configure_default_build_type(<build_type>)
```

**Type:** function


### Description
  Configures the default build type if none is specified.
  Usual values for <build_type> are: Debug, Release, MinSizeRel, RelWithDebInfo.


### Arguments
* `build_type`: The default build type to set.


### Example
```cmake
jrl_configure_default_build_type(RelWithDebInfo)
```
# `jrl_configure_default_binary_dirs`

```cpp
jrl_configure_default_binary_dirs()
```

**Type:** function


### Description
  Configures the default output directory for binaries and libraries.


### Arguments
  None


### Example
```cmake
jrl_configure_default_binary_dirs()
```
# `jrl_target_set_output_directory`

```cpp
jrl_target_set_output_directory(
    <target_name>
    OUTPUT_DIRECTORY <dir>
)
```

**Type:** function


### Description
  This function configures the `ARCHIVE_OUTPUT_DIRECTORY`,
  `LIBRARY_OUTPUT_DIRECTORY`, and `RUNTIME_OUTPUT_DIRECTORY` properties
  for the specified target.
  This is useful for python modules that need to be placed in a specific directory.


### Arguments
* `target_name`: The target to configure.
* `OUTPUT_DIRECTORY`: The directory where to put the output artifacts.


### Example
```cmake
jrl_target_set_output_directory(my_python_module_target OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/site-packages)
```
# `jrl_configure_default_install_dirs`

```cpp
jrl_configure_default_install_dirs()
```

**Type:** function


### Description
  Configures the default install directories using GNUInstallDirs (bin, lib, include, etc.).
  Works on all platforms.


### Arguments
  None


### Example
```cmake
jrl_configure_default_install_dirs()
```
# `jrl_configure_default_install_prefix`

```cpp
jrl_configure_default_install_prefix(<default_install_prefix>)
```

**Type:** function


### Description
  If not provided by the user, set a default CMAKE_INSTALL_PREFIX. Useful for IDEs.


### Arguments
* `default_install_prefix`: The default install prefix to set.


### Example
```cmake
jrl_configure_default_install_prefix(/opt/my_project)
```
# `jrl_configure_uninstall_target`

```cpp
jrl_configure_uninstall_target()
```

**Type:** function


### Description
  Setup an uninstall target that can be used to uninstall the project.
  It will create a cmake_uninstall.cmake script next to the cmake_install.cmake script in the build directory.


### Arguments
  None


### Example
```cmake
jrl_configure_uninstall_target()
# And then cmake --build . --target uninstall
```
# `jrl_configure_defaults`

```cpp
jrl_configure_defaults()
```

**Type:** function


### Description
  Setup the default options for a project (opinionated defaults).


### Arguments
  None


### Example
```cmake
jrl_configure_defaults()
```
# `jrl_get_cxx_compiler_id`

```cpp
jrl_get_cxx_compiler_id(<output_var>)
```

**Type:** function


### Description
  Get the CMAKE_CXX_COMPILER_ID variable, but also handles clang-cl and AppleClang exceptions.
  clang-cl is considered as MSVC, AppleClang as Clang.


### Arguments
* `output_var`: Variable to store the compiler ID.


### Example
```cmake
jrl_get_cxx_compiler_id(cxx_compiler_id)
message(STATUS "Compiler ID: ${cxx_compiler_id}")
```
# `jrl_target_set_default_compile_options`

```cpp
jrl_target_set_default_compile_options(
    <target_name>
    <visibility>
)
```

**Type:** function


### Description
  Enable the most common warnings for MSVC, GCC and Clang.
  Adding some extra warning on msvc to mimic gcc/clang behavior.


### Arguments
* `target_name`: The target to modify.
* `visibility`: PRIVATE, PUBLIC or INTERFACE.


### Example
```cmake
jrl_target_set_default_compile_options(my_target INTERFACE)
```
# `jrl_target_enforce_msvc_conformance`

```cpp
jrl_target_enforce_msvc_conformance(
    <target_name>
    <visibility>
)
```

**Type:** function


### Description
  Enforce MSVC c++ conformance mode so msvc behaves more like gcc and clang.
  If the compiler id is not MSVC, this function does nothing.


### Arguments
* `target_name`: The target to modify.
* `visibility`: PRIVATE, PUBLIC or INTERFACE.


### Example
```cmake
jrl_target_enforce_msvc_conformance(my_target INTERFACE)
```
# `jrl_target_treat_all_warnings_as_errors`

```cpp
jrl_target_treat_all_warnings_as_errors(
    <target_name>
    <visibility>
)
```

**Type:** function


### Description
  Treat all warnings as errors for a targets (/WX for MSVC, -Werror for GCC/Clang).
  Can be disabled on the cmake cli with --compile-no-warning-as-error.


### Arguments
* `target_name`: The target to modify.
* `visibility`: PRIVATE, PUBLIC or INTERFACE.


### Example
```cmake
jrl_target_treat_all_warnings_as_errors(my_target PRIVATE)
```
# `jrl_target_generate_warning_header`

```cpp
jrl_target_generate_warning_header(
    [<args>...]
)
```

**Type:** function


### Description


### Arguments
    <args>... - Additional arguments passed to _jrl_target_generate_header.


### Example
```cmake
jrl_target_generate_warning_header(my_target PUBLIC
    LIBRARY_NAME mylib
    FILENAME mylib/warning.hh
)
```
# `jrl_target_generate_deprecated_header`

```cpp
jrl_target_generate_deprecated_header(
    [<args>...]
)
```

**Type:** function


### Description
    Generate a <library_name>/deprecated.hpp header for a target.


### Arguments
    <args>... - Additional arguments passed to _jrl_target_generate_header.


### Example
```cmake
jrl_target_generate_deprecated_header(my_target PUBLIC
    LIBRARY_NAME mylib
    FILENAME mylib/deprecated.hh
)
```
# `jrl_target_generate_tracy_header`

```cpp
jrl_target_generate_tracy_header(
    [<args>...]
)
```

**Type:** function


### Description
    Generate a <library_name>/tracy.hpp header for a target.


### Arguments
    <args>... - Additional arguments passed to _jrl_target_generate_header.


### Example
```cmake
jrl_target_generate_tracy_header(my_target PUBLIC
    LIBRARY_NAME mylib
    FILENAME mylib/tracy.hh
)
```
# `jrl_target_generate_config_header`

```cpp
jrl_target_generate_config_header(
    [VERSION <version>]
    [<args>...]
)
```

**Type:** function


### Description
    Generate a config header for a target.
    The generated header is added to the target's include directories and scheduled for installation
    (via jrl_export_package()).


### Arguments
* `VERSION`: The version string to include in the generated header. Otherwise uses the target's VERSION property, and otherwise the PROJECT_VERSION.
    <args>... - Additional arguments passed to _jrl_target_generate_header.



### Example
```cmake
jrl_target_generate_config_header(mylib PUBLIC)
# Will generate mylib/config.hpp. Use with #include "mylib/config.hpp"
# This header will be installed automatically with the mylib target (via jrl_export_package()).

jrl_target_generate_config_header(mylib PRIVATE)
# Will generate mylib/config.hpp. Use with #include "mylib/config.hpp"
# This header will NOT be installed automatically.

jrl_target_generate_config_header(mylib INTERFACE
  LIBRARY_NAME myproject
  VERSION ${PROJECT_VERSION}
)
# Will generate myproject/config.hh. Use with #include "myproject/config.hh"
# Inside you will find MYPROJECT_LIBRARY_VERSION macros (not MYLIB_LIBRARY_VERSION).
```
# `jrl_export_dependency`

```cpp
jrl_export_dependency(
        PACKAGE_NAME <name>
        [FIND_PACKAGE_ARGS <args>...]
        [PACKAGE_VARIABLES <vars>...]
        [PACKAGE_TARGETS <targets>...]
        [MODULE_FILE <path>]
)
```

**Type:** function


### Description
Records a dependency discovered with `jrl_find_package()` into a JSON array stored in the
global property `_jrl_${PROJECT_NAME}_package_dependencies`.

The content of this property is later consumed by `jrl_export_package()` to reverse the link
between link libraries and the `find_package` calls that provided them.

It is called **automatically** by `jrl_find_package()`.

Note that it could also be useful in scenarios where the dependency that was not
discovered with jrl_find_package(). In that case, only the package name and the targets
are relevant.


### Arguments
* `PACKAGE_NAME`: Name of the dependency package (e.g., Eigen3).
* `FIND_PACKAGE_ARGS`: The arguments originally passed to `find_package()` (list).
* `PACKAGE_VARIABLES`: Variables created by `find_package()` that should be tracked (list).
* `PACKAGE_TARGETS`: Imported targets created by `find_package()` that should be tracked (list).
* `MODULE_FILE`: Absolute path to the Find<Package>.cmake module used, if any.


### Example
```cmake
# Dummy example
jrl_export_dependency(
    PACKAGE_NAME Eigen3
    FIND_PACKAGE_ARGS "Eigen3;3.4;REQUIRED"
    PACKAGE_VARIABLES "Eigen3_FOUND;Eigen3_VERSION"
    PACKAGE_TARGETS "Eigen3::Eigen"
    MODULE_FILE ${CMAKE_CURRENT_LIST_DIR}/FindEigen3.cmake
)

# Manual export of a dependency not found with jrl_find_package
jrl_export_dependency(
    PACKAGE_NAME MyLib
    FIND_PACKAGE_ARGS "MyLib;REQUIRED"
    PACKAGE_TARGETS "MyLib::MyLib"
)
# If you `target_link_libraries(my_target PUBLIC MyLib::MyLib)`, then jrl_export_package() will
# know that MyLib is a dependency of your package, and add the following lines to the generated
# `<project_name>-config.cmake` file:

if(NOT TARGET MyLib::MyLib)
    find_dependency(MyLib REQUIRED)
endif()
```
# `jrl_find_package`

```cpp
jrl_find_package(
    <PackageName>
    [version]
    [COMPONENTS <comp>...]
    [REQUIRED]
)
```

**Type:** macro


### Description
  Wrapper around CMake's find_package used for dependency tracking and logging.
  It forwards the arguments provided to the standard CMake find_package, while adding some new arguments.
  It records the find_package arguments, the variables created, the imported targets, and the module file used (if any).
  All that info is used for later introspection and analysis. It is very useful for exporting package dependencies (see jrl_export_package()).
  After the jrl_find_package calls, use jrl_print_dependencies_summary() for printing an extensive analysis.


### Arguments
    <PackageName> [<version>] [REQUIRED] [COMPONENTS <components>...] - The same as find_package.


### Example
```cmake
jrl_find_package(Eigen 3.3 REQUIRED)
jrl_find_package(Boost REQUIRED COMPONENTS filesystem system)
```
# `jrl_print_dependencies_summary`

```cpp
jrl_print_dependencies_summary()
```

**Type:** function


### Description
  Print a summary of all dependencies found via jrl_find_package, and some properties of their imported targets.


### Arguments
  None


### Example
```cmake
jrl_print_dependencies_summary()
```
# `jrl_add_export_component`

```cpp
jrl_add_export_component(
    NAME <component_name>
    TARGETS <target1> <target2> ...
)
```

**Type:** function


### Description
  Add an export component with associated targets that will be exported as a CMake package component.
  Each export component will have its own <package>-component-<name>-targets.cmake
  and <package>-component-<name>-dependencies.cmake generated.
  Components are used with: find_package(<package> CONFIG REQUIRED COMPONENTS <component1> <component2> ...)


### Arguments
* `NAME`: The name of the component.
* `TARGETS`: The targets to associate with this component.


### Example
```cmake
jrl_add_export_component(NAME my_component TARGETS my_target)
```
# `jrl_target_headers`

```cpp
jrl_target_headers(
    <target>
    <visibility>
    HEADERS <list_of_headers>
    [BASE_DIRS <list_of_base_dirs>]
)
```

**Type:** function


### Description
  Declare headers for target to be installed later.
  * This function does not target_include_directories(), only stores them for installation.
  * Only PUBLIC and INTERFACE will be installed.
  * It populates the _jrl_install_headers and _jrl_install_headers_base_dirs properties of the target.
  * In CMake 3.23, we will use FILE_SETS instead of this trick.
  cf: https://cmake.org/cmake/help/latest/command/target_sources.html#file-sets


### Arguments
* `target`: The target.
* `visibility`: Visibility scope (usually PUBLIC or INTERFACE).
* `HEADERS`: List of headers.
* `BASE_DIRS`: List of base dirs (Optional, default is empty).


### Example
```cmake
jrl_target_headers(my_target PUBLIC HEADERS my_header.hpp)
```
# `jrl_target_install_headers`

```cpp
jrl_target_install_headers(
    <target>
    [DESTINATION <destination>]
)
```

**Type:** function


### Description
  Install declared header for a given target and solve the relative path using the provided base dirs.
  It is using the _jrl_install_headers and _jrl_install_headers_base_dirs properties set via jrl_target_headers().
  For a whole project, use jrl_install_headers() instead (which calls this function for each component, that contains targets).


### Arguments
* `target`: The target.
* `DESTINATION`: Install destination (Optional, default is CMAKE_INSTALL_INCLUDEDIR).


### Example
```cmake
jrl_target_install_headers(my_target)
```
# `jrl_install_headers`

```cpp
jrl_install_headers(
    [DESTINATION <destination>]
    [COMPONENTS <component1> <component2> ...]
)
```

**Type:** function


### Description
  For each component, install declared headers for all targets.
  See jrl_target_headers() to declare headers for a target.


### Arguments
* `DESTINATION`: Install destination (Optional, default is CMAKE_INSTALL_INCLUDEDIR).
* `COMPONENTS`: List of components (Optional, default is all declared components).


### Example
```cmake
jrl_install_headers()
```
# `jrl_export_package`

```cpp
jrl_export_package(
    [PACKAGE_CONFIG_TEMPLATE <template>]
    [CMAKE_FILES_INSTALL_DIR <dir>]
    [PACKAGE_CONFIG_EXTRA_CONTENT <content>]
)
```

**Type:** function


### Description
  Export the CMake package with all its components (targets, headers, package modules, etc.)
  Generates and installs CMake package configuration files:
   - <INSTALL_DIR>/<package>/<package>-config.cmake
   - <INSTALL_DIR>/<package>/<package>-config-version.cmake
   - <INSTALL_DIR>/<package>/<package>/<componentA>/targets.cmake
   - <INSTALL_DIR>/<package>/<package>/<componentA>/dependencies.cmake
   - <INSTALL_DIR>/<package>/<package>/<componentB>/targets.cmake
   - <INSTALL_DIR>/<package>/<package>/<componentB>/dependencies.cmake
  NOTE: This is for CMake package export only. Python bindings are handled separately.


### Arguments
* `PACKAGE_CONFIG_TEMPLATE`: Custom template for the config file.
* `CMAKE_FILES_INSTALL_DIR`: Directory to install the cmake files.
* `PACKAGE_CONFIG_EXTRA_CONTENT`: Extra content to append to the config file.


### Example
```cmake
jrl_export_package()
```
# `jrl_dump_package_dependencies_json`

```cpp
jrl_dump_package_dependencies_json(<output>)
```

**Type:** function


### Description
  Internal function to dump the package dependencies recorded with jrl_find_package()
  It is called at the end of the configuration step via cmake_language(DEFER CALL ...)
  In the function jrl_export_package().


### Arguments
* `output`: The output file path.


### Example
```cmake
jrl_dump_package_dependencies_json(my_deps.json)
```
# `jrl_legacy_option`

```cpp
jrl_legacy_option(
    NEW_OPTION <new_option_name>
    OLD_OPTION <old_option_name>
)
```

**Type:** function


### Description
  Migrate a legacy option value to a new option name and emit a deprecation warning.
  If the old option is defined, its value is migrated to the new option.
  The NEW_OPTION must already exist in the cache (created via jrl_option or option()).
  The help text is automatically retrieved from the NEW_OPTION cache property.


### Arguments
* `NEW_OPTION`: The current/new option name (must already exist in cache).
* `OLD_OPTION`: The deprecated/old option name to migrate from.


### Example
```cmake
jrl_legacy_option(
    NEW_OPTION BUILD_PYTHON
    OLD_OPTION BUILD_PYTHON_BINDINGS
)
```
# `jrl_option`

```cpp
jrl_option(
    <name>
    <help_text>
    <default_value>
    [CONDITION <cmake_condition> [FALLBACK <fallback_value>]]
    [LEGACY_NAME <legacy_name>]
)
```

**Type:** function


### Description
  Declare a cache BOOL option with optional conditional availability and legacy name migration.
  When `CONDITION` evaluates to false, the option is forced to the `FALLBACK` value (default OFF) with FORCE and hidden.
  When `LEGACY_NAME` is set, its value is migrated to `<name>` and a deprecation
  warning is emitted.


### Arguments
* `name`: The option name.
* `help_text`: The cache entry help string.
* `default_value`: The default value (ON/OFF).
* `CONDITION`: CMake condition string to evaluate (optional). If false, the option will be forced to FALLBACK value.
* `FALLBACK`: Value to force when CONDITION is false (optional).
* `LEGACY_NAME`: Deprecated option name to migrate (optional).


### Example
```cmake
jrl_option(BUILD_TESTS "Build unit tests" ON)
jrl_option(
    BUILD_PYTHON
    "Build Python bindings"
    ON
    CONDITION "BUILD_SHARED_LIBS AND Python_FOUND"
    FALLBACK OFF
    LEGACY_NAME BUILD_PYTHON_BINDINGS
)
```
# `jrl_print_options_summary`

```cpp
jrl_print_options_summary()
```

**Type:** function


### Description
  Print all options defined via jrl_option() in a nice table.


### Arguments
  None


### Example
```cmake
jrl_print_options_summary()
```
# `jrl_find_python`

```cpp
jrl_find_python(
    [version]
    [REQUIRED]
    [COMPONENTS ...]
)
```

**Type:** macro


### Description
  Shortcut to find Python package and check main variables.


### Arguments
* `version`: Python version.
* `REQUIRED`: If set, the package is required.
* `COMPONENTS`: List of components.


### Example
```cmake
jrl_find_python(3.10 REQUIRED COMPONENTS Interpreter Development.Module)
```
# `jrl_find_nanobind`

```cpp
jrl_find_nanobind([<args>...])
```

**Type:** macro


### Description
  Shortcut to find the nanobind package.
  It forwards all arguments to find_package(nanobind ...).
  Needs the python interpreter to be found first via jrl_find_python().


### Arguments
* `args`: Arguments forwarded to find_package(nanobind ...).


### Example
```cmake
jrl_find_python(3.10 REQUIRED COMPONENTS Interpreter Development.Module)
jrl_find_nanobind(2.5.0 CONFIG REQUIRED)
```
# `jrl_python_get_interpreter`

```cpp
jrl_python_get_interpreter(<output_var>)
```

**Type:** function


### Description
  Get the python interpreter path from the Python::Interpreter target.


### Arguments
* `output_var`: The variable to store the path.


### Example
```cmake
jrl_python_get_interpreter(python_interpreter)
execute_process(COMMAND ${python_interpreter} -c "print('Hello from Python!')")
```
# `jrl_python_compile_all`

```cpp
jrl_python_compile_all(
    DIRECTORY <directory>
    [VERBOSE]
)
```

**Type:** function


### Description
  Compiles all the python files recursively in a given directory, via the compileall module.
  It creates the corresponding .pyc files in __pycache__ folders.


### Arguments
* `DIRECTORY`: The directory to compile.
* `VERBOSE`: If set, print more info.


### Example
```cmake
jrl_python_compile_all(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/my_python_package)
```
# `jrl_python_generate_init_py`

```cpp
jrl_python_generate_init_py(
    <module_target_name>
    OUTPUT_PATH <output_path>
    [TEMPLATE_FILE <template_file>]
)
```

**Type:** function


### Description
  Generates a __init__.py file for a given python module target.
  It computes all the relative paths to dlls it needs to add to os.add_dll_directory based on the target's LINK_LIBRARIES.
  The generated __init__.py will call the os.add_dll_directory(<relative_path/to/coal.dll>).


### Arguments
* `module_target_name`: The python module target name.
* `OUTPUT_PATH`: Path where to generate the init file.
* `TEMPLATE_FILE`: Custom template file.


### Example
```cmake
nanobind_add_module(coal_pywrap_nb module.cpp)
# Link the python module with the main pure c++ shared library 'coal'
target_link_libraries(coal_pywrap_nb PRIVATE coal)
jrl_target_set_output_directory(coal_pywrap_nb OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/site-packages/coal)

jrl_python_generate_init_py(
    coal_pywrap_nb
    OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib/site-packages/coal/__init__.py
)
```
# `jrl_check_python_module`

```cpp
jrl_check_python_module(
    <module_name>
    [REQUIRED]
    [QUIET]
)
```

**Type:** function


### Description
  Find if a python module is available, fills <module_name>_FOUND variable.
  Also fills <module_name>_VERSION variable if the module has a __version__ attribute.
  Displays messages based on REQUIRED and QUIET options.


### Arguments
* `module_name`: The python module name.
* `REQUIRED`: If set, the package is required.
* `QUIET`: If set, do not print messages.


### Example
```cmake
jrl_check_python_module(numpy REQUIRED)
```
# `jrl_python_relative_site_packages`

```cpp
jrl_python_relative_site_packages(<output>)
```

**Type:** function


### Description
  Compute the relative path of the Python site-packages directory with respect to
  the Python data directory. It is the result of:
  ```python
    sysconfig.get_path('purelib')).relative_to(sysconfig.get_path('data')
  ```

  This function is used to compute the installation directory for Python bindings in
  in jrl_python_compute_install_dir(<output>), and for ros2 package files.

  NOTE: For installing Python bindings, use jrl_python_compute_install_dir() instead.


### Arguments
  <output> - Name of the variable to store the result.


### Example
```cmake
    jrl_python_relative_site_packages(python_relative_site_packages)
    message(STATUS "Python relative site-packages: ${python_relative_site_packages}")
```

# `jrl_python_absolute_site_packages`

```cpp
jrl_python_absolute_site_packages(<output>)
```

**Type:** function


### Description
  Compute the absolute path of the Python site-packages directory with respect to
  the Python data directory. It is the result of:
  ```python
    sysconfig.get_path('purelib')
  ```

  This function is used to compute the installation directory for Python bindings in
  in jrl_python_compute_install_dir(<output>).

  NOTE: For installing Python bindings, use jrl_python_compute_install_dir() instead.


### Arguments
  <output> - Name of the variable to store the result.


### Example
```cmake
    jrl_python_absolute_site_packages(python_absolute_site_packages)
    message(STATUS "Python absolute site-packages: ${python_absolute_site_packages}")
```

# `jrl_python_compute_install_dir`

```cpp
jrl_python_compute_install_dir(<output>)
```

**Type:** function


### Description
    Compute the installation directory for Python libraries.
    It chooses the installation based using the following priority:
 1. If <PROJECT_NAME_UPPER>_PYTHON_INSTALL_DIR is defined, its value is used.
    Usually passed via CMake command line: -D<PROJECT_NAME_UPPER>_PYTHON_INSTALL_DIR=<path>
    It is usually an absolute path to a specific site-packages folder.
    Note: <PROJECT_NAME_UPPER> is the PROJECT_NAME converted to a valid C identifier and in upper case.
 2. If <PROJECT_NAME_UPPER>_PYTHON_INSTALL_DIR **environment** variable is defined, its value is used.
 3. If running inside a CMeel environment (on Windows), the PYTHON_SITELIB variable is used.
    CMeel is detected when CMAKE_INSTALL_PREFIX contains "cmeel.prefix".
    The PYTHON_SITELIB variable is forwareded by CMeel.
 4. If running inside a Conda environment, on Windows, the absolute path to site-packages is used.
    It is the return value of: `sysconfig.get_path('purelib')`.
    Example: `C:/Users/You/Miniconda3/envs/myenv/Lib/site-packages`
 5. The relative path to site-packages is used.
    It is the result of: `sysconfig.get_path('purelib')).relative_to(sysconfig.get_path('data')`
    On macOS/Linux: `lib/python3.11/site-packages`
    On Windows: `Lib/site-packages`

#### Conda Windows Layout

On Conda Windows, the site-packages is located in the `Lib\site-packages` folder,
but the Conda native libraries (DLLs) are located in the `Library\bin` folder.
CMAKE_INSTALL_PREFIX is set to CMAKE_INSTALL_PREFIX=%PREFIX%\Library.
But the python libraries are installed in %PREFIX%\Lib\site-packages.

```
C:\Users\You\Miniconda3\envs\myenv\
├── python.exe                  # The Python Interpreter
├── pythonw.exe
├── DLLs\                       # Standard Python DLLs
├── Lib\
│   └── site-packages\          # <--- PURELIB IS HERE
│       ├── pandas\
│       ├── requests\
│       └── ...
├── Scripts\                    # Python Entry points (pip.exe, jupyter.exe)
├── Library\                    # <--- CONDA SPECIFIC FOLDER
│   ├── bin\                    # Native DLLs (libssl-1_1-x64.dll, mkl.dll)
│   ├── include\                # C Headers (.h files)
│   └── lib\                    # Link libraries (.lib)
└── ...
```

#### Conda Linux & macOS Layout (Unix)

On Unix Conda environments, the site-packages is located in the `lib/pythonX.Y/site-packages` folder,
and the Conda native libraries are located in the `lib/` folder, just like a standard installation.

```
/home/user/miniconda3/envs/myenv/
├── bin/                        # Executables (python, pip, jupyter)
├── include/                    # C Headers
├── lib/
│   ├── libssl.so               # Native shared libraries
│   └── python3.11/
│       └── site-packages/      # <--- PURELIB IS HERE
│           ├── pandas/
│           └── ...
└── ...
```


### Arguments
  <output> - Name of the variable to store the result.


### Example
```cmake
  jrl_python_compute_install_dir(python_install_dir)
  install(TARGETS my_python_module DESTINATION ${python_install_dir} ...)
```
# `jrl_check_python_module_name`

```cpp
jrl_check_python_module_name(<module_target>)
```

**Type:** function


### Description
  Check that the python module defined with NB_MODULE(<module_name>)
  or BOOST_PYTHON_MODULE(<module_name>) has the same name as the target: <module_name>.cpython-XY.so.
  Otherwise the module will fail to load in Python.
  NOTE: It verifies that the symbol PyInit_<module_name> exists in the built module.


### Arguments
* `module_target`: The python module target.


### Example
```cmake
jrl_check_python_module_name(my_module)
```
# `jrl_boostpy_add_module`

```cpp
jrl_boostpy_add_module(
    <name>
    [sources...]
)
```

**Type:** function


### Description
  Creates a Boost.Python module with the given name and sources.
  The library name will be in the form <name>-<SOABI>.so, where <SOABI> is the
  Python SOABI tag (e.g., cp39-cp39m-linux_x86_64).


### Arguments
* `name`: The name of the module.
* `sources`: Source files.


### Example
```cmake
jrl_boostpy_add_module(my_module module.cpp)
```
# `jrl_boostpy_add_stubs`

```cpp
jrl_boostpy_add_stubs(
    <name>
    MODULE <module_path>
    OUTPUT_PATH <output_path>
    [PYTHON_PATH <python_path>]
    [DEPENDS <dep1> <dep2> ...]
    [VERBOSE]
)
```

**Type:** function


### Description
  Generates Boost.Python stubs for the given module using the pybind11-stubgen fork included in this repo.


### Arguments
* `name`: The target name.
* `MODULE`: The module to generate stubs for.
* `OUTPUT_PATH`: Output path.
* `PYTHON_PATH`: PYTHONPATH to use (optional).
* `DEPENDS`: Dependencies (optional).
* `VERBOSE`: Verbose output (optional).


### Example
```cmake
jrl_boostpy_add_stubs(my_stubs MODULE my_module OUTPUT_PATH ${CMAKE_BINARY_DIR})
```
# `jrl_generate_ros2_package_files`

```cpp
jrl_generate_ros2_package_files(
    [INSTALL_CPP_PACKAGE_FILES <ON|OFF>]
    [INSTALL_PYTHON_PACKAGE_FILES <ON|OFF>]
    [PACKAGE_XML_PATH <path>]
    [DESTINATION <install destination>]
    [GEN_DIR <gen_dir>]
    [SKIP_INSTALL]
)
```

**Type:** function


### Description
  Generates the necessary files for a ROS 2 package to be discoverable by ament.
  It creates the following files:
   - ${GEN_DIR}/share/ament_index/resource_index/packages/<PROJECT_NAME>
   - ${GEN_DIR}/share/<PROJECT_NAME>/hook/ament_prefix_path.dsv
   - ${GEN_DIR}/share/<PROJECT_NAME>/hook/python_path.dsv

  By default, it installs all generated files to the CMAKE_INSTALL_DATAROOTDIR directory.
  You can override the installation destination using the DESTINATION argument.


### Arguments
* `INSTALL_CPP_PACKAGE_FILES`: Whether to install the C++ package files (default: ON).
* `INSTALL_PYTHON_PACKAGE_FILES`: Whether to install the Python package files (default: ON).
* `PACKAGE_XML_PATH`: Path to the package.xml file (default: ${CMAKE_CURRENT_SOURCE_DIR}/package.xml).
* `DESTINATION`: Installation destination for the generated files (default: CMAKE_INSTALL_DATAROOTDIR).
* `GEN_DIR`: Directory where to generate the files (default: ${CMAKE_BINARY_DIR}/generated/ros2/${PROJECT_NAME}/ros2).
* `SKIP_INSTALL`: If set, skips the installation of the generated files.


### Example
```cmake
jrl_generate_ros2_package_files()

jrl_generate_ros2_package_files(
    INSTALL_CPP_PACKAGE_FILES "NOT BUILD_STANDALONE_PYTHON_BINDINGS"
)
```

