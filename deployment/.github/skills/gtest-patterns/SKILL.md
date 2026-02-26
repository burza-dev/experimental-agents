---
name: gtest-patterns
description: GoogleTest (gtest) testing patterns for C++. Apply when writing unit tests, integration tests, or mock-based tests using GoogleTest/GMock framework.
technologies: [gtest, gmock, cpp]
---

# GoogleTest Patterns

## When to Apply

- Writing new unit tests for C++ code
- Creating mock objects for dependency injection
- Adding parameterized tests for multiple input scenarios
- Implementing death tests for error handling validation
- Setting up test fixtures for shared test state
- Integrating tests with CMake build system

## Test Structure

### Basic Test (TEST macro)

Use `TEST` for simple tests without shared setup:

```cpp
#include <gtest/gtest.h>

TEST(CalculatorTest, AddsTwoPositiveNumbers) {
    Calculator calc;
    EXPECT_EQ(calc.add(2, 3), 5);
}

TEST(CalculatorTest, HandlesNegativeNumbers) {
    Calculator calc;
    EXPECT_EQ(calc.add(-1, -2), -3);
}
```

### Test Fixture (TEST_F macro)

Use `TEST_F` when tests share common setup/teardown:

```cpp
#include <gtest/gtest.h>

class DatabaseTest : public ::testing::Test {
protected:
    void SetUp() override {
        db_ = std::make_unique<Database>(":memory:");
        db_->connect();
        db_->createTable("users");
    }

    void TearDown() override {
        db_->dropTable("users");
        db_->disconnect();
    }

    std::unique_ptr<Database> db_;
};

TEST_F(DatabaseTest, InsertsRecord) {
    EXPECT_TRUE(db_->insert("users", {"name", "Alice"}));
    EXPECT_EQ(db_->count("users"), 1);
}

TEST_F(DatabaseTest, DeletesRecord) {
    db_->insert("users", {"name", "Bob"});
    EXPECT_TRUE(db_->remove("users", "name", "Bob"));
    EXPECT_EQ(db_->count("users"), 0);
}
```

## Assertion Macros

### ASSERT_* vs EXPECT_*

| Macro Type | Behavior on Failure | When to Use |
|------------|---------------------|-------------|
| `ASSERT_*` | Aborts current test | Preconditions; continuing would crash or be meaningless |
| `EXPECT_*` | Continues test | Most assertions; allows seeing all failures at once |

### Common Assertions

```cpp
// Boolean
EXPECT_TRUE(condition);
EXPECT_FALSE(condition);

// Equality
EXPECT_EQ(expected, actual);    // ==
EXPECT_NE(val1, val2);          // !=
EXPECT_LT(val1, val2);          // <
EXPECT_LE(val1, val2);          // <=
EXPECT_GT(val1, val2);          // >
EXPECT_GE(val1, val2);          // >=

// String
EXPECT_STREQ(expected, actual); // C-string equality
EXPECT_STRNE(str1, str2);       // C-string inequality
EXPECT_STRCASEEQ(s1, s2);       // Case-insensitive equality

// Floating point (with tolerance)
EXPECT_FLOAT_EQ(expected, actual);
EXPECT_DOUBLE_EQ(expected, actual);
EXPECT_NEAR(val1, val2, abs_error);

// Exception handling
EXPECT_THROW(statement, exception_type);
EXPECT_NO_THROW(statement);
EXPECT_ANY_THROW(statement);
```

### Custom Failure Messages

```cpp
EXPECT_EQ(result, expected) << "Failed for input: " << input;
ASSERT_TRUE(isValid) << "Validation failed with error: " << error_code;
```

## GMock Integration

### Mock Class Definition

```cpp
#include <gmock/gmock.h>

class MockDatabase : public DatabaseInterface {
public:
    MOCK_METHOD(bool, connect, (), (override));
    MOCK_METHOD(void, disconnect, (), (override));
    MOCK_METHOD(bool, insert, (const std::string& table, const Record& record), (override));
    MOCK_METHOD(std::optional<Record>, find, (const std::string& table, int id), (const, override));
    MOCK_METHOD(int, count, (const std::string& table), (const, noexcept, override));
};
```

### MOCK_METHOD Syntax

```cpp
// Format: MOCK_METHOD(return_type, method_name, (args), (qualifiers))

// No qualifiers
MOCK_METHOD(void, simpleMethod, ());

// Const method
MOCK_METHOD(int, getValue, (), (const));

// Override virtual method
MOCK_METHOD(void, virtualMethod, (), (override));

// Multiple qualifiers
MOCK_METHOD(int, complexMethod, (int x, int y), (const, override, noexcept));
```

