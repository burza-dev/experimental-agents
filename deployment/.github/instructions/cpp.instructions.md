---
applyTo: "**/*.cpp,**/*.hpp,**/*.cc,**/*.hh,**/*.cxx,**/*.hxx"
---

# C++ Code Rules

## Overview

Rules for modern C++ development targeting C++23 with safe, maintainable code through RAII,
smart pointers, and strong static analysis.

## Language Standards

- Target C++23 as primary standard
- Support C++20 fallback where C++23 features unavailable
- Support C++17 for legacy codebases (document deviations)
- Use modules where compiler/build system supports them
- Prefer `std::format` over iostreams for output formatting
- Use `std::print` / `std::println` (C++23) when available

## Modern C++ Idioms

### Memory and Resources
- RAII for all resource management - no exceptions
- No raw `new`/`delete` - use smart pointers exclusively
- `std::unique_ptr` as default smart pointer
- `std::shared_ptr` only when ownership is genuinely shared
- `std::weak_ptr` to break cycles in shared ownership

### Modern Language Features
- Range-based algorithms: prefer `std::ranges::` over `std::`
- Structured bindings for multiple return values
- `auto` with care - use when type is obvious or constrained
- `constexpr` for compile-time computation
- `consteval` for guaranteed compile-time evaluation
- `[[nodiscard]]` on functions where return value matters

### Templates and Concepts
```cpp
// Prefer concepts over SFINAE
template<std::integral T>
T add(T a, T b) { return a + b; }

// Named concepts for domain-specific constraints
template<typename T>
concept Serializable = requires(T t, std::ostream& os) {
    { t.serialize(os) } -> std::same_as<void>;
};
```

## Code Style

### Formatting
- Use clang-format with project `.clang-format` file
- 4-space indentation (no tabs)
- Maximum line length: 100 characters
- Opening brace on same line (Allman style acceptable with consistency)

### Naming Conventions
| Element | Style | Example |
|---------|-------|---------|
| Classes/Structs | PascalCase | `UserAccount` |
| Methods | camelCase | `getUserName()` |
| Local variables | snake_case | `user_count` |
| Member variables | snake_case with suffix | `user_count_` |
| Constants | UPPER_SNAKE_CASE | `MAX_CONNECTIONS` |
| Namespaces | snake_case | `network_utils` |
| Template params | PascalCase | `typename ValueType` |
| Concepts | PascalCase | `Serializable` |

### File Organization
- One class per file (with possible nested types)
- Header guards: `#pragma once` (or `#ifndef` for portability)
- Include order: own header, project headers, third-party, standard library
- Forward declare when possible to reduce includes

## Resource Management

### Rule of Zero (Preferred)
```cpp
// Let compiler generate special members
class User {
    std::string name_;
    std::unique_ptr<Profile> profile_;
public:
    // No destructor, copy, or move operations needed
};
```

### Rule of Five (When Required)
```cpp
class Resource {
public:
    Resource();
    ~Resource();
    Resource(const Resource&);
    Resource& operator=(const Resource&);
    Resource(Resource&&) noexcept;
    Resource& operator=(Resource&&) noexcept;
};
```

### RAII Patterns
```cpp
// File handle with RAII
class FileHandle {
    FILE* handle_;
public:
    explicit FileHandle(const char* path) : handle_(fopen(path, "r")) {
        if (!handle_) throw std::runtime_error("Failed to open file");
    }
    ~FileHandle() { if (handle_) fclose(handle_); }

    // Delete copy, implement move
    FileHandle(const FileHandle&) = delete;
    FileHandle& operator=(const FileHandle&) = delete;
    FileHandle(FileHandle&& other) noexcept : handle_(other.handle_) {
        other.handle_ = nullptr;
    }
    FileHandle& operator=(FileHandle&&) noexcept;
};
```

## Error Handling

### Recoverable Errors
```cpp
// Use std::expected for recoverable errors (C++23)
std::expected<User, Error> find_user(int id) {
    if (id <= 0) {
        return std::unexpected(Error::InvalidId);
    }
    // ...
}

// Use std::optional for optional values
std::optional<Config> load_config(const std::filesystem::path& path);
```

### Exceptions
- Use exceptions for truly exceptional conditions
- Never throw from destructors
- Document exceptions with `@throws` in Doxygen
- Catch by const reference: `catch (const std::exception& e)`

### Noexcept
```cpp
// Mark move operations noexcept
Resource(Resource&&) noexcept;
Resource& operator=(Resource&&) noexcept;

// Mark functions that cannot throw
int size() const noexcept { return size_; }
```

