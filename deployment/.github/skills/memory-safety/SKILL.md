---
name: memory-safety
description: Memory safety tools and patterns for C/C++. Apply when debugging memory issues, configuring sanitizers, or setting up memory validation in CI.
technologies: [sanitizers, valgrind, cpp, c]
---

# Memory Safety

## When to Apply

- Debugging segmentation faults or crashes
- Investigating memory leaks or corruption
- Setting up CI pipelines for C/C++ projects
- Reviewing code that handles dynamic memory
- Performance profiling with memory validation

## AddressSanitizer (ASan)

ASan detects memory errors at runtime with ~2x slowdown.

### What It Detects

- Buffer overflows (stack, heap, global)
- Use-after-free
- Double-free
- Use-after-return (with flags)
- Memory leaks (with LeakSanitizer)

### Compiler Flags

```bash
# GCC/Clang
-fsanitize=address -fno-omit-frame-pointer -g

# For better stack traces
-fno-optimize-sibling-calls
```

### Runtime Options

```bash
# Common ASAN_OPTIONS
export ASAN_OPTIONS="detect_leaks=1:abort_on_error=1:halt_on_error=1"

# Detailed options
export ASAN_OPTIONS="detect_leaks=1:\
detect_stack_use_after_return=1:\
check_initialization_order=1:\
strict_init_order=1:\
print_stats=1:\
verbosity=1"
```

### Example Detection

```cpp
// ASan catches this buffer overflow
int main() {
    int array[10];
    return array[10];  // ERROR: stack-buffer-overflow
}
```

## UndefinedBehaviorSanitizer (UBSan)

UBSan catches undefined behavior with minimal overhead.

### What It Detects

- Signed integer overflow
- Null pointer dereference
- Array bounds violations
- Misaligned memory access
- Invalid enum values
- Divide by zero
- Unreachable code execution

### Compiler Flags

```bash
# Basic UBSan
-fsanitize=undefined

# Specific checks
-fsanitize=integer,bounds,null,alignment,vptr

# Useful combinations
-fsanitize=undefined,integer -fno-sanitize-recover=all
```

### Recommended Checks

```bash
# All integer checks
-fsanitize=signed-integer-overflow,unsigned-integer-overflow,shift,integer-divide-by-zero

# Bounds checking
-fsanitize=bounds,bounds-strict

# Pointer checks
-fsanitize=null,nonnull-attribute,returns-nonnull-attribute
```

### Example Detection

```cpp
// UBSan catches signed overflow
int main() {
    int x = INT_MAX;
    return x + 1;  // ERROR: signed-integer-overflow
}
```

## MemorySanitizer (MSan)

MSan detects reads of uninitialized memory. Clang-only.

### What It Detects

- Uninitialized memory reads
- Uninitialized memory used in conditionals

### Requirements

MSan requires an instrumented standard library:

```bash
# Build libc++ with MSan
cmake -GNinja ../llvm \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DLLVM_USE_SANITIZER=MemoryWithOrigins \
  -DLLVM_ENABLE_PROJECTS="libcxx;libcxxabi"
```

### Compiler Flags

```bash
# Basic MSan
-fsanitize=memory -fno-omit-frame-pointer -g

# Track origins (slower but more informative)
-fsanitize=memory -fsanitize-memory-track-origins=2
```

### When to Use

- Final verification before release
- Debugging mysterious crashes
- Dedicated CI job (due to instrumented stdlib requirement)

### Example Detection

```cpp
// MSan catches uninitialized read
int main() {
    int x;
    return x;  // ERROR: use-of-uninitialized-value
}
```

## ThreadSanitizer (TSan)

TSan detects data races and threading issues with ~5-15x slowdown.

### What It Detects

- Data races
- Lock order inversions (potential deadlocks)
- Thread leaks

### Compiler Flags

```bash
# TSan (mutually exclusive with ASan)
-fsanitize=thread -g
```

### Runtime Options

```bash
export TSAN_OPTIONS="halt_on_error=1:second_deadlock_stack=1"
```

### Important Limitations

- **Mutually exclusive with ASan** - cannot use both simultaneously
- Requires all code (including libraries) to be instrumented
- Higher memory overhead (~5-10x)

### Example Detection

```cpp
// TSan catches this data race
#include <thread>
int counter = 0;

void increment() { counter++; }

int main() {
    std::thread t1(increment);
    std::thread t2(increment);
    t1.join();
    t2.join();
    return counter;  // WARNING: data race
}
```

## Valgrind

Valgrind provides memory debugging without recompilation (~20-50x slowdown).

### Memcheck Basics

