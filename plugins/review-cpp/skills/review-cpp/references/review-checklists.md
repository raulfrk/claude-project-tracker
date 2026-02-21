# C++ Review Checklists

Domain-specific checklists for each review agent. Agents should reference these as supplementary guidance alongside their own system prompts.

---

## Architect Checklist

- [ ] Are module/component boundaries clearly defined with minimal coupling?
- [ ] Does data flow in one direction through the system? (no circular dependencies)
- [ ] Is the dependency graph acyclic? (check with `include-what-you-use` or manually trace headers)
- [ ] Are abstractions at the right level? (not too leaky, not over-engineered)
- [ ] Does each class have a single, clear responsibility?
- [ ] Are interfaces (pure abstract classes or concepts) used to decouple consumers from implementations?
- [ ] Is PIMPL used where appropriate to reduce header coupling and binary compatibility?
- [ ] Are namespaces organized to reflect the module structure?
- [ ] Are global variables or singletons present? (flag for discussion — prefer dependency injection)
- [ ] Are design patterns used appropriately? (not applied just to apply them)
- [ ] Are factory methods / abstract factories used where object creation logic is complex?
- [ ] Is the observer/event system implemented cleanly? (no naked callbacks, prefer `std::function` or signals)
- [ ] Would a different top-level design (e.g., ECS instead of OOP hierarchy) be meaningfully simpler?

---

## C++ Language Specialist Checklist

- [ ] Does every class with resources follow the Rule of Zero or Rule of Five?
- [ ] Is `const` applied wherever possible (member functions, parameters, local variables, return types)?
- [ ] Are parameters passed by value when the callee needs ownership, by const-ref otherwise?
- [ ] Is `std::move` used correctly (not on const objects, not after move)?
- [ ] Are `unique_ptr` / `shared_ptr` used correctly? (prefer unique_ptr unless shared ownership needed)
- [ ] Is `auto` used where it improves clarity? Is it avoided where it hides important type info?
- [ ] Are structured bindings (`auto [a, b] = ...`) used where applicable?
- [ ] Are C++20 concepts used instead of SFINAE where available?
- [ ] Is `std::optional` used instead of sentinel values or nullable raw pointers?
- [ ] Is `std::variant` used instead of union + type tag?
- [ ] Are range-based for loops used over index-based where possible?
- [ ] Are lambdas captured minimally? (no `[&]` when specific captures suffice)
- [ ] Is `std::string_view` used for read-only string parameters instead of `const std::string&`?
- [ ] Are macros avoided in favor of `constexpr`, `inline`, or templates?
- [ ] Is `nullptr` used instead of `NULL` or `0` for pointers?
- [ ] Is brace initialization used consistently?
- [ ] Are deprecated C++11/14 features replaced with modern equivalents?

---

## Low Latency Checklist

- [ ] Are heap allocations present on the hot path? (flag any `new`, `make_shared`, `make_unique`, container resizing)
- [ ] Are vectors pre-reserved to the expected capacity?
- [ ] Is data laid out for cache efficiency? (structs of arrays vs arrays of structs)
- [ ] Is false sharing possible? (shared cache lines between threads with independent data)
- [ ] Are virtual functions called in tight loops? (flag — consider devirtualization or std::variant dispatch)
- [ ] Are copies made where moves would suffice?
- [ ] Is `std::function` used in hot paths? (flag — prefers heap allocation; consider function pointers or templates)
- [ ] Are branch-heavy conditionals in hot paths? (consider lookup tables, branchless patterns)
- [ ] Is I/O synchronous in the hot path? (should be async or batched)
- [ ] Are `std::map` / `std::set` used where `std::unordered_map` / `flat_map` would be faster?
- [ ] Are `std::deque` or `std::list` used where `std::vector` would have better cache behavior?
- [ ] Are there missed `constexpr` opportunities? (compile-time computation that happens at runtime)
- [ ] Is `__builtin_expect` / `[[likely]]` / `[[unlikely]]` missing on frequently-predicted branches?
- [ ] Are unnecessary copies returned? (check for NRVO opportunities)
- [ ] Are lock contention points in the hot path? (consider lock-free structures or finer-grained locking)

