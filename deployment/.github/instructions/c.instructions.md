---
applyTo: "**/*.c,**/*.h"
---

# C code rules

## Overview

Rules for writing safe, maintainable, and portable C code. These guidelines emphasize
memory safety, proper error handling, and modern C standards while maintaining
compatibility with older codebases.

## Standards

- Target C23 standard (`-std=c23` or `-std=c2x`)
- C17/C11 fallbacks acceptable when C23 unavailable
- Use `_Bool` type with `true`/`false` from `<stdbool.h>`
- Modern designated initializers for structs and arrays
- Use `nullptr` (C23) or `NULL` macro for null pointers
- Prefer `static_assert` for compile-time checks

### Version Feature Matrix

| Feature                | C23  | C17  | C11  |
|------------------------|------|------|------|
| `nullptr`              | Yes  | No   | No   |
| `typeof`               | Yes  | Ext  | Ext  |
| `constexpr`            | Yes  | No   | No   |
| `_Static_assert`       | Yes  | Yes  | Yes  |
| `_Generic`             | Yes  | Yes  | Yes  |
| `_Thread_local`        | Yes  | Yes  | Yes  |

## Code style

### Formatting

- clang-format required (LLVM or Google style base)
- 4-space indentation (no tabs)
- Max line length: 100 characters
- Opening braces on same line for functions and control structures
- Single space after keywords (`if`, `for`, `while`, `switch`)

### Naming conventions

| Element         | Convention          | Example                    |
|-----------------|---------------------|----------------------------|
| Functions       | snake_case          | `parse_config_file()`      |
| Variables       | snake_case          | `buffer_size`              |
| Constants       | UPPER_SNAKE_CASE    | `MAX_BUFFER_SIZE`          |
| Macros          | UPPER_SNAKE_CASE    | `ARRAY_SIZE(arr)`          |
| Types (struct)  | snake_case_t        | `config_entry_t`           |
| Types (enum)    | snake_case_e        | `log_level_e`              |
| Enum values     | UPPER_SNAKE_CASE    | `LOG_LEVEL_DEBUG`          |

### Header guards

Prefer `#pragma once` for modern compilers. Use traditional guards for maximum
portability:

```c
#ifndef PROJECT_MODULE_NAME_H
#define PROJECT_MODULE_NAME_H

/* content */

#endif /* PROJECT_MODULE_NAME_H */
```

## Memory safety (CRITICAL)

### Allocation rules

- ALWAYS check `malloc()`, `calloc()`, `realloc()` return values
- Free memory in reverse allocation order
- Set pointers to `NULL` after `free()`
- Use `calloc()` for zero-initialized memory
- Prefer stack allocation for small, fixed-size data

```c
/* Correct allocation pattern */
char *buffer = malloc(size);
if (buffer == NULL) {
    log_error("allocation failed: %zu bytes", size);
    return -ENOMEM;
}

/* Use buffer... */

free(buffer);
buffer = NULL;
```

### Ownership semantics

- Document ownership transfer in function comments
- Use naming conventions: `create_*` (caller owns), `get_*` (borrowed)
- Consider opaque handles for complex resources

```c
/**
 * Creates a new connection object.
 *
 * @param host Server hostname
 * @param port Server port
 * @return New connection (caller must call connection_destroy())
 *         or NULL on failure
 */
connection_t *connection_create(const char *host, uint16_t port);
```

### Sanitizers (debug builds)

- AddressSanitizer (`-fsanitize=address`) for memory errors
- UndefinedBehaviorSanitizer (`-fsanitize=undefined`) for UB detection
- Valgrind for comprehensive leak detection
- MemorySanitizer (`-fsanitize=memory`) for uninitialized reads

## Error handling

### Return code conventions

- Return `0` for success
- Return negative errno-style codes for errors
- Use `errno` for system call errors
- Document ALL error conditions in function comments