### Setting Expectations with EXPECT_CALL

```cpp
using ::testing::Return;
using ::testing::_;
using ::testing::AtLeast;

TEST_F(ServiceTest, CallsDatabaseOnProcess) {
    MockDatabase mock_db;

    // Expect connect() to be called exactly once, return true
    EXPECT_CALL(mock_db, connect())
        .Times(1)
        .WillOnce(Return(true));

    // Expect insert() with any arguments, at least once
    EXPECT_CALL(mock_db, insert(_, _))
        .Times(AtLeast(1))
        .WillRepeatedly(Return(true));

    Service service(&mock_db);
    service.process();
}
```

### Cardinality

```cpp
using ::testing::Exactly;
using ::testing::AtLeast;
using ::testing::AtMost;
using ::testing::Between;
using ::testing::AnyNumber;

EXPECT_CALL(mock, method()).Times(Exactly(3));
EXPECT_CALL(mock, method()).Times(AtLeast(1));
EXPECT_CALL(mock, method()).Times(AtMost(5));
EXPECT_CALL(mock, method()).Times(Between(2, 4));
EXPECT_CALL(mock, method()).Times(AnyNumber());
```

### Matchers

```cpp
using ::testing::Eq;
using ::testing::Ne;
using ::testing::Lt;
using ::testing::Gt;
using ::testing::Le;
using ::testing::Ge;
using ::testing::IsNull;
using ::testing::NotNull;
using ::testing::Ref;
using ::testing::TypedEq;

// Value matchers
EXPECT_CALL(mock, setValue(Eq(42)));
EXPECT_CALL(mock, setPointer(NotNull()));

// String matchers
using ::testing::HasSubstr;
using ::testing::StartsWith;
using ::testing::EndsWith;
using ::testing::MatchesRegex;
using ::testing::ContainsRegex;

EXPECT_CALL(mock, log(HasSubstr("error")));
EXPECT_CALL(mock, setPath(StartsWith("/home/")));

// Container matchers
using ::testing::Contains;
using ::testing::Each;
using ::testing::ElementsAre;
using ::testing::UnorderedElementsAre;
using ::testing::IsEmpty;
using ::testing::SizeIs;

EXPECT_CALL(mock, process(Contains(42)));
EXPECT_CALL(mock, setList(ElementsAre(1, 2, 3)));
EXPECT_CALL(mock, setVector(SizeIs(Gt(0))));

// Composite matchers
using ::testing::AllOf;
using ::testing::AnyOf;
using ::testing::Not;

EXPECT_CALL(mock, setValue(AllOf(Gt(0), Lt(100))));
EXPECT_CALL(mock, setName(AnyOf("Alice", "Bob")));
```

### Actions

```cpp
using ::testing::Return;
using ::testing::ReturnRef;
using ::testing::ReturnPointee;
using ::testing::SetArgPointee;
using ::testing::SetArgReferee;
using ::testing::Throw;
using ::testing::DoAll;
using ::testing::Invoke;
using ::testing::InvokeWithoutArgs;

// Return values
EXPECT_CALL(mock, getValue()).WillOnce(Return(42));
EXPECT_CALL(mock, getRef()).WillOnce(ReturnRef(value));

// Throw exceptions
EXPECT_CALL(mock, riskyOperation()).WillOnce(Throw(std::runtime_error("failed")));

// Multiple actions
EXPECT_CALL(mock, getAndSet(_, _))
    .WillOnce(DoAll(SetArgPointee<1>(42), Return(true)));

// Custom behavior
EXPECT_CALL(mock, compute(_))
    .WillOnce(Invoke([](int x) { return x * 2; }));
```

### Sequences and Order

```cpp
using ::testing::InSequence;

TEST(OrderTest, CallsInOrder) {
    MockService mock;

    {
        InSequence seq;
        EXPECT_CALL(mock, initialize());
        EXPECT_CALL(mock, process());
        EXPECT_CALL(mock, cleanup());
    }

    runWorkflow(&mock);
}
```

## Parameterized Tests

### Basic Parameterized Test

```cpp
#include <gtest/gtest.h>

class PrimeTest : public ::testing::TestWithParam<int> {};

TEST_P(PrimeTest, IsPrime) {
    int n = GetParam();
    EXPECT_TRUE(isPrime(n)) << n << " should be prime";
}

INSTANTIATE_TEST_SUITE_P(
    PrimeNumbers,
    PrimeTest,
    ::testing::Values(2, 3, 5, 7, 11, 13)
);
```

