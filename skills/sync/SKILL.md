---
name: sync
description: "Catch-up ingest for the AI Chief of Staff. Use this skill whenever the executive says '/sync', has dropped multiple files or sources into /data without processing them, says 'catch up on what I added', 'process my sources', 'I dumped a bunch of stuff in there', or wants the system to absorb everything that's accumulated since the last sync. Scans /data for raw sources that haven't been compiled into memory yet, reads them, and merges their knowledge into the existing wiki structure. This is the batch version of /capture — maintenance rather than intentional single-source ingest."
version: 1.0.0
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

## Step 1 — Find What's Unprocessed

Determine which files in `/data` have already been compiled and which haven't.

A source is already processed if it appears in the `sources` field of any memory file. To check:

1. Read `memory.md` and scan the `sources` lists across memory files
2. List everything in `/data`
3. The unprocessed sources are the ones in `/data` that don't appear in any memory file's `sources`

If everything is already processed, say so — "Memory is current, nothing new to sync" — and stop. Don't manufacture work.

---

## Step 2 — Process Each Source

For each unprocessed source, run the same compilation logic as `/capture`:

1. Read the source through the lens of the executive's priorities, projects, and people
2. Extract the takeaways that matter to *this* executive
3. Update existing memory files where relevant — add insights, note the source in metadata
4. Create new library files for topics worth retaining on their own
5. Always set `sources` lineage pointing back to the `/data` filename

Work through them in order, oldest first, so the memory reflects how knowledge accumulated over time.

**If sources relate to each other** — three articles on the same topic, a report and its follow-up — compile them together into a coherent picture rather than three disconnected entries. This is where batch processing beats one-at-a-time capture: you can see the connections across sources.

---

## Step 3 — Update memory.md

Once all sources are processed, update `memory.md` to reflect every new and changed file. The index must be current — the next `/start` or `/query` depends on it.

---

## Step 4 — Report

Summarize what the sync accomplished. Be concise but specific:

*"Synced [N] sources. [One line on what they covered.] Updated [which projects or topics], and added [N] new entries to the library. [One line flagging anything that stood out or needs the executive's attention, if relevant.]"*

If any source couldn't be processed — unreadable file, ambiguous content — flag it here and ask how the executive wants to handle it.

---

## Reminders

- Check `sources` lineage to avoid reprocessing what's already in memory. Double-processing pollutes the wiki.
- Oldest first — let the memory reflect the real sequence of how knowledge arrived.
- Related sources get compiled together, not in isolation. The connections are the value.
- If nothing is unprocessed, say so and stop. A clean sync is a valid outcome.
- Don't sacrifice synthesis for speed. A shallow batch is worse than a slow one.
