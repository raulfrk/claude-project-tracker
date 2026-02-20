# Recommended clang-tidy Checks

Use these when running `clang-tidy` via `--tool`. Grouped by tier alignment.

## Full Command Template

```bash
clang-tidy <file> \
  --checks=-*,bugprone-*,modernize-*,readability-*,performance-*,cppcoreguidelines-* \
  -- -std=c++20 -I<include-paths>
```

Or a targeted subset by tier:

```bash
# Tier 1+2 only (fastest, use in CI)
clang-tidy <file> \
  --checks=-*,bugprone-*,cppcoreguidelines-owning-memory,cppcoreguidelines-no-malloc,cppcoreguidelines-special-member-functions \
  -- -std=c++20
```

---

## Tier 1 — Bugs/Safety

```
bugprone-dangling-handle
bugprone-use-after-move
bugprone-undefined-memory-manipulation
bugprone-unhandled-self-assignment
bugprone-infinite-loop
bugprone-signed-char-misuse
bugprone-incorrect-roundings
cppcoreguidelines-owning-memory
cppcoreguidelines-no-malloc
cppcoreguidelines-pro-bounds-pointer-arithmetic
cppcoreguidelines-pro-type-reinterpret-cast
```

## Tier 2 — Correctness/Design

```
bugprone-exception-escape
bugprone-narrowing-conversions
cppcoreguidelines-special-member-functions
cppcoreguidelines-slicing
misc-non-private-member-variables-in-classes
misc-unconventional-assign-operator
```

## Tier 3 — Quality/Modern Practices

```
modernize-avoid-bind
modernize-avoid-c-arrays
modernize-deprecated-headers
modernize-loop-convert
modernize-make-shared
modernize-make-unique
modernize-pass-by-value
modernize-use-auto
modernize-use-default-member-init
modernize-use-emplace
modernize-use-nodiscard
modernize-use-noexcept
modernize-use-nullptr
modernize-use-override
modernize-use-using
performance-for-range-copy
performance-inefficient-string-concatenation
performance-move-const-arg
performance-noexcept-move-constructor
performance-unnecessary-copy-initialization
performance-unnecessary-value-param
readability-const-return-type
readability-container-size-empty
```

## Tier 4 — Style

```
readability-braces-around-statements
readability-function-cognitive-complexity
readability-identifier-naming
readability-magic-numbers
readability-redundant-string-cstr
readability-simplify-boolean-expr
```

---

## cppcheck Command

```bash
cppcheck --enable=all --suppress=missingIncludeSystem --std=c++20 <file-or-dir>
```

Key flags:
- `--enable=all` — enables all checks (performance, portability, style, unusedFunction, etc.)
- `--suppress=missingIncludeSystem` — silences noise from missing system headers
- `--std=c++20` — sets C++ standard
