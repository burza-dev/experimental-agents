---
name: cmake-modern
description: Modern CMake 3.28+ patterns and best practices for C/C++ projects
---

# Modern CMake Patterns

## When to Apply

- Creating new CMake-based C/C++ projects
- Migrating legacy CMake configurations to modern patterns
- Setting up FetchContent dependencies
- Configuring cross-platform builds with presets
- Creating installable/findable packages

## Core Principles

### Target-Based Mindset
Everything in modern CMake revolves around targets. Targets have properties that propagate
to dependent targets based on scope.

```cmake
# Targets are the fundamental abstraction
add_library(my_lib src/impl.cpp)
add_executable(my_app src/main.cpp)

# Properties attach to targets, not global state
target_include_directories(my_lib PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_compile_definitions(my_lib PRIVATE INTERNAL_BUILD)
target_link_libraries(my_app PRIVATE my_lib)
```

### Properties Over Variables
Prefer `target_*` commands over global variables:

```cmake
# Modern: Target properties
target_compile_options(my_lib PRIVATE -Wall -Wextra)

# Legacy: Global variables (avoid)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")  # Don't do this
```

### Scopes: PUBLIC, PRIVATE, INTERFACE

| Scope     | Used by target | Propagates to consumers |
|-----------|----------------|-------------------------|
| PRIVATE   | Yes            | No                      |
| PUBLIC    | Yes            | Yes                     |
| INTERFACE | No             | Yes                     |

```cmake
target_include_directories(my_lib
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)
```

## Interface Libraries

### Header-Only Libraries
```cmake
add_library(my_headers INTERFACE)
target_include_directories(my_headers INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
target_compile_features(my_headers INTERFACE cxx_std_20)
```

### Configuration Interfaces
Group compiler options into reusable targets:

```cmake
add_library(project_warnings INTERFACE)
target_compile_options(project_warnings INTERFACE
    $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall -Wextra -Wpedantic>
    $<$<CXX_COMPILER_ID:MSVC>:/W4 /WX>
)

add_library(project_options INTERFACE)
target_compile_features(project_options INTERFACE cxx_std_20)
target_link_libraries(project_options INTERFACE project_warnings)

# Apply to all targets
target_link_libraries(my_lib PRIVATE project_options)
```

## Generator Expressions

Generator expressions evaluate at build-time, enabling conditional logic:

```cmake
# Target file location
$<TARGET_FILE:my_lib>
$<TARGET_FILE_DIR:my_lib>

# Build vs install interface
$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
$<INSTALL_INTERFACE:include>

# Configuration-specific
$<$<CONFIG:Debug>:-DDEBUG_MODE>
$<$<CONFIG:Release>:-DNDEBUG -O3>

# Compiler-specific
$<$<CXX_COMPILER_ID:GNU>:-fdiagnostics-color=always>
$<$<CXX_COMPILER_ID:Clang>:-fcolor-diagnostics>
$<$<CXX_COMPILER_ID:MSVC>:/MP>

# Boolean expressions
$<$<AND:$<CXX_COMPILER_ID:GNU>,$<CONFIG:Debug>>:-Og>
$<$<BOOL:${ENABLE_FEATURE}>:-DFEATURE_ENABLED>

# Target properties
$<TARGET_PROPERTY:my_lib,INTERFACE_INCLUDE_DIRECTORIES>
```

## FetchContent Patterns

### Basic Usage
```cmake
include(FetchContent)

FetchContent_Declare(
    fmt
    GIT_REPOSITORY https://github.com/fmtlib/fmt.git
    GIT_TAG        10.2.1
    GIT_SHALLOW    TRUE
)

FetchContent_Declare(
    spdlog
    GIT_REPOSITORY https://github.com/gabime/spdlog.git
    GIT_TAG        v1.14.1
    GIT_SHALLOW    TRUE
)

# Download and make available (preferred)
FetchContent_MakeAvailable(fmt spdlog)

target_link_libraries(my_app PRIVATE fmt::fmt spdlog::spdlog)
```

### Advanced Control
```cmake
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        v1.15.2
    GIT_SHALLOW    TRUE
)

# Customize before making available
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
set(BUILD_GMOCK ON CACHE BOOL "" FORCE)

# Populate manually for more control
FetchContent_GetProperties(googletest)
if(NOT googletest_POPULATED)
    FetchContent_Populate(googletest)
    add_subdirectory(${googletest_SOURCE_DIR} ${googletest_BINARY_DIR})
endif()
```

### Using URL/Archive
```cmake
FetchContent_Declare(
    json
    URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.tar.xz
    URL_HASH SHA256=d6c65aca6b1ed68e7a182f4757f21f8a2b8f0e7b
)
```

## Find Package Patterns

### CONFIG vs MODULE Mode

```cmake
# CONFIG mode (preferred) - uses package's CMake config files
find_package(Boost 1.84 REQUIRED CONFIG COMPONENTS filesystem system)

# MODULE mode - uses CMake's FindXXX.cmake modules
find_package(OpenSSL 3.0 REQUIRED MODULE)

# Let CMake choose (tries CONFIG first)
find_package(fmt REQUIRED)
```

### Version Constraints
```cmake
find_package(Boost 1.80...<2.0 REQUIRED)  # Range notation (CMake 3.19+)
find_package(OpenSSL 3.0 EXACT)            # Exact version
find_package(Threads REQUIRED)              # No version required
```

### Creating Findable Packages

Your package needs:
1. Exported targets with namespace
2. Config and version files
3. Proper RPATH handling

