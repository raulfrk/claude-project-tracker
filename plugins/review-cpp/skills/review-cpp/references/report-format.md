# Agent Report Format

Every review agent MUST write its report using this exact structure. Do not deviate.

---

## Template

```markdown
# [Agent Name] Review Report

## Summary

[1–2 sentence summary. State how many issues found and their severity breakdown.
If no issues found, state that clearly and briefly describe what was checked.]

## Findings

### Finding 1

- **Severity**: Critical | High | Medium | Low
- **File**: path/to/file.cpp
- **Line(s)**: 42–50  (use "N/A" for project-wide / architectural issues)
- **Category**: [category specific to this agent's domain — e.g., "Dangling Reference", "Lock Ordering", "CMake Best Practice"]
- **Description**: Clear explanation of what is wrong and why it matters. Be specific.
- **Suggestion**: Specific, actionable fix. Include code if it makes the fix clearer.

**Code snippet** (include when helpful):
`​`​`cpp
// Before
<problematic code>

// After
<suggested fix>
`​`​`

### Finding 2

...

## Positive Observations

[Optional section. Note specific things the code does well within this agent's domain.
Do not pad this section — only include genuine observations.]
```

---

## Severity Definitions

| Severity | Meaning |
|----------|---------|
| **Critical** | Will cause crashes, data corruption, security breaches, or undefined behavior. Must fix before shipping. |
| **High** | Significant correctness, performance, or maintainability issue. Should fix soon. |
| **Medium** | Code quality issue that increases technical debt. Fix when convenient. |
| **Low** | Minor improvement or style suggestion. Nice to have. |

---

## Rules

1. Every finding MUST have a `**File**` and `**Line(s)**`. Do not report vague findings without location.
2. Every finding MUST have a `**Suggestion**`. Do not just point out problems — provide solutions.
3. Rate severity honestly. Do not inflate severity to seem more thorough.
4. If you find no issues, write a Summary stating "No issues found in [domain]" and leave Findings empty.
5. Only report issues in files within scope. In diff mode: only changed files. In full mode: all C++ files under the target.
6. Separate findings clearly. Do not combine multiple distinct issues into one finding.
7. Code snippets are optional but encouraged for anything non-trivial to explain in words.
