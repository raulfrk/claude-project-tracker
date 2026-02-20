# claude-project-tracker

A Claude Code plugin marketplace with productivity and code quality plugins.

## Plugins

| Plugin | Description | Install |
|--------|-------------|---------|
| `project-tracker` | Local project management with YAML indexes, tracking files, learning mode, and Todoist integration | `claude plugin install project-tracker@claude-project-tracker` |
| `code-review-agents` | Per-language code review agents with tiered severity findings and actionable suggestions (C++ supported) | `claude plugin install code-review-agents@claude-project-tracker` |

---

## `project-tracker`

### What It Does

- **Unified project index**: All projects tracked in `~/projects/tracking/active-projects.yaml`
- **Per-project files**: Each project gets `NOTES.md` and `TODOS.md` in `~/projects/tracking/<name>/`
- **CLAUDE.md auto-sync**: Project context file in your repo, auto-updated by `/project save`
- **Todoist integration** (optional): Bidirectional task sync between local TODOS.md and Todoist
- **Learning mode**: Tracks concepts taught per-project with mastery levels, adjusts explanations accordingly
- **Fuzzy name matching**: All commands use case-insensitive partial matching on project names

### Prerequisites

- Claude Code CLI
- `zoxide` — `apt install zoxide` or `brew install zoxide`
- `jq` — `apt install jq` or `brew install jq`
- Python 3 with `pyyaml` — `pip install pyyaml`
- **Optional**: [Todoist MCP server](https://github.com/Doist/todoist-mcp)

### Command Reference

| Command | Description |
|---------|-------------|
| `/project list` | Show all active projects |
| `/project new <name>` | Create a new project with guided setup |
| `/project map <path>` | Map an existing directory into the tracker |
| `/project load <name>` | Load project context into the session |
| `/project save <name>` | Sync session knowledge back to tracking files |
| `/project archive <name>` | Move a project to archived status |
| `/project unarchive <name>` | Restore an archived project |
| `/project sync <name> [--dry-run]` | Bidirectional Todoist task sync |
| `/project status <name>` | Quick summary (TODO count, last session) |
| `/project search <query>` | Search across all projects' NOTES and TODOS |
| `/project link-todoist <name>` | Link a project to Todoist |
| `/project rename <old> <new>` | Rename across all locations |
| `/project edit <name>` | Update project metadata interactively |
| `/project mode <name> [mode]` | Get or set learning/standard/active-learning mode |

### Recommended Permissions

```json
{
  "permissions": {
    "allow": [
      "Bash(zoxide add *)",
      "Bash(zoxide remove *)",
      "Bash(test -d //home/<you>/**)",
      "Bash(git -C //home/<you>/**)",
      "Bash(mkdir -p ~/projects/**)",
      "Write(//home/<you>/projects/**)"
    ]
  }
}
```

---

## `code-review-agents`

### What It Does

- Structured code reviews with **4 severity tiers**: Bugs/Safety → Correctness → Quality → Style
- **Actionable findings**: Every issue includes a before/after code example
- **Git-aware**: Review staged changes, diffs between refs, or specific files/directories
- **Fix mode**: Offer to apply fixes interactively
- **Tool integration**: Optionally run `clang-tidy` and `cppcheck` and integrate their output
- **Extensible**: New languages are added as reference files — no structural changes needed

### Languages

| Language | Status |
|----------|--------|
| C++ | ✅ Supported |
| Rust | Planned |
| Python | Planned |
| Go | Planned |

### Usage

```
/review cpp <file.cpp>          — review a single file
/review cpp src/                — review all C++ files in a directory
/review cpp staged              — review git staged changes
/review cpp HEAD~3              — review last 3 commits
/review cpp main..HEAD          — review branch diff
/review cpp <target> --fix      — review and offer to apply fixes
/review cpp <target> --tier 1   — only show blocking (Tier 1) issues
/review cpp <target> --tool     — also run clang-tidy/cppcheck
```

### Review Tiers

| Tier | Name | Verdict |
|------|------|---------|
| 1 | Bugs/Safety | BLOCK MERGE |
| 2 | Correctness/Design | NEEDS CHANGES |
| 3 | Quality/Modern Practices | PASS WITH COMMENTS |
| 4 | Style | PASS WITH COMMENTS |

### Prerequisites

- Claude Code CLI
- `jq` (for the post-edit hook)
- **Optional**: `clang-tidy`, `cppcheck` (for `--tool` mode)

---

## License

MIT
