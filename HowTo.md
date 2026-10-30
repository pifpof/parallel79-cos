# HowTo — Technical Guide

This guide is for whoever maintains and extends the Chief of Staff system. It covers the architecture, how the pieces fit, how to keep a vault healthy, and how to build new skills. If you're an executive just using the system, you want `README.md` instead.

---

## 1. Architecture

The system is an implementation of the Karpathy LLM knowledge base pattern: instead of retrieving document chunks at query time (RAG), an LLM incrementally compiles raw sources into a structured, human-readable Markdown wiki. The wiki itself is the knowledge base. No vector database, no embeddings — just Markdown files that both the model and a human can read.

There are three logical layers:

**Raw sources (`/data`)** — Append-only. Every document, article, transcript, or note the system has ever ingested. Nothing here is ever edited after it lands. This is the source of truth and the lineage anchor for everything in memory.

**The wiki (`/memory`)** — LLM-maintained. Structured, interlinked Markdown that compiles the raw sources into knowledge: who the executive is, what they're working on, what's been decided, what's worth retaining. This is the layer that compounds.

**The schema (`CLAUDE.md`)** — Configuration. Defines who the Chief of Staff is, how the vault is structured, the rules it operates by, and the full skill list. This is what makes the system a Chief of Staff rather than a generic assistant. It is the highest-leverage file in the system — most customization happens here, not in the skills.

### Folder structure

```
vault/
├── CLAUDE.md           # schema / operating instructions — read first every session
├── memory.md           # index of everything in /memory — read second
├── README.md           # executive-facing guide
├── HowTo.md            # this file
│
├── data/               # raw sources, append-only, never edited
├── memory/
│   ├── profile/        # identity, priorities, workflows, people, style
│   ├── projects/       # active and reference project knowledge
│   ├── library/        # retained knowledge, research, reference, decisions log
│   ├── reference/      # system settings, e.g. meetings.md (/minutes config)
│   ├── sync-ledger.md  # what /data sources were compiled, and when
│   └── meetings-ledger.md  # every meeting /minutes has processed
├── outputs/            # generated briefs, query answers
│   ├── reviews/        # weekly reviews, one file per week (/review saves here)
│   ├── meetings/       # minutes, one file per meeting (/minutes saves here)
│   └── follow-ups.md   # action items, when no task system is configured
└── trash/              # removed from context, preserved (never hard-deleted)
```

### Why this design

- **Markdown over a database** — portable, human-auditable, no vendor lock-in, readable in any editor and viewable as a graph in Obsidian. If the tooling disappears, the knowledge survives.
- **`memory.md` as an index** — lets the model orient across the whole vault without reading every file. Skills read the index first, then load only the files they need. This is what keeps token usage flat as the vault grows.
- **Lineage via `sources`** — every memory file traces back to the `/data` file(s) it was compiled from. Nothing is generated from thin air, and any claim can be audited back to its origin.

---

## 2. The Memory File Contract

Every file in `/memory` must open with this metadata block. The skills depend on it — break the contract and querying, briefing, and linting all degrade.

```yaml
---
title: ""
summary: ""
sources: []
aliases: []
tags: []
---
```

| Field | Purpose | Notes |
|---|---|---|
| `title` | Plain name of the subject | Human-readable, not a filename |
| `summary` | One sentence — what this file is and why it matters | This is what skills read from the index before deciding whether to load the full file. Keep it sharp. |
| `sources` | Filenames in `/data` this was compiled from | The lineage. Use `session — [date]` when knowledge came from conversation, not a document. |
| `aliases` | Alternate names / shorthand the executive uses | This is how `/query` resolves "the migration thing" to `project-alpha.md`. |
| `tags` | Status and type labels | Drives filtering in `/start`, `/review`, `/lint`. Keep the vocabulary consistent. |

**Standard tag vocabulary:** `active`, `archived`, `decision`, `blocked`, `person`, `project`, `reference`. Add to this set deliberately — every new tag is something the skills need to understand. Don't let it sprawl.

---

## 3. How the Skills Work Together

Nine skills, grouped by function. They share two pieces of common infrastructure: they all read `CLAUDE.md` + `memory.md` to orient, and they all respect the memory file contract when writing.