```c
/* Error code definitions */
#define ERR_SUCCESS      0
#define ERR_INVALID_ARG -EINVAL
#define ERR_NO_MEMORY   -ENOMEM
#define ERR_IO_FAILURE  -EIO

int process_data(const char *input, size_t len) {
    if (input == NULL || len == 0) {
        return ERR_INVALID_ARG;
    }

    char *buffer = malloc(len);
    if (buffer == NULL) {
        return ERR_NO_MEMORY;
    }

    /* Process... */

    free(buffer);
    return ERR_SUCCESS;
}
```

### Cleanup patterns

Use goto for centralized cleanup on error paths:

```c
int complex_operation(void) {
    int result = ERR_SUCCESS;
    char *buffer1 = NULL;
    char *buffer2 = NULL;

    buffer1 = malloc(SIZE1);
    if (buffer1 == NULL) {
        result = ERR_NO_MEMORY;
        goto cleanup;
    }

    buffer2 = malloc(SIZE2);
    if (buffer2 == NULL) {
        result = ERR_NO_MEMORY;
        goto cleanup;
    }

    /* Work with buffers... */

cleanup:
    free(buffer2);
    free(buffer1);
    return result;
}
```

## Headers

### Organization rules

- Forward declarations where possible to reduce dependencies
- Include ONLY what you need (IWYU principle)
- Headers must be self-contained (include all dependencies)
- System headers in angle brackets: `<stdio.h>`
- Local headers in quotes: `"module.h"`

### Include order

```c
/* 1. Corresponding header (for .c files) */
#include "module.h"

/* 2. C standard library headers */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

/* 3. System/OS headers */
#include <sys/types.h>
#include <unistd.h>

/* 4. Third-party library headers */
#include <openssl/ssl.h>

/* 5. Project headers */
#include "config.h"
#include "utils.h"
```

### Header structure

```c
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

/* Includes */
#include <stddef.h>
#include <stdint.h>

/* Forward declarations */
struct connection;

/* Type definitions */
typedef struct config {
    const char *name;
    int value;
} config_t;

/* Constants */
#define CONFIG_MAX_NAME_LEN 256

/* Function declarations */
int config_load(config_t *cfg, const char *path);
void config_free(config_t *cfg);

#ifdef __cplusplus
}
#endif
```

## Static analysis

### Required tools

- clang-tidy: Primary static analyzer
- cppcheck: Additional checks for common errors
- scan-build: Clang static analyzer for deep analysis
- include-what-you-use: Header dependency analysis

### Configuration

```yaml
# .clang-tidy example
Checks: >
  -*,
  bugprone-*,
  cert-*,
  clang-analyzer-*,
  misc-*,
  modernize-*,
  performance-*,
  portability-*,
  readability-*,
  -readability-magic-numbers
WarningsAsErrors: '*'
```

### Zero warnings policy

- All code must compile with zero warnings
- CI must fail on any warning
- Use `-Werror` to enforce this policy
- Suppress warnings only with documented justification

## Documentation

### Doxygen style

All public API functions require Doxygen documentation:

```c
/**
 * @brief Parses configuration from file.
 *
 * Reads and parses the configuration file at the specified path.
 * The caller is responsible for freeing the returned config with
 * config_free().
 *
 * @param[out] cfg    Pointer to config structure to populate
 * @param[in]  path   Path to configuration file
 *
 * @return 0 on success, negative error code on failure
 * @retval -EINVAL  cfg or path is NULL
 * @retval -ENOENT  File not found
 * @retval -ENOMEM  Memory allocation failed
 *
 * @note Thread-safe: No
 * @see config_free()
 */
int config_load(config_t *cfg, const char *path);
```

### Documentation requirements

- Document ownership semantics for pointers
- Document thread safety for each function
- Document all error conditions
- Document side effects and preconditions
- Use `@warning` for critical usage notes

## Build integration

### CMake configuration

Prefer CMake 3.28+ for modern features:

