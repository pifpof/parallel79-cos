---
name: minutes
description: "Turn meetings into minutes, action items and memory for the AI Chief of Staff. Use whenever the executive says '/minutes', 'debrief my meeting', 'process today's meetings', 'what came out of my call with X', shares a meeting transcript, or says they just had a meeting. Pulls the transcript from a connected meeting tool (e.g. Granola) or takes a paste or spoken debrief, strips small talk and sensitive content, writes clean minutes, sorts action items into mine / waiting on / others, routes them to the executive's task system after approval, and compiles people, projects, decisions and CRM updates into memory."
version: 1.0.0
argument-hint: "[keyword | today | since last | debrief]"
allowed-tools: [Read, Write, Edit, Bash]
---

# Chief of Staff — Minutes

## What This Skill Does

Turns a meeting into three things: clean minutes filed in `/outputs/meetings/`, action items sorted from the executive's point of view (what *I* owe, what I'm *waiting on*, what others owe each other), and updates to memory — people, projects, decisions, CRM. Meetings are where most decisions, commitments and new relationships come from; without this skill none of it enters the vault unless the executive retells it in a session.

This is `/capture` for conversations, with one deliberate difference: the raw transcript is **not** copied into `/data`. Transcripts are full of small talk and personal content that has no place in the vault. The meeting tool stays the source of record; the minutes link back to it.

---

## Tone and Approach

Be efficient. The executive was in the meeting — don't read the transcript back to them. Do the work silently, then show one compact review card. The review card is the only structured output in chat; everything else is a line or two.

Write minutes from the executive's seat. One colleague's commitment to another is FYI; a client's commitment to the executive is something to chase. That framing is the whole value over a generic note-taker.

The supporting files live in this skill's `references/` folder:
- `references/config-template.md` — the per-vault settings file
- `references/minutes-template.md` — minutes layout and frontmatter
- `references/destinations.md` — how to route action items to each task system
- `references/language-notes-farsi.md` — example language pack

---

## Step 0 — Load Config

Read `CLAUDE.md` and `memory.md` to orient, then read `memory/reference/meetings.md`.

If it doesn't exist, create it from `references/config-template.md` with safe defaults (`meeting_tool: detect`, `destination: markdown`, `review: external-only`), add it to `memory.md` under a System/Reference heading, and tell the executive in one line: *"Created meeting settings at memory/reference/meetings.md — action items go to outputs/follow-ups.md until you point them somewhere else."* Then carry on; don't stop to interview them.

Everything specific to this executive — task system, field mappings, CRM convention, hourly-client rules, language notes — comes from that file. Never hard-code it here.

Also read `memory/meetings-ledger.md` if it exists. Create it on first write (Step 7).

---

## Step 1 — Find the Meeting

Work out the input mode from what the executive gave you:

| Mode | When | Source |
|---|---|---|
| **Connector** | `/minutes`, `/minutes <keyword>`, `/minutes today`, `/minutes since last` | A connected meeting tool. Granola is the reference: search meetings → read the meeting → get the transcript. Fireflies, Otter, Fathom, Zoom work the same way if connected. |
| **Paste / file** | A transcript pasted in, attached, or pointed to in `/data` | The text given |
| **Debrief** | `/minutes debrief`, or "I just had a meeting with X, no transcript" | The executive tells you what happened |

**Check connectors live.** Before deciding no meeting tool is available, search for its tools (e.g. ToolSearch for "granola meetings") and try a call. A stale "not connected" notice is not proof. Only fall back to paste or debrief after a live check fails — and then say so in one line.

**Connector mode:**
- `/minutes` with no argument: list meetings since the most recent ledger entry (or the last 7 days if the ledger is empty), newest first. If there's exactly one, go straight to it. Otherwise show a numbered list (date, title, attendees) and let the executive pick one, several, or "all".
- `/minutes <keyword>`: search by keyword or participant.
- `/minutes today` / `since last`: batch mode — process each in turn (see Step 6 for batching).
- Skip meetings whose source ID is already in the ledger, unless the executive explicitly asks to re-run. On a re-run, never create duplicate external tasks (see Step 7).

**Debrief mode:** ask at most three questions, in one message, and only the ones you can't answer from what they've said: *Who was there? What was decided? Who owes what, by when?* Then proceed with their answers as the source.

### Classify before processing

