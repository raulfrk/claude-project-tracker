# C++ Review Checklist

Use this checklist when reviewing C++ code. Work through every applicable rule per tier.

**Standards referenced:**
- **[CG]** — C++ Core Guidelines (isocpp.github.io/CppCoreGuidelines)
- **[GSG]** — Google C++ Style Guide
- **[LLVM]** — LLVM Coding Standards

---

## Tier 1 — Bugs/Safety [BLOCKING]

Issues that can cause crashes, data corruption, security vulnerabilities, or undefined behavior. Must be fixed before merge.

### 1A. Memory Safety

| ID | Rule | What to look for | Fix |
|----|------|-----------------|-----|
| M1 | No raw `new`/`delete` | `new T`, `delete p`, `new T[]`, `delete[] p` in application code | `std::make_unique<T>()`, `std::make_shared<T>()`, containers |
| M2 | No dangling pointers/references | Returning reference/pointer to local variable, reference to temporary, iterator invalidation after mutation | Return by value, extend lifetime, use indices instead of iterators |
| M3 | No use-after-move | Accessing an object after `std::move()` (except assignment or destruction) | Restructure control flow; do not read moved-from objects |
| M4 | No buffer overflows | Raw array indexing without bounds check, `strcpy`/`strcat`/`sprintf`, pointer arithmetic | `std::array::at()`, `std::span`, `std::format`, `std::string` |
| M5 | No null pointer dereference | Dereferencing without null check, especially from `dynamic_cast`, `map::find`, external APIs | Check before dereference, use `std::optional`, prefer references |

### 1B. Undefined Behavior

| ID | Rule | What to look for | Fix |
|----|------|-----------------|-----|
| U1 | No signed integer overflow | `int a + int b` where overflow is possible, especially loop counters | Use `unsigned`, wider type, or check bounds before operation |
| U2 | No uninitialized reads | Variables declared but not initialized, especially on conditional paths | Initialize at declaration with `{}` or a meaningful value |
| U3 | No unsequenced modifications | `i++ + i++`, `a[i] = i++`, multiple modifications to same var in one expression | Split into separate statements |
| U4 | No strict aliasing violations | Casting between unrelated pointer types, type-punning through unions | `std::bit_cast` (C++20), `memcpy`, `std::variant` |
| U5 | No dangling temporaries | `string_view` bound to a temporary `string`, reference to temporary that is destroyed | Store the value explicitly; use `const T&` only for lifetime-extended temporaries |

### 1C. Thread Safety

| ID | Rule | What to look for | Fix |
|----|------|-----------------|-----|
| T1 | No data races | Shared mutable state accessed without synchronization | `std::mutex` + `std::lock_guard`, `std::atomic`, thread-local storage |
| T2 | No deadlocks | Multiple mutexes acquired in inconsistent order, locking the same mutex twice | `std::scoped_lock` for multiple mutexes simultaneously |
| T3 | Correct atomic usage | Non-atomic read-modify-write on shared counter/flag | `std::atomic<T>`, use `fetch_add`/`compare_exchange_*` for RMW |

### 1D. Resource Leaks

| ID | Rule | What to look for | Fix |
|----|------|-----------------|-----|
| R1 | RAII for all resources | Raw `fopen`/`fclose`, `malloc`/`free`, OS handles without RAII wrapper | Smart pointers with custom deleters, `std::fstream`, RAII wrappers |
| R2 | Exception-safe acquisition | Resources acquired before a `try` block, early returns that skip cleanup | Use RAII; never rely on explicit cleanup code |

### 1E. Exception Safety

| ID | Rule | What to look for | Fix |
|----|------|-----------------|-----|
| E1 | No throwing destructors | `throw` in destructors, or calls to potentially-throwing functions in destructors | Mark destructors `noexcept`; catch exceptions internally |
| E2 | Basic guarantee met | Operations that leave objects in an invalid (not just unspecified) state on throw | Ensure class invariants hold after any exception |

---

## Tier 2 — Correctness/Design

Design problems or subtle correctness bugs. Should be fixed.

### 2A. Object Lifecycle

| ID | Rule | What to look for | Fix |
|----|------|-----------------|-----|
| O1 | Rule of Zero | Class defines destructor/copy/move but members are all RAII types | Remove custom special members; let the compiler generate them |
| O2 | Rule of Five | Class defines one of {destructor, copy-ctor, copy-assign, move-ctor, move-assign} but not all five | Declare or `= default`/`= delete` all five |
| O3 | No object slicing | Passing derived object by value to base type parameter | Pass by reference/pointer; use `std::reference_wrapper` |
| O4 | Move correctness | Move constructor/assignment that copies instead of moves; missing `noexcept` on move ops | Use `std::exchange` for member transfers; mark move ops `noexcept` |

### 2B. Const Correctness

| ID | Rule | What to look for | Fix |
|----|------|-----------------|-----|
| C1 | Const member functions | Member functions that don't modify state but lack `const` | Add `const` qualifier to the function |
| C2 | Const reference parameters | Large objects passed by value when not modified | `const T&` for input-only parameters |
| C3 | Const local variables | Local variables assigned once and never modified | `const auto x = ...` |

### 2C. Ownership Clarity

| ID | Rule | What to look for | Fix |
|----|------|-----------------|-----|
| L1 | Clear ownership semantics | Raw pointer return/parameter where ownership intent is ambiguous | `std::unique_ptr` for owning; raw pointer/reference for non-owning; document intent |
| L2 | No unnecessary `shared_ptr` | `shared_ptr` used where `unique_ptr` would suffice | Replace with `std::unique_ptr` |
| L3 | Safe `string_view` usage | Storing `string_view` as a class member or beyond the referred-to value's lifetime | Store `std::string` for owned data; `string_view` for temporary borrows only |