## Templates and Concepts

### Concept Usage
```cpp
// Define clear concepts
template<typename T>
concept Hashable = requires(T t) {
    { std::hash<T>{}(t) } -> std::convertible_to<std::size_t>;
};

// Use in template constraints
template<Hashable K, typename V>
class HashMap { /* ... */ };

// Use with auto
void process(Hashable auto const& value);
```

### Template Best Practices
- Document concept requirements in comments
- Provide static_assert messages for failed constraints
- Avoid deep template nesting (max 3 levels)
- Consider template instantiation impact on compile time

## Static Analysis

### Required Tools
- clang-tidy with C++ Core Guidelines checks enabled
- cppcheck for additional static analysis
- Address Sanitizer (ASan) in debug builds
- Undefined Behavior Sanitizer (UBSan) in debug builds

### Compiler Flags
```cmake
# Required warning flags
target_compile_options(${TARGET} PRIVATE
    -Wall
    -Wextra
    -Werror
    -Wpedantic
    -Wconversion
    -Wshadow
    -Wnon-virtual-dtor
    -Wold-style-cast
    -Wcast-align
    -Woverloaded-virtual
)
```

### clang-tidy Configuration
```yaml
# .clang-tidy
Checks: >
    -*,
    bugprone-*,
    cppcoreguidelines-*,
    modernize-*,
    performance-*,
    readability-*,
    -modernize-use-trailing-return-type
WarningsAsErrors: '*'
```

## Testing

### Framework
- GoogleTest (gtest) as primary testing framework
- GMock for mocking dependencies
- Prefer dependency injection for testability

### Test Structure
```cpp
#include <gtest/gtest.h>

class UserServiceTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Setup code
    }

    void TearDown() override {
        // Cleanup code
    }

    UserService service_;
};

TEST_F(UserServiceTest, FindUserReturnsUserWhenExists) {
    auto result = service_.find_user(1);
    ASSERT_TRUE(result.has_value());
    EXPECT_EQ(result->name(), "Alice");
}
```

### Coverage
- Use gcov/llvm-cov for code coverage
- Target minimum 80% line coverage
- 100% coverage for critical paths
- Test all public interfaces

## Build Integration

### CMake Configuration
```cmake
cmake_minimum_required(VERSION 3.28)
project(MyProject LANGUAGES CXX)

# Modern CMake standards
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Target-based configuration (not global)
add_library(mylib)
target_sources(mylib PRIVATE src/mylib.cpp)
target_include_directories(mylib PUBLIC include)
target_compile_features(mylib PUBLIC cxx_std_23)
```

### CMake Best Practices
- Use target-based properties, not global settings
- Use `target_link_libraries` with visibility (PUBLIC/PRIVATE/INTERFACE)
- Generate `compile_commands.json` for tooling
- Use `FetchContent` or `find_package` for dependencies
- Define presets in `CMakePresets.json`

## Documentation

### Doxygen Style
```cpp
/**
 * @brief Finds a user by their unique identifier.
 *
 * Searches the user database for a user with the given ID.
 *
 * @param id The unique user identifier (must be positive).
 * @return The user if found, or an error code.
 * @throws DatabaseError If database connection fails.
 *
 * @note Thread-safe. Uses internal mutex for synchronization.
 * @see User, UserRepository
 */
std::expected<User, Error> find_user(int id);
```

### Documentation Requirements
- All public API must have Doxygen comments
- Document exception specifications with `@throws`
- Document ownership transfer with `@param` annotations
- Document thread safety guarantees with `@note`
- Document preconditions and postconditions

## Forbidden Patterns

### Memory Management
- Raw `new`/`delete` - use smart pointers
- `malloc`/`free`/`realloc` - use containers or smart pointers
- Manual memory management in any form
- Owning raw pointers (non-owning observation is acceptable)

### Type Safety
- C-style casts: `(int)x` - use `static_cast`, `dynamic_cast`, etc.
- `reinterpret_cast` without justification comment
- `const_cast` without justification comment
- Implicit narrowing conversions

### Style
- `using namespace std;` in headers (pollutes namespace)
- `using namespace` at file scope in headers
- `#define` for constants - use `constexpr`
- `#define` for functions - use `constexpr` functions or templates
- Macros without `PROJECT_` prefix

### Architecture
- Mutable global state
- Singletons (except for genuine single-instance resources)
- Circular dependencies between modules
- Deep inheritance hierarchies (prefer composition)

### Unsafe Patterns
- `std::move` on const objects
- Use-after-move without reassignment
- Dangling references or pointers
- Uninitialized variables
