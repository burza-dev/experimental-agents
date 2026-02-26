---
skill: cpp-core-guidelines
description: C++ Core Guidelines enforcement and patterns for safe, efficient,
  and maintainable C++ code
technologies: [cpp, clang-tidy]
---

# C++ Core Guidelines

## When to Apply

- Writing new C++ code (C++17 or later recommended)
- Reviewing existing C++ codebases
- Configuring static analysis tools
- Teaching modern C++ best practices
- Refactoring legacy C++ code

## Philosophy (P)

### P.1: Express ideas directly in code

```cpp
// Avoid: unclear intent
int x = arr[7];

// Prefer: express intent clearly
auto current_month = months[MonthIndex::August];
```

### P.2: Write for humans first, computers second

```cpp
// Avoid: clever but obscure
int c = (a > b) ? (a -= b, a) : (b -= a, b);

// Prefer: clear and readable
int gcd = std::gcd(a, b);
```

### P.3: Express intent

```cpp
// Avoid: unclear loop purpose
for (size_t i = 0; i < v.size(); ++i) {
    if (v[i] == target) return i;
}

// Prefer: express the search intent
auto it = std::ranges::find(v, target);
```

### P.4: Catch errors at compile time

```cpp
// Use static_assert for compile-time checks
static_assert(sizeof(int) >= 4, "int must be at least 32 bits");

// Use concepts to constrain templates
template<std::integral T>
T safe_divide(T a, T b) {
    return a / b;
}
```

## Interfaces (I)

### I.1: Make interfaces explicit

```cpp
// Avoid: implicit dependencies on global state
int compute(); // What does it depend on?

// Prefer: explicit dependencies
int compute(const Config& config, const Data& data);
```

### I.2: Avoid non-const global variables

```cpp
// Avoid
int global_counter = 0;

// Prefer: encapsulate state
class Counter {
public:
    int increment() { return ++value_; }
    int get() const { return value_; }
private:
    int value_ = 0;
};
```

### I.3: Express preconditions

```cpp
#include <gsl/gsl>

void process(gsl::not_null<Widget*> widget, int count) {
    Expects(count > 0);  // GSL precondition
    // ...
}
```

### I.4: Express postconditions

```cpp
gsl::not_null<Resource*> allocate(size_t size) {
    auto* p = allocate_internal(size);
    Ensures(p != nullptr);  // GSL postcondition
    return p;
}
```

## Functions (F)

### F.1: Prefer pure functions

```cpp
// Pure function: same input always produces same output
constexpr double square(double x) { return x * x; }

// Impure: depends on/modifies external state
double scale_by_factor(double x) {
    return x * global_factor;  // Avoid
}
```

### F.2: Parameter passing rules

| Type | In | In/Out | Out | Forward |
|------|-----|--------|-----|---------|
| Cheap to copy (≤ 2×ptr) | `X` | `X&` | `X&` | `X&&` / `T&&` |
| Expensive to copy | `const X&` | `X&` | `X&` | `X&&` / `T&&` |
| Move-only types | `X&&` | `X&` | `X&` | `X&&` |
| Optional input | `const X*` | `X*` | `X*` | - |
| Smart pointers | See below | - | - | - |

### F.3: Smart pointer passing

```cpp
// Transfer ownership: unique_ptr by value
void sink(std::unique_ptr<Widget> widget);

// Share ownership: shared_ptr by value
void share(std::shared_ptr<Widget> widget);

// Use but don't own: raw pointer or reference
void use(Widget& widget);
void use(Widget* widget);  // nullable
```

### F.4: Return values

```cpp
// Prefer returning by value (RVO applies)
std::vector<int> make_vector();

// Return optional for "may not have value"
std::optional<int> find_first_even(std::span<const int> numbers);

// Return expected for operations that may fail
std::expected<Result, Error> parse(std::string_view input);
```

## Classes (C)

### C.1: Rule of Zero

```cpp
// Preferred: rely on compiler-generated special members
class Widget {
public:
    void do_work();
private:
    std::string name_;
    std::vector<int> data_;
};
```

### C.2: Rule of Five

