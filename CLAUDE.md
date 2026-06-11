# CLAUDE.md — AI Chief of Staff (Skill Pack)
> Developer reference for continuing work on this project.

---

## What This Project Is

**AI Chief of Staff** is a Claude Code Skill Pack — a set of nine interrelated skills that turns Claude Code into a personal knowledge operating system for an executive. Built on Andrej Karpathy's LLM wiki pattern: raw sources are compiled incrementally into a structured Markdown knowledge base that grows more valuable over time.

**Origin:** Created by Shahed Khalili (Parallel79) to fulfil a consulting engagement (a multi-executive, 3-session workshop series). Now being packaged for submission to the Claude Marketplace.

**Positioning:** "You've hired a Chief of Staff. Not a chatbot — a system that knows your business, remembers context, and works alongside you every day."

---

## Architecture

Three layers:

```
/data         ← Raw sources. Append-only. Never edited. Source of truth.
/memory       ← LLM-maintained wiki. Structured Markdown. Compounds over time.
CLAUDE.md     ← Schema. Operating instructions + persona. Highest-leverage file.
```

**Why Markdown, not RAG:** No vector DB, no embeddings. Knowledge is compiled ahead of time into a human-readable wiki. The index (`memory.md`) lets the model orient without reading every file — token usage stays flat as the vault grows.

**Why this compounds:** Every `/save`, every `/capture`, every `/review` adds to the wiki. A year-old decision is queryable. A month-old conversation is still context. The longer it runs, the smarter it gets.

---

## Project File Structure

```
ai-chief of staff/
├── CLAUDE.md                    ← This file (developer reference)
├── README.md                    ← Executive-facing guide (polished, no edits needed)
├── HowTo.md                     ← Technical/maintainer guide (polished, no edits needed)
│
├── schema/                      ← Template vault (deployed per executive on /onboard)
│   ├── CLAUDE.md                ← Operating instructions template (customised per exec)
│   ├── memory.md                ← NEEDS FIX: currently duplicates CLAUDE.md — should be
│   │                               an empty memory index template, not instructions
│   ├── data/                    ← Empty. Populated as sources arrive.
│   ├── memory/
│   │   ├── profile/             ← Empty. Seeded by /onboard.
│   │   ├── projects/            ← Empty. Written by /save and /capture.
│   │   └── library/             ← Empty. Written by /capture and /sync.
│   ├── output/                  ← Empty. Written by /brief, /review, /query.
│   └── trash/                   ← Empty. Receives removed files.
│
├── skills/                      ← All 9 skills. Each is a folder with SKILL.md.
│   ├── onboard/SKILL.md         ← First-time setup. Two-phase: define persona → brief
│   ├── load/SKILL.md            ← Session start. Read vault → deliver brief.
│   ├── save/SKILL.md            ← Session end. Synthesize → write back. THE keystone.
│   ├── brief/SKILL.md           ← Daily morning read. Faster/lighter than /load.
│   ├── review/SKILL.md          ← Weekly synthesis + pattern recognition. Self-saves.
│   ├── capture/SKILL.md         ← Ingest one source → /data → compile into /memory.
│   ├── sync/SKILL.md            ← Batch: process all uncompiled sources in /data.
│   ├── query/SKILL.md           ← Answer from wiki. Writes to /outputs.
│   └── lint/SKILL.md            ← Health check. Fix safe issues, surface judgment calls.
│
├── dist/                        ← EMPTY. Target for packaged distribution artifacts.
└── docs/                        ← EMPTY. Target for marketplace-facing documentation.
```

---

## The Nine Skills — Summary

| Skill | When | What it does |
|---|---|---|
| `/onboard` | Once | Two-phase hire: exec defines persona → briefs the CoS. Seeds vault. |
| `/load` | Session start | Reads vault, delivers structured brief. Never ask exec to repeat context. |
| `/save` | Session end | Synthesizes session → writes back to memory. The habit the system depends on. |
| `/brief` | Daily | One-page morning read. Tighter than `/load`. Built for coffee. |
| `/review` | Weekly | Honest look back, pattern recognition, sets one priority + 3 intentions. Self-saves. |
| `/capture` | Ad hoc | Ingest one source. Preserve in `/data`, compile into wiki, cross-link. |
| `/sync` | Batch | Catch up on everything dropped into `/data` since last sync. Oldest first. |
| `/query` | Ad hoc | Answer question from compiled wiki. Lead with the answer. Save to `/outputs`. |
| `/lint` | Weekly/monthly | Health check. Fix safe issues silently; surface judgment calls. Never delete. |