```
SETUP        /onboard    Defines persona (writes CLAUDE.md) + seeds profile

SESSION      /start      Read vault → brief. Start of session. Also the one place
                         to run extra, session-specific instructions beyond
                         CLAUDE.md (a slow connector lookup only this session
                         needs, say) — pass them as arguments: /start <extra>.
LOOP         /save       Synthesize session → write back. End of session.

CONSUMPTION  /review     Weekly synthesis + accountability. Self-saves.

INGEST       /capture    One source → /data → compile into /memory.
             /sync       Batch: scan /data for unprocessed → compile.
             /minutes    Meeting → minutes in /outputs/meetings → action items
                         (mine / waiting on / others) → memory + task system.

RETRIEVAL    /query      Question → read wiki → grounded answer → /outputs.

MAINTENANCE  /lint       Health check. Fix safe issues, surface judgment calls.
```

**`/load` was renamed to `/start`, and `/brief` was retired.** `/brief`'s fast-daily-read niche didn't earn a second skill once `/start` covers it — one command that also takes optional per-session instructions beats two overlapping ones. If you're maintaining a vault that predates this change, `/load` calls become `/start` calls and any workflow built around `/brief` should move to `/start`.

### The two write paths

Everything that enters memory comes through one of two paths:

1. **Conversation → memory** via `/save` and `/review`. Knowledge generated by talking. Sourced as `session — [date]`.
2. **Document → memory** via `/capture` and `/sync`. Knowledge compiled from raw sources. Sourced as the `/data` filename.

`/minutes` is a hybrid: it compiles from a source like `/capture` does, but the source is a meeting and the lineage points at the minutes file in `/outputs/meetings/`, not at `/data`. That's deliberate — raw transcripts are full of small talk and personal content that shouldn't live in the vault, so they stay in the meeting tool and the sanitized minutes become the lineage anchor.

Both paths write through the same memory file contract and both update `memory.md`. If you build a new skill that writes to memory, it must do both too.

### The dependency that matters most

`/save` is the keystone. Every consumption and retrieval skill is only as good as what `/save` wrote last session. If the executive doesn't save, the system silently stops compounding. This is a behavioral dependency, not a technical one — which is why the README and the workshop hammer the save habit. Worth keeping in mind when you diagnose "the system feels dumb" complaints: nine times out of ten, the executive stopped saving.

---

## 4. Maintaining a Vault

### Routine maintenance

`/lint` is the built-in maintenance tool. It catches the common decay modes:

- Files missing or with malformed metadata
- `active` projects that are actually done
- Orphaned `/data` sources that were never compiled (run `/sync` to fix)
- Broken lineage — `sources` pointing to deleted files
- Colliding `aliases` that make `/query` ambiguous
- Contradictions between files
- `memory.md` drifting out of sync with the actual files

Recommend executives run it weekly or monthly. It fixes what's safe automatically and surfaces judgment calls rather than guessing.

### Meetings (`/minutes`)

`/minutes` is the one skill with per-vault configuration, in `memory/reference/meetings.md`. It's created from `skills/minutes/references/config-template.md` on first run, with safe defaults: meeting tool auto-detected, action items to `outputs/follow-ups.md`, external writes held for approval. To customise it for an executive:

- **`destination` + `mapping`** — where their to-dos live (Airtable, Asana, Todoist, Linear, Trello, Notion, or markdown) and the IDs/field names to use. `skills/minutes/references/destinations.md` lists what each destination needs.
- **`crm_convention`** — point at a CRM conventions file in the vault if new contacts and opportunities from meetings should land in a CRM.
- **`language_notes`** — culture-specific rules for non-English meetings. A Persian/Farsi pack ships as the worked example; copy its shape for other languages.
- **`review`** — `external-only` (default) writes minutes and memory immediately and asks before touching any external system. Keep it that way unless the executive asks otherwise.
- **`hourly_rule`**, **`never_record`**, **`aliases`**, title patterns — optional.

Keep everything executive-specific (names, base IDs, table IDs) in this file, never in the skill — the skill is shared across every install.

`memory/meetings-ledger.md` records every processed meeting. It's what prevents duplicates on re-runs and what "since last" counts from; don't hand-edit it except to remove a row you want reprocessed.

### Manual interventions

When you need to step in directly:

- **Vault feels slow or unfocused** — `memory.md` is probably bloated or stale. Trim it to sharp one-line summaries. The index should be scannable in one read.
- **Queries returning thin answers** — check whether sources are actually being compiled. Orphaned files in `/data` mean `/capture` or `/sync` isn't running. Check `sources` coverage.
- **Memory contradicts itself** — `/lint` surfaces these but won't resolve them. A human picks the correct version. Move the wrong one to `/trash` with a note.
- **Profile drift** — as the executive's role evolves, `/memory/profile/` goes stale. There's no automatic trigger for this; periodically re-confirm priorities and workflows.

