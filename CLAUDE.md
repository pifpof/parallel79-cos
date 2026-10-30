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
│   ├── memory.md                ← Empty memory index template
│   ├── data/                    ← Empty. Populated as sources arrive.
│   ├── memory/
│   │   ├── profile/             ← Empty. Seeded by /onboard.
│   │   ├── projects/            ← Empty. Written by /save, /capture, /minutes.
│   │   ├── library/             ← Empty. Written by /capture and /sync.
│   │   └── reference/           ← Empty. meetings.md created by /minutes on first run.
│   ├── outputs/                 ← Written by /review, /query. (Renamed from output/
│   │   └── meetings/               in v1.6.0 — every skill writes to /outputs.)
│   └── trash/                   ← Empty. Receives removed files.
│                                   (Empty folders carry a .gitkeep so git installs
│                                    get the full structure.)
│
├── skills/                      ← All 9 skills. Each is a folder with SKILL.md.
│   ├── onboard/SKILL.md         ← First-time setup. Two-phase: define persona → brief
│   ├── start/SKILL.md           ← Session start. Read vault → deliver brief. Also the
│   │                               one place to layer in extra, session-specific
│   │                               instructions beyond CLAUDE.md. (Renamed from /load.)
│   ├── save/SKILL.md            ← Session end. Synthesize → write back. THE keystone.
│   ├── review/SKILL.md          ← Weekly synthesis + pattern recognition. Self-saves.
│   ├── capture/SKILL.md         ← Ingest one source → /data → compile into /memory.
│   ├── sync/SKILL.md            ← Batch: process all uncompiled sources in /data.
│   ├── query/SKILL.md           ← Answer from wiki. Writes to /outputs.
│   ├── lint/SKILL.md            ← Health check. Fix safe issues, surface judgment calls.
│   └── minutes/                 ← Meeting → minutes, action items, memory. (v1.6.0)
│       ├── SKILL.md
│       └── references/          ← config-template, minutes-template, destinations,
│                                   language-notes-farsi
│
├── dist/                        ← Packaged distribution artifacts, built by install.sh:
│                                    one combined ai-chief-of-staff.zip (the whole plugin,
│                                    one-step install) plus one .skill file per skill.
└── docs/                        ← Marketplace-facing documentation (docs/index.html).
```

**`/brief` was removed** — its daily-read use case is covered by `/start`; a separate lighter skill wasn't earning its keep. **`/load` was renamed to `/start`** and reframed: beyond the standard vault-read brief, it's now the deliberate place to add extra, session-specific instructions that are too costly to run by default on every turn (a connector lookup, a calendar pull, anything CLAUDE.md shouldn't pay for on every message). See `skills/start/SKILL.md`.

**`/start` and `/review` stay separate** — `/start` is fast and runs every session, `/review` is deep and runs weekly; merging them would force every session to pay the review's cost, or need branching logic to guess which mode to run. What `/start` does do (v1.3.0) is check `/outputs/reviews/` for the most recent `*-weekly-review.md` and flag in "On my radar" when it's more than ~10 days old — connective tissue between the two skills without merging their mechanics.

---

## The Nine Skills — Summary

| Skill | When | What it does |
|---|---|---|
| `/onboard` | Once | Two-phase hire: exec defines persona → briefs the CoS. Seeds vault. |
| `/start` | Session start | Reads vault, delivers structured brief. Never ask exec to repeat context. Also where extra, session-specific instructions beyond CLAUDE.md get run (e.g. a slow connector lookup), and flags in "On my radar" when `/review` is overdue (>~10 days). Formerly `/load`. |
| `/save` | Session end | Synthesizes session → writes back to memory. The habit the system depends on. |
| `/review` | Weekly | Honest look back, pattern recognition, sets one priority + 3 intentions. Self-saves. |
| `/capture` | Ad hoc | Ingest one source. Preserve in `/data`, compile into wiki, cross-link. |
| `/sync` | Batch | Catch up on everything dropped into `/data` since last sync. Oldest first. |
| `/query` | Ad hoc | Answer question from compiled wiki. Lead with the answer. Save to `/outputs`. |
| `/lint` | Weekly/monthly | Health check. Fix safe issues silently; surface judgment calls. Never delete. |
| `/minutes` | After meetings | Granola (or paste / spoken debrief) → sanitized minutes in `/outputs/meetings/`, action items as mine / waiting on / others, memory + CRM updates, routing to the exec's task system after approval. Config in the vault at `memory/reference/meetings.md`. |

### `/minutes` design notes (v1.6.0)

- **Generic in the plugin, specific in the vault.** No names, base/table IDs or connectors in `skills/minutes/`. Everything executive-specific lives in `memory/reference/meetings.md`, created from `references/config-template.md` on first run. Before release, grep `skills/` and `schema/` for client names and IDs.
- **No raw transcripts in the vault.** Deliberate exception to `/capture`'s "preserve raw in /data": the meeting tool is the source of record, the sanitized minutes file is the lineage anchor (`sources` points at `outputs/meetings/...`).
- **External writes need approval** in the default `review: external-only` mode; minutes and memory are written immediately.
- **`memory/meetings-ledger.md`** is the system file for processed meetings (dedupe, "since last"), parallel to `sync-ledger.md`.
- **Not yet wired into other skills.** `/start` (radar line for undebriefed meetings + overdue follow-ups), `/save` (suggest `/minutes debrief`), `/review` (meeting/action-item flow), `/onboard` (optional meetings question) and `/lint` (ledger gaps, lineage, config) are planned but not built. Spec: `updates/ai-chief-of-staff-minutes/` (gitignored).
- **Untested against real meetings.** Fixtures F1–F7 in the implementation plan still need running.

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
Breaking this contract degrades `/query`, `/start`, and `/lint`. Never create a memory file without it.

**Two write paths into memory:**
1. Conversation → memory via `/save` and `/review`. Source: `session — [date]`
2. Document → memory via `/capture` and `/sync`. Source: the `/data` filename

**The index (`memory.md`)** — every skill reads this before loading individual files. Every write to memory must update it. If the index drifts, the whole system degrades silently.

**Trash, not delete** — never hard-delete. Move to `/trash` with a one-line note explaining why.

**Tone** — direct, warm, senior colleague. No filler ("certainly", "great question"). No bullet points in spoken responses unless genuinely parallel items. No preamble.

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
│   ├── start/
│   │   └── SKILL.md
│   ├── save/
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

**Correction (2026-09-03):** the previous version of this section documented `skills` as an array of objects (`{ "name", "path", "description", "command", "version", "tags" }`) and called it "verified." That was wrong — a real install (drag-and-drop in Cowork) failed validation with "skills list items must be strings ... got dict" for every entry. The actual schema: `skills` — if present at all — is a string or array of strings, each a relative path to a *directory* of skills, not an array of metadata objects. Per-skill metadata (description, trigger command, etc.) lives entirely in that skill's own `SKILL.md` frontmatter, never in the manifest.

Only `name` is required. Everything else — `description`, `version`, `author`, `homepage`, `repository`, `license`, `keywords` — is optional. Since this plugin uses the default `skills/` directory at the plugin root, **omit `skills` entirely** — it's auto-discovered:

```json
{
  "name": "ai-chief-of-staff",
  "version": "1.6.0",
  "description": "A personal AI Chief of Staff for executives. Maintains a structured knowledge base that compounds over time — knows your business, remembers context, and works alongside you every day.",
  "author": {
    "name": "Shahed Khalili / Parallel79",
    "email": "shahed@parallel79.com"
  },
  "homepage": "https://parallel79.com",
  "repository": "https://github.com/parallel79/ai-chief-of-staff",
  "license": "MIT",
  "keywords": ["chief-of-staff", "knowledge-management", "executive", "productivity", "memory", "wiki"]
}
```

Only add a `skills` field if skills live somewhere other than the default `skills/` directory, e.g. `"skills": ["./skills/", "./extra-skills/"]` — and even then, as bare path strings, never objects.

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

All 9 SKILL.md files include `name`, `description`, `version`, and `allowed-tools` in frontmatter. `start` and `minutes` additionally set `argument-hint`, since they take optional arguments. No changes needed.

### What's still missing

1. **GitHub repo** — exists at `github.com/pifpof/parallel79-cof`; needed for marketplace install via `/install-plugin github.com/pifpof/parallel79-cof`
2. **Submission** — via the Claude plugin directory submission form

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

## Distribution

### Distribution channels (all configured)

| Channel | How | Status |
|---|---|---|
| GitHub | `/plugin install github.com/parallel79/ai-chief-of-staff` | Needs repo (existing: `pifpof/parallel79-cof`) |
| npx | `npx ai-chief-of-staff-skills [--platform <name>]` | Ready — `bin/install.js` + `package.json` |
| npm | `/plugin install npm:ai-chief-of-staff-skills` | Needs `npm publish` after repo created |
| Claude Marketplace | Search in-app | Needs submission |
| agentskills.io | Community directory | Needs registration |

### Platform support matrix

The SKILL.md format is the agentskills.io open standard — portable to all major agentic tools with no modification.

| Platform | Skills | Vault (memory wiki) |
|---|---|---|
| Claude Code | ✓ | ✓ |
| Claude Cowork | ✓ | ✓ |
| Google Antigravity | ✓ | ✓ |
| Gemini CLI | ✓ | ✓ |
| OpenAI Codex CLI | ✓ | ✓ (filesystem access) |
| GitHub Copilot | ✓ | No (workspace-only) |
| Browser-only tools | ✓ | No (no filesystem) |

### Combined package (`install.sh`)

Run `./install.sh` to build `dist/`. It now produces two kinds of output:

1. **`dist/ai-chief-of-staff.zip`** — the whole plugin (`.claude-plugin/`, all of `skills/`, `schema/`, `README.md`, `LICENSE`) as one archive. This is the one-step install: unzip it and install the folder as a Claude Code plugin, or push it to GitHub and run `/plugin install <repo>`. It replaces the old ad hoc approach of manually zipping `skills/` in Finder (that produced `skills.zip` at the repo root, which is now stale and superseded — safe to delete).
2. **`dist/<skill>.skill`** — one zip per skill (the whole skill folder, including `references/`), kept for flows that only support installing a single skill at a time (e.g. dragging one skill into Cowork's Customize → Skills panel).

Both are built with `COPYFILE_DISABLE=1` and `zip -X` to avoid macOS resource-fork cruft (`__MACOSX/`, `._*` files) — the older manual zips in `dist/` (`onboard-save-sync.zip`, `save-lint.zip`) had this problem and were manual workarounds for not having a combined package; they're superseded by `ai-chief-of-staff.zip` and safe to delete.

### Installer (`bin/install.js`)

Copies each `skills/<name>/` folder (SKILL.md plus `references/`) to the correct directory for the target platform. Run with `npx ai-chief-of-staff-skills` or `npx ai-chief-of-staff-skills --platform <name>`. The `--vault` flag also copies `schema/` as a vault template.

Supported platform flags: `claude`, `claude-project`, `cowork`, `antigravity`, `gemini`, `codex`, `copilot`.

### Shared marketplace

A shared `marketplace.json` lives at `../marketplace.json` (parallel79 org root). Host it on GitHub to enable: `/plugin marketplace add github.com/parallel79/skills-marketplace`.

### What's still needed before publishing

1. **Clarify GitHub repo** — use existing `pifpof/parallel79-cof` or create `parallel79/ai-chief-of-staff`
2. **Run `npm publish`** — from the repo root after pushing to GitHub
3. **Submit to Claude Marketplace** — via the Claude plugin directory submission form
4. **Register on agentskills.io** — community directory for Antigravity/Gemini users

## Marketplace Submission Target

Claude Marketplace (claude.ai/marketplace) — submit as a Skill Pack.
Author: Shahed Khalili / Parallel79 (shahed@parallel79.com)
