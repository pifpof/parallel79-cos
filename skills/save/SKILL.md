---
name: save
description: "End-of-session memory write-back for the AI Chief of Staff. Use this skill whenever the executive is wrapping up a session, says '/save', 'save to memory', 'save this', 'remember this', or signals the conversation is ending. Synthesizes everything significant from the session — shifted priorities, project updates, decisions made, new people, new context — and writes it back to the vault, logs decisions, saves outputs, updates the folder indexes, and refreshes the hot-state card that the next /start reads. This is the habit that makes the system compound. Prompt for it before any session ends; nothing persists to the next session without it."
version: 2.0.0
allowed-tools: [Read, Write, Edit, Bash]
---

# Chief of Staff — Save to Memory

## What This Skill Does

Captures everything significant from the current session and writes it back to the vault. This is the habit that makes the system compound. Nothing that happens in a session is permanent until `/save` runs.

---

## Tone and Approach

This is a closing ritual, not a filing task. Be efficient. Do not ask the executive to recap the session — you were there. You already know what happened. Write it back without making them work for it.

The only thing you ask is whether anything was missed.

---

## Step 1 — Synthesize the Session

Review everything discussed in the current conversation. Identify what needs to be written back:

**Changes to existing memory:**
- Priorities that shifted or resolved
- Projects that moved — new decisions made, blockers cleared, status changed
- People context that was added or updated
- Anything in the profile that is now out of date

**New memory to create:**
- New projects or initiatives that surfaced
- New people introduced
- New reference material or knowledge worth retaining
- Decisions made that should be logged

**Outputs generated:**
- Any briefs, analyses, or responses produced during the session worth keeping

**Meetings discussed but not debriefed:**
- If the session talked about a meeting in any substance — what someone said, what was agreed, who owes what — and the vault uses `/minutes` (`memory/reference/meetings.md` exists), check `memory/meetings-ledger.md`. If the meeting isn't there, suggest `/minutes debrief` before saving, in one line: *"We talked through the call with Jordan but it isn't in the meetings ledger — want to run `/minutes debrief` first so the action items get tracked?"* If they decline, save what was discussed as normal; just don't create action items here.
- If the session already ran `/minutes`, its memory writes are done — don't duplicate them. Only save what the session added beyond the minutes.

If nothing significant changed — a short session, a single task, no new context — say so honestly. A light save is still a save.

---

## Step 2 — Write Back to Memory

### Updating existing files

For each file that needs updating, open it and make the changes. Preserve what is accurate. Update what has changed. Add what is new. Do not rewrite files from scratch unless the content has changed substantially.

**Folded files.** If a file has a `<!-- history -->` line (priorities, workflows, running logs), rewrite the current state above it and append the dated change below it. If a file without a marker is growing a changelog, add the marker: current state on top, history below.

Always update the metadata block if the content changes:
- Set `updated` to today's date
- On project files, rewrite `status` (one line: where it stands, the next step) whenever either changed. The hot-state card is compiled from these lines, so a stale `status` means a stale brief
- Update `summary` if the file's subject has meaningfully evolved
- Add new `sources` if new raw material informed the update
- Update `tags` if status has changed (e.g., `active` → `archived`)

---

### Creating new files

For each new topic that warrants its own file, create it in the right location:

| What it is | Where it lives |
|---|---|
| A new project or initiative | `/memory/projects/[project-name].md` |
| A new person | `/memory/profile/people.md` (add entry) or `/memory/projects/[project].md` |
| Reference knowledge, research | `/memory/library/[topic].md` |
| A logged decision | `/memory/projects/[project].md` (add to decisions section) |

Every new file also gets one line in its folder's `_index.md` (Step 3).

Every new file opens with the standard metadata block:

```yaml
---
title: ""
summary: ""
sources: ["session — [date]"]
aliases: []
tags: []
updated: "[YYYY-MM-DD]"
---
```

Project files also get `status: "[where it stands]. Next: [action]."`

Use `session — [date]` as the source when the knowledge came from conversation rather than a captured document.

---

### Logging decisions

Decisions are important. They are the history of how this executive thinks and operates. When a decision was made in the session, log it in the relevant project file under a `## Decisions` section:

```markdown
## Decisions

### [Decision title] — [date]
**What was decided:** [one sentence]
**Why:** [the reasoning, in their words if possible]
**What it affects:** [downstream impacts]
```

If the decision is not project-specific, create `/memory/library/decisions.md` as a running log.

---

### Saving outputs

If a brief, analysis, query response, or other generated content was produced and is worth keeping, save it to `/outputs/` with a descriptive filename:

```
/outputs/[YYYY-MM-DD]-[brief-description].md
```

