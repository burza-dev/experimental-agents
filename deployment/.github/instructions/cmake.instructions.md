---
applyTo: "**/CMakeLists.txt,**/*.cmake"
---

# CMake Build Rules

## Overview

Modern CMake (3.28+) configuration rules for C/C++ projects. Use target-based approach, 
proper scoping, and leverage modern features like presets and FetchContent.

## Version Requirements

### Minimum Version
```cmake
cmake_minimum_required(VERSION 3.28)
```

### Feature Documentation
Document required CMake features in comments:
```cmake
# Requires CMake 3.28+ for:
# - C++23 module support
# - FetchContent_MakeAvailable_Simple
# - Enhanced generator expressions
cmake_minimum_required(VERSION 3.28)
```

## Project Structure

### Project Declaration
Always specify VERSION, DESCRIPTION, and LANGUAGES:
```cmake
project(my_project
    VERSION 1.2.3
    DESCRIPTION "Brief project description"
    LANGUAGES CXX
)
```

### Language Standards (Mandatory)
```cmake
# C++ Standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# C Standard (if applicable)
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
```

### Development Settings
```cmake
# Export compile commands for tooling (clangd, LSP)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Position Independent Code (required for shared libs)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
```

## Modern CMake Patterns

### Target-Based Approach (Mandatory)
Use `target_*` commands instead of global settings:
```cmake
# Good: Target-scoped
target_include_directories(my_target PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_compile_definitions(my_target PRIVATE DEBUG_ENABLED)
target_compile_options(my_target PRIVATE -Wall -Wextra)

# Bad: Global scope (FORBIDDEN)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)  # DON'T
add_definitions(-DDEBUG_ENABLED)                       # DON'T
```

### Generator Expressions
Use generator expressions for conditional logic:
```cmake
target_compile_options(my_target PRIVATE
    $<$<CXX_COMPILER_ID:GNU>:-Wall -Wextra -Wpedantic>
    $<$<CXX_COMPILER_ID:Clang>:-Wall -Wextra -Wpedantic>
    $<$<CXX_COMPILER_ID:MSVC>:/W4 /WX>
    $<$<CONFIG:Debug>:-g -O0>
    $<$<CONFIG:Release>:-O3 -DNDEBUG>
)
```

### Interface Libraries for Headers
```cmake
add_library(my_headers INTERFACE)
target_include_directories(my_headers INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
```

## Dependencies

### FetchContent (Preferred for Simple Dependencies)
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

FetchContent_MakeAvailable(fmt spdlog)

target_link_libraries(my_target PRIVATE fmt::fmt spdlog::spdlog)
```

### find_package (Prefer CONFIG Mode)
```cmake
# CONFIG mode preferred - uses package's CMake config
find_package(Boost 1.84 REQUIRED CONFIG COMPONENTS filesystem system)
find_package(OpenSSL 3.0 REQUIRED)

target_link_libraries(my_target PRIVATE
    Boost::filesystem
    Boost::system
    OpenSSL::SSL
    OpenSSL::Crypto
)
```

### vcpkg Integration
```cmake
# Set toolchain in CMakePresets.json or command line:
# cmake -DCMAKE_TOOLCHAIN_FILE=/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake

# In CMakeLists.txt, just use find_package normally:
find_package(nlohmann_json CONFIG REQUIRED)
target_link_libraries(my_target PRIVATE nlohmann_json::nlohmann_json)
```

### Conan Integration
```cmake
# Using conan_provider.cmake (CMake 3.24+):
list(APPEND CMAKE_PROJECT_TOP_LEVEL_INCLUDES
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/conan_provider.cmake
)

# Or use generated files:
find_package(fmt REQUIRED)
find_package(spdlog REQUIRED)
```

### Version Constraints
```cmake
find_package(Boost 1.80...<2.0 REQUIRED)  # Range notation
find_package(OpenSSL 3.0 EXACT)           # Exact version
```

## Targets

### Library Targets
```cmake
# Let BUILD_SHARED_LIBS control library type
add_library(my_lib
    src/module_a.cpp
    src/module_b.cpp
)

