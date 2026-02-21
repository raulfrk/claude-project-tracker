---
name: review-cpp
description: Comprehensive C++ code review using 10 specialized parallel agents. Use when the user invokes /review-cpp, asks for a C++ code review, wants to review C++ code quality, or says things like "review my C++ code", "C++ review", "check my C++ for issues", "audit the C++ code".
argument-hint: "[path] [--full]"
allowed-tools: Read, Write, Bash, Glob, Grep, Task
---

# C++ Code Review Skill

You are a review pipeline orchestrator. When invoked, you run 10 specialized C++ review agents in parallel, then consolidate their findings and present them to the user interactively.

---

## Phase 0: Argument Parsing

Parse `$ARGUMENTS`:
- Extract any path argument (first non-flag token)
- Detect `--full` flag (full codebase review instead of diff)

---

## Phase 1: Target Detection

Determine `{target_dir}`:

1. If a path was provided as an argument, use it. Verify with `test -d <path>`. If missing, report error and stop.
2. If no path provided, check for a loaded project by looking for a `CLAUDE.md` or `CLAUDE.local.md` in the current working directory or parent directories (search up to 3 levels). If found, use that directory as `{target_dir}`.
3. If neither (1) nor (2) yields a path, ask the user: "Which directory should I review? Provide a path to a C++ project."

After resolving `{target_dir}`, verify it contains C++ files:

```bash
find {target_dir} -maxdepth 5 \( -name "*.cpp" -o -name "*.cc" -o -name "*.cxx" -o -name "*.h" -o -name "*.hpp" -o -name "*.hxx" \) -print -quit
```

If no C++ files found, report: "No C++ files found at `{target_dir}`." and stop.

---

## Phase 2: Scope Determination

Generate a session ID:

```bash
date +%Y%m%d-%H%M%S
```

Store as `{session_id}`. The session directory is `/tmp/review-cpp-{session_id}/`.

Create it:

```bash
mkdir -p /tmp/review-cpp-{session_id}
```

**Check if git repo:**

```bash
git -C {target_dir} rev-parse --show-toplevel 2>&1
```

If this fails, warn the user: "Target is not a git repository — switching to full review mode." and treat as `--full`.

**Diff mode** (default, no `--full` and git repo exists):

1. Check for uncommitted changes:
   ```bash
   git -C {target_dir} diff --name-only && git -C {target_dir} diff --cached --name-only
   ```
2. Filter for C++ extensions (`.cpp`, `.cc`, `.cxx`, `.h`, `.hpp`, `.hxx`, `.C`, `.H`).
3. If C++ files found in uncommitted changes:
   - Run `git -C {target_dir} diff && git -C {target_dir} diff --cached` and write combined output to `/tmp/review-cpp-{session_id}/diff.txt`
   - Write filtered file list to `/tmp/review-cpp-{session_id}/changed-files.txt`
4. Else check latest commit:
   ```bash
   git -C {target_dir} diff HEAD~1 --name-only
   ```
   - Filter for C++ files. If found, write `git -C {target_dir} diff HEAD~1` to `diff.txt` and file list to `changed-files.txt`.
5. If still no C++ files in any diff: report "No recent C++ changes found. Use `--full` to review the entire codebase." and stop.

**Full mode** (`--full`):

Use Glob to find all C++ files under `{target_dir}` and write to `/tmp/review-cpp-{session_id}/changed-files.txt`. No diff file is generated.

**Report scope to user:**
- Diff mode: "Reviewing N changed C++ file(s) (uncommitted changes / latest commit)."
- Full mode: "Full review of N C++ file(s) in `{target_dir}`."

---

## Phase 3: Launch 10 Review Agents in Parallel

**In a single message, launch all 10 agents using 10 parallel Task tool calls.**

Each agent call uses `subagent_type` matching the agent name (e.g., `review-cpp:architect-reviewer`). Provide each agent a prompt following this template:

```
You are the [AGENT NAME] for a C++ code review pipeline.

Review target: {target_dir}
Review mode: {diff | full}
[DIFF MODE ONLY] Diff file (read this to see what changed): /tmp/review-cpp-{session_id}/diff.txt
Changed C++ files (review only these): /tmp/review-cpp-{session_id}/changed-files.txt
Your report output path: /tmp/review-cpp-{session_id}/[agent-name].md

Instructions:
1. Read the changed-files.txt to get the list of files to review.
2. [DIFF MODE] Read diff.txt to understand what changed. Focus your review on the changed lines and their surrounding context.
   [FULL MODE] Read each file in the changed-files list directly using Read and Glob.
3. Apply your specialized review lens (defined in your system prompt).
4. Write your findings to the report output path using the standardized format.

Report format reference: read the format from the skill's references directory if you need it.

If you find no issues in your domain, write a report stating "No issues found" with a brief summary of what you checked.
```

