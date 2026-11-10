---
name: capture
description: "Ingest a source into the AI Chief of Staff's memory. Use this skill whenever the executive says '/capture', shares a URL, file, article, report, or document and wants it added to their system, says 'add this', 'save this source', 'read this and remember it', or drops in material they want the Chief of Staff to absorb. Clips the source into /data, reads it, extracts the takeaways that matter, and updates every relevant memory file. This is how new knowledge enters the system — the compilation step that turns raw material into structured memory."
version: 1.2.0
allowed-tools: [Read, Write, Edit, WebFetch]
---

# Chief of Staff — Capture

## What This Skill Does

Takes a single source — a URL, a file, a pasted document — and folds it into the system. The raw material is preserved in `/data`, and the knowledge inside it is compiled into the wiki where it becomes part of what the Chief of Staff knows.

This is the intentional ingest: "I want this specific thing in my system." It is the most important habit after `/save`, because it's how the library grows.

---

## Tone and Approach

Be efficient and thorough. The executive handed you something because they want it absorbed, not summarized back at them. Read it, extract what matters, file it correctly, and confirm what you did in a few lines.

The value is in the synthesis — connecting the new source to what's already in memory. A capture that just dumps a summary into a file is half the job. A capture that updates three existing project pages because the source touches all of them is the system working as intended.

---

## Step 1 — Take in the Source

Identify what was handed to you:

- **A URL** — fetch it and read the full content. Preserve the text as Markdown.
- **An uploaded file** — read it using the appropriate method for its type.
- **Pasted text** — use it directly.

If the source is a **meeting transcript** or meeting notes, hand it to `/minutes` instead and say so in one line. `/minutes` extracts action items and keeps the raw transcript out of `/data` — capturing it here would store exactly the small talk and personal content it's designed to strip. Webinars and recorded talks are the exception: those are content, and `/capture` is the right home for them.

If the source can't be accessed — a broken link, a paywalled page, a file that won't read — say so plainly and ask the executive how they'd like to proceed. Don't guess at content you couldn't read.

---

## Step 2 — Preserve the Raw Source

Write the source into `/data` as an append-only record. Never edit it after this — it is the source of truth.

Filename: `/data/[YYYY-MM-DD]-[descriptive-slug].md`

At the top of the file, add a short provenance header:

```markdown
> Source: [URL or filename]
> Captured: [date]
> Type: [article / report / transcript / notes / etc.]

---

[full content]
```

---

## Step 3 — Extract What Matters

Read the source with the executive's context in mind. You know their priorities, projects, and people — read through that lens. Ask:

- What in here is relevant to an active priority or project?
- Does this inform a decision the executive is weighing?
- Does it mention a person, company, or topic already in memory?
- Is there a fact, number, or insight worth retaining on its own?

Pull out the takeaways that matter to *this* executive. Ignore what's irrelevant to them — a capture is not a book report.

---

## Step 4 — Update Memory

This is the compilation step. Based on what you extracted:

**Update existing files** where the source is relevant:
- Add the insight to the relevant `/memory/projects/` file
- Add to a person's entry if the source informs it
- Note the new `source` filename in the metadata block of any file you update

**Create a new library file** if the source introduces a topic worth retaining on its own:

`/memory/library/[topic].md`

```yaml
---
title: ""
summary: ""
sources: ["[the data filename you just created]"]
aliases: []
tags: [reference]
---
```

Always set `sources` to point back to the `/data` file. This is the lineage — the executive can always trace a piece of knowledge back to where it came from.

---

## Step 5 — Update memory.md and Confirm

Update `memory.md` to reflect any new or changed files.

Then add or update the source's row in `memory/sync-ledger.md` (source path, current time, memory files it fed) so `/sync` and `/health-check` know it's compiled and current. Create the ledger if it doesn't exist.

Then confirm to the executive in a few lines:

*"Captured. [One sentence on what the source was.] I've updated [what you updated] and filed the source in /data. [One line on the single most useful thing in it, if there is one.]"*

Keep it tight. The point of capture is that the knowledge is now *in the system* — the executive doesn't need a full readout.

---

## Reminders

- Preserve the raw source untouched. Compile knowledge into the wiki, never into `/data`.
- Read through the lens of what this executive cares about. Relevance is everything.
- The synthesis — connecting the source to existing memory — is the real work. Don't skip it.
- Always set lineage via `sources`. Untraceable knowledge erodes trust in the system.
- If a single source touches multiple projects, update all of them. That cross-linking is what makes the system smarter than a folder of files.