---

## Key Conventions (apply to all skills)

**Memory file contract** — every file in `/memory` opens with:
```yaml
---
title: ""
summary: ""      ← One sentence. Read from index before loading full file.
sources: []      ← Filenames in /data, or "session — [date]" for conversation-derived
aliases: []      ← How exec might refer to this topic informally
tags: []         ← active | archived | decision | blocked | person | project | reference
---
```
Breaking this contract degrades `/query`, `/brief`, and `/lint`. Never create a memory file without it.

**Two write paths into memory:**
1. Conversation → memory via `/save` and `/review`. Source: `session — [date]`
2. Document → memory via `/capture` and `/sync`. Source: the `/data` filename

**The index (`memory.md`)** — every skill reads this before loading individual files. Every write to memory must update it. If the index drifts, the whole system degrades silently.

**Trash, not delete** — never hard-delete. Move to `/trash` with a one-line note explaining why.

**Tone** — direct, warm, senior colleague. No filler ("certainly", "great question"). No bullet points in spoken responses unless genuinely parallel items. No preamble.

---

## Known Issues / Things That Need Fixing

### `schema/memory.md` is wrong
`schema/memory.md` currently contains the same content as `schema/CLAUDE.md` (the operating instructions). It should be an empty template for the vault's memory index file. 

The correct `memory.md` template should look like:
```markdown
# Memory Index

> Read this file to orient across the vault. Load individual files only for what's relevant.

## Profile
<!-- Entries added by /onboard -->

## Projects
<!-- Entries added by /save and /capture -->

## Library
<!-- Entries added by /capture and /sync -->
```

---

## Marketplace Packaging Requirements (verified)

