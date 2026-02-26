---
name: clang-tidy
description: C/C++ static analysis with clang-tidy for code quality, modernization, and bug detection. Apply to C/C++ projects using Clang tooling.
---

# Clang-Tidy Static Analysis

## When to Apply

Use clang-tidy when:
- Writing or reviewing C/C++ code
- Modernizing legacy C++ codebases
- Enforcing C++ Core Guidelines
- Setting up CI/CD for C/C++ projects
- Detecting common bugs and performance issues
- Preparing code for C++ standard upgrades

## Configuration

### .clang-tidy File

```yaml
---
# Modern C++17/20 configuration with comprehensive checks
Checks: >
  -*,
  bugprone-*,
  cert-*,
  clang-analyzer-*,
  concurrency-*,
  cppcoreguidelines-*,
  misc-*,
  modernize-*,
  performance-*,
  portability-*,
  readability-*,
  -modernize-use-trailing-return-type,
  -readability-identifier-length,
  -cppcoreguidelines-avoid-magic-numbers,
  -readability-magic-numbers

# Treat warnings as errors in CI
WarningsAsErrors: ''

# Header filter for project headers only
HeaderFilterRegex: '^(src|include)/.*'

# Format style for fix suggestions
FormatStyle: file

# Check options
CheckOptions:
  # Naming conventions
  - key: readability-identifier-naming.ClassCase
    value: CamelCase
  - key: readability-identifier-naming.FunctionCase
    value: camelBack
  - key: readability-identifier-naming.VariableCase
    value: lower_case
  - key: readability-identifier-naming.ConstantCase
    value: UPPER_CASE
  - key: readability-identifier-naming.PrivateMemberSuffix
    value: '_'
  - key: readability-identifier-naming.ProtectedMemberSuffix
    value: '_'

  # Function complexity
  - key: readability-function-cognitive-complexity.Threshold
    value: 25
  - key: readability-function-size.LineThreshold
    value: 100

  # Performance tuning
  - key: performance-unnecessary-value-param.AllowedTypes
    value: 'std::shared_ptr;std::unique_ptr'
  - key: performance-move-const-arg.CheckTriviallyCopyableMove
    value: false

  # Smart pointer preferences
  - key: modernize-make-unique.MakeSmartPtrFunction
    value: 'std::make_unique'
  - key: modernize-make-shared.MakeSmartPtrFunction
    value: 'std::make_shared'

  # C++ standard version
  - key: modernize-use-nullptr.NullMacros
    value: 'NULL'
  - key: misc-non-private-member-variables-in-classes.IgnoreClassesWithAllMemberVariablesBeingPublic
    value: true
```

## Check Categories

| Category | Key Checks | Purpose |
|----------|------------|---------|
| **bugprone-*** | `bugprone-use-after-move`, `bugprone-dangling-handle`, `bugprone-incorrect-roundings` | Detect common programming errors and potential bugs |
| **cert-*** | `cert-err33-c`, `cert-dcl50-cpp`, `cert-oop54-cpp` | CERT secure coding standards compliance |
| **clang-analyzer-*** | `clang-analyzer-core.*`, `clang-analyzer-deadcode.*` | Deep static analysis for memory leaks, null pointers |
| **concurrency-*** | `concurrency-mt-unsafe`, `concurrency-thread-canceltype-asynchronous` | Thread safety and concurrent code issues |
| **cppcoreguidelines-*** | `cppcoreguidelines-pro-bounds-*`, `cppcoreguidelines-owning-memory` | C++ Core Guidelines enforcement |
| **misc-*** | `misc-unused-*`, `misc-redundant-expression` | Miscellaneous code quality checks |
| **modernize-*** | `modernize-use-auto`, `modernize-use-nullptr`, `modernize-use-override` | Upgrade code to modern C++ standards |
| **performance-*** | `performance-move-const-arg`, `performance-unnecessary-copy-*` | Performance optimization suggestions |
| **portability-*** | `portability-simd-intrinsics`, `portability-restrict-system-includes` | Cross-platform compatibility |
| **readability-*** | `readability-braces-around-statements`, `readability-identifier-naming` | Code readability and consistency |

### Must-Enable Checks for Modern C++