```cmake
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

# Export targets
install(EXPORT MyProjectTargets
    FILE MyProjectTargets.cmake
    NAMESPACE MyProject::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyProject
)

# Generate version file
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/MyProjectConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

# Configure config file
configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/MyProjectConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/MyProjectConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyProject
)

# Install config files
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/MyProjectConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/MyProjectConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyProject
)
```

Config template (`cmake/MyProjectConfig.cmake.in`):
```cmake
@PACKAGE_INIT@

include(CMakeFindDependencyMacro)
find_dependency(Boost 1.80 COMPONENTS filesystem)

include("${CMAKE_CURRENT_LIST_DIR}/MyProjectTargets.cmake")
check_required_components(MyProject)
```

## CMakePresets.json

Complete example with configure, build, and test presets:

```json
{
    "version": 6,
    "cmakeMinimumRequired": {
        "major": 3,
        "minor": 28,
        "patch": 0
    },
    "configurePresets": [
        {
            "name": "base",
            "hidden": true,
            "generator": "Ninja",
            "binaryDir": "${sourceDir}/build/${presetName}",
            "cacheVariables": {
                "CMAKE_EXPORT_COMPILE_COMMANDS": "ON"
            }
        },
        {
            "name": "debug",
            "inherits": "base",
            "displayName": "Debug Build",
            "cacheVariables": {
                "CMAKE_BUILD_TYPE": "Debug"
            }
        },
        {
            "name": "release",
            "inherits": "base",
            "displayName": "Release Build",
            "cacheVariables": {
                "CMAKE_BUILD_TYPE": "Release",
                "CMAKE_INTERPROCEDURAL_OPTIMIZATION": "ON"
            }
        },
        {
            "name": "ci",
            "inherits": "release",
            "displayName": "CI Build",
            "cacheVariables": {
                "BUILD_TESTING": "ON",
                "ENABLE_CLANG_TIDY": "ON"
            }
        },
        {
            "name": "vcpkg",
            "inherits": "base",
            "cacheVariables": {
                "CMAKE_TOOLCHAIN_FILE": "$env{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
            }
        }
    ],
    "buildPresets": [
        {
            "name": "debug",
            "configurePreset": "debug"
        },
        {
            "name": "release",
            "configurePreset": "release",
            "configuration": "Release"
        },
        {
            "name": "ci",
            "configurePreset": "ci",
            "configuration": "Release"
        }
    ],
    "testPresets": [
        {
            "name": "default",
            "configurePreset": "debug",
            "output": {
                "outputOnFailure": true
            }
        },
        {
            "name": "ci",
            "configurePreset": "ci",
            "output": {
                "outputOnFailure": true,
                "verbosity": "verbose"
            },
            "execution": {
                "jobs": 4,
                "timeout": 300
            }
        }
    ]
}
```

Usage:
```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset default
```

## Installation Best Practices

### GNUInstallDirs Compliance
```cmake
include(GNUInstallDirs)

install(TARGETS my_lib my_app
    EXPORT MyProjectTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(DIRECTORY include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
)
```

### RPATH Handling
```cmake
# Use link path for RPATH
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# Set RPATH to library directory
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}")

# macOS specific
set(CMAKE_MACOSX_RPATH ON)

# Don't skip RPATH for build tree
set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
```

### Package Config Generation
See "Creating Findable Packages" section above for complete example.

## Common Anti-patterns

| Anti-pattern | Modern Alternative |
|--------------|-------------------|
| `include_directories()` | `target_include_directories()` |
| `add_definitions()` | `target_compile_definitions()` |
| `add_compile_options()` | `target_compile_options()` |
| `link_directories()` | `target_link_directories()` or link to targets |
| `link_libraries()` | `target_link_libraries()` |
| `file(GLOB SOURCES ...)` | Explicit source listing |
| Setting `CMAKE_CXX_FLAGS` | `target_compile_options()` |
| Hardcoded paths | Generator expressions, GNUInstallDirs |
| `aux_source_directory()` | Explicit source listing |
| Non-namespaced export | `NAMESPACE` in install(EXPORT) |

### More Anti-patterns to Avoid

```cmake
# Don't glob sources (breaks incremental builds)
file(GLOB SOURCES "src/*.cpp")  # DON'T

# Don't hardcode paths
target_include_directories(my_lib PRIVATE /usr/local/include)  # DON'T

# Don't use global linking
link_libraries(pthread)  # DON'T

# Don't modify global flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")  # DON'T
```

## Quick Reference

### Project Setup
```cmake
cmake_minimum_required(VERSION 3.28)
project(my_project
    VERSION 1.0.0
    DESCRIPTION "My project"
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
```

### Target Types
```cmake
add_library(static_lib STATIC src/lib.cpp)      # Static library
add_library(shared_lib SHARED src/lib.cpp)      # Shared library
add_library(header_only INTERFACE)               # Header-only/interface
add_library(obj_lib OBJECT src/lib.cpp)          # Object library
add_executable(app src/main.cpp)                 # Executable
add_library(MyProject::lib ALIAS static_lib)     # Alias target
```

### Target Commands
```cmake
target_sources(target PRIVATE src/extra.cpp)
target_include_directories(target PUBLIC include PRIVATE src)
target_compile_definitions(target PRIVATE DEBUG_MODE)
target_compile_options(target PRIVATE -Wall)
target_compile_features(target PUBLIC cxx_std_20)
target_link_libraries(target PRIVATE dependency)
target_link_options(target PRIVATE -static)
target_precompile_headers(target PRIVATE <vector> <string>)
```
