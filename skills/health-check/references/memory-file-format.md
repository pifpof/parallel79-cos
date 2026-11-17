## Memory File Format

The memory folder follows the Open Knowledge Format (OKF) v0.2: plain markdown, YAML frontmatter, a reserved `index.md` and `log.md` in each folder, and ordinary markdown links between files. Every file in `/memory` except `index.md` and `log.md` opens with this block. Never create a memory file without it.

```yaml
---
type: project
title: ""
description: ""
tags: []
generated:
  by: "/save"
  at: "2026-11-17T06:30:00-08:00"
aliases: []
sources:
  - resource: "data/2026-11-17-board-pack.md"
next: ""
---
```

**Field rules:**
- `type` — required. One of `profile`, `person`, `project`, `client`, `decision`, `source`, `reference`, `system`.
- `title` — plain name of the file's subject.
- `description` — one sentence: what this file is about and why it matters. Folder indexes are built from it.
- `tags` — use these consistently: `active`, `archived`, `blocked`, `decision`, `person`, `project`, `reference`.
- `generated` — the last meaningful change: `by` is the skill that made it (`/save`, `/minutes`…) or `executive` for a hand edit, `at` is the time in ISO 8601 with its offset. Set it every time you change the file.
- `aliases` — alternate names or shorthand the executive might use in conversation.
- `sources` — where the knowledge came from, one `resource` each: a `/data` path, an `outputs/meetings/` path, or `session:YYYY-MM-DD` for something learned in conversation.
- `next` — project files only. One line: where it stands and the next step. Rewritten by `/save` when it changes.
- Don't write OKF's own `status` field (it means draft / stable / deprecated). Our project line is `next`.

**Older files** may use `summary` (same as `description`), `updated` (same as `generated.at`), a free-text `status` on projects (same as `next`) and plain filename `sources`. Read them as equivalent. Don't rewrite them unprompted; `/health-check` offers the conversion.

**Folder index (`index.md`).** No frontmatter. A heading, the folder's one-line description, then one line per file: `- [Title](./file.md): description` (150 characters or fewer). Derived from frontmatter; `/health-check` can rebuild it. Older vaults call it `_index.md`.

**Folder log (`log.md`).** No frontmatter. Newest first, one `## YYYY-MM-DD` heading per day, one line per meaningful change: `- **Updated** [Priorities](./priorities.md): Series A moved to first (/save)`. History goes here; files hold only their current state. (Older files may keep history below a `<!-- history -->` line. Read it; don't add to it.)

**Links.** When a file mentions a person, project, client or decision that has its own file, link it with a relative markdown link: `[Jordan Lee](../profile/people.md)`, `[Website relaunch](../projects/website-relaunch.md)`. Links are how you move between files without searching.