### Value Generators

```cpp
using ::testing::Values;
using ::testing::ValuesIn;
using ::testing::Range;
using ::testing::Combine;
using ::testing::Bool;

// Explicit values
INSTANTIATE_TEST_SUITE_P(Explicit, MyTest, Values(1, 2, 3, 4, 5));

// From container
std::vector<int> testCases = {10, 20, 30};
INSTANTIATE_TEST_SUITE_P(FromVector, MyTest, ValuesIn(testCases));

// Range of values
INSTANTIATE_TEST_SUITE_P(RangeTest, MyTest, Range(0, 10));  // 0-9
INSTANTIATE_TEST_SUITE_P(RangeStep, MyTest, Range(0, 100, 10));  // 0, 10, 20...

// Boolean combinations
INSTANTIATE_TEST_SUITE_P(BoolTest, MyTest, Bool());  // true, false
```

### Tuple Parameters with Combine

```cpp
class MathOpTest : public ::testing::TestWithParam<std::tuple<int, int, int>> {};

TEST_P(MathOpTest, AdditionWorks) {
    auto [a, b, expected] = GetParam();
    EXPECT_EQ(a + b, expected);
}

INSTANTIATE_TEST_SUITE_P(
    AdditionCases,
    MathOpTest,
    ::testing::Combine(
        ::testing::Values(1, 2),
        ::testing::Values(10, 20),
        ::testing::Values(11, 12, 21, 22)
    )
);
```

### Struct Parameters for Readability

```cpp
struct TestCase {
    std::string name;
    int input;
    int expected;
};

class CalculatorTest : public ::testing::TestWithParam<TestCase> {};

TEST_P(CalculatorTest, ComputesCorrectly) {
    const auto& tc = GetParam();
    EXPECT_EQ(compute(tc.input), tc.expected) << "Failed: " << tc.name;
}

INSTANTIATE_TEST_SUITE_P(
    Cases,
    CalculatorTest,
    ::testing::Values(
        TestCase{"zero", 0, 0},
        TestCase{"positive", 5, 25},
        TestCase{"negative", -3, 9}
    ),
    [](const ::testing::TestParamInfo<TestCase>& info) {
        return info.param.name;  // Custom test name
    }
);
```

## Death Tests

### Basic Death Test

```cpp
TEST(DeathTest, DiesOnInvalidInput) {
    ASSERT_DEATH(processInvalid(nullptr), ".*null pointer.*");
}

TEST(DeathTest, ExitsWithCode) {
    EXPECT_EXIT(exitWithError(), ::testing::ExitedWithCode(1), "");
}

TEST(DeathTest, KilledBySignal) {
    EXPECT_EXIT(segfault(), ::testing::KilledBySignal(SIGSEGV), ".*");
}
```

### Death Test Style

```cpp
// In main() or test setup
::testing::GTEST_FLAG(death_test_style) = "threadsafe";  // or "fast"
```

### When to Use Death Tests

- Validating assertion macros (CHECK, DCHECK)
- Testing fatal error handlers
- Verifying process termination behavior
- Testing signal handlers

**Avoid death tests for:**
- Normal exception handling (use EXPECT_THROW instead)
- Non-fatal errors
- Performance-critical test suites (death tests fork processes)

## Test Organization

### File Naming Conventions

```
src/
├── calculator.cpp
├── calculator.h
tests/
├── calculator_test.cpp      # Unit tests for calculator
├── integration/
│   └── system_test.cpp      # Integration tests
└── fixtures/
    └── test_data.h          # Shared test fixtures
```

### Test Naming

Use descriptive names that explain expected behavior:

```cpp
// Given-When-Then style
TEST_F(AccountTest, GivenInsufficientFunds_WhenWithdraw_ThenReturnsError) { }

// Descriptive style
TEST_F(AccountTest, WithdrawReturnsErrorWhenInsufficientFunds) { }

// Method_Scenario_Expected style
TEST_F(AccountTest, Withdraw_InsufficientFunds_ReturnsError) { }
```

### Test Independence

Each test must be independent and repeatable:

```cpp
class IndependentTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Create fresh state for each test
        system_ = std::make_unique<System>();
        system_->reset();
    }

    void TearDown() override {
        // Clean up any external resources
        system_->cleanup();
    }

    std::unique_ptr<System> system_;
};
```

## CMake Integration

### Basic Setup

