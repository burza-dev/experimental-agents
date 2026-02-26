---
applyTo: "**/Makefile,**/makefile,**/*.mk"
---

# Makefile Build Rules

## Overview

Instructions for writing portable, maintainable Makefiles following GNU Make conventions.
Focus on automatic dependency tracking, proper target declarations, and build reproducibility.

## Standards

### GNU Make 4.x Features
- Use `$(file ...)` for file operations
- Use `$(info ...)`, `$(warning ...)`, `$(error ...)` for diagnostics
- Use `.ONESHELL` when multi-line shell commands benefit from single shell
- Use grouped targets with `&:` for rules that produce multiple outputs

### POSIX Compatibility
- Avoid bash-isms in recipes for portability (use `/bin/sh` compatible syntax)
- Use `$(SHELL)` variable instead of hardcoding shell paths
- Prefer `printf` over `echo -e` for portable output
- Use `test` or `[ ]` instead of `[[ ]]` in recipes

```make
# Portable shell commands
SHELL := /bin/sh

# Good: POSIX compatible
install:
	test -d $(DESTDIR)$(PREFIX)/bin || mkdir -p $(DESTDIR)$(PREFIX)/bin

# Bad: bash-ism
install:
	[[ -d $(DESTDIR)$(PREFIX)/bin ]] || mkdir -p $(DESTDIR)$(PREFIX)/bin
```

## Structure

### File Organization
1. Variables at top
2. PHONY declarations
3. Default target (`all`)
4. Build rules
5. Utility targets (clean, install, help)

```make
# 1. Variables
CC := gcc
CFLAGS := -Wall -Wextra

# 2. PHONY declarations
.PHONY: all clean test install help

# 3. Default target
all: $(TARGET)

# 4. Build rules
$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^

# 5. Utility targets
clean:
	$(RM) $(OBJS) $(TARGET)

help:
	@echo "Usage: make [target]"
```

### PHONY Targets
Declare all non-file targets as PHONY to avoid conflicts with files:

```make
.PHONY: all clean test install uninstall distclean help coverage lint
```

## Variables

### Assignment Types
```make
# User-overridable (use defaults if not set)
CC ?= gcc
PREFIX ?= /usr/local
DEBUG ?= 0

# Immediate evaluation (evaluated once when defined)
BUILD_DIR := build
SOURCES := $(wildcard src/*.c)
OBJECTS := $(SOURCES:src/%.c=$(BUILD_DIR)/%.o)

# Recursive evaluation (evaluated each time used)
CFLAGS = $(BASE_FLAGS) $(EXTRA_FLAGS)
```

### Standard Variable Names
```make
# Compilers
CC := gcc
CXX := g++
AR := ar
LD := $(CC)

# Flags
CFLAGS := -Wall -Wextra -Werror -pedantic -std=c23
CXXFLAGS := -Wall -Wextra -Werror -pedantic -std=c++23
CPPFLAGS := -Iinclude
LDFLAGS := -Llib
LDLIBS := -lm

# Directories
PREFIX ?= /usr/local
DESTDIR ?=
BUILD_DIR := build
SRC_DIR := src
INC_DIR := include
```

### Variable Grouping
```make
# Project configuration
PROJECT := myapp
VERSION := 1.0.0
TARGET := $(BUILD_DIR)/$(PROJECT)

# Source files
SOURCES := $(wildcard $(SRC_DIR)/*.c)
HEADERS := $(wildcard $(INC_DIR)/*.h)
OBJECTS := $(SOURCES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
DEPS := $(OBJECTS:.o=.d)

# Build flags
BASE_FLAGS := -Wall -Wextra -Werror -pedantic
DEBUG_FLAGS := -g -O0 -fsanitize=address,undefined
RELEASE_FLAGS := -O3 -DNDEBUG -flto
```

## Pattern Rules

### Basic Pattern Rules
```make
# Compile C sources
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# Compile C++ sources
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

# Generate assembly
$(BUILD_DIR)/%.s: $(SRC_DIR)/%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -S $< -o $@
```

### Automatic Variables
```make
# $@  - Target filename
# $<  - First prerequisite
# $^  - All prerequisites (deduplicated)
# $+  - All prerequisites (with duplicates)
# $*  - Stem (matched by %)
# $(@D) - Directory part of $@
# $(@F) - Filename part of $@

$(TARGET): $(OBJECTS)
	@echo "Linking $@"
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)
```

## Dependencies