```bash
# Basic usage
valgrind --leak-check=full ./program

# Detailed checking
valgrind --leak-check=full \
         --show-leak-kinds=all \
         --track-origins=yes \
         --verbose \
         ./program

# Generate XML for CI
valgrind --xml=yes --xml-file=valgrind.xml ./program
```

### Common Error Types

| Error | Meaning |
|-------|---------|
| Invalid read/write | Buffer overflow or use-after-free |
| Conditional jump depends on uninitialised | Uninitialized memory in condition |
| Invalid free() | Double-free or freeing non-heap memory |
| Definitely lost | Memory leak - no pointers remain |
| Indirectly lost | Memory reachable only through leaked memory |
| Possibly lost | Ambiguous - interior pointer exists |
| Still reachable | Memory not freed but pointers exist at exit |

### Suppression Files

Create suppressions for known issues or third-party code:

```
# valgrind.supp
{
   ignore_third_party_lib
   Memcheck:Leak
   match-leak-kinds: reachable
   fun:malloc
   ...
   obj:*/libthirdparty.so*
}
```

```bash
# Use suppressions
valgrind --suppressions=valgrind.supp ./program
```

### Generate Suppressions

```bash
# Generate suppression entries for encountered errors
valgrind --gen-suppressions=all ./program 2>&1 | grep -A20 "^{"
```

## CMake Configuration

### Complete Sanitizer Setup

```cmake
# cmake/Sanitizers.cmake

option(ENABLE_ASAN "Enable AddressSanitizer" OFF)
option(ENABLE_UBSAN "Enable UndefinedBehaviorSanitizer" OFF)
option(ENABLE_MSAN "Enable MemorySanitizer" OFF)
option(ENABLE_TSAN "Enable ThreadSanitizer" OFF)

function(enable_sanitizers target)
    if(MSVC)
        message(WARNING "Sanitizers have limited MSVC support")
        return()
    endif()

    set(SANITIZER_FLAGS "")

    if(ENABLE_ASAN)
        if(ENABLE_TSAN OR ENABLE_MSAN)
            message(FATAL_ERROR "ASan cannot be combined with TSan or MSan")
        endif()
        list(APPEND SANITIZER_FLAGS "-fsanitize=address")
        list(APPEND SANITIZER_FLAGS "-fno-omit-frame-pointer")
    endif()

    if(ENABLE_UBSAN)
        list(APPEND SANITIZER_FLAGS "-fsanitize=undefined")
        list(APPEND SANITIZER_FLAGS "-fno-sanitize-recover=all")
    endif()

    if(ENABLE_MSAN)
        if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
            message(FATAL_ERROR "MSan requires Clang")
        endif()
        if(ENABLE_ASAN OR ENABLE_TSAN)
            message(FATAL_ERROR "MSan cannot be combined with ASan or TSan")
        endif()
        list(APPEND SANITIZER_FLAGS "-fsanitize=memory")
        list(APPEND SANITIZER_FLAGS "-fsanitize-memory-track-origins=2")
        list(APPEND SANITIZER_FLAGS "-fno-omit-frame-pointer")
    endif()

    if(ENABLE_TSAN)
        if(ENABLE_ASAN OR ENABLE_MSAN)
            message(FATAL_ERROR "TSan cannot be combined with ASan or MSan")
        endif()
        list(APPEND SANITIZER_FLAGS "-fsanitize=thread")
    endif()

    if(SANITIZER_FLAGS)
        target_compile_options(${target} PRIVATE ${SANITIZER_FLAGS})
        target_link_options(${target} PRIVATE ${SANITIZER_FLAGS})
    endif()
endfunction()
```

### Usage in CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.16)
project(myproject)

include(cmake/Sanitizers.cmake)

add_executable(myapp main.cpp)
enable_sanitizers(myapp)
```

### Build Commands

```bash
# ASan build
cmake -B build-asan -DENABLE_ASAN=ON -DCMAKE_BUILD_TYPE=Debug
cmake --build build-asan

# UBSan build
cmake -B build-ubsan -DENABLE_UBSAN=ON -DCMAKE_BUILD_TYPE=Debug
cmake --build build-ubsan

# Combined ASan + UBSan
cmake -B build-sanitizers -DENABLE_ASAN=ON -DENABLE_UBSAN=ON \
      -DCMAKE_BUILD_TYPE=Debug
cmake --build build-sanitizers
```

## CTest Integration with Valgrind

### CMake Configuration

```cmake
# CMakeLists.txt
enable_testing()

find_program(VALGRIND_EXECUTABLE valgrind)