# PUBLIC: Used by target AND consumers
# PRIVATE: Used only by target
# INTERFACE: Used only by consumers
target_include_directories(my_lib
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(my_lib
    PUBLIC Boost::boost
    PRIVATE fmt::fmt
)
```

### ALIAS Targets
Always create ALIAS targets for internal use:
```cmake
add_library(my_lib src/lib.cpp)
add_library(MyProject::my_lib ALIAS my_lib)

# Use alias in other targets
target_link_libraries(my_app PRIVATE MyProject::my_lib)
```

### Executable Targets
```cmake
add_executable(my_app
    src/main.cpp
    src/app.cpp
)

target_link_libraries(my_app PRIVATE MyProject::my_lib)
```

### Object Libraries (for Sharing Compilation)
```cmake
add_library(common_objects OBJECT
    src/common_a.cpp
    src/common_b.cpp
)

target_link_libraries(my_lib PRIVATE common_objects)
target_link_libraries(my_app PRIVATE common_objects)
```

## Testing

### CTest Setup
```cmake
# In top-level CMakeLists.txt
include(CTest)

if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()
```

### GoogleTest Integration
```cmake
include(FetchContent)
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        v1.15.2
    GIT_SHALLOW    TRUE
)
# Prevent GTest from overriding compiler settings on Windows
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

include(GoogleTest)

add_executable(my_tests
    tests/test_module_a.cpp
    tests/test_module_b.cpp
)

target_link_libraries(my_tests PRIVATE
    GTest::gtest
    GTest::gtest_main
    GTest::gmock
    MyProject::my_lib
)

gtest_discover_tests(my_tests
    PROPERTIES
        TIMEOUT 60
        LABELS "unit"
)
```

### Custom Test Properties
```cmake
add_test(NAME integration_test COMMAND my_integration_test)
set_tests_properties(integration_test PROPERTIES
    TIMEOUT 300
    LABELS "integration"
    ENVIRONMENT "TEST_DB=test.db"
)
```

### Coverage Configuration
```cmake
option(ENABLE_COVERAGE "Enable code coverage" OFF)

if(ENABLE_COVERAGE)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        target_compile_options(my_lib PRIVATE --coverage -fprofile-arcs -ftest-coverage)
        target_link_options(my_lib PRIVATE --coverage)
    endif()
endif()

# Custom coverage target
add_custom_target(coverage
    COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
    COMMAND lcov --capture --directory . --output-file coverage.info
    COMMAND lcov --remove coverage.info '/usr/*' --output-file coverage.info
    COMMAND genhtml coverage.info --output-directory coverage_report
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    DEPENDS my_tests
    COMMENT "Generating coverage report"
)
```

## Static Analysis Integration

### Clang-Tidy
```cmake
option(ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)

if(ENABLE_CLANG_TIDY)
    find_program(CLANG_TIDY_EXE NAMES clang-tidy)
    if(CLANG_TIDY_EXE)
        set(CMAKE_CXX_CLANG_TIDY
            ${CLANG_TIDY_EXE}
            -checks=*,-fuchsia-*,-llvmlibc-*
            -warnings-as-errors=*
            -header-filter=${CMAKE_SOURCE_DIR}/include
        )
    endif()
endif()
```

### Cppcheck
```cmake
option(ENABLE_CPPCHECK "Enable cppcheck" OFF)

if(ENABLE_CPPCHECK)
    find_program(CPPCHECK_EXE NAMES cppcheck)
    if(CPPCHECK_EXE)
        set(CMAKE_CXX_CPPCHECK
            ${CPPCHECK_EXE}
            --enable=all
            --suppress=missingIncludeSystem
            --inline-suppr
            --inconclusive
        )
    endif()
endif()
```

### Include-What-You-Use (IWYU)
```cmake
option(ENABLE_IWYU "Enable include-what-you-use" OFF)

if(ENABLE_IWYU)
    find_program(IWYU_EXE NAMES include-what-you-use iwyu)
    if(IWYU_EXE)
        set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE
            ${IWYU_EXE}
            -Xiwyu --mapping_file=${CMAKE_SOURCE_DIR}/.iwyu.imp
        )
    endif()