### The trash rule

Never hard-delete. `/trash` exists so things can be removed from context without being lost. When you remove something, move it to `/trash` and leave a one-line note on why. The cost of keeping a file is near zero; the cost of deleting something that turns out to matter is high.

---

## 5. Building New Skills

Skills are the extension point. The nine baseline skills cover the core loop; role-specific and workflow-specific skills are where each executive's system diverges. This is the intended path — teach the pattern, then let each person extend it.

### Anatomy

Each skill is a folder with a `SKILL.md`:

```
skill-name/
└── SKILL.md
    ├── YAML frontmatter (name + description — required)
    └── Markdown instructions (the body)
```

Larger skills can add `references/` (docs loaded as needed), `assets/` (templates), and `scripts/` (executable helpers), but most Chief of Staff skills are a single `SKILL.md`. `/minutes` is the example of a skill that uses `references/` — its templates and destination guide live there so `SKILL.md` stays readable. Both installers (`install.sh` and `bin/install.js`) copy the whole skill folder, so anything in `references/` ships with it.

### The frontmatter is the most important part

```yaml
---
name: skill-name
description: "What it does AND when to trigger. List the natural phrasings the executive would actually say."
---
```

The `description` is the triggering mechanism. Claude reads it to decide whether to use the skill. The model tends to *under*-trigger, so be generous and a little pushy with trigger phrases — list the slash command, the natural-language asks, and the contexts where it should fire. All the "when to use this" information lives here, not in the body.

Compare:
- Weak: `"Generates a weekly review."`
- Strong: `"Use whenever the executive says '/review', wants a weekly review, asks 'how did the week go', wants to plan the week ahead, or step back across projects..."`

### Body conventions

Follow the patterns the baseline skills use, so the suite stays coherent:

- **Imperative voice.** "Read the vault." Not "The skill should read the vault."
- **Explain why, not just what.** A skill that says *why* a step matters produces better judgment than one that just lists rules. "Lead with the answer — the executive asked because they want to know" beats "Always put the answer first."
- **Read the index first.** Any skill that touches memory should read `memory.md`, then load only relevant files. Don't load the whole vault.
- **Respect the memory contract.** Anything written to `/memory` gets a metadata block. Anything compiled from a source sets `sources` lineage. Update `memory.md` after writing.
- **Tone reminders at the end.** The baseline skills close with a short reminders section reinforcing the non-negotiables. This is where you re-state the easy-to-miss rules.
- **Keep it under ~500 lines.** If a skill is getting long, push detail into a `references/` file and point to it.

### Recommended workflow

1. Draft the `SKILL.md` — frontmatter first, then body.
2. Test it against 2–3 realistic prompts the executive would actually say. Confirm it triggers and produces the right shape of output.
3. Refine based on what you see. Triggering problems are almost always a `description` issue.
4. Drop the folder into the vault. It's available immediately.

The `skill-creator` skill (if available in the environment) automates testing and can optimize a description for triggering accuracy. Worth using for anything that will be widely deployed.

### Extending the schema

When a new skill introduces a concept the whole system should understand — a new tag, a new folder, a new file convention — update `CLAUDE.md` too. The schema is the shared context every skill reads. A skill that depends on a convention not documented in `CLAUDE.md` is fragile. Keep them in sync.

---

## 6. Quick Reference

| Task | Where to look |
|---|---|
| Change the Chief of Staff's persona or rules | `CLAUDE.md` → Who You Are / Tone |
| Add a status or type label | `CLAUDE.md` → tag vocabulary, then use it in skills |
| Fix a slow or unfocused vault | Trim `memory.md` to sharp summaries |
| Diagnose thin query answers | Check `/data` for orphaned (uncompiled) sources, run `/sync` |
| Resolve a contradiction | `/lint` surfaces it; a human resolves it; loser → `/trash` |
| Add a new capability | New skill folder with `SKILL.md`; update `CLAUDE.md` if it adds a convention |
| Recover something removed | Check `/trash` — nothing is ever hard-deleted |
| Change where meeting action items go | `memory/reference/meetings.md` → `destination` + `mapping` |
| Reprocess a meeting | Remove its row from `memory/meetings-ledger.md`, or ask `/minutes` to re-run it |

---

*The architecture is deliberately simple: Markdown files, an index, and a contract. Most problems resolve to one of three things — the index is stale, a source wasn't compiled, or the executive stopped saving. Check those first.*