**The 10 agents and their report filenames:**

| Agent | Subagent type | Report file |
|-------|--------------|-------------|
| Architect | `review-cpp:architect-reviewer` | `architect-reviewer.md` |
| C++ Specialist | `review-cpp:cpp-specialist-reviewer` | `cpp-specialist-reviewer.md` |
| Low Latency | `review-cpp:low-latency-reviewer` | `low-latency-reviewer.md` |
| Devil's Advocate | `review-cpp:devils-advocate-reviewer` | `devils-advocate-reviewer.md` |
| CI/CD | `review-cpp:cicd-reviewer` | `cicd-reviewer.md` |
| Complexity | `review-cpp:complexity-reviewer` | `complexity-reviewer.md` |
| Memory Safety | `review-cpp:memory-safety-reviewer` | `memory-safety-reviewer.md` |
| Concurrency | `review-cpp:concurrency-reviewer` | `concurrency-reviewer.md` |
| Security | `review-cpp:security-reviewer` | `security-reviewer.md` |
| Test Quality | `review-cpp:test-quality-reviewer` | `test-quality-reviewer.md` |

---

## Phase 4: Wait and Check

After all 10 Task calls complete, check which reports were produced:

```bash
ls /tmp/review-cpp-{session_id}/
```

Note any missing agent reports. If an agent failed, warn: "Warning: `{agent-name}` did not complete — its domain will be absent from the consolidated report."

If all agents failed, report: "All review agents failed. Please try again." and stop.

---

## Phase 5: Consolidation

Launch the consolidation agent:

```
Consolidate the C++ review reports in /tmp/review-cpp-{session_id}/.

Reports present: [list files that exist]
Missing reports (agents that failed): [list missing agents, or "none"]

Write the consolidated report to: /tmp/review-cpp-{session_id}/consolidated-report.md
```

Use subagent_type `review-cpp:consolidation-agent`.

---

## Phase 6: Interactive Presentation

Read `/tmp/review-cpp-{session_id}/consolidated-report.md`.

Present findings one at a time, in severity order (Critical → High → Medium → Low). Discussion Points from the devil's advocate are shown after all severity findings.

For each finding, display:

```
────────────────────────────────────────
Finding N of TOTAL  [SEVERITY]
────────────────────────────────────────
File:        path/to/file.cpp (lines X–Y)
Category:    [category]
Agents:      [comma-separated agents that flagged this]
Description: [description]

Suggestion:
[suggestion text + code snippet if present]

Recommendation: [ADOPT / REVIEW / DEFER]
[1-sentence rationale for the recommendation]

Action? (adopt / skip / defer)
```

**Recommendation logic:**
- `ADOPT` — Critical or High severity, or flagged by 2+ agents
- `REVIEW` — Medium severity, nuanced tradeoff, or devil's advocate-only
- `DEFER` — Low severity, stylistic, or highly context-dependent

**On user response:**
- **adopt**: Apply the suggested change using Edit or Write. Confirm: "Applied." Then move to next finding.
- **skip**: Move to next finding without applying.
- **defer**: Add to deferred list. Move to next finding.
- If a change fails to apply: "Could not apply automatically. Suggested fix:\n[suggestion]\nApply manually, then continue." Move to next finding.

After all findings are presented:

```
────────────────────────────────────────
Review Complete
────────────────────────────────────────
Applied:  X
Skipped:  Y
Deferred: Z

[If Z > 0:]
Deferred items:
- [Finding summary, file, severity]
  ...

Reports saved to: /tmp/review-cpp-{session_id}/
```

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Target dir doesn't exist | Report error, stop |
| No C++ files in target | Report "no C++ files found", stop |
| Not a git repo (diff mode) | Warn, switch to full mode |
| No changed C++ files in diff | Report "no recent changes, use --full", stop |
| Agent timeout/crash | Continue, note absence in consolidation |
| All agents fail | Report error, stop |
| Consolidation fails | Read individual reports directly, present without deduplication |
| Change fails to apply | Show suggestion, ask user to apply manually, continue |
| `/tmp` write fails | Report error: "Could not write to /tmp — check disk space" |