Verified against `/Users/shahedkhalili/.claude/plugins/marketplaces/claude-plugins-official/plugins/example-plugin/` (Anthropic's own reference) and the PositioningHQ production skill pack.

### Required folder structure for marketplace submission

```
ai-chief-of-staff/            ← repo / zip root (rename: no spaces)
├── .claude-plugin/
│   └── plugin.json           ← REQUIRED manifest
├── skills/                   ← PREFERRED format (already matches current layout)
│   ├── onboard/
│   │   └── SKILL.md
│   ├── load/
│   │   └── SKILL.md
│   ├── save/
│   │   └── SKILL.md
│   ├── brief/
│   │   └── SKILL.md
│   ├── review/
│   │   └── SKILL.md
│   ├── capture/
│   │   └── SKILL.md
│   ├── sync/
│   │   └── SKILL.md
│   ├── query/
│   │   └── SKILL.md
│   └── lint/
│       └── SKILL.md
├── schema/                   ← Vault template (not a marketplace concept — bundle it
│   └── ...                      here and document in README how /onboard deploys it)
├── LICENSE                   ← REQUIRED (MIT recommended)
└── README.md                 ← Executive-facing guide (already written)
```

The `commands/` folder is the legacy format. The current `skills/` layout is correct and preferred.

### `plugin.json` format

The official Anthropic minimal format only requires `name`, `description`, and `author`. The PositioningHQ production format extends this with version, homepage, repository, license, keywords, and a full skills inventory array. Use the extended format:

```json
{
  "name": "ai-chief-of-staff",
  "version": "1.0.0",
  "description": "A personal AI Chief of Staff for executives. Maintains a structured knowledge base that compounds over time — knows your business, remembers context, and works alongside you every day.",
  "author": {
    "name": "Shahed Khalili / Parallel79",
    "email": "shahed@parallel79.com"
  },
  "homepage": "https://parallel79.com",
  "repository": "https://github.com/parallel79/ai-chief-of-staff",
  "license": "MIT",
  "keywords": ["chief-of-staff", "knowledge-management", "executive", "productivity", "memory", "wiki"],
  "skills": [
    { "name": "onboard", "path": "skills/onboard/SKILL.md", "command": "/onboard", "version": "1.0.0", "tags": ["setup"] },
    { "name": "load",    "path": "skills/load/SKILL.md",    "command": "/load",    "version": "1.0.0", "tags": ["session"] },
    { "name": "save",    "path": "skills/save/SKILL.md",    "command": "/save",    "version": "1.0.0", "tags": ["session"] },
    { "name": "brief",   "path": "skills/brief/SKILL.md",   "command": "/brief",   "version": "1.0.0", "tags": ["daily"] },
    { "name": "review",  "path": "skills/review/SKILL.md",  "command": "/review",  "version": "1.0.0", "tags": ["weekly"] },
    { "name": "capture", "path": "skills/capture/SKILL.md", "command": "/capture", "version": "1.0.0", "tags": ["ingest"] },
    { "name": "sync",    "path": "skills/sync/SKILL.md",    "command": "/sync",    "version": "1.0.0", "tags": ["ingest"] },
    { "name": "query",   "path": "skills/query/SKILL.md",   "command": "/query",   "version": "1.0.0", "tags": ["retrieval"] },
    { "name": "lint",    "path": "skills/lint/SKILL.md",    "command": "/lint",    "version": "1.0.0", "tags": ["maintenance"] }
  ]
}
```

### SKILL.md frontmatter — two types

**User-invoked slash command** (all 9 CoS skills are this type):
```yaml
---
name: skill-name
description: Short description shown in /help
argument-hint: <arg> [optional]   # only if takes args
allowed-tools: [Read, Write, Edit, Bash, WebFetch]  # pre-approves tools, reduces prompts
---
```

**Model-invoked (contextual)** — not applicable here; all CoS skills are user-triggered.

### SKILL.md frontmatter — current state vs. required

The current SKILL.md files use only `name` and `description` in frontmatter. To be fully marketplace-ready, each should also have:
- `version: 1.0.0`
- `allowed-tools:` listing the tools each skill actually uses (reduces permission prompts for users — good UX)

### What's still missing

1. **`.claude-plugin/plugin.json`** — create this file (see format above)
2. **`LICENSE`** — add MIT license file at repo root
3. **`allowed-tools` in each SKILL.md** — add to reduce permission prompts
4. **`version: 1.0.0` in each SKILL.md** — minor but expected
5. **Fix `schema/memory.md`** — currently duplicates CLAUDE.md; should be empty memory index template
6. **GitHub repo** — exists at `github.com/pifpof/parallel79-cof`; needed for marketplace install via `/install-plugin github.com/pifpof/parallel79-cof`
7. **Submission** — via the Claude plugin directory submission form

---

## Context on Origin (Consulting Proposal)

The proposal sold a 3-session workshop series:
- **Session 1:** Set up each exec's vault, seed with the client's context
- **Session 2:** Install and customise the core skill set, build one role-specific skill live
- **Session 3:** Run on real work, teach independence

The system's value proposition in the proposal: "Humans abandon wikis because the maintenance burden grows faster than the value. LLMs don't get bored, don't forget to update a cross-reference." — Karpathy.

This context is useful for writing marketplace copy. The use case is concrete: 6 executives, each with their own vault, each growing over time as context accumulates.

---

## Development Conventions for New Skills

1. **Frontmatter first** — the `description` field is the trigger mechanism. Be generous and explicit with trigger phrases. Under-triggering is the most common failure mode.
2. **Imperative voice** in the body. "Read the vault." Not "The skill should read the vault."
3. **Explain why, not just what.** Skills that know why a step matters produce better judgment.
4. **Index first.** Always read `memory.md` before loading individual files.
5. **Respect the contract.** Every memory write gets a metadata block. Every source gets lineage.
6. **Tone reminder at the end.** Close skills with a short reminders section.
7. **Under 500 lines.** Push overflow detail to a `references/` file.
8. **Update CLAUDE.md** in the schema if a new skill introduces a convention the whole system needs to know.

---

## Marketplace Submission Target

Claude Marketplace (claude.ai/marketplace) — submit as a Skill Pack.
Author: Shahed Khalili / Parallel79 (shahed@parallel79.com)