```cpp
// When managing resources directly, define all five
class ResourceHandle {
public:
    ResourceHandle();
    ~ResourceHandle();
    ResourceHandle(const ResourceHandle& other);
    ResourceHandle& operator=(const ResourceHandle& other);
    ResourceHandle(ResourceHandle&& other) noexcept;
    ResourceHandle& operator=(ResourceHandle&& other) noexcept;

private:
    void* handle_ = nullptr;
};
```

### C.3: Single responsibility

```cpp
// Avoid: mixed responsibilities
class UserManager {
    void authenticate();
    void save_to_database();
    void send_email();
    void generate_report();
};

// Prefer: focused classes
class Authenticator { /* ... */ };
class UserRepository { /* ... */ };
class EmailService { /* ... */ };
class ReportGenerator { /* ... */ };
```

### C.4: Prefer composition over inheritance

```cpp
// Avoid: deep inheritance hierarchies
class Vehicle { /* ... */ };
class Car : public Vehicle { /* ... */ };
class ElectricCar : public Car { /* ... */ };

// Prefer: composition
class Car {
private:
    Engine engine_;
    Transmission transmission_;
    Battery battery_;  // For electric cars
};
```

### C.5: Use struct for passive data

```cpp
// Data only: use struct
struct Point {
    double x;
    double y;
};

// Invariants to maintain: use class
class Circle {
public:
    Circle(Point center, double radius);
    double area() const;
private:
    Point center_;
    double radius_;  // invariant: radius_ > 0
};
```

## Resource Management (R)

### R.1: RAII everywhere

```cpp
// Avoid: manual resource management
void bad_example() {
    auto* file = fopen("data.txt", "r");
    process(file);
    fclose(file);  // May leak if process() throws
}

// Prefer: RAII wrapper
void good_example() {
    std::ifstream file("data.txt");
    process(file);
}  // Automatically closed
```

### R.2: Smart pointer usage

```cpp
// Unique ownership (default choice)
auto widget = std::make_unique<Widget>();

// Shared ownership (use sparingly)
auto shared_widget = std::make_shared<Widget>();

// Weak reference to shared (break cycles)
std::weak_ptr<Widget> observer = shared_widget;
```

### R.3: Never use raw new/delete

```cpp
// Forbidden
Widget* w = new Widget();
delete w;

// Correct: make_unique/make_shared
auto w = std::make_unique<Widget>();

// For arrays
auto arr = std::make_unique<int[]>(100);
```

### R.4: Lock management

```cpp
// Avoid: manual lock management
void bad() {
    mutex_.lock();
    process();  // If throws, lock not released
    mutex_.unlock();
}

// Prefer: RAII lock guards
void good() {
    std::lock_guard lock(mutex_);
    process();
}

// For complex locking
void conditional() {
    std::unique_lock lock(mutex_);
    cv_.wait(lock, [] { return ready_; });
}
```

## Expressions and Statements (ES)

### ES.1: Prefer initialization to assignment

```cpp
// Avoid
int x;
x = 5;

// Prefer
int x = 5;

// Use uniform initialization
std::vector<int> v{1, 2, 3};
Point p{.x = 1.0, .y = 2.0};  // C++20 designated initializers
```

### ES.2: Use nullptr, not 0 or NULL

```cpp
// Avoid
int* p = 0;
int* q = NULL;

// Prefer
int* p = nullptr;
```

### ES.3: Avoid magic constants

```cpp
// Avoid
if (status == 42) { /* ... */ }

// Prefer
constexpr int STATUS_READY = 42;
if (status == STATUS_READY) { /* ... */ }

// Even better: use enums
enum class Status { Ready = 42, Busy, Error };
```

### ES.4: Use auto judiciously

```cpp
// Good: obvious types
auto i = 42;  // int
auto s = "hello"s;  // std::string
auto it = container.begin();

// Good: complex types
auto lambda = [](int x) { return x * 2; };

// Avoid: obscures important type information
auto result = compute();  // What type is result?
```

### ES.5: Prefer range-for

```cpp
// Avoid
for (size_t i = 0; i < vec.size(); ++i) {
    process(vec[i]);
}

// Prefer
for (const auto& item : vec) {
    process(item);
}

// With index (C++20)
for (auto [idx, item] : vec | std::views::enumerate) {
    process(idx, item);
}
```

