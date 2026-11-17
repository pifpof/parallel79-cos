---
name: save
description: "End-of-session memory write-back for the AI Chief of Staff. Use this skill whenever the executive is wrapping up a session, says '/save', 'save to memory', 'save this', 'remember this', or signals the conversation is ending. Synthesizes everything significant from the session — shifted priorities, project updates, decisions made, new people, new context — and writes it back to the vault, logs decisions, saves outputs, records each change in the folder's change log, updates the folder indexes, refreshes the hot-state card that the next /start reads, and commits if the vault is a Git repo. This is the habit that makes the system compound. Prompt for it before any session ends; nothing persists to the next session without it."
version: 3.0.0
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

## Which Format to Write

Read `layout:` in `memory.md`'s frontmatter (you'll have the router in context already).

- **`layout: "2.2"`:** write the format in "Layout 2.2" below.
- **Anything else** (no `layout`, an older vault): write in the format its files already use (`summary`, `updated`, a project `status` line, `_index.md`, history below `<!-- history -->`) and convert nothing. `/health-check` offers the upgrade; `/save` never does it on its own.

### Layout 2.2

- **Frontmatter:** `type` (profile, person, project, client, decision, source, reference or system), `title`, `description` (one sentence), `tags`, `generated` (`by: "/save"`, `at:` now in ISO 8601 with offset), `aliases`, `sources` (a list of `- resource: "…"`), and on projects `next` (one line: where it stands, the next step). Never write a `status` field; OKF reserves it.
- **Folder index** `memory/<folder>/index.md`: no frontmatter; one line per file, `- [Title](./file.md): description`, 150 characters or fewer.
- **Folder log** `memory/<folder>/log.md`: no frontmatter; newest first; a `## YYYY-MM-DD` heading per day, one line per change: `- **Updated** [Title](./file.md): what changed (/save)`. Verbs: Created, Updated, Decided, Archived, Moved. History goes here; files hold only their current state.
- **Links:** when a file you write mentions a person, project, client or decision that has its own file, link it with a relative markdown link (`[Jordan Lee](../profile/people.md)`).

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

**Current state in the file, history in the log.** Rewrite the file so it says how things stand now. In layout 2.2, record what changed as one line in the folder's `log.md` (Step 3); don't keep a changelog in the file. In an older vault, if a file has a `<!-- history -->` line, rewrite the state above it and append the dated change below it, as before.

Always update the metadata block if the content changes:
- Set `generated` (`by: "/save"`, `at:` now), or `updated` to today in an older vault
- On project files, rewrite `next` (older vaults: `status`) whenever where it stands or the next step changed. The hot-state card is compiled from these lines, so a stale one means a stale brief
- Update `description` (older: `summary`) if the file's subject has meaningfully evolved
- Add new `sources` if new raw material informed the update
- Update `tags` if the state has changed (e.g., `active` → `archived`)
- Add links to any person, project or decision file the new text mentions

---

### Creating new files

For each new topic that warrants its own file, create it in the right location:

| What it is | Where it lives |
|---|---|
| A new project or initiative | `/memory/projects/[project-name].md` |
| A new person | `/memory/profile/people.md` (add entry) or `/memory/projects/[project].md` |
| Reference knowledge, research | `/memory/library/[topic].md` |
| A logged decision | `/memory/projects/[project].md` (add to decisions section) |

Every new file also gets one line in its folder's index and a `Created` line in its log (Step 3).

Every new file opens with the standard metadata block:

```yaml
---
type: project
title: ""
description: ""
tags: [active]
generated:
  by: "/save"
  at: "[YYYY-MM-DDTHH:MM:SS±HH:MM]"
aliases: []
sources:
  - resource: "session:[YYYY-MM-DD]"
next: "[where it stands]. Next: [action]."
---
```

`next` is for project files only. Use `session:[YYYY-MM-DD]` as the source when the knowledge came from conversation rather than a captured document.

In an older vault, use its block instead: `title`, `summary`, `sources: ["session — [date]"]`, `aliases`, `tags`, `updated`, and `status` on projects.

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

If the decision is not project-specific, create `/memory/library/decisions.md` as a running log. Either way, add a `Decided` line to the folder's `log.md` (layout 2.2).

---

### Saving outputs

If a brief, analysis, query response, or other generated content was produced and is worth keeping, save it to `/outputs/` with a descriptive filename:

```
/outputs/[YYYY-MM-DD]-[brief-description].md
```

---

### Files edited in /data during the session

Sessions often write straight into a living document in `/data` (adding a section to a roadmap, updating a plan) instead of a memory file. That knowledge is not in memory yet. For every `/data` file created or edited this session:

- Make sure any new initiative, project, offering or event it now contains has a line in the right folder's index (pointer to the file and heading is enough)
- Update that file's row in `memory/sync-ledger.md` to now, so `/sync` and `/health-check` know it's current

---

## Step 3 — Update the Logs and Indexes

