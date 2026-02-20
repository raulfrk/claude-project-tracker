# YAML Schemas

## `active-projects.yaml` and `archived-projects.yaml`

```yaml
projects:
  - name: "kebab-case-id"           # Unique identifier, used for directory and lookups
    display_name: "Human Name"       # Human-readable name
    tracking_path: "~/projects/tracking/kebab-case-id"
    content_path: "~/repos/my-app"  # Where actual project files live. null if unset.
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
- `content_path` and `todoist_project_id` may be `null` when not applicable.
- `mode` defaults to `standard` when not present (backward compatible).
- The file always starts with `projects:` at the root level, even when empty (`projects: []`).
- Dates use `YYYY-MM-DD` format.