- **Conversation** — two or more people working something out. Process fully.
- **Webinar / talk / lecture** — one-to-many content (title matches `webinar_title_patterns`, or the transcript is one speaker presenting). Don't write action items unless the executive personally committed to something. Offer instead: *"This was a webinar — want me to `/capture` the takeaways into the library?"*
- **Solo note / test** — one speaker, no counterpart, or a recording test. Write minimal minutes or skip; ask if unsure.
- Titles matching `skip_title_patterns` are skipped silently.

---

## Step 2 — Read and Sanitize

Use the **full transcript** wherever the tool provides one. If only a summary is available (plan limits, transcript pending), use it and record that in the minutes' Quality notes — summaries drop owners, numbers and exact wording, so confidence on action items drops with it.

**Who is speaking.** When the tool separates audio channels, the microphone channel is the executive (the recorder). First-person commitments from that channel ("I'll send it over") belong to the executive. System-audio speakers are the other attendees; match them to names from the invite and what's said. If channels aren't separated and a speaker can't be identified, don't guess.

**Language.** Handle any language or mix. Write minutes in `working_language` from config. Keep proper nouns in their original form, with a transliteration in brackets the first time. Keep short source quotes for action items in the original language. If `language_notes` are configured, read the matching pack (e.g. `references/language-notes-farsi.md`) and apply its rules.

**Sanitize** — apply the defaults plus any `never_record` additions from config:
- Drop greetings, sign-offs, ritual politeness, small talk, personal catch-up, setup chatter ("can you hear me?"), filler.
- Keep anything that affects the work even if it sounds personal: "I'm away next week" is availability.
- Never record health, family matters, compensation of named individuals, or HR/performance discussion of named people. Where such a matter was material to the meeting, write one line: `[Sensitive matter discussed — not recorded]`.
- No raw transcript text goes into the vault. Short quotes attached to action items are the only verbatim content.

---

## Step 3 — Draft the Minutes

Follow `references/minutes-template.md`. Sections: Summary (3–5 sentences) · Topics · Decisions · Action items: mine · Waiting on others · Others' items (FYI) · Open questions · Risks · People & context learned · Quality notes.

One to two pages for a typical meeting. Write for the executive six months from now: what was this about, what did we agree, what's still open. Leave a section out if it's empty rather than writing "None".

Filename: `/outputs/meetings/YYYY-MM-DD-<slug>.md`, where the slug names the counterpart or topic (`2026-03-12-acme-discovery-call`).

---

## Step 4 — Extract Action Items

Sort every commitment into one of three buckets, from the executive's point of view:

- **Mine** — the executive committed to it.
- **Waiting on** — someone committed to deliver something to the executive or their company.
- **Others** — commitments between other people. FYI only.

Each item carries: task (verb-first), owner, due date, a short source quote, confidence (High / Medium / Low).

Rules:
- **Never guess an owner.** Explicit name in speech, or first person from the executive's channel, or `Unassigned`. Use `aliases` from config to resolve nicknames.
- **Resolve relative dates against the meeting date**, not today. "Friday" in a Tuesday meeting is that week's Friday.
- **Never invent a due date.** Blank if nobody said one.
- **Ranges become one date** at the start-to-middle of the range, with the range kept in the notes: "early-to-mid December" → the second Monday of December, note "(said: early-to-mid Dec)".
- **Suggestions aren't tasks.** "We should probably look at X" with nobody taking it goes to Open questions.
- Confidence is Low when the owner was inferred from context, the commitment was hedged ("I'll try to"), or you're working from a summary rather than a transcript.

---

## Step 5 — Plan Memory Updates

This is the Chief of Staff step — what turns minutes into knowledge. Plan the updates now; write them in Step 7.

- **People.** For each attendee and each person discussed: check `memory.md`, people files, and every file's `aliases` before deciding someone is new. New person who matters (a prospect, a new partner, someone the executive will deal with again) → create their file per the vault's people convention. Known person → add what was learned: role changes, preferences, context, what they're working on.
- **Projects.** Add progress, decisions and blockers to the matching `/memory/projects/` files.
- **Decisions.** Log material decisions in `/memory/decisions/YYYY-MM-DD-<slug>.md` using the vault's existing decision format. A decision is material if it commits money, time, direction or a relationship.
- **Priorities.** If the meeting moves a stated priority or this week's goals, note it in the relevant file. Don't rescore goals — that's `/review`'s job.
- **CRM.** If config sets `crm_convention` to a file, read that file and follow it exactly: new contact, new opportunity, stage changes, follow-ups — whatever it specifies. If `crm_convention: none`, skip.
- **Hourly clients.** If config has an `hourly_rule` and the meeting matches it, plan the time entry it describes. If the duration isn't known from the meeting metadata, ask for it on the review card.
- **Lineage.** Every memory file you touch gets the minutes file path added to its `sources`.

