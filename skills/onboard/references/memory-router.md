---
type: system
title: "Memory router"
description: "Map of the vault: what each memory folder holds, when to open it, and where its index is. Read at the start of every session."
tags: [system]
layout: "2.2"
okf_version: "0.2"
generated:
  by: ""
  at: ""
---

# Memory Router

> This file is the map, not the catalogue. It lists folders, not files. Each folder keeps an `index.md` (one line per file) and a `log.md` (what changed, newest first). Open them only when the conversation needs that folder. Keep this file under 6 KB.
>
> `layout: "2.2"` above tells the skills which file format this vault uses. `memory/` is an Open Knowledge Format v0.2 bundle.

## Start here

- `memory/_state.md`: the hot-state card. This week's #1 goal, active projects and their next step, open decisions, overdue items, last review. Written by `/save`, `/review` and `/minutes`. Read first by `/start`.

## Folders

| Folder | What lives there | Open when | Index |
|---|---|---|---|
| `memory/profile/` | Who the executive is: about, priorities, workflows, key people, working style | Every session (about, style, top of priorities); people when a name comes up | `memory/profile/index.md` |
| `memory/projects/` | One file per project or initiative, with a `next:` line and a Decisions section | A project, client or initiative is named, or a decision is asked about | `memory/projects/index.md` |
| `memory/library/` | Retained knowledge, research, captured sources, the decisions log | A topic, source or "what do we know about" question | `memory/library/index.md` |
| `memory/reference/` | System settings, such as how `/minutes` finds meetings and routes action items | A skill needs its settings | `memory/reference/index.md` |

## Where to look

| The conversation mentions... | Look here first |
|---|---|
| A person | `aliases` in `memory/profile/people.md`, then any project file that names them |
| A project, client or initiative | `memory/projects/index.md`, then the file, then the links in it |
| A past decision ("what did we decide", "why did we") | The project file's Decisions section, then `memory/library/decisions.md` |
| A source, article or document | `memory/library/index.md`, then `memory/sync-ledger.md`, then `/data` |
| A meeting, or what someone said or owes | `memory/meetings-ledger.md`, then `/outputs/meetings/` |
| Priorities, goals, what matters this week | `memory/_state.md`, then `memory/profile/priorities.md`, then `/outputs/goals/` |
| How the executive writes or likes to work | `memory/profile/style.md` |
| What changed recently, or when | The folder's `log.md` |

<!-- Add rows for this vault's own folders and recurring questions. -->

## System files

- `memory/_state.md`: hot-state card (derived, rebuildable)
- `memory/sync-ledger.md`: when each `/data` source was last compiled
- `memory/meetings-ledger.md`: every meeting processed by `/minutes` (only if used)

## Rules

- **New file:** add one line to its folder's `index.md`. Do not add it here.
- **Any meaningful change:** one line in the folder's `log.md`. Files hold only their current state.
- **New folder:** add a row to the Folders table and to `memory/index.md`, and create its `index.md` and `log.md`.
- **Finding something:** follow the links in the file you have open first. Otherwise search frontmatter `aliases` and `description` (older files: `summary`) across `memory/` and open the top 1 to 3 hits. Never read a whole folder.