## Error Handling (E)

### E.1: Use exceptions for exceptional cases

```cpp
// Exceptions for unexpected failures
void load_config(const std::filesystem::path& path) {
    if (!std::filesystem::exists(path)) {
        throw ConfigError("Config file not found: " + path.string());
    }
    // ...
}
```

### E.2: Design for error handling

```cpp
// Use expected for recoverable errors (C++23 or use tl::expected)
std::expected<Config, ParseError> parse_config(std::string_view text) {
    if (text.empty()) {
        return std::unexpected(ParseError::EmptyInput);
    }
    // ...
}

// Use optional for "value may not exist"
std::optional<User> find_user(int id);
```

### E.3: Exception safety guarantees

```cpp
// Strong guarantee: operation succeeds completely or has no effect
void Container::push_back(const T& value) {
    auto new_data = std::make_unique<T[]>(size_ + 1);
    std::copy(data_.get(), data_.get() + size_, new_data.get());
    new_data[size_] = value;
    data_ = std::move(new_data);  // noexcept
    ++size_;
}
```

### E.4: noexcept for move operations

```cpp
class Widget {
public:
    Widget(Widget&& other) noexcept
        : data_(std::exchange(other.data_, nullptr)) {}

    Widget& operator=(Widget&& other) noexcept {
        data_ = std::exchange(other.data_, nullptr);
        return *this;
    }
private:
    int* data_ = nullptr;
};
```

## Constants and Immutability (Con)

### Con.1: Use const liberally

```cpp
// Mark everything that shouldn't change as const
void process(const std::vector<int>& data);

const int MAX_SIZE = 100;

class Widget {
public:
    int get_value() const { return value_; }  // const member function
private:
    int value_;
};
```

### Con.2: Use constexpr for compile-time constants

```cpp
// Compile-time evaluation
constexpr int factorial(int n) {
    return n <= 1 ? 1 : n * factorial(n - 1);
}

constexpr int fact5 = factorial(5);  // Evaluated at compile time

// constexpr variables
constexpr double PI = 3.14159265358979;
constexpr size_t BUFFER_SIZE = 1024;
```

### Con.3: Use consteval for compile-time-only functions (C++20)

```cpp
consteval int square(int n) {
    return n * n;
}

int a = square(5);  // OK: compile-time
int b = square(runtime_value);  // Error: must be compile-time
```

## Templates and Generic Programming (T)

### T.1: Use concepts to constrain templates (C++20)

```cpp
// Define concepts
template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template<typename T>
concept Sortable = requires(T& t) {
    { t.begin() } -> std::forward_iterator;
    { t.end() } -> std::forward_iterator;
    requires std::totally_ordered<std::iter_value_t<decltype(t.begin())>>;
};

// Use concepts
template<Numeric T>
T add(T a, T b) { return a + b; }

template<Sortable Container>
void sort_container(Container& c) {
    std::ranges::sort(c);
}
```

### T.2: Document semantic requirements

```cpp
// Even with concepts, document behavior requirements
/**
 * @brief Hash function for use in hash maps
 * @tparam T Type to hash. Must satisfy:
 *   - std::hash<T> is defined
 *   - Equal objects must produce equal hashes
 *   - Hash should distribute uniformly
 */
template<typename T>
requires std::is_default_constructible_v<std::hash<T>>
size_t compute_hash(const T& value) {
    return std::hash<T>{}(value);
}
```

### T.3: Avoid template code bloat

```cpp
// Avoid: full template generates code for each type
template<typename T>
void process_all(const std::vector<T>& items) {
    for (const auto& item : items) {
        log_start();
        process(item);  // Only this needs T
        log_end();
    }
}

// Prefer: factor out type-independent code
void log_start();
void log_end();

template<typename T>
void process_all(const std::vector<T>& items) {
    log_start();
    for (const auto& item : items) {
        process(item);
    }
    log_end();
}
```

## GSL (Guidelines Support Library)

### Common GSL types

