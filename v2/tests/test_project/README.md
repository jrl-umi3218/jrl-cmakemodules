# Test Project for jrl-cmakemodules-v2

This is a test C++ project demonstrating the usage of various functions from jrl-cmakemodules-v2.cmake.

## Features

- Two C++17 libraries: math_lib (static) and string_lib (shared)
- Python bindings using nanobind
- Generated config headers
- Component-based packaging
- Header installation

## Dependencies

This project uses Pixi for dependency management.

### Install Pixi

If you don't have Pixi installed, install it first:

```bash
curl -fsSL https://pixi.sh/install.sh | bash
```

### Install Dependencies

```bash
pixi install
```

This will install Python and nanobind.

### Build the Project

Enter the Pixi environment and build:

```bash
pixi shell
mkdir build
cd build
cmake ..
make
```

### Install the Project

```bash
make install
```

## Usage

After building and installing, you can use the libraries in your C++ projects or import the Python module.

### Python Example

```python
import pytest_bindings

# Math operations
result = pytest_bindings.Math.add(2, 3)
print(result)  # 5

# String operations
upper = pytest_bindings.StringUtils.to_upper("hello")
print(upper)  # "HELLO"
```