---

## Memory Safety Checklist

- [ ] Are raw pointers used without ownership semantics? (flag — prefer smart pointers)
- [ ] Are references returned to local variables or temporaries?
- [ ] Are iterators used after container modification (insert/erase) that may invalidate them?
- [ ] Is `delete` / `delete[]` called manually? (flag — prefer RAII)
- [ ] Is `new` used without a corresponding guaranteed `delete`? (flag — prefer `make_unique`)
- [ ] Are array accesses checked against bounds? (or use `std::span`, `std::array::at()`)
- [ ] Can signed integer arithmetic overflow? (flag unchecked arithmetic on user-controlled values)
- [ ] Are uninitialized variables read before assignment?
- [ ] Is `reinterpret_cast` used? (flag — often indicates UB via strict aliasing violation)
- [ ] Is type punning done safely? (`std::bit_cast` in C++20, or `memcpy`)
- [ ] Are C-style casts used? (flag — use `static_cast`, `const_cast`, `reinterpret_cast` explicitly)
- [ ] Can exceptions in constructors leak resources? (check RAII of partially-constructed objects)
- [ ] Are destructors `noexcept`? (destructor that throws in stack unwind = `std::terminate`)
- [ ] Is `shared_ptr` used in ways that could create cycles? (check for `weak_ptr` usage)
- [ ] Are C-style arrays used where `std::array` or `std::vector` would be safer?
- [ ] Are `char` buffers used for string manipulation? (prefer `std::string` / `std::string_view`)

---

## Concurrency Checklist

- [ ] Is shared mutable state accessed from multiple threads without synchronization?
- [ ] Are mutexes locked in a consistent order everywhere they are used together? (deadlock risk)
- [ ] Are `std::lock_guard` / `std::scoped_lock` used (RAII) rather than manual lock/unlock?
- [ ] Are condition variables used with a predicate loop (spurious wakeup handling)?
- [ ] Is the correct `std::memory_order` used for each atomic operation?
- [ ] Is `std::atomic<bool>` used as a stop flag correctly? (load with `acquire`, store with `release`)
- [ ] Are there potential ABA problems in lock-free code?
- [ ] Is thread-local storage used correctly? (no cross-thread access to `thread_local` variables)
- [ ] Are threads joined or detached before destruction? (detached threads with references to locals = UB)
- [ ] Is `std::async` with `std::launch::async` or `std::launch::deferred` used intentionally?
- [ ] Are `std::future` results retrieved before the future's destructor? (deferred tasks block on destruction)
- [ ] Are clang thread safety annotations (`GUARDED_BY`, `REQUIRES`, `EXCLUDES`) present on shared state?
- [ ] Are signal handlers accessing non-async-signal-safe functions? (only `sig_atomic_t` + async-safe calls allowed)
- [ ] Is false sharing mitigated with `alignas(64)` on independently-updated data?

---

## Security Checklist

- [ ] Are any C standard library functions that are inherently unsafe used? (`gets`, `strcpy`, `sprintf`, `scanf("%s")`)
- [ ] Is user-supplied input used to determine buffer sizes without overflow checks?
- [ ] Is user-supplied input passed to `system()`, `popen()`, `exec*()`, or shell commands?
- [ ] Are format strings user-controlled? (`printf(user_input)` = format string vulnerability)
- [ ] Are hardcoded secrets, API keys, or passwords present in source?
- [ ] Are file paths from user input used without canonicalization? (path traversal risk)
- [ ] Is cryptography implemented manually instead of using a vetted library?
- [ ] Are weak or deprecated cryptographic algorithms used? (MD5, SHA1, DES, RC4)
- [ ] Is random number generation used for security purposes with non-cryptographic RNG? (`rand()` = bad)
- [ ] Are TOCTOU (time-of-check time-of-use) patterns present for file operations?
- [ ] Does error handling leak sensitive information in error messages or logs?
- [ ] Are third-party dependencies pinned to specific versions? (supply chain risk)
- [ ] Is input length validated before processing?
- [ ] Is integer arithmetic on externally-provided sizes checked for overflow before use in allocation?