```cmake
cmake_minimum_required(VERSION 3.28)
project(myproject C)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# Strict warnings
add_compile_options(
    -Wall
    -Wextra
    -Werror
    -pedantic
    -Wconversion
    -Wshadow
    -Wformat=2
    -Wnull-dereference
)

# Sanitizers for debug builds
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_options(-fsanitize=address,undefined)
    add_link_options(-fsanitize=address,undefined)
endif()
```

### Compiler flags (GCC/Clang)

| Flag                   | Purpose                              |
|------------------------|--------------------------------------|
| `-Wall`                | Enable common warnings               |
| `-Wextra`              | Enable extra warnings                |
| `-Werror`              | Treat warnings as errors             |
| `-pedantic`            | Strict ISO C compliance              |
| `-Wconversion`         | Implicit conversion warnings         |
| `-Wshadow`             | Variable shadowing warnings          |
| `-Wformat=2`           | Format string security checks        |
| `-fstack-protector-strong` | Stack buffer overflow protection |
| `-D_FORTIFY_SOURCE=2`  | Runtime buffer overflow detection    |

## Testing

### Framework options

- CMocka: Lightweight, mock support
- Unity: Minimal, embedded-friendly
- Check: Fork-based isolation

### Test structure

```c
#include <stdarg.h>
#include <stddef.h>
#include <setjmp.h>
#include <cmocka.h>

#include "module.h"

static void test_function_returns_success(void **state) {
    (void)state;

    int result = target_function(valid_input);

    assert_int_equal(result, 0);
}

static void test_function_handles_null_input(void **state) {
    (void)state;

    int result = target_function(NULL);

    assert_int_equal(result, -EINVAL);
}

int main(void) {
    const struct CMUnitTest tests[] = {
        cmocka_unit_test(test_function_returns_success),
        cmocka_unit_test(test_function_handles_null_input),
    };

    return cmocka_run_group_tests(tests, NULL, NULL);
}
```

### Testing requirements

- Test all error paths
- Test boundary conditions
- Mock external dependencies
- Achieve minimum 80% code coverage
- Run tests under sanitizers in CI

## Forbidden patterns

### Never use

| Forbidden            | Use instead                  | Reason                     |
|----------------------|------------------------------|----------------------------|
| `gets()`             | `fgets()`                    | Buffer overflow            |
| `sprintf()`          | `snprintf()`                 | Buffer overflow            |
| `strcpy()`           | `strncpy()` or `strlcpy()`   | Buffer overflow            |
| `strcat()`           | `strncat()` or `strlcat()`   | Buffer overflow            |
| `atoi()`             | `strtol()` with error check  | No error handling          |
| `scanf("%s")`        | `scanf("%Ns")` with limit    | Buffer overflow            |

### Avoid

- Uninitialized variables (always initialize)
- Implicit function declarations (include headers)
- VLAs (Variable Length Arrays) in production code
- `alloca()` for large or user-controlled sizes
- Casting away `const` without justification
- Magic numbers (use named constants)

### Required patterns

```c
/* Always initialize variables */
int count = 0;
char *ptr = NULL;
struct config cfg = {0};

/* Always check array bounds */
if (index >= ARRAY_SIZE(arr)) {
    return -EINVAL;
}

/* Use sizeof on variable, not type */
char buffer[256];
memset(buffer, 0, sizeof(buffer));  /* Correct */
/* NOT: memset(buffer, 0, 256);     -- Magic number */

/* Null-terminate after string operations */
buffer[sizeof(buffer) - 1] = '\0';
```

## Security considerations

### Input validation

- Validate ALL external input
- Check buffer lengths before operations
- Sanitize strings before use in system calls
- Use allowlists over denylists

### Integer safety

- Check for overflow before arithmetic
- Use `size_t` for sizes and counts
- Be careful with signed/unsigned conversions
- Consider using safe integer libraries

```c
/* Check for addition overflow */
if (a > SIZE_MAX - b) {
    return -EOVERFLOW;
}
size_t sum = a + b;
```
