# File Templates

## NOTES.md Template

When creating a new project, create `~/projects/tracking/<name>/NOTES.md` with:

```markdown
# <Display Name>

**Type**: <type>
**Created**: <YYYY-MM-DD>
**Content paths**:
- `<path>` (<type>) — <label or basename>
- *(none if content_paths is empty)*

## Overview

<overview text if provided, otherwise leave the comment placeholder>

<!-- What is this project? What problem does it solve? -->

## Tech Stack

<!-- Languages, frameworks, tools, and infrastructure. Populated by /project map. -->

## Key Files

<!-- Important files and directories with brief notes. Populated by /project map. -->

## Key Decisions

<!-- Important architectural, design, or process decisions made during the project. -->

## Links & References

<!-- Relevant URLs, docs, tickets, PRs, etc. -->

## Session Log

<!-- Brief notes from each work session. Newest first. -->

### <YYYY-MM-DD>

- Started project
```

---

## TODOS.md Template

When creating a new project, create `~/projects/tracking/<name>/TODOS.md` with:

```markdown
# TODOs — <Display Name>

> Todoist is the primary task tracker for this project.
> Use `/project load <name>` to fetch live tasks from Todoist.
> This file is for quick offline reference or tasks not yet synced.

## Active

## Completed

- [x] Project created
```

---

## CLAUDE.md Template (public)

When creating a new project, create `<path>/CLAUDE.md` in **each entry** in `content_paths`. This file is safe to commit — it contains no local paths or private data.

```markdown
# <Display Name>

**Type**: <type>
**Created**: <YYYY-MM-DD>

## Description

<description or "No description provided.">

## Overview

<overview text if provided, otherwise "No overview yet.">

## Key Decisions

<!-- Populated by /project save -->

## Project Structure

<!-- Populated by /project map or /project save -->

## Development Notes

<!-- Populated by /project save -->
```

When updated by `/project save`, replace the Key Decisions, Project Structure, and Development Notes sections with current content from NOTES.md. Write identical content to the `CLAUDE.md` in **each** content directory.

---

## CLAUDE.local.md Template (private)

When creating a new project, create `<path>/CLAUDE.local.md` in **each entry** in `content_paths`. This file must **not** be committed — ensure `*.local.md` is in `.gitignore`.

```markdown
# <Display Name> — Local Context

> **Do not commit this file.** It contains local paths and session data.
> Run `/project load <name>` to restore full project context.

**Tracking directory**: `~/projects/tracking/<name>`

## Active TODOs

<!-- Populated by /project save -->

## Recent Sessions

<!-- 2-3 most recent session log entries. Populated by /project save -->
```

When updated by `/project save`, replace the Active TODOs section with current content from TODOS.md, and the Recent Sessions section with the 2–3 most recent entries from the Session Log in NOTES.md. Write identical content to the `CLAUDE.local.md` in **each** content directory.

---

## learning.yaml Template

When creating the learning directory for a project switching to `learning` or `active-learning` mode, create `~/projects/tracking/<name>/learning/learning.yaml` with:

```yaml
topics: []
```

---

## Learning Topic .md Template

When saving a new topic learned during a session, create `~/projects/tracking/<name>/learning/<topic-slug>.md` with:

```markdown
# <Topic Title>

**Category**: <category>
**Introduced**: <YYYY-MM-DD>
**Mastery**: <mastery>
**Can reimplement**: <can_reimplement>

## Explanation
<Core explanation tailored to user's level>

## Key Points
- <takeaways>

## Examples
<Code examples from the session>

## Context
<Which task prompted this topic>

## Review Notes
<!-- Updated on revisits -->
```