- **Folder log (`memory/<folder>/log.md`, layout 2.2).** One line per meaningful change to a file in that folder, under today's `## YYYY-MM-DD` heading at the top (add the heading if it isn't there). Created, updated, decided, archived, moved. Not for typo fixes or a refreshed `generated` time. Create the log from the format above if it's missing. `/review` reads the week from these lines, so a change that isn't logged is a change the review won't see.
- **Folder index (`index.md`, or `_index.md` in an older vault).** One line per file, from its `description` (or `summary`): in 2.2 `- [Title](./file.md): description`, in an older vault `` `memory/<folder>/<file>.md`: hook ``. Add a line for every new file, update the line for any file whose description changed, and remove the line for any file moved to `/trash`.
- **Router (`memory.md`).** Touch it only when a **new folder** appeared (add a row to its Folders table and to `memory/index.md`, and create the folder's index and log) or a new kind of question needs a "Where to look" row. Never list individual files here.
- **Initiatives that live in `/data`.** A new initiative written only into a `/data` document still needs a line in the folder index it belongs to (usually the projects index): a pointer to the file and heading is enough. If it isn't indexed, the next session won't find it.

If the vault is an older one whose `memory.md` still lists files (no folder indexes yet), update `memory.md` as before and say nothing about the layout.

---

## Step 3b — Refresh the Hot-State Card

Do this **last**, after every other write, so the card reflects the final state of the vault.

Rewrite `memory/_state.md` whole (never append). 2 KB at most, about 15 lines. Every line must come from a file, never from memory of the conversation alone:

```markdown
---
type: system
title: "Hot-state card"
description: "Compiled snapshot of what matters right now. Derived from memory files, never authoritative. Read first by /start."
tags: [system]
generated:
  by: "/save"
  at: "[YYYY-MM-DDTHH:MM:SS±HH:MM]"
---

## This week
- #1 goal: [goal] ([Done | On track | At risk | No evidence]). Others: [n of m on track, at risk: name]. [Draft, awaiting confirmation | Confirmed]

## Active projects
- [Project]: [next line from its frontmatter]

## Open decisions
- [Decision not yet made, and where it lives]

## Overdue or stale
- [Follow-up past due, or active item untouched too long, with the date]

## Review
- Last review: [YYYY-MM-DD] ([N] days ago[, overdue])
```

Sources for each section:

- **This week:** the newest `outputs/goals/*-weekly-goals.md` within 7 days, if the executive uses weekly goals. Otherwise one line from the top of `priorities.md`.
- **Active projects:** the `next` line (older files: `status`) of each project file tagged `active`. One line each. More than six active projects? Keep the six most recently changed (`generated.at`, or `updated`) and add "and [n] more".
- **Open decisions** and **Overdue or stale:** what this session and the project files show. Leave a section out rather than pad it.
- **Review:** the filename date of the newest `outputs/reviews/*-weekly-review.md`.

Nothing from live connectors (CRM, calendar, task systems) goes on the card. It must be rebuildable from the vault alone. In an older vault, keep the card's existing frontmatter shape (`updated`, `written_by: "/save"`).

---

## Step 3c — Commit, If the Vault Uses Git

Only commit when **both** are true; otherwise skip this step silently:

1. A `.git` exists at the vault root: `test -e "<vault root>/.git"`. No `.git`, no commit, and never run `git init` here (that's `/git-vault-setup`'s job, on request).
2. The vault root is that repo's top level: `git -C "<vault root>" rev-parse --show-toplevel` prints the vault root exactly. This rules out a vault sitting inside some other repo.

If both hold, make **one** commit of everything this save changed: `git add -A` then `git commit -m "save: <one-line summary of the session>"`. Skip if there is nothing to commit. If the commit fails, say so in one line and carry on; the files are saved either way.

**Push only if** the vault's `CLAUDE.md` says `push after save: yes` (set by `/git-vault-setup`) **and** the remote passes the private check first: the `origin` URL is on github.com, and `gh repo view <owner>/<repo> --json visibility -q .visibility` prints `PRIVATE` (without the GitHub CLI: `curl -s -o /dev/null -w '%{http_code}' https://api.github.com/repos/<owner>/<repo>` returns `404`, not `200`). If the repo is public, or the check can't be completed, don't push: keep the commit local and tell the executive in one line that the repo is public (or couldn't be verified) and needs to be made private before anything is uploaded.

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
- [ ] All new files created with metadata blocks, including `type` and `generated` (and `next` on projects), or the older vault's own fields
- [ ] Decisions logged where relevant
- [ ] Outputs saved to `/outputs/` if worth keeping
- [ ] Every meaningful change has a line in its folder's `log.md` (layout 2.2)
- [ ] Every new file and initiative has a line in its folder's index, including ones written only into `/data`
- [ ] `memory/sync-ledger.md` updated for any `/data` file touched this session
- [ ] Any meeting discussed in substance is in `memory/meetings-ledger.md`, or `/minutes debrief` was offered
- [ ] `memory.md` touched only if a folder was added
- [ ] `memory/_state.md` rewritten last, under 2 KB
- [ ] One commit made only if `.git` exists at the vault root and it's the repo's top level; nothing pushed unless `CLAUDE.md` allows it and the remote is verified private
- [ ] Executive confirmed nothing was missed

If anything is incomplete, finish it before closing.

---

## Reminders

- You were in the session. Do not ask the executive to recap. Write from what you know.
- A session with no significant changes is still worth a light save — even confirming that nothing changed is useful context.
- Decisions are the most valuable thing to log. They are the hardest to reconstruct later.
- The folder indexes and the card are what the next `/start` reads, and the logs are what `/review` reads. Never skip them.
- The card is compiled, never invented. If a line can't be traced to a file, it doesn't go on the card.
- The executive's next session starts with what you write now. Get it right.