### Automatic Dependency Generation
```make
# Generate dependencies during compilation
CPPFLAGS += -MMD -MP

# Source files
SOURCES := $(wildcard $(SRC_DIR)/*.c)
OBJECTS := $(SOURCES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
DEPS := $(OBJECTS:.o=.d)

# Include dependencies (silent if missing)
-include $(DEPS)

# Pattern rule generates both .o and .d
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@
```

### Explanation of Flags
- `-MMD` - Generate dependency file, excluding system headers
- `-MP` - Add phony targets for each dependency (prevents errors if header deleted)

## Standard Targets

```make
.PHONY: all clean test install uninstall distclean help

# Default: build everything
all: $(TARGET)

# Build the target
$(TARGET): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

# Remove build artifacts
clean:
	$(RM) -r $(BUILD_DIR)

# Remove all generated files including config
distclean: clean
	$(RM) config.mk tags TAGS

# Run tests
test: $(TARGET)
	$(BUILD_DIR)/test_runner

# Install to system
install: $(TARGET)
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 $(TARGET) $(DESTDIR)$(PREFIX)/bin/

# Remove from system
uninstall:
	$(RM) $(DESTDIR)$(PREFIX)/bin/$(PROJECT)

# Display available targets
help:
	@echo "Available targets:"
	@echo "  all        - Build $(PROJECT) (default)"
	@echo "  clean      - Remove build artifacts"
	@echo "  distclean  - Remove all generated files"
	@echo "  test       - Run test suite"
	@echo "  install    - Install to $(PREFIX)"
	@echo "  uninstall  - Remove from $(PREFIX)"
	@echo "  help       - Show this help"
```

## Build Directories

### Order-Only Prerequisites
Use `|` to create directories without triggering rebuilds:

```make
BUILD_DIR := build
OBJ_DIR := $(BUILD_DIR)/obj
BIN_DIR := $(BUILD_DIR)/bin

# Create directories as order-only prerequisites
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJECTS) | $(BIN_DIR)
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

# Directory creation rules
$(BUILD_DIR) $(OBJ_DIR) $(BIN_DIR):
	mkdir -p $@
```

### Out-of-Source Builds
```make
# Keep build artifacts separate from source
BUILD_DIR := build

# All outputs go to BUILD_DIR
OBJECTS := $(SOURCES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
TARGET := $(BUILD_DIR)/$(PROJECT)

# Clean only removes build directory
clean:
	$(RM) -r $(BUILD_DIR)
```

## Compiler Flags

### Build Configurations
```make
# Base flags (always applied)
CFLAGS := -Wall -Wextra -Werror -pedantic -std=c23

# Debug configuration
DEBUG_FLAGS := -g -O0 -fsanitize=address,undefined
DEBUG_LDFLAGS := -fsanitize=address,undefined

# Release configuration
RELEASE_FLAGS := -O3 -DNDEBUG -flto
RELEASE_LDFLAGS := -flto

# Select configuration
ifeq ($(DEBUG),1)
    CFLAGS += $(DEBUG_FLAGS)
    LDFLAGS += $(DEBUG_LDFLAGS)
else
    CFLAGS += $(RELEASE_FLAGS)
    LDFLAGS += $(RELEASE_LDFLAGS)
endif
```

### Usage
```sh
# Debug build
make DEBUG=1

# Release build (default)
make
```

## Testing Integration

```make
.PHONY: test coverage sanitize

# Test directory
TEST_DIR := tests
TEST_SOURCES := $(wildcard $(TEST_DIR)/*.c)
TEST_OBJECTS := $(TEST_SOURCES:$(TEST_DIR)/%.c=$(BUILD_DIR)/test/%.o)
TEST_TARGET := $(BUILD_DIR)/test_runner

# Build and run tests
test: $(TEST_TARGET)
	./$(TEST_TARGET)

$(TEST_TARGET): $(TEST_OBJECTS) $(filter-out $(BUILD_DIR)/main.o,$(OBJECTS))
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

# Coverage report
coverage: CFLAGS += --coverage
coverage: LDFLAGS += --coverage
coverage: clean test
	gcov -o $(BUILD_DIR) $(SOURCES)
	lcov --capture --directory $(BUILD_DIR) --output-file coverage.info
	genhtml coverage.info --output-directory $(BUILD_DIR)/coverage

# Sanitizer builds
sanitize-address: CFLAGS += -fsanitize=address
sanitize-address: LDFLAGS += -fsanitize=address
sanitize-address: clean test

sanitize-undefined: CFLAGS += -fsanitize=undefined
sanitize-undefined: LDFLAGS += -fsanitize=undefined
sanitize-undefined: clean test

sanitize-thread: CFLAGS += -fsanitize=thread
sanitize-thread: LDFLAGS += -fsanitize=thread
sanitize-thread: clean test
```

