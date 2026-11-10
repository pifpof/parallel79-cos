---
name: health-check
description: "Health check for the AI Chief of Staff's memory. Use this skill whenever the executive says '/health-check', '/lint', asks to 'clean up the wiki', 'check the memory', 'tidy things up', wants to know if the system is healthy, or periodically as maintenance to keep the knowledge base from degrading. Scans memory for gaps, stale files, missing metadata, contradictions, and orphaned sources, then reports what needs attention and fixes what it safely can. Run it weekly or monthly. It is what stops a long-running wiki from rotting over time. (Formerly named /lint. Same behaviour.)"
version: 1.3.0
allowed-tools: [Read, Write, Edit, Bash]
---

# Chief of Staff — Health Check

## What This Skill Does

Runs a health check across the entire memory and reports what it finds. Over time, any knowledge base accumulates rough edges — files missing metadata, projects marked active that are really done, sources dropped in `/data` that never got compiled, two files that quietly contradict each other. Left alone, these degrade the quality of every brief, query, and review.

The health check catches them. The executive runs it periodically — weekly or monthly — to keep the system clean. This is what makes a wiki maintainable where human-maintained wikis fail: the maintenance burden falls on the Chief of Staff, not the executive.

---

## Tone and Approach

Be systematic and honest. This is a diagnostic, so report problems plainly — but distinguish between what you fixed automatically and what needs the executive's judgment. Don't make decisions that are theirs to make.

The output should leave the executive confident the system is healthy, or clear on exactly what needs their attention.

---

## Step 1 — Scan the Vault

Read `memory.md` and walk the full memory structure. Check `/data` against the compiled record. Look for each of the following:

**Missing or malformed metadata:**
- Files in `/memory` with no metadata block, or with empty required fields (`title`, `summary`)
- Inconsistent or missing `tags`

**Stale status:**
- Files tagged `active` that haven't changed in a long time and may be done or abandoned
- Projects with no recent activity that should perhaps move to `archived` or `/trash`

**Orphaned sources:**
- Files in `/data` that don't appear in any memory file's `sources` — raw material that was never compiled (these are candidates for `/sync`)

**Stale sources (edited since last compile):**
- Compare each `/data` file's last-modified time (Bash `find`/`stat`) against its `last compiled` time in `memory/sync-ledger.md`. Any file modified after it was compiled is stale: memory may be missing whatever was added. Candidates for `/sync`.
- Files referenced in `sources` but missing from the ledger are **unverified**, not clean. Flag them for `/sync` too.
- A filename appearing in `sources` is never, on its own, proof that a source is current.

**Unindexed initiatives:**
- Living documents in `/data` (roadmaps, backlogs, plans, trackers) often hold several initiatives under separate headings. For each such heading that names a project, offering, event or initiative, check that `memory.md` has a line pointing to it. Any that don't are invisible to `/start` and `/query`. Report them by name.

**Broken lineage:**
- Memory files whose `sources` point to `/data` files that no longer exist
- `aliases` that collide across files, which would make `/query` ambiguous

**Meetings (only if `memory/reference/meetings.md` exists):**
- The config itself: required settings present (`meeting_tool`, `destination`, `review`), values from the allowed lists, and a non-placeholder `mapping` when `destination` isn't `markdown`. A broken config means `/minutes` silently routes nowhere useful.
- `memory/meetings-ledger.md` rows whose minutes file no longer exists, and minutes files in `/outputs/meetings/` with no ledger row.
- Minutes files missing frontmatter or a `source_id`.
- If a meeting tool is connected, meetings older than 7 days that aren't in the ledger — commitments from those meetings are untracked. Candidates for `/minutes`. Skip titles matching `skip_title_patterns`.
- Memory files whose `sources` point to an `outputs/meetings/` file that doesn't exist (same as broken lineage for `/data`).

**Contradictions and gaps:**
- Two memory files that state conflicting facts
- Topics referenced repeatedly across files but lacking their own entry
- `memory.md` entries that point to files that don't exist, or files missing from the index

---

## Step 2 — Fix What's Safe

Some issues you can fix without asking. Do these automatically and note them in the report:

- Add missing metadata blocks to files that clearly need them, inferring `title` and `summary` from content
- Update `memory.md` to match the actual state of the vault — add missing entries, remove dead ones, refresh summaries
- Fix obvious tag inconsistencies
- Flag orphaned and stale `/data` sources for sync (don't auto-process them — that's `/sync`'s job, and the executive may want to review first)
- Add a one-line `memory.md` pointer for any unindexed initiative found in a `/data` living document (pointer only; the detail stays where it is)
- Create `memory/sync-ledger.md` if it's missing (empty table), so the next `/sync` can start recording
- Add a ledger row for any minutes file that has a `source_id` but no row (the minutes exist; the ledger just missed them)

Do **not** automatically:
- Move anything to `/trash` or change `active` to `archived` — status is the executive's call
- Resolve contradictions by picking a winner — surface them instead
- Delete anything, ever

---

## Step 3 — Report

Give the executive a clean health report:

---

**Memory health check · [date]**

**Fixed automatically:**
What you cleaned up without needing input. Keep it brief — a few lines. If nothing needed fixing, say the system is clean.

**Needs your call:**
The things only the executive can decide:
- Projects that look done but are still marked active — archive them?
- Contradictions between files — which is correct?
- Orphaned or stale sources in /data — run /sync to process them? (name the files and, for stale ones, when they were last edited vs. compiled)
- Meetings older than a week with no minutes — run `/minutes` on them? (name them)
- Meeting settings that look broken — fix now? (name the setting)
Each as a short, specific question.

**Overall:**
One line on the state of the system. "Healthy, minor cleanup done" or "A few things need your attention before the next review."

---

## Step 4 — Act on Decisions

If the executive answers the open questions — yes archive that, this file is the correct one, go ahead and sync — act on those decisions now. Update files, move things to `/trash` with a note, or trigger `/sync` as needed. Then update `memory.md` to reflect the final state.

---

## Reminders

- Fix the safe things silently; surface the judgment calls. Never make a status or deletion decision that belongs to the executive.
- Orphaned and stale sources are a `/sync` job — flag them, don't process them here. Undebriefed meetings are a `/minutes` job — same rule.
- "Referenced in `sources`" is not the same as "current." Check modified times against the ledger.
- Contradictions get surfaced, never silently resolved. The executive knows which version is true.
- Trash is not delete. When the executive approves removal, move to `/trash` with a note — never hard-delete.
- A clean report is a valid outcome. If the system is healthy, say so and stop.