```yaml
# Minimal recommended set for C++17+ projects
Checks: >
  bugprone-use-after-move,
  bugprone-dangling-handle,
  bugprone-forwarding-reference-overload,
  cppcoreguidelines-init-variables,
  cppcoreguidelines-pro-type-member-init,
  cppcoreguidelines-slicing,
  modernize-use-auto,
  modernize-use-nullptr,
  modernize-use-override,
  modernize-make-unique,
  modernize-make-shared,
  modernize-use-emplace,
  modernize-avoid-bind,
  modernize-loop-convert,
  performance-for-range-copy,
  performance-implicit-conversion-in-loop,
  performance-inefficient-vector-operation,
  performance-move-const-arg,
  performance-unnecessary-value-param,
  readability-const-return-type,
  readability-redundant-smartptr-get
```

## CMake Integration

### Basic Integration

```cmake
# Enable clang-tidy for all targets
set(CMAKE_CXX_CLANG_TIDY
  clang-tidy
  -checks=-*,bugprone-*,modernize-*,performance-*,readability-*
  --warnings-as-errors=*
  --header-filter=${CMAKE_SOURCE_DIR}/include
)
```

### Configurable Integration

```cmake
# CMakeLists.txt
option(ENABLE_CLANG_TIDY "Enable clang-tidy static analysis" OFF)

if(ENABLE_CLANG_TIDY)
  find_program(CLANG_TIDY_EXE
    NAMES clang-tidy clang-tidy-18 clang-tidy-17 clang-tidy-16
    DOC "Path to clang-tidy executable"
  )

  if(NOT CLANG_TIDY_EXE)
    message(WARNING "clang-tidy not found, static analysis disabled")
  else()
    message(STATUS "Found clang-tidy: ${CLANG_TIDY_EXE}")
    set(CMAKE_CXX_CLANG_TIDY
      ${CLANG_TIDY_EXE}
      --config-file=${CMAKE_SOURCE_DIR}/.clang-tidy
      --header-filter=^${CMAKE_SOURCE_DIR}/(src|include)/.*
    )
  endif()
endif()
```

### Per-Target Integration

```cmake
# Apply to specific target only
add_executable(myapp src/main.cpp src/app.cpp)
set_target_properties(myapp PROPERTIES
  CXX_CLANG_TIDY "clang-tidy;--config-file=${CMAKE_SOURCE_DIR}/.clang-tidy"
)

# Disable for specific target (e.g., third-party code)
add_library(third_party STATIC vendor/lib.cpp)
set_target_properties(third_party PROPERTIES
  CXX_CLANG_TIDY ""
)
```

### Generate compile_commands.json

```cmake
# Required for clang-tidy to understand build flags
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
```

## CI Integration

### GitHub Actions Workflow

```yaml
name: C++ Static Analysis

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  clang-tidy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install LLVM and clang-tidy
        run: |
          wget https://apt.llvm.org/llvm.sh
          chmod +x llvm.sh
          sudo ./llvm.sh 18
          sudo apt-get install -y clang-tidy-18
          sudo update-alternatives --install /usr/bin/clang-tidy clang-tidy \
            /usr/bin/clang-tidy-18 100

      - name: Configure CMake
        run: |
          cmake -B build \
            -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
            -DCMAKE_CXX_COMPILER=clang++-18

      - name: Run clang-tidy
        run: |
          # Find all source files
          find src include -name '*.cpp' -o -name '*.hpp' | \
            xargs clang-tidy -p build --warnings-as-errors='*'

      - name: Run clang-tidy on changed files only
        if: github.event_name == 'pull_request'
        run: |
          git diff --name-only origin/${{ github.base_ref }} -- '*.cpp' '*.hpp' | \
            xargs -r clang-tidy -p build --warnings-as-errors='*'
```

### Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pocc/pre-commit-hooks
    rev: v1.3.5
    hooks:
      - id: clang-tidy
        args: [-p=build, --warnings-as-errors=*]
        files: \.(cpp|hpp|c|h)$
```

### Manual Pre-commit Script

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Get staged C/C++ files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.(cpp|hpp|c|h)$')

if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

# Ensure compile_commands.json exists
if [ ! -f build/compile_commands.json ]; then
  echo "Error: compile_commands.json not found. Run cmake first."
  exit 1
fi

# Run clang-tidy
echo "Running clang-tidy..."
echo "$STAGED_FILES" | xargs clang-tidy -p build --warnings-as-errors='*'

if [ $? -ne 0 ]; then
  echo "clang-tidy found issues. Fix them before committing."
  exit 1
fi
```

## Suppression Patterns

### NOLINT Comments

