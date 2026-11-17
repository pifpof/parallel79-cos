---
name: health-check
description: "Health check for the AI Chief of Staff's memory. Use this skill whenever the executive says '/health-check', '/lint', asks to 'clean up the wiki', 'check the memory', 'tidy things up', wants to know if the system is healthy, or periodically as maintenance to keep the knowledge base from degrading. Scans memory for gaps, stale files, missing metadata, contradictions, orphaned sources, an index that has grown too large and a stale hot-state card, then reports what needs attention and fixes what it safely can, including rebuilding the folder indexes and the card from the files, checks Open Knowledge Format (OKF) conformance and broken links, and offers to upgrade an older vault one step at a time. Run it weekly or monthly. It is what stops a long-running wiki from rotting over time. (Formerly named /lint. Same behaviour.)"
version: 2.0.0
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

## Step 0 — Which Layout Is This?

Read `layout:` in `memory.md`'s frontmatter:

- **`"2.2"`** — the current layout: an OKF v0.2 bundle. Frontmatter uses `type`, `description`, `generated` (`by`, `at`), `sources` as `- resource:` entries, and `next` on projects. Each folder has `index.md` (no frontmatter, `- [Title](./file.md): description` lines) and `log.md` (no frontmatter, newest first, `## YYYY-MM-DD` headings). Files link to each other with relative markdown links.
- **No `layout`, but `memory.md` has a Folders table and folders have `_index.md`** — layout 2.0: `summary`, `updated`, a free-text project `status`, `_index.md`, history below `<!-- history -->`.
- **No `layout`, `memory.md` lists files** — pre-2.0.

Check the vault against the rules for its own layout. Never convert it silently: upgrades are offered in "Needs your call" (Step 3) and run only on a yes.

---

## Step 1 — Scan the Vault

Read `memory.md` (the router) and walk the full memory structure. This is the one skill that reads every file's frontmatter; it doesn't need to read every file's body. Check `/data` against the compiled record. Look for each of the following:

**Missing or malformed metadata:**
- Files in `/memory` with no metadata block, or with empty required fields (`title`, and `description` or `summary`)
- **Layout 2.2:** any file other than `index.md` and `log.md` with no `type` (the one field OKF requires), or a `type` outside profile, person, project, client, decision, source, reference, system; `sources` written as plain strings; a `status` field used as a free-text project line (OKF reserves `status` for draft / stable / deprecated)
- Inconsistent or missing `tags`
- Files with no `generated` (or, before 2.2, `updated`)
- Project files with no `next` line (before 2.2: `status`), or one that contradicts the file's body (says "waiting on contract" when the body logs it as signed)

**Links:**
- Markdown links between memory files whose target doesn't exist (resolve each relative link from the file it's in). Report them; don't delete them
- Files that name a person, project or decision that has its own file, with no link to it (report a handful, not every instance)

**Index and budget (the light-start contract):**
- `memory.md` over 6 KB, or listing individual files rather than folders (an older layout; see Step 2)
- A memory folder with no index (`index.md` in 2.2, `_index.md` before), or with no row in the router's Folders table
- Index lines pointing to files that don't exist, files missing from their folder's index, and lines over 150 characters
- **Layout 2.2:** an `index.md` or `log.md` with frontmatter (OKF says none, except `okf_version` in `memory/index.md`); a folder with no `log.md`; log entries not grouped under `## YYYY-MM-DD` headings, or not newest first; a `memory/index.md` missing or not listing every folder
- `memory/profile/about.md` or `style.md` over 2 KB
- Files carrying their own changelog: in 2.2 any history in a file belongs in the folder's `log.md`; before 2.2, a growing changelog with no `<!-- history -->` line (priorities and workflows above all)
- The `/start` hot set (router + card + about + style + the top of priorities) well over 12 KB

**Hot-state card (`memory/_state.md`):**
- Missing, over 2 KB, or `generated.at` (before 2.2: `updated`) more than 7 days ago
- Older than files it summarises (any project file or goals file modified after the card)
- Lines that don't trace to a file: a project on the card that isn't tagged `active`, an active project missing from the card, a #1 goal that differs from the current goals file

**Stale status:**
- Files tagged `active` that haven't changed in a long time and may be done or abandoned
- Projects with no recent activity that should perhaps move to `archived` or `/trash`

**Orphaned sources:**
- Files in `/data` that don't appear in any memory file's `sources` (as a `resource`, or a plain filename in older files) — raw material that was never compiled (these are candidates for `/sync`)

**Stale sources (edited since last compile):**
- Compare each `/data` file's last-modified time (Bash `find`/`stat`) against its `last compiled` time in `memory/sync-ledger.md`. Any file modified after it was compiled is stale: memory may be missing whatever was added. Candidates for `/sync`.
- Files referenced in `sources` but missing from the ledger are **unverified**, not clean. Flag them for `/sync` too.
- A filename appearing in `sources` is never, on its own, proof that a source is current.

**Unindexed initiatives:**
- Living documents in `/data` (roadmaps, backlogs, plans, trackers) often hold several initiatives under separate headings. For each such heading that names a project, offering, event or initiative, check that a folder index has a line pointing to it. Any that don't are invisible to `/start` and `/query`. Report them by name.

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
- Router rows or index lines that point to files or folders that don't exist, or files missing from their folder's index

