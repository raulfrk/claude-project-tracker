# YAML Schemas

## `active-projects.yaml` and `archived-projects.yaml`

```yaml
projects:
  - name: "kebab-case-id"           # Unique identifier, used for directory and lookups
    display_name: "Human Name"       # Human-readable name
    tracking_path: "~/projects/tracking/kebab-case-id"
    content_paths:                   # Ordered list of content directories. Empty list = none.
      - path: "~/repos/my-app"
        type: "code"               # code | docs | config | assets | other
        label: "main repo"         # Optional. Defaults to directory basename if omitted.
        mode: "learning"           # Optional. standard | learning. Overrides project-level mode for this path.
    type: "code"                     # One of: code | personal | documentation | learning
    mode: "standard"                 # standard | learning. Default: standard.
    created: "2026-02-19"            # ISO date
    todoist_project_id: "12345"      # Todoist project ID string. null if not linked.
    description: "Short description" # One-line description. Empty string if none.
    last_session: "2026-02-19"       # ISO date of last save or sync. null if never.
```

Archived entries add one additional field:

```yaml
    archived: "2026-03-01"           # ISO date when the project was archived
```

## `learning/learning.yaml`

Stored at `~/projects/tracking/<name>/learning/learning.yaml`. Created on-demand when a project's mode is set to `learning`.

```yaml
topics:
  - slug: "topic-slug"              # Kebab-case, matches filename (without .md)
    title: "Topic Title"
    category: "concept"              # concept | pattern | tool | technique | language-feature
    introduced: "2026-02-19"
    last_reviewed: "2026-02-19"
    mastery: "emerging"              # none | emerging | developing | solid | mastered
    can_reimplement: "low"           # none | low | medium | high | confident
    related_tasks: []
    tags: []
```

**Mastery scale**:
- `none` — not yet encountered
- `emerging` — needed full explanation, couldn't predict approach
- `developing` — recognized concept but needed help applying
- `solid` — described approach before Claude coded it
- `mastered` — caught mistakes or explained concept back

**Can-reimplement scale**:
- `none` — couldn't articulate steps at all
- `low` — watched but couldn't articulate steps
- `medium` — described general approach, not specifics
- `high` — outlined implementation steps correctly
- `confident` — wrote the code themselves

## Notes

- `name` must be kebab-case (lowercase letters, digits, hyphens only).
- `content_paths` is a list; use `content_paths: []` when no directories are set.
- `todoist_project_id` may be `null` when not applicable.
- `mode` at project level defaults to `standard` when not present (backward compatible).
- `mode` on a `content_paths` entry is optional. When present, it overrides the project-level `mode` for that path. When absent, the path inherits the project-level `mode`. Effective mode = `entry.mode ?? project.mode ?? "standard"`.
- The file always starts with `projects:` at the root level, even when empty (`projects: []`).
- Dates use `YYYY-MM-DD` format.

## Backward Compatibility: `content_path` → `content_paths`

Older entries may have a singular `content_path: "string" | null` field. On read, normalize it:

- `content_path: "~/some/path"` → `content_paths: [{path: "~/some/path", type: null, label: null}]`
- `content_path: null` → `content_paths: []`

On every write, always output `content_paths` (plural) and omit `content_path`. No bulk migration — projects update incrementally as touched.

## Backward Compatibility: Per-Path `mode`

Older entries have `mode` only at the project level, not on individual `content_paths` entries. This is valid and requires no migration.

- If a `content_paths` entry has no `mode` field, its effective mode is the project-level `mode` (which itself defaults to `standard`).
- On write, only include `mode` on a `content_paths` entry if it differs from the project-level `mode`. Omit it otherwise to keep YAML clean.
