# Action item destinations

How `/minutes` routes action items. The destination and its field mapping come from `memory/reference/meetings.md` — never from this file. Tool names below are examples from Claude Code connectors; use whatever the platform's equivalent is.

## Rules for every destination

- **Check the connector live** (ToolSearch, then a read call) before using it. If it's missing or a write fails, fall back to markdown and say so.
- **Duplicate check first.** Search open items for the meeting's `source_id` (or the minutes filename) plus a similar title. Found → skip and report.
- **Every item carries:** the task (verb-first), due date if stated, the meeting date, a short source quote, and the minutes file path. If the destination has no notes field, put this in the description/body.
- **Waiting on:** use the destination's own waiting/blocked concept if it has one (listed below). If not, route to markdown with status `waiting`.
- Never close, edit or reassign existing items. `/minutes` only creates.

## markdown (default fallback)

Append to `outputs/follow-ups.md`. Create it with this header if missing; newest rows go directly under the header row.

```markdown
---
title: "Follow-ups"
summary: "Action items from meetings, newest first. Written by /minutes."
tags: [system]
---

| Added | Task | Owner | Due | Status | Meeting | Quote |
|---|---|---|---|---|---|---|
| 2026-03-12 | Send pricing deck | me | 2026-03-14 | open | [acme call](meetings/2026-03-12-acme-discovery-call.md) | "deck by Friday" |
```

Status values: `open` (mine), `waiting` (waiting on), `fyi` (others, only if `route_others`), `done`.

## airtable

Mapping needs: base ID, table ID, and the field names for task, due date, status (with the select value for a new item), and notes. Optional: links to a contacts/opportunities table, priority, channel, source.
- Search: list records filtered on the notes field containing the `source_id`.
- Create: one batch create per meeting. Resolve linked-record IDs first (search the linked table) — never invent record IDs.
- Waiting on: use a status value like `Waiting` if the mapping provides one.

## asana

Mapping needs: workspace, project ID, optional section for waiting items, assignee rule (`me` for Mine).
- Search: tasks in the project with the `source_id` in the description.
- Create: task name = task, `due_on`, notes = date + quote + minutes path.
- Waiting on: a "Waiting on" section, or a tag; assignee stays the executive.

## todoist

Mapping needs: project name/ID, optional label for waiting items (e.g. `waiting`).
- Search: tasks in the project whose description contains the `source_id`.
- Create: content = task, natural-language or ISO due date, description = date + quote + minutes path.
- Waiting on: the configured label.

## linear

Mapping needs: team, optional project, state for new issues, label for waiting items.
- Search: issues with the `source_id` in the description.
- Create: title = task, description = date + quote + minutes path, assignee = executive for Mine.
- Waiting on: a label such as `waiting-on`, unassigned to the executive.

## trello

Mapping needs: board, list for new items, list or label for waiting items.
- Search: cards on the board with the `source_id` in the description.
- Create: card name = task, `due` in UTC (convert from the executive's timezone), description = date + quote + minutes path.
- Waiting on: the configured list ("Waiting") or label.

## notion

Mapping needs: database ID, property names for title, due date, status (and its value for new / waiting), and a text property or page body for notes.
- Search: query the database filtering on the notes property containing the `source_id`.
- Create: one page per item with the mapped properties.
- Waiting on: the status value for waiting, if mapped.