endif()
```

## CMake Presets

### Example CMakePresets.json
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
            "displayName": "Debug",
            "cacheVariables": {
                "CMAKE_BUILD_TYPE": "Debug"
            }
        },
        {
            "name": "release",
            "inherits": "base",
            "displayName": "Release",
            "cacheVariables": {
                "CMAKE_BUILD_TYPE": "Release"
            }
        },
        {
            "name": "ci",
            "inherits": "base",
            "displayName": "CI Build",
            "cacheVariables": {
                "CMAKE_BUILD_TYPE": "Release",
                "ENABLE_CLANG_TIDY": "ON",
                "BUILD_TESTING": "ON"
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
            "configurePreset": "release"
        },
        {
            "name": "ci",
            "configurePreset": "ci"
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
            }
        }
    ]
}
```

### Using Presets
```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset default
```

## Installation

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
)
```

### CMake Package Config (for find_package Support)
```cmake
include(CMakePackageConfigHelpers)

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

# Install export targets with namespace
install(EXPORT MyProjectTargets
    FILE MyProjectTargets.cmake
    NAMESPACE MyProject::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyProject
)

# Install config files
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/MyProjectConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/MyProjectConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyProject
)
```

### Config Template (cmake/MyProjectConfig.cmake.in)
```cmake
@PACKAGE_INIT@

include(CMakeFindDependencyMacro)

# Add any runtime dependencies
find_dependency(Boost 1.80 COMPONENTS filesystem)

include("${CMAKE_CURRENT_LIST_DIR}/MyProjectTargets.cmake")

check_required_components(MyProject)
```

### Proper RPATH Handling
```cmake
# Set RPATH for installed binaries
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}")

# macOS specific
set(CMAKE_MACOSX_RPATH ON)
```

## Forbidden Patterns

### Global Commands (NEVER Use)
```cmake
# FORBIDDEN: Global include directories
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

# FORBIDDEN: Global definitions
add_definitions(-DDEBUG_ENABLED)

# FORBIDDEN: Global compile options
add_compile_options(-Wall -Wextra)

# FORBIDDEN: Link directories
link_directories(/usr/local/lib)
```

### Bad Practices
```cmake
# FORBIDDEN: file(GLOB) for sources - breaks incremental builds
file(GLOB SOURCES "src/*.cpp")
add_library(my_lib ${SOURCES})

# FORBIDDEN: Hardcoded paths
target_include_directories(my_lib PRIVATE /usr/local/include)

# FORBIDDEN: Using variables for target properties
set(MY_LIB_SOURCES src/a.cpp src/b.cpp)
# Instead, list sources directly in add_library/add_executable

# FORBIDDEN: Modifying CMAKE_CXX_FLAGS directly
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")  # Don't do this
```

### Anti-Patterns to Avoid
- Using `link_libraries()` (global linking)
- Setting properties on `CMAKE_TARGETS` variable
- Using `aux_source_directory()` for source collection
- Mixing `add_subdirectory()` with `include()` inconsistently
- Not using namespaced targets for exported libraries

## Project Template

### Minimal Modern CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.28)
project(my_project
    VERSION 1.0.0
    DESCRIPTION "Project description"
    LANGUAGES CXX
)

# Global settings
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Options
option(BUILD_TESTING "Build tests" ON)
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

# Include CMake modules
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Dependencies
include(FetchContent)
FetchContent_Declare(fmt
    GIT_REPOSITORY https://github.com/fmtlib/fmt.git
    GIT_TAG 10.2.1
    GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(fmt)

# Library target
add_library(my_lib
    src/module.cpp
)
add_library(MyProject::my_lib ALIAS my_lib)

target_include_directories(my_lib
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)
target_link_libraries(my_lib PRIVATE fmt::fmt)

# Executable
add_executable(my_app src/main.cpp)
target_link_libraries(my_app PRIVATE MyProject::my_lib)

# Testing
if(BUILD_TESTING)
    include(CTest)
    enable_testing()
    add_subdirectory(tests)
endif()

# Installation
install(TARGETS my_lib my_app
    EXPORT MyProjectTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
```
