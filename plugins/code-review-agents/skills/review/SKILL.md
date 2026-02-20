---
name: review
description: Per-language code review agent. Produces structured reviews with tiered severity findings and actionable suggestions. Use when asked to review code, check a file, or audit a directory.
argument-hint: <language> [target] [--fix] [--tier 1|2|3|4] [--tool]
allowed-tools: Read, Bash, Glob, Grep, Edit
---

# Code Review Agent

Multi-language code review agent. Currently supports: **C++**.

## Usage

```
/review cpp <file.cpp>         — review a single file
/review cpp src/               — review all C++ files in a directory
/review cpp staged             — review git staged changes
/review cpp HEAD~3             — review changes in the last 3 commits
/review cpp main..HEAD         — review diff between branches
/review cpp <target> --fix     — review and offer to apply fixes
/review cpp <target> --tier 1  — only show blocking (Tier 1) issues
/review cpp <target> --tool    — also run clang-tidy/cppcheck if available
```

## Target Resolution

Before reviewing, resolve the target:

1. **File path** (e.g., `src/main.cpp`): Read and review that file directly.
2. **Directory** (e.g., `src/`): Glob for `**/*.{cpp,cc,cxx,h,hpp,hxx}`. Cap at 20 files; if more exist, tell the user and ask them to narrow the scope.
3. **`staged`**: Run `git diff --cached --name-only` filtered to C++ extensions, then `git diff --cached` for diff content. Review the diff.
4. **Git ref** (e.g., `HEAD~3`, `main..HEAD`): Run `git diff <ref> --name-only` filtered to C++ extensions, then `git diff <ref>` for diff content. Review the diff.
5. **No target provided**: Check for staged C++ changes (`git diff --cached --name-only`). If found, review those. If not, ask the user for a target.

## Language Dispatch

Based on the `<language>` argument:

- `cpp` or `c++` → load [references/cpp.md](references/cpp.md) as the review checklist.
- Any other value → report: "Language `<language>` is not yet supported. Available: `cpp`."

## Review Process

For each file or diff chunk:

1. **Acquire the code**: Use Read for files; parse diff output for staged/ref targets.
2. **Apply the language checklist** from the reference file. Work through every applicable tier and rule.
3. **Classify each finding** into the correct tier (1–4). When uncertain, use Tier 2, not Tier 1.
4. **For each finding**, record:
   - Location (file:line or diff hunk reference)
   - The problematic code snippet
   - What is wrong and why
   - A concrete fix with a before/after code example
5. **Produce output** using the format defined in [references/review-format.md](references/review-format.md).

Do not report Tier 4 (style) findings when Tier 1 findings are present — focus on what matters most.

## Static Analysis Integration (`--tool`)

When `--tool` is passed:

1. Check if `clang-tidy` is available: `which clang-tidy`
2. If available, run:
   ```
   clang-tidy <file> --checks=-*,bugprone-*,modernize-*,readability-*,performance-*,cppcoreguidelines-* -- -std=c++20 2>&1
   ```
3. Check if `cppcheck` is available: `which cppcheck`
4. If available, run:
   ```
   cppcheck --enable=all --suppress=missingIncludeSystem <file> 2>&1
   ```
5. Integrate tool findings into the appropriate tiers. If neither tool is available, suggest installation commands and note this in the Static Analysis section.

For recommended check sets, see [references/clang-tidy-checks.md](references/clang-tidy-checks.md).

## Fix Mode (`--fix`)

When `--fix` is passed:

1. Complete the full review first.
2. For each Tier 1 and Tier 2 finding that has a concrete, safe fix:
   - Ask: "Apply fix for #N (`<short description>`)? (y/n/all)"
   - `y`: Apply using the Edit tool.
   - `n`: Skip.
   - `all`: Apply all remaining fixes without further prompting.
3. After applying fixes, re-read the modified sections and confirm no new issues were introduced.

## Tier Filtering (`--tier N`)

When `--tier N` is passed, only report findings at severity N or higher (more critical).

- `--tier 1`: Tier 1 only (blocking bugs/safety)
- `--tier 2`: Tiers 1–2
- `--tier 3`: Tiers 1–3
- `--tier 4` or omitted: All tiers (default)

## Multi-File Reviews

When reviewing a directory or multiple files from a diff:

1. Review each file individually.
2. After all individual reviews, produce a **Cross-File Summary** noting:
   - Recurring patterns (e.g., "raw `new` used in 4 of 6 files")
   - Architectural concerns visible across files
   - Inconsistencies between files
3. Provide a single overall verdict for the full scope.

## Behavioral Rules

- Be specific. Never write "consider using RAII" — show the exact lines to change.
- Every finding must include a before/after code example.
- When reviewing diffs, focus on changed lines but flag pre-existing issues in surrounding context that directly interact with the changes.
- Count findings per tier. If zero findings across all tiers, say so explicitly: "No issues found."
- Limit Tier 4 findings to 5 items max per file to avoid overwhelming the developer.
