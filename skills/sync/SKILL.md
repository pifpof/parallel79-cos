---
name: sync
description: "Catch-up ingest for the AI Chief of Staff. Use this skill whenever the executive says '/sync', has dropped multiple files or sources into /data without processing them, says 'catch up on what I added', 'process my sources', 'I dumped a bunch of stuff in there', or wants the system to absorb everything that's accumulated since the last sync. Scans /data for raw sources that haven't been compiled into memory yet, reads them, and merges their knowledge into the existing wiki structure. This is the batch version of /capture — maintenance rather than intentional single-source ingest."
version: 1.2.0
allowed-tools: [Read, Write, Edit, Bash]
---

# Chief of Staff — Sync

## What This Skill Does

Scans the raw sources folder for anything that hasn't been compiled into memory yet, and processes it. Where `/capture` handles one intentional source, `/sync` is the catch-up pass — the executive has dropped a stack of material into `/data` and wants the system to absorb all of it.

This is Karpathy's compilation step run in batch: read the unprocessed raw material, compile it into the wiki, update the index.

---

## Tone and Approach

This is maintenance, so be systematic. Work through the backlog methodically and report what you did at the end. The executive doesn't need a play-by-play of each file — they need to know the system is now current.

The synthesis still matters. Even in batch, each source should be read through the lens of the executive's priorities and cross-linked to existing memory. Volume is not an excuse for shallow processing.

---

## Step 1 — Find What's Unprocessed or Changed

A source needs processing if it is **new** or has **changed since it was last compiled**. Filename presence alone is not enough: many files in `/data` are living documents (roadmaps, backlogs, checklists, plans) that keep getting edited after their first compile. A new section added to an already-compiled file is exactly as invisible to a filename check as a brand-new file, and it is the more common case.

The record of what was compiled and when lives in `memory/sync-ledger.md` (see "The Sync Ledger" below).

1. List every file in `/data` with its last-modified time (skip `/data/src`, `/data/archive`, and binary build artefacts unless the executive says otherwise). Use Bash, e.g. `find data -type f -not -path 'data/src/*' -not -path 'data/archive/*' -printf '%TY-%Tm-%Td %TH:%TM  %p\n'` (on macOS: `stat -f '%Sm  %N' -t '%Y-%m-%d %H:%M'`).
2. Read `memory/sync-ledger.md`.
3. Classify each file:
   - **New** — not in the ledger and not in any memory file's `sources`.
   - **Changed** — in the ledger, but its modified time is later than its `last compiled` time.
   - **Unledgered** — referenced in some memory file's `sources` but missing from the ledger (vaults created before the ledger existed). Treat these as **changed**: read them in full and compare against memory, because there is no record of what they contained when first compiled.
   - **Current** — in the ledger and unmodified since. Skip.
4. If every file is current, say so ("Memory is current, nothing new to sync") and stop. Don't manufacture work.

### The Sync Ledger

`memory/sync-ledger.md` is a plain table, one row per `/data` file:

```markdown
---
title: "Sync ledger"
summary: "When each /data source was last compiled into memory. Maintained by /sync, /capture and /save; checked by /lint."
tags: [system]
---

| Source | Last compiled | Memory files it feeds |
|---|---|---|
| data/product-roadmap.md | 2026-09-24 10:15 | memory.md (Roadmap), memory/projects/platform-launch.md |
```

Create it if it doesn't exist. It is a system file: list it in `memory.md` once, don't treat it as knowledge.

---

## Step 2 — Process Each Source

**Meeting transcripts are not a `/sync` job.** If a new source is a meeting transcript or raw meeting notes (speaker turns, timestamps, an attendee list), don't compile it here — list it in the report as a candidate for `/minutes`, which extracts action items and strips the small talk and personal content a raw transcript carries. Leave the file where it is; the executive decides. Webinar and talk transcripts are content and sync as normal.

For each **new** source, run the same compilation logic as `/capture`:

1. Read the source through the lens of the executive's priorities, projects, and people
2. Extract the takeaways that matter to *this* executive
3. Update existing memory files where relevant — add insights, note the source in metadata
4. Create new library files for topics worth retaining on their own
5. Always set `sources` lineage pointing back to the `/data` filename

For each **changed** or **unledgered** source, read the whole file, not a skim, and find what memory doesn't already reflect:

1. Walk the file section by section (every heading is a candidate unit of knowledge)
2. For each section, check whether memory already covers it and whether memory's version is current. A status line, date, or decision that moved in the source but not in memory counts as a gap
3. Merge only the new or changed knowledge, and note where memory now disagrees with the source so the executive can see it
4. **Every distinct initiative, project, offering or event found in a living document must get at least a one-line pointer in `memory.md`**, even if its detail stays in `/data`. An initiative that exists only inside a backlog file is invisible to `/start` and `/query`

Work through them in order, oldest first, so the memory reflects how knowledge accumulated over time.

**If sources relate to each other** — three articles on the same topic, a report and its follow-up — compile them together into a coherent picture rather than three disconnected entries. This is where batch processing beats one-at-a-time capture: you can see the connections across sources.

After each source is processed, update its row in `memory/sync-ledger.md` with the current time and the memory files it fed.

---

## Step 3 — Update memory.md

Once all sources are processed, update `memory.md` to reflect every new and changed file. The index must be current — the next `/start` or `/query` depends on it.

---

## Step 4 — Report

Summarize what the sync accomplished. Be concise but specific:

*"Synced [N] sources ([n] new, [n] changed since last compile). [One line on what they covered.] Updated [which projects or topics], and added [N] new entries to the library. [One line flagging anything that stood out or needs the executive's attention, if relevant.]"*

If any source couldn't be processed — unreadable file, ambiguous content — flag it here and ask how the executive wants to handle it.

If any sources were meeting transcripts, name them in one line and offer `/minutes` on them.

---

## Reminders

- Check the ledger, not just `sources`. A filename in `sources` means the file was compiled once, not that memory reflects what it says today.
- Re-reading a changed file is not double-processing. Merge only what's new; don't duplicate what memory already holds.
- Every initiative gets a `memory.md` line. If it's only findable by opening the right file in `/data`, it's lost.
- Oldest first — let the memory reflect the real sequence of how knowledge arrived.
- Related sources get compiled together, not in isolation. The connections are the value.
- If nothing is unprocessed, say so and stop. A clean sync is a valid outcome.
- Don't sacrifice synthesis for speed. A shallow batch is worse than a slow one.