---

## Step 2 — Fix What's Safe

Some issues you can fix without asking. Do these automatically and note them in the report:

- Add missing metadata blocks to files that clearly need them, inferring `title` and `description` (`summary` before 2.2) from content. In 2.2, add a missing `type` when the folder makes it obvious (`projects/` → `project`, the card and ledgers → `system`)
- **Rebuild every folder index from frontmatter.** One line per file, in the layout's format (2.2: `- [Title](./file.md): description`; before: `` `memory/<folder>/<file>.md`: hook ``), 150 characters or fewer, from its `description` or `summary`. This is safe because the frontmatter is the source of truth; the index is derived. Create any missing index (and, in 2.2, any missing `log.md` and `memory/index.md` entry), and add any missing folder row to the router
- **Rebuild `memory/_state.md`** from the files when it's missing, stale or inaccurate, in the format `/save` uses, with `generated.by: "/health-check"` (before 2.2: `written_by`). Safe for the same reason: the card is derived
- Add a missing `generated` (`by: "executive"`, `at:` the file's last-modified time), or `updated` before 2.2
- Keep `memory.md` a router: if it has grown file-by-file lines, move each line into its folder's index (nothing is lost; it changes place) and leave only the folder rows, the "Where to look" table and the system files. If the vault is an older one that still lists files throughout, don't convert it silently: offer the conversion in "Needs your call"

- Fix obvious tag inconsistencies
- Flag orphaned and stale `/data` sources for sync (don't auto-process them — that's `/sync`'s job, and the executive may want to review first)
- Add a one-line pointer in the right folder's index for any unindexed initiative found in a `/data` living document (pointer only; the detail stays where it is)
- Create `memory/sync-ledger.md` if it's missing (empty table), so the next `/sync` can start recording
- Add a ledger row for any minutes file that has a `source_id` but no row (the minutes exist; the ledger just missed them)

Do **not** automatically:
- Write a project's `next` (or `status`) line, or move history out of a file: both change what the file says. Propose the edit instead
- Upgrade the vault's layout, rename fields or files, or reshape `sources`. Offer it (Step 3)
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
- Project files missing a `next` (or `status`) line — here's a proposed line for each, OK to write?
- Broken links — fix the ones with an obvious target, and list the rest?
- **An upgrade, one step at a time** (offer only the next step for this vault, say what it changes and that nothing is deleted):
  - **Pre-2.0 → 2.0:** `memory.md` still lists every file. Convert it to the router and folder indexes? (say how much smaller the start would get)
  - **2.0 → 2.2 (Open Knowledge Format):** rename `_index.md` to `index.md` and rewrite them as links; add a `log.md` to each folder and move each file's `<!-- history -->` section into it (dated lines, newest first); add `memory/index.md`; in every file, add `type`, rename `summary` → `description`, `updated` → `generated` (`by: "executive"` unless known, `at:` that date), a project's `status` → `next`, and plain `sources` → `- resource:` entries; set `layout: "2.2"` and `okf_version: "0.2"` in `memory.md`. Also offer to add `references/memory-file-format.md` to the vault's `CLAUDE.md` as its "Memory File Format" section, replacing the old one. Show a count of files affected before asking.
  - In 2.2, files still in older fields (written by hand or by another tool): convert them? (name them)
Each as a short, specific question.

**Overall:**
One line on the state of the system. "Healthy, minor cleanup done" or "A few things need your attention before the next review."

---

## Step 4 — Act on Decisions

If the executive answers the open questions — yes archive that, this file is the correct one, go ahead and sync — act on those decisions now. Update files, move things to `/trash` with a note, or trigger `/sync` as needed. Then rebuild the affected folder indexes and the card to reflect the final state.

**Running an upgrade.** Work folder by folder. Rename with `mv` (or `git mv` if the vault is its own Git repo), never by deleting and recreating. Move history; don't summarise it away: each dated entry below a `<!-- history -->` line becomes a log line under its date, and the marker line is removed once the file is empty below it. Keep every unknown frontmatter field as it is. Set `layout` in `memory.md` last, only when every folder is done, so a half-finished upgrade still reads as the old layout. Then rerun Step 1 on the result and report what's left.

---

## Reminders

- Fix the safe things silently; surface the judgment calls. Never make a status or deletion decision that belongs to the executive.
- Orphaned and stale sources are a `/sync` job — flag them, don't process them here. Undebriefed meetings are a `/minutes` job — same rule.
- "Referenced in `sources`" is not the same as "current." Check modified times against the ledger.
- Contradictions get surfaced, never silently resolved. The executive knows which version is true.
- Trash is not delete. When the executive approves removal, move to `/trash` with a note — never hard-delete.
- The folder indexes and the card are derived. Rebuild them freely. The files and their frontmatter are the truth.
- Upgrades are offered one step at a time and run only on a yes. The vault's `layout` line changes last.
- The budgets exist so `/start` stays light as the vault grows. Report the hot-set size in the Overall line.
- A clean report is a valid outcome. If the system is healthy, say so and stop.