## Verbose Mode

Use the `V=1` pattern for optional verbose output:

```make
# Verbose control
ifeq ($(V),1)
    Q :=
    ECHO := @true
else
    Q := @
    ECHO := @echo
endif

# Use in rules
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJECTS)
	$(ECHO) "LD $@"
	$(Q)$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)
```

### Usage
```sh
# Quiet build (default)
make

# Verbose build
make V=1
```

## Complete Example

```make
# Project configuration
PROJECT := myapp
VERSION := 1.0.0

# Directories
SRC_DIR := src
INC_DIR := include
BUILD_DIR := build
PREFIX ?= /usr/local

# Compiler settings
CC ?= gcc
CFLAGS := -Wall -Wextra -Werror -pedantic -std=c23
CPPFLAGS := -I$(INC_DIR) -MMD -MP
LDLIBS := -lm

# Debug/Release
DEBUG_FLAGS := -g -O0 -fsanitize=address,undefined
RELEASE_FLAGS := -O3 -DNDEBUG
ifeq ($(DEBUG),1)
    CFLAGS += $(DEBUG_FLAGS)
    LDFLAGS += -fsanitize=address,undefined
else
    CFLAGS += $(RELEASE_FLAGS)
endif

# Verbose control
ifeq ($(V),1)
    Q :=
else
    Q := @
endif

# Sources and objects
SOURCES := $(wildcard $(SRC_DIR)/*.c)
OBJECTS := $(SOURCES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
DEPS := $(OBJECTS:.o=.d)
TARGET := $(BUILD_DIR)/$(PROJECT)

# Targets
.PHONY: all clean test install uninstall help

all: $(TARGET)

$(TARGET): $(OBJECTS) | $(BUILD_DIR)
	@echo "LD $@"
	$(Q)$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	@echo "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD_DIR):
	$(Q)mkdir -p $@

clean:
	$(Q)$(RM) -r $(BUILD_DIR)

test: $(TARGET)
	$(Q)./$(TARGET) --test

install: $(TARGET)
	$(Q)install -d $(DESTDIR)$(PREFIX)/bin
	$(Q)install -m 755 $(TARGET) $(DESTDIR)$(PREFIX)/bin/

uninstall:
	$(Q)$(RM) $(DESTDIR)$(PREFIX)/bin/$(PROJECT)

help:
	@echo "$(PROJECT) v$(VERSION)"
	@echo "Targets: all clean test install uninstall help"
	@echo "Options: DEBUG=1 V=1 PREFIX=$(PREFIX)"

-include $(DEPS)
```

## Forbidden Patterns

### Syntax Errors
```make
# Bad: Spaces instead of tabs (Make REQUIRES tabs for recipes)
target:
    echo "This will fail"  # Uses spaces

# Good: Tab character for indentation
target:
	echo "This works"  # Uses tab
```

### Missing Declarations
```make
# Bad: Missing PHONY for non-file targets
clean:
	rm -rf build/

# Good: Declare PHONY targets
.PHONY: clean
clean:
	rm -rf build/
```

### Hardcoded Paths
```make
# Bad: Hardcoded absolute paths
CC := /usr/bin/gcc
INSTALL_DIR := /usr/local/bin

# Good: Use variables and allow overrides
CC ?= gcc
PREFIX ?= /usr/local
INSTALL_DIR := $(DESTDIR)$(PREFIX)/bin
```

### Silent Failures
```make
# Bad: Silent rules hide problems
target:
	@$(CC) -o $@ $<

# Good: Use V=1 pattern for optional verbosity
target:
	$(ECHO) "CC $<"
	$(Q)$(CC) -o $@ $<
```

### Missing Dependencies
```make
# Bad: No automatic dependency tracking
%.o: %.c
	$(CC) -c $< -o $@

# Good: Generate and include dependencies
CPPFLAGS += -MMD -MP
-include $(DEPS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@
```

### Other Forbidden Patterns
- Using recursive make without explicit variable passing
- Missing clean target
- Not using automatic variables (`$@`, `$<`, `$^`)
- Duplicating file lists instead of using wildcards/substitution
- Not creating build directories before writing to them
- Using shell commands where Make functions suffice
