---
name: project
description: Manage projects with local tracking files and Todoist integration. Use when listing projects, creating a new project, archiving a project, or loading project context.
argument-hint: [list|new|map|archive|unarchive|load|save|sync|status|search|link-todoist|rename|edit|mode] [project-name-or-path] [mode]
allowed-tools: Read, Write, Bash, Glob, Grep
---

# Project Management Skill

Manage code, personal, documentation, and learning projects with local YAML indexes, per-project tracking files, and optional Todoist integration.

## Data Locations

- **Active index**: `~/projects/tracking/active-projects.yaml`
- **Archived index**: `~/projects/tracking/archived-projects.yaml`
- **Per-project tracking**: `~/projects/tracking/<project-name>/NOTES.md` and `TODOS.md`
- **Context file**: `<content_path>/CLAUDE.md` (auto-loaded by Claude on future sessions)

For YAML schemas, see [references/yaml-schemas.md](references/yaml-schemas.md).
For file templates, see [references/templates.md](references/templates.md).

---

## Global Behavior: Fuzzy Name Matching

When a `<name>` argument is provided and no exact match is found in the project index:

1. Compute partial/fuzzy matches against all project `name` fields (case-insensitive substring and prefix match).
2. If exactly one close match exists, suggest it: "Did you mean **<match>**? (y/n)"
3. If multiple close matches exist, list them and ask the user to choose.
4. If no match found at all, report: "No project named '<name>' found."

Apply fuzzy matching to all commands that accept a `<name>` argument.

---

## Commands

### `/project list`

1. Check if `~/projects/tracking/active-projects.yaml` exists. If not, report "No projects yet."
2. Read `active-projects.yaml` and display a formatted table:

   | Name | Display Name | Type | Mode | Created | Last Session | Todoist |
   |------|-------------|------|------|---------|--------------|---------|
   | ... | ... | ... | standard / learning | ... | ... | linked / — |

3. Check if `~/projects/tracking/archived-projects.yaml` exists. If so, read it and mention the count: "X archived project(s). Use `/project load <name>` to view archived."

---

### `/project new <name>`

1. Normalize the provided name to kebab-case (lowercase, spaces→hyphens, strip special chars).
2. Check `active-projects.yaml` and `archived-projects.yaml` for duplicates. Abort if found, tell the user.
3. **Ask the user** (if not already provided via arguments) for:
   - **Project type**: `code`, `personal`, `documentation`, or `learning`
   - **Display name**: Human-readable name (default: title-case of the kebab name)
   - **Description**: Short one-line description (optional)
   - **Overview**: What is this project and what problem does it solve? (1–3 sentences, optional)
   - **Content directory**: Where the actual project files live (e.g., `~/repos/my-app`). Leave blank to default to `~/projects/<name>`. Enter "none" to skip content directory entirely.
   - **Todoist integration**: Create a corresponding Todoist project? (yes/no)

4. Resolve content path:
   - If user provided a path → use it.
   - If user left blank → use `~/projects/<name>` as the default.
   - If user entered "none" → `content_path` is `null`; skip CLAUDE.md creation.

5. **Content path validation**: If `content_path` is not null, check `active-projects.yaml` and `archived-projects.yaml` for any existing project with the same `content_path`. If a duplicate is found, warn: "Path `<path>` is already used by project **<other-name>**. Proceed anyway? (y/n)"