```cmake
cmake_minimum_required(VERSION 3.14)
project(MyProject)

# Enable testing
enable_testing()

# Fetch GoogleTest
include(FetchContent)
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG v1.14.0
)
FetchContent_MakeAvailable(googletest)

# Create test executable
add_executable(mytests
    tests/calculator_test.cpp
    tests/database_test.cpp
)

target_link_libraries(mytests
    PRIVATE
        mylib
        GTest::gtest_main
        GTest::gmock
)

# Discover tests for CTest
include(GoogleTest)
gtest_discover_tests(mytests)
```

### Test Discovery Options

```cmake
gtest_discover_tests(mytests
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    PROPERTIES
        LABELS "unit"
        TIMEOUT 30
    DISCOVERY_TIMEOUT 60
)
```

### Separate Unit and Integration Tests

```cmake
# Unit tests
add_executable(unit_tests
    tests/unit/calculator_test.cpp
)
target_link_libraries(unit_tests PRIVATE GTest::gtest_main)
gtest_discover_tests(unit_tests
    PROPERTIES LABELS "unit"
)

# Integration tests
add_executable(integration_tests
    tests/integration/system_test.cpp
)
target_link_libraries(integration_tests PRIVATE GTest::gtest_main)
gtest_discover_tests(integration_tests
    PROPERTIES LABELS "integration"
)

# Custom targets for selective testing
add_custom_target(test_unit
    COMMAND ${CMAKE_CTEST_COMMAND} -L unit --output-on-failure
    DEPENDS unit_tests
)

add_custom_target(test_integration
    COMMAND ${CMAKE_CTEST_COMMAND} -L integration --output-on-failure
    DEPENDS integration_tests
)
```

## Coverage Integration

### Compiler Flags (GCC/Clang)

```cmake
option(ENABLE_COVERAGE "Enable code coverage" OFF)

if(ENABLE_COVERAGE)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        add_compile_options(--coverage -fprofile-arcs -ftest-coverage)
        add_link_options(--coverage)
    endif()
endif()
```

### LLVM-cov (Clang)

```cmake
if(ENABLE_COVERAGE AND CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    add_compile_options(-fprofile-instr-generate -fcoverage-mapping)
    add_link_options(-fprofile-instr-generate)
endif()
```

### Coverage Report Generation

```bash
# GCC with gcov/lcov
cmake -B build -DENABLE_COVERAGE=ON
cmake --build build
cd build && ctest --output-on-failure
lcov --capture --directory . --output-file coverage.info
lcov --remove coverage.info '/usr/*' '*/tests/*' --output-file coverage.info
genhtml coverage.info --output-directory coverage_report

# Clang with llvm-cov
LLVM_PROFILE_FILE="coverage.profraw" ./mytests
llvm-profdata merge -sparse coverage.profraw -o coverage.profdata
llvm-cov show ./mytests -instr-profile=coverage.profdata -format=html > coverage.html
llvm-cov report ./mytests -instr-profile=coverage.profdata
```

### CMake Coverage Target

```cmake
if(ENABLE_COVERAGE)
    find_program(LCOV lcov)
    find_program(GENHTML genhtml)

    if(LCOV AND GENHTML)
        add_custom_target(coverage
            COMMAND ${LCOV} --zerocounters --directory .
            COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
            COMMAND ${LCOV} --capture --directory . --output-file coverage.info
            COMMAND ${LCOV} --remove coverage.info '/usr/*' '*/tests/*' 
                    --output-file coverage.info
            COMMAND ${GENHTML} coverage.info --output-directory coverage_report
            COMMAND ${CMAKE_COMMAND} -E echo "Coverage report: coverage_report/index.html"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS mytests
        )
    endif()
endif()
```

## Best Practices

### Do

- Keep tests fast (< 100ms each for unit tests)
- Use fixtures to avoid code duplication
- Test one behavior per test
- Use descriptive test names
- Prefer `EXPECT_*` over `ASSERT_*` unless continuing is meaningless
- Use `ON_CALL` for default behavior, `EXPECT_CALL` for expectations
- Clean up resources in `TearDown()`

### Avoid

- Testing implementation details (test behavior, not structure)
- Shared mutable state between tests
- Sleeping or timing-based tests
- Over-mocking (mock boundaries, not everything)
- Flaky tests (fix or disable, never ignore)

### Test Smell Detection

```cpp
// Bad: tests implementation details
TEST(ListTest, InternalArrayHasCorrectCapacity) {
    List list;
    EXPECT_EQ(list.internal_capacity_, 16);  // Exposes internals
}

// Good: tests behavior
TEST(ListTest, CanAddElements) {
    List list;
    list.add(1);
    list.add(2);
    EXPECT_EQ(list.size(), 2);
}
```
