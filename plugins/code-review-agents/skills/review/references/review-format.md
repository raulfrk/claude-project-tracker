# Review Output Format

All language review agents produce output in this exact format for consistency.

---

## Header

```
## Code Review: <target>

**Language**: <language>
**Files reviewed**: <N>
**Scope**: file | directory | staged | diff (<ref>)
```

---

## Summary Block

```
### Summary

<1–3 sentences: overall quality, most critical issue if any, general impression.>

**Findings**: T1: <n> | T2: <n> | T3: <n> | T4: <n>
**Verdict**: <PASS | PASS WITH COMMENTS | NEEDS CHANGES | BLOCK MERGE>
```

**Verdict logic:**

| Verdict | Condition |
|---------|-----------|
| BLOCK MERGE | Any Tier 1 finding |
| NEEDS CHANGES | No Tier 1, but Tier 2 findings exist |
| PASS WITH COMMENTS | No Tier 1 or 2, but Tier 3/4 findings exist |
| PASS | Zero findings |

---

## Findings Sections

One section per tier that has findings. Omit empty tiers entirely.

```
### Tier <N> — <Tier Name> [BLOCKING] (only add [BLOCKING] for Tier 1)

#### <N>.<M> <Short title> (`file.cpp:line`)

**Issue**: <What is wrong and why — 1–2 sentences.>

**Current**:
```cpp
// problematic code here
```

**Fix**:
```cpp
// corrected code here
```

**Why**: <Brief explanation referencing the relevant guideline if applicable. E.g., "[CG R.11] Avoid calling `new` and `delete` explicitly.">
```

---

## Static Analysis Section (include only when `--tool` was used)

```
### Static Analysis

**Tools run**: <list, or "none — use --tool to enable">

<Findings from tools integrated into tier sections above, or listed here if not tier-mappable.>

**Commands to run manually**:
```bash
clang-tidy <file> --checks=<checks> -- -std=c++20
cppcheck --enable=all <file>
```
```

---

## Cross-File Summary (multi-file reviews only)

```
### Cross-File Summary

- **<Pattern name>**: <description> — affects `file1.cpp`, `file2.cpp`
- **<Pattern name>**: <description> — affects all files
```

---

## Verdict Block (at the end, always present)

```
### Verdict

**<VERDICT>**

<1–2 sentence justification. For BLOCK MERGE: list the blocking issue numbers, e.g., "Issues #1.1 and #1.3 must be resolved before merge.">
```

---

## Tier Names Reference

| Tier | Name | Verdict Impact |
|------|------|----------------|
| 1 | Bugs/Safety | BLOCK MERGE |
| 2 | Correctness/Design | NEEDS CHANGES |
| 3 | Quality/Modern Practices | PASS WITH COMMENTS |
| 4 | Style | PASS WITH COMMENTS |