```cpp
// Suppress single check on line
void legacy_func(int x) {  // NOLINT(readability-identifier-naming)
  // ...
}

// Suppress multiple checks
ptr = (char*)malloc(size);  // NOLINT(cppcoreguidelines-pro-type-cstyle-cast,cppcoreguidelines-no-malloc)

// Suppress all checks on line
do_unsafe_thing();  // NOLINT

// Suppress for next line
// NOLINTNEXTLINE(bugprone-narrowing-conversions)
int narrow = static_cast<int>(wide_value);

// Block suppression
// NOLINTBEGIN(modernize-use-auto)
Type* ptr1 = create();
Type* ptr2 = create();
Type* ptr3 = create();
// NOLINTEND(modernize-use-auto)
```

### .clang-tidy-ignore File (LLVM 14+)

```gitignore
# Ignore third-party code
vendor/
third_party/
external/

# Ignore generated code
build/
generated/
*_pb.cc
*_pb.h

# Ignore specific files
src/legacy_code.cpp
src/platform_specific_win32.cpp
```

## Common Issues and Fixes

| Warning | Cause | Fix |
|---------|-------|-----|
| `modernize-use-nullptr` | Using `NULL` or `0` for pointers | Replace with `nullptr` |
| `modernize-use-override` | Missing `override` on virtual method | Add `override` keyword |
| `modernize-use-auto` | Explicit type with obvious initializer | Use `auto` for DRY |
| `modernize-use-emplace` | Using `push_back` with construction | Use `emplace_back` instead |
| `performance-unnecessary-value-param` | Large object passed by value | Pass by `const&` or move semantics |
| `performance-for-range-copy` | Loop variable copies in range-for | Use `const auto&` |
| `bugprone-use-after-move` | Accessing object after `std::move` | Restructure code or reset object |
| `cppcoreguidelines-pro-type-cstyle-cast` | C-style cast `(int)x` | Use `static_cast<int>(x)` |
| `cppcoreguidelines-init-variables` | Uninitialized variable | Initialize at declaration |
| `readability-braces-around-statements` | Missing braces on single-line if/for | Add braces `{}` |
| `readability-redundant-smartptr-get` | `ptr.get()` where `*ptr` or `ptr->` works | Remove `.get()` call |
| `clang-analyzer-core.NullDereference` | Potential null pointer dereference | Add null check before use |
| `cert-err33-c` | Ignored return value of error-prone function | Check return value |

### Example Fixes

```cpp
// modernize-use-nullptr
// Before:
void* ptr = NULL;
if (obj == 0) { ... }

// After:
void* ptr = nullptr;
if (obj == nullptr) { ... }

// performance-unnecessary-value-param
// Before:
void process(std::string data);  // Copies string

// After:
void process(const std::string& data);  // Reference
void process(std::string_view data);     // Or string_view for read-only

// modernize-use-emplace
// Before:
vec.push_back(MyClass(arg1, arg2));

// After:
vec.emplace_back(arg1, arg2);

// cppcoreguidelines-init-variables
// Before:
int count;
double* ptr;

// After:
int count = 0;
double* ptr = nullptr;
```

## Run Commands

```bash
# Basic run on single file
clang-tidy src/main.cpp -- -std=c++17

# Run with compile_commands.json
clang-tidy -p build src/main.cpp

# Run on all source files
find src -name '*.cpp' | xargs clang-tidy -p build

# Run with specific checks
clang-tidy -checks='-*,modernize-*,performance-*' src/main.cpp -- -std=c++17

# Apply automatic fixes
clang-tidy -p build --fix src/main.cpp

# Apply fixes with format
clang-tidy -p build --fix --format-style=file src/main.cpp

# Export fixes to YAML (for review before applying)
clang-tidy -p build --export-fixes=fixes.yaml src/main.cpp
clang-apply-replacements --style=file .

# Run in parallel with run-clang-tidy
run-clang-tidy -p build -j$(nproc) 'src/.*\.cpp'
```

## Troubleshooting

### compile_commands.json Not Found

```bash
# Generate with CMake
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -sf build/compile_commands.json .

# Generate with Bear (for non-CMake projects)
bear -- make

# Generate with compiledb (for Makefiles)
pip install compiledb
compiledb make
```

### Header Files Not Checked

Ensure header-filter is set correctly:

```yaml
HeaderFilterRegex: '^.*/src/.*|^.*/include/.*'
```

### Conflicting Checks

Disable conflicting checks in `.clang-tidy`:

```yaml
Checks: >
  cppcoreguidelines-*,
  -cppcoreguidelines-avoid-magic-numbers,
  readability-*,
  -readability-magic-numbers
```

### False Positives in Third-Party Code

Use directory-based exclusion or per-file suppression:

```cpp
// At file top for entire file
// NOLINTBEGIN(*)
#include "problematic_header.h"
// NOLINTEND(*)
```