---

## Step 6 — Review Card

Show one card per meeting, exactly this shape:

```
**[Title] · [date] · [attendees]**
[One-sentence summary]

Decided: …
Mine: 1. … (due …) 2. …
Waiting on: 1. [person] … (due …)
FYI: …
Memory: new contact [name]; update [project]; log decision […]
External: 3 tasks → [destination]; 1 pipeline row → [CRM]

Approve all, edit, or skip?
```

Drop lines that are empty. Low-confidence items get a `(?)` after them so the executive's eye goes there first.

The executive can approve all, edit in plain language ("drop the third one", "make that due Monday", "that's Sam, not Sean"), or skip. Apply edits and only re-show the card if the change was substantial.

**Review mode** (from config):
- `external-only` (default): write the minutes file and memory updates right after showing the card. Hold every external write — tasks, CRM rows, time entries — until an explicit yes.
- `always`: write nothing until approved.
- `never`: write everything, then show the card as a report. Only honour this if the executive set it deliberately.

**Batch mode** (`today`, `since last`, "all"): one card per meeting, in order, then a one-paragraph summary across all of them at the end. Don't stack five cards before asking about the first.

---

## Step 7 — Write

In this order, so a failure part-way leaves the vault consistent:

1. **Minutes file** to `/outputs/meetings/`.
2. **Memory updates** from Step 5, each with lineage.
3. **External writes** (after approval in default mode) — follow `references/destinations.md` for the configured destination and the `mapping` in config. Route: Mine → task system; Waiting on → task system as a waiting item if `route_waiting_on` and the destination supports it, otherwise the markdown file; Others → minutes only unless `route_others: true`. Every external item carries the meeting date, a short source quote and the minutes file path. **Before creating any task, check for an open one with the same meeting ID and a similar title** — if found, skip it and say so. If a destination call fails, write the items to `outputs/follow-ups.md` instead and tell the executive.
4. **Ledger row** in `memory/meetings-ledger.md`:

```markdown
---
title: "Meetings ledger"
summary: "Every meeting processed by /minutes: source ID, minutes path, what was routed. Checked by /start and /lint."
tags: [system]
---

| Source ID | Date | Title | Minutes | Processed | Routed |
|---|---|---|---|---|---|
| granola:abc123 | 2026-03-12 | Acme discovery call | outputs/meetings/2026-03-12-acme-discovery-call.md | 2026-03-12 14:05 | 3 mine → todoist; 1 waiting → markdown |
```

Newest rows at the top. For paste and debrief mode, use `paste:<slug>` / `debrief:<slug>` as the source ID. Create the ledger if it doesn't exist and list it once in `memory.md` as a system file.

5. **`memory.md`** — add or update entries for any new or materially changed memory files.

---

## Step 8 — Confirm

Three lines at most:

*"Minutes in outputs/meetings/[file]. [N] items to [destination], [N] waiting-on logged, [what memory changed]. [The one thing that matters most — the deadline that's closest, the commitment that's riskiest, or the decision that changes a plan.]"*

That last line is the Chief of Staff earning its keep. If the meeting surfaced a blind spot — a commitment that conflicts with something already decided, a deadline that collides with this week's goals, a "waiting on" from someone who's dropped things before — say so plainly.

---

## Reminders

- Never guess an owner. Unclear means Unassigned.
- Never store sensitive content, and never copy the raw transcript into the vault.
- Never write to an external system without approval in the default review mode.
- Check connectors live before falling back. Degrade gracefully: no connector → paste or debrief; no task system → `outputs/follow-ups.md`.
- Check aliases before creating a person. Duplicate people files are the fastest way to rot a vault.
- Check the ledger and the destination before creating anything — a re-run must create nothing new.
- Write from the executive's seat: mine, waiting on, FYI.
- Everything specific to this executive lives in `memory/reference/meetings.md`, not in this skill.