---

### Files edited in /data during the session

Sessions often write straight into a living document in `/data` (adding a section to a roadmap, updating a plan) instead of a memory file. That knowledge is not in memory yet. For every `/data` file created or edited this session:

- Make sure any new initiative, project, offering or event it now contains has a line in the right folder's `_index.md` (pointer to the file and heading is enough)
- Update that file's row in `memory/sync-ledger.md` to now, so `/sync` and `/health-check` know it's current

---

## Step 3 — Update the Indexes

The vault has two levels of index. Keep them in step:

- **Folder index (`memory/<folder>/_index.md`).** One line per file: `` `memory/<folder>/<file>.md`: hook `` of 150 characters or fewer, taken from the file's `summary`. Add a line for every new file, update the line for any file whose summary changed, and remove the line for any file moved to `/trash`.
- **Router (`memory.md`).** Touch it only when a **new folder** appeared (add a row to its Folders table and create the folder's `_index.md`) or a new kind of question needs a "Where to look" row. Never list individual files here.
- **Initiatives that live in `/data`.** A new initiative written only into a `/data` document still needs a line in the folder index it belongs to (usually `memory/projects/_index.md`): a pointer to the file and heading is enough. If it isn't indexed, the next session won't find it.

If the vault is an older one whose `memory.md` still lists files (no folder indexes yet), update `memory.md` as before and say nothing about the layout.

---

## Step 3b — Refresh the Hot-State Card

Do this **last**, after every other write, so the card reflects the final state of the vault.

Rewrite `memory/_state.md` whole (never append). 2 KB at most, about 15 lines. Every line must come from a file, never from memory of the conversation alone:

```markdown
---
title: "Hot-state card"
summary: "Compiled snapshot of what matters right now. Derived from memory files, never authoritative. Read first by /start."
tags: [system]
updated: "[YYYY-MM-DD HH:MM]"
written_by: "/save"
---

## This week
- #1 goal: [goal] ([Done | On track | At risk | No evidence]). Others: [n of m on track, at risk: name]. [Draft, awaiting confirmation | Confirmed]

## Active projects
- [Project]: [status line from its frontmatter]

## Open decisions
- [Decision not yet made, and where it lives]

## Overdue or stale
- [Follow-up past due, or active item untouched too long, with the date]

## Review
- Last review: [YYYY-MM-DD] ([N] days ago[, overdue])
```

Sources for each section:

- **This week:** the newest `outputs/goals/*-weekly-goals.md` within 7 days, if the executive uses weekly goals. Otherwise one line from the top of `priorities.md`.
- **Active projects:** the `status` line of each project file tagged `active`. One line each. More than six active projects? Keep the six most recently `updated` and add "and [n] more".
- **Open decisions** and **Overdue or stale:** what this session and the project files show. Leave a section out rather than pad it.
- **Review:** the filename date of the newest `outputs/reviews/*-weekly-review.md`.

Nothing from live connectors (CRM, calendar, task systems) goes on the card. It must be rebuildable from the vault alone.

---

## Step 4 — Confirm to the Executive

When writing is complete, give a brief confirmation. Two or three sentences. Name what was saved without listing every file.

Format:

*"Saved. [One sentence on what was updated or added.] You're set for next time — type `/start` to pick up where we left off."*

Then ask:

*"Anything I missed before we close?"*

If they add something, write it back now. Then close.

---

## Step 5 — Final Check

Before the session ends, run a quick internal check:

- [ ] All changed files updated
- [ ] All new files created with metadata blocks, including `updated` (and `status` on projects)
- [ ] Decisions logged where relevant
- [ ] Outputs saved to `/outputs/` if worth keeping
- [ ] Every new file and initiative has a line in its folder's `_index.md`, including ones written only into `/data`
- [ ] `memory/sync-ledger.md` updated for any `/data` file touched this session
- [ ] Any meeting discussed in substance is in `memory/meetings-ledger.md`, or `/minutes debrief` was offered
- [ ] `memory.md` touched only if a folder was added
- [ ] `memory/_state.md` rewritten last, under 2 KB
- [ ] Executive confirmed nothing was missed

If anything is incomplete, finish it before closing.

---

## Reminders

- You were in the session. Do not ask the executive to recap. Write from what you know.
- A session with no significant changes is still worth a light save — even confirming that nothing changed is useful context.
- Decisions are the most valuable thing to log. They are the hardest to reconstruct later.
- The folder indexes and the card are what the next `/start` reads. Never skip them.
- The card is compiled, never invented. If a line can't be traced to a file, it doesn't go on the card.
- The executive's next session starts with what you write now. Get it right.