if(VALGRIND_EXECUTABLE)
    set(MEMORYCHECK_COMMAND ${VALGRIND_EXECUTABLE})
    set(MEMORYCHECK_COMMAND_OPTIONS
        "--leak-check=full --show-leak-kinds=all --error-exitcode=1")
    set(MEMORYCHECK_SUPPRESSIONS_FILE
        "${CMAKE_SOURCE_DIR}/valgrind.supp")
endif()

include(CTest)

add_test(NAME unit_tests COMMAND myapp_tests)
```

### Running Memory Tests

```bash
# Run all tests with Valgrind
ctest -T memcheck

# Run specific test with Valgrind
ctest -T memcheck -R test_name

# View results
cat Testing/Temporary/MemoryChecker.*.log
```

## CI Integration

### GitHub Actions Example

```yaml
name: Memory Safety

on: [push, pull_request]

jobs:
  sanitizers:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        sanitizer: [asan, ubsan, tsan]
        include:
          - sanitizer: asan
            cmake_flags: -DENABLE_ASAN=ON
            env_vars: ASAN_OPTIONS=abort_on_error=1:halt_on_error=1
          - sanitizer: ubsan
            cmake_flags: -DENABLE_UBSAN=ON
            env_vars: UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1
          - sanitizer: tsan
            cmake_flags: -DENABLE_TSAN=ON
            env_vars: TSAN_OPTIONS=halt_on_error=1

    steps:
      - uses: actions/checkout@v4

      - name: Configure
        run: cmake -B build ${{ matrix.cmake_flags }} -DCMAKE_BUILD_TYPE=Debug

      - name: Build
        run: cmake --build build

      - name: Test
        env:
          ${{ matrix.env_vars }}
        run: ctest --test-dir build --output-on-failure

  valgrind:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Valgrind
        run: sudo apt-get install -y valgrind

      - name: Configure
        run: cmake -B build -DCMAKE_BUILD_TYPE=Debug

      - name: Build
        run: cmake --build build

      - name: Memory Check
        run: |
          cd build
          ctest -T memcheck
          if grep -q "definitely lost" Testing/Temporary/MemoryChecker.*.log; then
            echo "Memory leaks detected!"
            cat Testing/Temporary/MemoryChecker.*.log
            exit 1
          fi
```

### Failure Handling

```yaml
# Continue on sanitizer failures but mark as failed
- name: Test with Sanitizers
  continue-on-error: true
  id: sanitizer-test
  run: ctest --test-dir build --output-on-failure

- name: Upload Sanitizer Logs
  if: failure() || steps.sanitizer-test.outcome == 'failure'
  uses: actions/upload-artifact@v4
  with:
    name: sanitizer-logs-${{ matrix.sanitizer }}
    path: build/Testing/Temporary/*.log
```

## Common Memory Bugs

| Bug Type | Detection Tool | Prevention |
|----------|----------------|------------|
| Buffer overflow | ASan, Valgrind | Bounds checking, `std::span`, `std::array` |
| Use-after-free | ASan, Valgrind | Smart pointers, RAII |
| Double-free | ASan, Valgrind | Smart pointers, null after free |
| Memory leak | ASan (LSan), Valgrind | RAII, smart pointers |
| Uninitialized read | MSan, Valgrind | Default initialization, constructors |
| Data race | TSan | Mutexes, atomics, thread-safe containers |
| Integer overflow | UBSan | Safe integer libraries, range checks |
| Null dereference | UBSan | `std::optional`, null checks |
| Stack overflow | ASan | Reduce recursion, heap allocation |
| Misaligned access | UBSan | `alignas`, packed struct awareness |

## Best Practices

### Development Workflow

1. **Local development**: Run tests with ASan + UBSan
2. **Pre-commit**: Quick sanitizer check on changed code
3. **CI pipeline**: Full sanitizer matrix + Valgrind
4. **Release builds**: Verify with MSan for uninitialized memory

### Performance Tips

- Use sanitizers only in Debug builds
- Disable leak checking for performance tests: `ASAN_OPTIONS=detect_leaks=0`
- Run TSan in a separate job (mutually exclusive with ASan)
- Use Valgrind selectively on critical tests only

### Suppressing False Positives

```cpp
// Suppress specific ASan issue
#if defined(__has_feature)
    #if __has_feature(address_sanitizer)
        __attribute__((no_sanitize("address")))
    #endif
#endif
void function_with_known_issue() {
    // ...
}
```

```cpp
// Suppress UBSan for specific function
__attribute__((no_sanitize("undefined")))
void intentional_overflow() {
    // Intentional wrapping arithmetic
}
```
