# File Templates

## NOTES.md Template

When creating a new project, create `~/projects/tracking/<name>/NOTES.md` with:

```markdown
# <Display Name>

**Type**: <type>
**Created**: <YYYY-MM-DD>
**Content path**: <content_path or "N/A">

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

## CLAUDE.md Template

When creating a new project (if content_path is not null), create `<content_path>/CLAUDE.md` with:

```markdown
# <Display Name>

> This file is auto-maintained by the `/project save` command.
> Run `/project load <name>` to restore full project context.

**Tracking directory**: `~/projects/tracking/<name>`
**Type**: <type>
**Created**: <YYYY-MM-DD>

## Description

<description or "No description provided.">

## Overview

<overview text if provided, otherwise "No overview yet.">

## Key Decisions

<!-- Populated by /project save -->

## Active TODOs

<!-- Populated by /project save -->

## Recent Sessions

<!-- 2-3 most recent session log entries. Populated by /project save -->

## Notes

<!-- Populated by /project save -->
```

When updated by `/project save`, replace the Key Decisions, Active TODOs, Recent Sessions, and Notes sections with current content from NOTES.md and TODOS.md.

---

## learning.yaml Template

When creating the learning directory for a project switching to `learning` mode, create `~/projects/tracking/<name>/learning/learning.yaml` with:

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