```cpp
#include <gsl/gsl>

// gsl::not_null - pointer that cannot be null
void process(gsl::not_null<Widget*> widget) {
    widget->do_work();  // No null check needed
}

// gsl::span - non-owning view of contiguous data
void process_data(gsl::span<const int> data) {
    for (int value : data) {
        // ...
    }
}

// Use std::span in C++20
void process_data(std::span<const int> data);
```

### GSL assertions

```cpp
#include <gsl/gsl>

void process(int* p, size_t count) {
    Expects(p != nullptr);      // Precondition
    Expects(count > 0);

    // ... processing ...

    Ensures(result.is_valid());  // Postcondition
}
```

### gsl::finally for cleanup

```cpp
#include <gsl/gsl>

void use_legacy_api() {
    legacy_acquire();
    auto _ = gsl::finally([] { legacy_release(); });

    // ... use resource ...
    // Automatically released even if exception thrown
}
```

## Clang-Tidy Configuration

### Recommended checks

```yaml
# .clang-tidy
Checks: >
  cppcoreguidelines-*,
  -cppcoreguidelines-avoid-magic-numbers,
  cppcoreguidelines-avoid-goto,
  cppcoreguidelines-avoid-non-const-global-variables,
  cppcoreguidelines-init-variables,
  cppcoreguidelines-interfaces-global-init,
  cppcoreguidelines-macro-usage,
  cppcoreguidelines-narrowing-conversions,
  cppcoreguidelines-no-malloc,
  cppcoreguidelines-owning-memory,
  cppcoreguidelines-prefer-member-initializer,
  cppcoreguidelines-pro-bounds-*,
  cppcoreguidelines-pro-type-*,
  cppcoreguidelines-slicing,
  cppcoreguidelines-special-member-functions,
  modernize-*,
  readability-*

WarningsAsErrors: >
  cppcoreguidelines-avoid-goto,
  cppcoreguidelines-no-malloc,
  cppcoreguidelines-owning-memory

CheckOptions:
  - key: cppcoreguidelines-special-member-functions.AllowSoleDefaultDtor
    value: true
  - key: cppcoreguidelines-macro-usage.AllowedRegexp
    value: '^(DEBUG_|PLATFORM_|PROJECT_)'
```

### Key checks explained

| Check | Purpose |
|-------|---------|
| `cppcoreguidelines-avoid-goto` | Disallow goto statements |
| `cppcoreguidelines-init-variables` | Ensure variables are initialized |
| `cppcoreguidelines-no-malloc` | Forbid malloc/free in favor of new/delete or smart pointers |
| `cppcoreguidelines-owning-memory` | Track ownership of raw pointers |
| `cppcoreguidelines-pro-bounds-*` | Bounds safety checks |
| `cppcoreguidelines-pro-type-*` | Type safety checks |
| `cppcoreguidelines-slicing` | Warn on object slicing |
| `cppcoreguidelines-special-member-functions` | Enforce Rule of Zero/Five |

### CMake integration

```cmake
# Enable clang-tidy in CMake
set(CMAKE_CXX_CLANG_TIDY
    clang-tidy;
    -checks=cppcoreguidelines-*,modernize-*;
    -warnings-as-errors=*;
    -header-filter=${CMAKE_SOURCE_DIR}/include/.*
)
```

## Quick Reference

### Memory safety checklist

- [ ] No raw `new`/`delete` - use smart pointers
- [ ] No raw arrays - use `std::array`, `std::vector`, or `std::span`
- [ ] No C-style casts - use `static_cast`, `dynamic_cast`, etc.
- [ ] No `void*` - use templates or variants
- [ ] Always initialize variables
- [ ] Use RAII for all resources

### Modern C++ checklist

- [ ] Use `auto` where type is obvious
- [ ] Use `nullptr` instead of `NULL` or `0`
- [ ] Use `constexpr` for compile-time constants
- [ ] Use range-for instead of index loops
- [ ] Use `std::string_view` for non-owning string references
- [ ] Use structured bindings for tuple/pair access
- [ ] Use `[[nodiscard]]` for functions whose return must be used

### References

- [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines)
- [GSL Repository](https://github.com/microsoft/GSL)
- [Clang-Tidy Checks](https://clang.llvm.org/extra/clang-tidy/checks/list.html)
