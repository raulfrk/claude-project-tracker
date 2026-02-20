# claude-project-tracker

A Claude Code plugin for local project management with YAML indexes, per-project tracking files, learning mode, and optional Todoist integration.

## What It Does

- **Unified project index**: All projects tracked in `~/projects/tracking/active-projects.yaml`
- **Per-project files**: Each project gets `NOTES.md` and `TODOS.md` in `~/projects/tracking/<name>/`
- **CLAUDE.md auto-sync**: Project context file in your repo, auto-updated by `/project save`
- **Todoist integration** (optional): Bidirectional task sync between local TODOS.md and Todoist
- **Learning mode**: Tracks concepts taught per-project with mastery levels, adjusts explanations accordingly
- **Fuzzy name matching**: All commands use case-insensitive partial matching on project names
- **YAML/JSON validation hook**: Validates syntax after every file edit

## Prerequisites

- Claude Code CLI
- `zoxide` (for frecency-based directory tracking) — `apt install zoxide` or `brew install zoxide`
- `jq` (for the validation hook) — `apt install jq` or `brew install jq`
- Python 3 with `pyyaml` — `pip install pyyaml`
- **Optional**: [Todoist MCP server](https://github.com/Doist/todoist-mcp) for Todoist integration

## Installation

```bash
# Add the plugin marketplace
/plugin marketplace add your-username/claude-project-tracker

# Install the plugin
/plugin install project-tracker@claude-project-tracker
```

Or clone and use locally:

```bash
git clone https://github.com/your-username/claude-project-tracker.git
claude --plugin-dir ~/path/to/claude-project-tracker
```

## Recommended Permissions

Add to your `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(zoxide add *)",
      "Bash(zoxide remove *)",
      "Bash(git log *)",
      "Bash(git remote *)",
      "Bash(mkdir -p ~/projects/**)",
      "Bash(mv ~/projects/tracking/**)",
      "Write(//home/<your-username>/projects/**)"
    ]
  }
}
```

## Quick Start

```
/project-tracker:project list
/project-tracker:project new my-app
/project-tracker:project load my-app
/project-tracker:project save my-app
```

## Data Directory Conventions

```
~/projects/
├── tracking/
│   ├── active-projects.yaml        # Project index
│   ├── archived-projects.yaml      # Archived projects
│   └── <project-name>/
│       ├── NOTES.md                # Notes, decisions, session log
│       ├── TODOS.md                # Task list (syncs with Todoist)
│       ├── session-log-archive.md  # Older session log entries (auto-created)
│       └── learning/               # Learning mode data (optional)
│           ├── learning.yaml
│           └── <topic-slug>.md
└── <project-name>/                 # Default content path (if no repo)
```

## Command Reference

| Command | Description |
|---------|-------------|
| `/project list` | Show all active projects in a table |
| `/project new <name>` | Create a new project with guided setup |
| `/project map <path>` | Map an existing directory into the tracker |
| `/project load <name>` | Load project context into the session |
| `/project save <name>` | Sync session knowledge back to tracking files |
| `/project archive <name>` | Move a project to archived status |
| `/project unarchive <name>` | Restore an archived project to active |
| `/project sync <name> [--dry-run]` | Bidirectional Todoist task sync |
| `/project status <name>` | Quick summary (TODO count, last session, Todoist) |
| `/project search <query>` | Search across all projects' NOTES and TODOS |
| `/project link-todoist <name>` | Link an existing project to a Todoist project |
| `/project rename <old> <new>` | Rename a project across all locations |
| `/project edit <name>` | Interactively update project metadata |
| `/project mode <name> [mode]` | Get or set learning/standard mode |

## Learning Mode

Enable per-project with `/project mode <name> learning`. When active:

- Claude explains concepts before using them (depth based on your tracked mastery)
- Mastery is assessed at save time and stored in `learning/learning.yaml`
- Each topic gets its own `.md` file with explanation, examples, and review notes
- Mastery levels: `none` → `emerging` → `developing` → `solid` → `mastered`

## Todoist Integration

Todoist is **optional**. When linked:

- `/project new` can create a paired Todoist project
- `/project sync` bidirectionally reconciles tasks
- `/project load` shows live open tasks from Todoist
- `/project save` offers to sync at session end

Projects without Todoist work fully with local TODOS.md only.

## License

MIT