### 2D. Integer Safety

| ID | Rule | What to look for | Fix |
|----|------|-----------------|-----|
| I1 | No implicit narrowing | `int` → `short`, `size_t` → `int`, `double` → `float` without explicit cast | `static_cast` with range check, or use the correct type throughout |
| I2 | No signed/unsigned mismatch | Comparing `int` with `size_t`/`unsigned`, loop counter type mismatch | Use consistent signedness; `std::ssize()` for signed container size (C++20) |

### 2E. Error Handling

| ID | Rule | What to look for | Fix |
|----|------|-----------------|-----|
| H1 | No ignored return values | Discarded return from functions indicating failure | Check the return value; add `[[nodiscard]]` to the function |
| H2 | No empty catch blocks | `catch (...) {}` or `catch (const std::exception&) {}` with no body | Log, rethrow, or handle meaningfully |
| H3 | Consistent error strategy | Mixing exceptions and error codes within a single module | Choose one strategy per module boundary |

---

## Tier 3 — Quality/Modern Practices

Recommended improvements. Not blocking but improve maintainability and correctness.

### 3A. Modern C++ Opportunities

| ID | Rule | What to look for | Fix |
|----|------|-----------------|-----|
| N1 | Structured bindings (C++17) | `auto p = m.find(k); p->first; p->second` | `auto [key, val] = *it;` |
| N2 | `std::optional` | Sentinel values (`-1`, `nullptr`, `""`) representing "no value" | `std::optional<T>` |
| N3 | `if constexpr` (C++17) | Runtime `if` on type traits, `enable_if` in function bodies | `if constexpr (std::is_integral_v<T>)` |
| N4 | Concepts over SFINAE (C++20) | `std::enable_if_t`, `static_assert` on type traits for function constraints | `template<std::integral T>` or `requires` clause |
| N5 | Range algorithms (C++20) | Raw loops that could use `std::ranges::*` or `std::views::*` | `std::ranges::sort`, `std::views::filter \| std::views::transform` |
| N6 | `std::format` (C++20) | `printf`, `sprintf`, `std::stringstream` for formatting strings | `std::format("{}", value)` or `fmt::format` |
| N7 | `std::expected` (C++23) | Functions returning error codes as out-params alongside `bool` return | `std::expected<T, ErrorCode>` with monadic chaining |

### 3B. Performance

| ID | Rule | What to look for | Fix |
|----|------|-----------------|-----|
| P1 | Avoid unnecessary copies | Passing large objects by value, returning `const std::string`, copy in range-for | `const T&` for input params; `auto&` in range-for; don't return `const` values |
| P2 | Reserve before push loop | `push_back` in a loop with a known count, no `reserve` | `vec.reserve(n)` before the loop |
| P3 | Appropriate container | `std::list` for random access; `std::map` where `unordered_map` would do; `vector<bool>` | Choose container to match access pattern; prefer `std::vector` by default |
| P4 | Enable move semantics | Last use of an expensive object passed/returned by value without `std::move` | `std::move` on last use; avoid `const` return values (prevents move) |

### 3C. Attributes & Qualifiers

| ID | Rule | What to look for | Fix |
|----|------|-----------------|-----|
| A1 | `[[nodiscard]]` | Functions where ignoring the return value is always a bug | Add `[[nodiscard]]` to the function declaration |
| A2 | `override` | Virtual overrides without `override`; redundant `virtual` on overrides | Add `override`; remove redundant `virtual` |
| A3 | `explicit` constructors | Single-argument constructors without `explicit` (unintentional implicit conversions) | Add `explicit` |
| A4 | `noexcept` on move ops | Move constructor, move assignment, `swap` without `noexcept` | Mark `noexcept`; required for `std::vector` reallocation to use moves |
| A5 | `constexpr` | Functions computable at compile time not marked `constexpr` | Add `constexpr` where applicable |

---

## Tier 4 — Style

Cosmetic improvements. Report at most 5 per file. Skip entirely if Tier 1 issues are present.

| ID | Rule | What to look for | Fix |
|----|------|-----------------|-----|
| S1 | Meaningful names | Single-letter variables (except `i`/`j` loop indices), opaque abbreviations | Descriptive names that express intent |
| S2 | No magic numbers | Unexplained numeric/string literals | Named `constexpr` constant or `enum` value |
| S3 | Function length | Functions over ~50 lines | Extract into well-named helper functions |
| S4 | No commented-out code | `// Widget* w = new Widget();` blocks left in | Delete dead code; it lives in git history |
| S5 | Comment quality | Comments restating the code (`// increment i`); missing comments for non-obvious logic | Comments explain *why*, not *what*; remove obvious ones |
| S6 | `using namespace std;` in headers | Namespace pollution in any header file | Explicit `std::` prefix; `using` in `.cpp` files only |
| S7 | C-style casts | `(int)x`, `(void*)p` | `static_cast<int>(x)`, `reinterpret_cast`, etc. |

---

## Review Decision Guide

When uncertain about a finding's tier:

- **Tier 1 only if**: The issue will definitely cause a bug, crash, or UB in real usage.
- **Tier 2**: It's a clear design problem or likely correctness issue but not certain to manifest.
- **Tier 3**: There's a demonstrably better modern approach.
- **Tier 4**: It's purely stylistic with no correctness impact.

When in doubt, err conservative (Tier 2 over Tier 1). Note the uncertainty in the finding.