6. Create the tracking directory: `~/projects/tracking/<name>/`
7. Create `NOTES.md` from the NOTES template in [references/templates.md](references/templates.md), inserting the overview text into the Overview section if provided.
8. Create `TODOS.md` from the TODOS template in [references/templates.md](references/templates.md).
9. If `content_path` is not null, create it: `mkdir -p <content_path>` and create `CLAUDE.md` from the CLAUDE.md template in [references/templates.md](references/templates.md).
10. If Todoist: call `add-projects` with `name: <display_name>`. Save the returned project ID.
11. Append the new entry to `~/projects/tracking/active-projects.yaml` (create the file with `projects: []` header if it doesn't exist). Set `last_session: null`.

    Use schema from [references/yaml-schemas.md](references/yaml-schemas.md).

12. If `content_path` is not null, run `for i in $(seq 100); do zoxide add <content_path>; done` to register it with high frecency.

13. Confirm: "Created project **<display_name>**. Tracking at `~/projects/tracking/<name>/`."

---

### `/project map <path>`

Maps an existing content directory (e.g., a repo), extracts useful insights, and sets up project tracking files and `CLAUDE.md` for it.

1. **Resolve the path**: Expand `~` and resolve the provided `<path>` to an absolute path. If it does not exist, report an error and stop.

2. **Explore the directory** using Glob and Read to extract:
   - **README**: Read `README.md` (or `README.rst`, `README.txt`) if present — use it for description and overview.
   - **Tech stack**: Detect from files present:
     - `package.json` → Node.js/JS/TS (read it for name, description, scripts, dependencies)
     - `pyproject.toml` / `requirements.txt` / `setup.py` → Python
     - `go.mod` → Go
     - `Cargo.toml` → Rust
     - `pom.xml` / `build.gradle` → Java/JVM
     - `Gemfile` → Ruby
     - `Dockerfile` / `docker-compose.yml` → containerized
     - `.github/workflows/` → GitHub Actions CI/CD
   - **Project structure**: Top-level directories and notable files (src, lib, tests, docs, etc.)
   - **Git context**: Run `git log --oneline -10` to see recent commit history (if it's a git repo). Run `git remote get-url origin` to capture the remote URL.
   - **Existing CLAUDE.md**: If one already exists at the root, read it for any recorded context.

3. **Synthesize findings** into:
   - A one-line **description** (from README title/first sentence, or `package.json` description)
   - A 2–3 sentence **overview** (what the project does, its tech stack, its purpose)
   - A **Tech Stack** list
   - A **Key Files** list of notable files/dirs with brief notes
   - Any obvious **initial TODOs** (e.g., missing README, no tests directory, no CI config)

4. **Present a summary** of the findings to the user and ask for confirmation/corrections:
   - **Project name** (kebab-case, default: derived from directory name)
   - **Display name** (default: title-case of the directory name or README title)
   - **Project type**: `code`, `personal`, `documentation`, or `learning` (suggest `code` for repos)
   - **Description**: pre-filled from analysis, user can edit
   - **Todoist integration**: yes/no

5. Check `active-projects.yaml` and `archived-projects.yaml` for duplicates on the confirmed name. Abort if found.

6. **Content path validation**: Check if `<path>` is already used as `content_path` by another project in either YAML file. If so, warn: "Path `<path>` is already used by project **<other-name>**. Proceed anyway? (y/n)"

7. Create the tracking directory: `~/projects/tracking/<name>/`

8. Create `NOTES.md` using the NOTES template, enriched with:
   - Overview section populated from synthesis
   - A **Tech Stack** section listing detected languages, frameworks, and tools
   - A **Key Files** section listing important files/directories with brief notes
   - A **Links & References** entry for the git remote URL if found
   - Session log entry: "Mapped from `<path>`"

9. Create `TODOS.md` using the TODOS template, with any inferred initial todos pre-filled in Active (or empty if none).

10. Create/overwrite `CLAUDE.md` in `<path>` using the CLAUDE.md template, populated with description, overview, key decisions (if any), and active TODOs.

11. Append the new entry to `~/projects/tracking/active-projects.yaml` with `content_path: <path>` and `last_session: <today>`.

12. Run `for i in $(seq 100); do zoxide add <path>; done` to register the content path with high frecency.

13. If Todoist: call `add-projects` with `name: <display_name>`. Save the returned project ID.

14. Confirm: "Mapped **<display_name>** from `<path>`. Tracking at `~/projects/tracking/<name>/`."

---

### `/project archive <name>`

1. Read `active-projects.yaml`. If `<name>` not found, apply fuzzy matching. Report error and stop if no match.
2. Remove the entry from `active-projects.yaml`.
3. Add the entry to `archived-projects.yaml` (create file if needed), appending an `archived: "<today's date>"` field.
4. If the project's `content_path` is not null, run `zoxide remove <content_path>` to remove it from the frecency database.
5. Do **not** touch Todoist. Inform the user: "Todoist project was not archived — manage that manually if needed."
6. Confirm: "Archived **<name>**. Tracking files preserved at `~/projects/tracking/<name>/`."

---

### `/project unarchive <name>`

1. Read `archived-projects.yaml`. If `<name>` not found, apply fuzzy matching. Report error and stop if no match.
2. Remove the entry from `archived-projects.yaml`.
3. Remove the `archived` field from the entry.
4. Append the entry to `active-projects.yaml`.
5. If the project's `content_path` is not null, run `for i in $(seq 100); do zoxide add <content_path>; done` to re-register it with high frecency.
6. Confirm: "Unarchived **<name>**. Project is now active."

---

### `/project load <name>`

1. Search `active-projects.yaml` for `<name>`. If not found, also check `archived-projects.yaml` and note if archived. Apply fuzzy matching if no exact match.
2. Display project metadata (type, created, content path, description, last_session).
3. **Content path validation**: If `content_path` is not null, check that the directory exists (`Bash: test -d <content_path>`). If missing, warn: "Content path `<content_path>` does not exist. You may need to clone or restore the directory."
4. Read and display `~/projects/tracking/<name>/NOTES.md`.
5. Read and display `~/projects/tracking/<name>/TODOS.md`.
6. If `todoist_project_id` is set (not null), call `find-tasks` with `projectId: <todoist_project_id>` and display open tasks.
7. If `mode: learning` (or mode field absent defaults to `standard`):
   - Read `~/projects/tracking/<name>/learning/learning.yaml` if it exists.
   - If the file exists and has topics, display: "**Learning mode active.** X topic(s) tracked:" followed by a mastery breakdown (count per mastery level, e.g., `emerging: 2, developing: 1, solid: 1`).
   - If the file is empty or missing: "**Learning mode active.** No topics tracked yet."
   - Append to announcement: "Learning mode active — I'll teach as we build."
8. Announce: "Project **<name>** is now loaded. I'll offer to sync tasks to Todoist as we work."

---

### `/project save <name>`

Syncs the current session's knowledge back to all project files, keeping tracking files and `CLAUDE.md` up to date.

1. Read `active-projects.yaml` to find `<name>`. Apply fuzzy matching if no exact match. Report error and stop if not found.
2. **Content path validation**: If `content_path` is not null, check that the directory exists. Warn if missing (but continue saving tracking files).
3. Read the current `~/projects/tracking/<name>/NOTES.md` and `TODOS.md`.
4. Synthesize from the current conversation:
   - Any new decisions, context, or discoveries worth recording.
   - Any new or completed todos.
   - A brief session log entry for today.
5. **Update `NOTES.md`**:
   - Prepend a new `### <YYYY-MM-DD>` entry to the Session Log with bullet points summarizing what happened.
   - Update the Overview section if the project's purpose has been refined.
   - Append to Key Decisions if any architectural or process decisions were made.
   - **Session log rotation**: If the Session Log has more than 20 entries, move entries beyond the 20 most recent to `~/projects/tracking/<name>/session-log-archive.md` (creating it if needed, with a `# Session Log Archive — <Display Name>` header). Append a note at the bottom of the Session Log section: `<!-- Older entries archived in session-log-archive.md -->`.
6. **Update `TODOS.md`**:
   - Move completed items from Active to Completed.
   - Add any new todos identified during the session.
7. If `content_path` is not null and the directory exists, **update `CLAUDE.md`** in the content directory:
   - Rewrite it using the CLAUDE.md template from [references/templates.md](references/templates.md), populated with the latest description, overview, key decisions, active todos, and tracking directory path.
   - Include the 2–3 most recent session log entries in the **Recent Sessions** section.
8. Update `last_session: <today's date>` in `active-projects.yaml` for this project.
9. If `mode: learning`:
   - Identify any concepts taught or significantly discussed during this session.
   - For each **new** concept: create `~/projects/tracking/<name>/learning/<topic-slug>.md` from the Learning Topic template in [references/templates.md](references/templates.md). Add a new entry to `learning.yaml`.
   - For each **revisited** concept (already in `learning.yaml`): update `last_reviewed` to today, re-assess mastery based on the session, and append a dated note to the `## Review Notes` section of its `.md` file.
   - Add a "Learning" bullet to the session log entry: "Covered topics: <comma-separated titles>."
10. **Sync offer**: If `todoist_project_id` is not null, ask: "Sync tasks with Todoist now? (y/n)". If yes, run the sync logic from `/project sync <name>`.
10. Confirm: "Saved project **<name>**. Tracking files and `CLAUDE.md` are up to date."

---

### `/project sync <name> [--dry-run]`

Bidirectionally synchronizes tasks between Todoist and the local `TODOS.md` file. Todoist is the primary source of truth for task state.

Supports an optional `--dry-run` flag: if provided, show a preview of what would change without applying any changes.

1. Read `active-projects.yaml` to find `<name>`. Apply fuzzy matching if no exact match. If not found, report error and stop.
2. If `todoist_project_id` is null, report: "Project is not linked to Todoist. Use `/project link-todoist <name>` to link it." Stop.
3. Read `~/projects/tracking/<name>/TODOS.md` and parse:
   - **Local active**: items in the `## Active` section (skip blank `- [ ]` placeholders)
   - **Local completed**: item titles in the `## Completed` section
4. Call `find-tasks` with `projectId: <todoist_project_id>` to get all open Todoist tasks.
5. Call `find-completed-tasks` with `projectId: <todoist_project_id>`, `since` = 30 days ago, `until` = today to get recently completed Todoist tasks.
6. **Reconcile** (match tasks by case-insensitive title comparison):

   | Situation | Action |
   |-----------|--------|
   | Open in Todoist, not in Local active | Add to `## Active` in TODOS.md |
   | In Local active, not in Todoist | Call `add-tasks` to create in Todoist |
   | Completed in Todoist, still in Local active | Move from Active → Completed in TODOS.md |
   | In Local completed, still open in Todoist | Call `complete-tasks` to close in Todoist |

7. **Metadata sync**: For tasks synced from Todoist to local, carry over Todoist metadata as inline annotations:
   - Priority p1/p2/p3: append `[p<n>]` to the task line
   - Due date (if set): append `[due: YYYY-MM-DD]`
   - Labels (if any): append `[labels: a, b]`

   For tasks pushed from local to Todoist, parse these annotations from the task line and set them as Todoist fields (`priority`, `dueString`, `labels`).

8. **Dry-run mode**: If `--dry-run` was passed, display a preview instead of making changes:

   ```
   [DRY RUN] Sync preview for <name>:
   + Add to TODOS.md: "Task title"
   + Add to Todoist: "Task title"
   ~ Mark complete in TODOS.md: "Task title"
   ~ Mark complete in Todoist: "Task title"
   No changes applied. Run without --dry-run to apply.
   ```

9. If not dry-run, write the updated `TODOS.md` with all changes applied.
10. Report a clear summary of what changed, e.g.:
    - "Added to TODOS.md: X tasks from Todoist"
    - "Added to Todoist: X tasks from TODOS.md"
    - "Marked complete in TODOS.md: X tasks"
    - "Marked complete in Todoist: X tasks"
    - "Already in sync — no changes needed." (if nothing changed)

---

### `/project status <name>`

Quick-glance summary without loading all file content.

1. Read `active-projects.yaml` to find `<name>`. Apply fuzzy matching if no exact match. If not found, also check `archived-projects.yaml`.
2. Display a compact summary block:
   - **Name / Display Name / Type**
   - **Last session**: value of `last_session` (or "never")
   - **TODO count**: count of `- [ ]` lines in `TODOS.md` (use Grep)
   - **Todoist**: if linked, call `find-tasks` with `projectId` and show open task count. If not linked, show "—".
   - **Content path**: show path and whether it exists on disk.

---

### `/project link-todoist <name>`

Retroactively links an existing project to a Todoist project.

1. Read `active-projects.yaml` to find `<name>`. Apply fuzzy matching if no exact match. Report error and stop if not found.
2. If `todoist_project_id` is already set (not null), report: "Already linked to Todoist project ID `<id>`." Stop.
3. Fetch the user's Todoist projects via `find-projects` and display a numbered list.
4. Ask: "Which Todoist project to link? Enter a number to select existing, or type a name to create a new one."
5. If user selects an existing project → use its ID.
6. If user types a name → call `add-projects` to create it, use the returned ID.
7. Update `todoist_project_id` in `active-projects.yaml` for this project.
8. Confirm: "Linked **<name>** to Todoist project **<todoist_name>** (ID: `<id>`)."

---

### `/project rename <old> <new>`

Renames a project across all locations.

1. Read `active-projects.yaml` to find `<old>`. Apply fuzzy matching if no exact match. Report error and stop if not found.
2. Normalize `<new>` to kebab-case. Check for duplicates in both YAML files. Abort if `<new>` already exists.
3. Ask for confirmation: "Rename **<old>** → **<new>**? This will rename the tracking directory and update all project files. (y/n)"
4. Perform the rename:
   - Rename `~/projects/tracking/<old>/` → `~/projects/tracking/<new>/` (use `mv`)
   - Update `name` and `tracking_path` in `active-projects.yaml`.
   - Update the `/project load <name>` reference line in `TODOS.md`.
   - Ask: "Also update the display name? Current: **<display_name>**. (y/n/new value)"
   - If `content_path` is not null and `CLAUDE.md` exists there, update the `**Tracking directory**` line.
   - If `todoist_project_id` is set, ask: "Also rename in Todoist? (y/n)". If yes, call `update-projects`.
5. Confirm: "Renamed **<old>** → **<new>**."

---

### `/project edit <name>`

Interactively update project metadata without manual YAML editing.

1. Read `active-projects.yaml` to find `<name>`. Apply fuzzy matching if no exact match. Report error and stop if not found.
2. Display current metadata: `display_name`, `type`, `description`, `content_path`.
3. Ask which fields to update (user can specify one or more, or "all").
4. For each selected field, prompt for the new value.
5. Write the updated entry back to `active-projects.yaml`.
6. If `display_name` changed:
   - Update the heading in `NOTES.md`.
   - Update the heading in `TODOS.md`.
   - If `content_path` is not null and `CLAUDE.md` exists, update its heading.
   - If Todoist is linked, ask: "Also update Todoist project name? (y/n)". If yes, call `update-projects`.
7. Confirm: "Updated metadata for **<name>**."

---

### `/project mode <name> [mode]`

Get or set the assistance mode for a project.

1. Find project in `active-projects.yaml`. Apply fuzzy matching. Report error and stop if not found.
2. If no `[mode]` argument provided:
   - Display current mode (read `mode` field; treat missing as `standard`).
   - If mode is `learning`, read `learning/learning.yaml` and show topic count + mastery breakdown.
   - Stop.
3. Validate `[mode]` is `standard` or `learning`. If invalid, report: "Unknown mode '<mode>'. Valid modes: standard, learning." Stop.
4. If project is already set to that mode, report: "Project **<name>** is already in `<mode>` mode." Stop.
5. **Switching to `learning`**:
   - Create `~/projects/tracking/<name>/learning/` directory if it doesn't exist.
   - Create `learning.yaml` from the learning.yaml template in [references/templates.md](references/templates.md) only if it doesn't already exist (preserve prior data).
   - Update `mode: "learning"` in `active-projects.yaml`.
   - Confirm: "Project **<name>** switched to `learning` mode. Learning directory ready at `~/projects/tracking/<name>/learning/`."
6. **Switching to `standard`**:
   - Update `mode: "standard"` in `active-projects.yaml`.
   - Do NOT delete or modify the learning directory or any `.md` files — preserve all prior data.
   - Confirm: "Project **<name>** switched to `standard` mode. Learning data preserved."

---

### `/project search <query>`

Searches across all active projects' NOTES.md and TODOS.md for matching content.

1. Read `active-projects.yaml` to get all project names.
2. For each project, search `~/projects/tracking/<name>/NOTES.md` and `~/projects/tracking/<name>/TODOS.md` for lines containing `<query>` (case-insensitive).
3. Display results grouped by project:

   ```
   ## project-name (Display Name)
   NOTES.md:42: matching line content
   TODOS.md:7: matching line content
   ```

4. If no matches found: "No results for '<query>' across X projects."

---

## Ambient Behavior (when a project is loaded)

When the user mentions tasks, todos, or action items during a session after `/project load`:
- Offer to add them to the Todoist project via `add-tasks`.
- Offer to mark tasks complete via `complete-tasks`.
- Offer to update `NOTES.md` with key decisions or context.

---

## Ambient Behavior: Learning Mode

When a project is loaded with `mode: learning`, apply these behaviors throughout the session in addition to the standard ambient behaviors.

### Before tasks

- Identify key concepts the task will require.
- Cross-reference `learning.yaml` mastery levels:
  - `solid` / `mastered` → skip explanation, proceed directly.
  - `developing` → brief refresh (1–2 sentences) before starting.
  - `emerging` / `none` / new concept → full explanation before starting.

### During implementation

- Briefly narrate significant decisions (why, not just what).
- Highlight transferable patterns when they appear (e.g., "this is the same pattern as X").

### Gauging understanding

- After meaningful work units, occasionally check comprehension with a light question (e.g., "Does that make sense? Could you describe what we just did?").
- Do not quiz after every step — use judgment about when it adds value.

### Mastery heuristics (assess at end of session for `/project save`)

| Mastery | Indicator |
|---------|-----------|
| `emerging` | Needed full explanation; couldn't predict the approach |
| `developing` | Recognized the concept but needed help applying it |
| `solid` | Described the approach before Claude coded it |
| `mastered` | Caught a mistake or explained the concept back accurately |

### Can-reimplement heuristics (assess at end of session for `/project save`)

| Level | Indicator |
|-------|-----------|
| `none` / `low` | Watched but couldn't articulate the steps |
| `medium` | Described the general approach but not specifics |
| `high` | Outlined implementation steps correctly |
| `confident` | Wrote the code themselves |