---

## Complexity Checklist

**Thresholds** (flag when exceeded):
- Function length: > 50 lines
- Cyclomatic complexity per function: > 10
- Nesting depth: > 3 levels
- Class public method count: > 20
- Class line count: > 500
- File line count: > 1000

**Patterns to flag:**
- [ ] Nested ternary operators
- [ ] Long chains of if/else if with similar structure (consider `std::map` dispatch or `std::variant`)
- [ ] Functions that do more than one thing (name with "and" is a hint)
- [ ] Duplicated logic that could be extracted (DRY violations)
- [ ] Magic numbers without named constants
- [ ] Overly clever one-liners that sacrifice readability for brevity
- [ ] Dead code (unreachable branches, unused variables / functions / methods)
- [ ] Comment-code drift (comments that describe what the code no longer does)
- [ ] Deeply nested lambdas
- [ ] Template metaprogramming where simpler runtime code would suffice
- [ ] Functions that take too many parameters (> 5 is a hint — consider parameter objects)

---

## CI/CD Checklist

**CMake:**
- [ ] Targets use `target_*` commands rather than global `include_directories` / `link_libraries`?
- [ ] `cmake_minimum_required` version is recent (3.20+)?
- [ ] `CMAKE_BUILD_TYPE` is not hardcoded (should be set at configure time)?
- [ ] Are compile options set per-target, not globally?
- [ ] Is dependency management explicit? (vcpkg, Conan, FetchContent, or submodules — not ad-hoc)

**Linters / Static Analysis:**
- [ ] Is `.clang-tidy` present with meaningful checks enabled?
- [ ] Is `.clang-format` present with a consistent style?
- [ ] Is `cppcheck` or `include-what-you-use` integrated?
- [ ] Are compiler warnings at maximum useful level? (`-Wall -Wextra -Wpedantic`)
- [ ] Is `-Werror` enabled in CI to catch regressions?

**Sanitizers in CI:**
- [ ] AddressSanitizer (ASan) — memory errors
- [ ] UndefinedBehaviorSanitizer (UBSan) — undefined behavior
- [ ] ThreadSanitizer (TSan) — data races (if multi-threaded)
- [ ] MemorySanitizer (MSan) — uninitialized reads (Linux/Clang only)

**CI Pipeline:**
- [ ] Build matrix covers multiple compilers (GCC + Clang) and standards (C++17, C++20)?
- [ ] Debug and Release build modes both tested?
- [ ] Build artifacts are cached for speed?
- [ ] CI runs on PRs before merge?

---

## Test Quality Checklist

- [ ] Are tests independent of each other? (no shared mutable state between tests)
- [ ] Do tests follow the Arrange-Act-Assert pattern?
- [ ] Are both happy paths and error paths tested?
- [ ] Are boundary values tested? (0, -1, max, empty, null/nullptr)
- [ ] Are tests named to describe behavior, not implementation? (`CalculatesTax_WhenRateIsZero_ReturnsZero`)
- [ ] Are mocks used minimally? (only for truly external dependencies)
- [ ] Are `EXPECT_*` vs `ASSERT_*` used correctly? (ASSERT stops test, EXPECT continues)
- [ ] Are parameterized tests used for table-driven cases?
- [ ] Do tests verify observable behavior, not internal state?
- [ ] Are there tests for thread safety if the code is concurrent?
- [ ] Are flakiness risks present? (sleeps, wall-clock time, external services, filesystem side effects)
- [ ] Is test coverage adequate for the risk level of the code?
- [ ] Are negative tests present? (invalid input should be rejected or handled gracefully)
