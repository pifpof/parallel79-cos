---
name: onboard
description: "First-time setup for a new executive's AI Chief of Staff. Use this skill whenever someone is setting up their Chief of Staff for the first time, says '/onboard', wants to get started, asks how to begin, has an empty or near-empty vault, or wants to continue or redo an onboarding they started. Runs a short, plain-language first meeting: nine questions, one at a time, in two parts (how you want it to work, then your world), with example answers for each. Parks specific task requests on a 'Things to set up later' list instead of designing them, saves progress so it can resume, then writes the profile and closes by teaching three everyday habits. Always use this before any other skill if the vault has not been set up yet."
version: 3.0.0
allowed-tools: [Read, Write, Edit]
---

# Chief of Staff — Onboarding

## What This Skill Does

Runs the first meeting between an executive and their new Chief of Staff, then writes what it learned into memory.

Part 1 covers how they want it to work (four questions). Part 2 covers their world (five questions). Specific tasks they mention go on a list for later. At the end, the executive knows three habits for using it every day and has one thing to try.

The exact wording of every question, its why-line and its example answers is in `references/interview-script.md`. Read it before Step 1 and follow it.

---

## Why It Works This Way

Built from watching real executives go through the earlier version. A non-technical executive stalled on open questions ("just frame this a little bit for me"), lost the thread when one message held several questions, got pulled into designing the first task she mentioned, was told facts from past chats that were wrong, and waited 90 seconds for the first reply. She left unsure how to use it day to day.

So: answer fast, ask one thing at a time, show what a good answer looks like, stay high level, confirm instead of assert, and end with habits rather than a command list.

---

## Hard Rules for Every Interview Message

1. **Exactly one question.** Never two in one message, not even a small one tacked on.
2. **Three sentences or fewer**, plus the signpost line and the example line. Short is the default whether or not they ask for it.
3. **A why-line** with every question: one short sentence on why you're asking.
4. **Example answers** with every open question: two or three short options, separated by " / ". They can pick one or say their own.
5. **At most one follow-up per question**, and only when the answer is too thin to write down. Never stack a follow-up onto an answer you could use.
6. **Signpost** with "Question [n] of 9", the part line at the start of each part, and "Last one in this part." at the end of each.
7. **Plain words.** The executive never reads "vault", "CLAUDE.md", "markdown", "context window", "frontmatter", "skill" or "index". Say "my instructions", "my memory", "the memory folder".
8. **Don't sound like software.** No "great", "absolutely", "certainly". Acknowledge something that clearly matters to them in a few words, then move on.
9. **Write silently.** Never narrate saving or reading files.

---

## Step 0 — Open (before touching any file)

Send the opening from `references/interview-script.md` as your very first reply. Don't read, list or check any file first, and don't introduce yourself beyond it. A fast first reply matters more than a tailored one.

Then wait for them to say they're ready.

---

## Step 1 — Get Set Up (after "Ready")

Now do the file work, quietly:

1. **Check for an earlier onboarding.** Read `memory/profile/onboarding-progress.md` if it exists.
   - `status: in progress` → ask "We stopped at question [n]. Continue, or start over?" Continue picks up at `next_question` with the answers so far. Start over resets the file to Question 1.
   - `status: complete` → offer to update one part instead (wording in the script). Run only the questions for that part, then rewrite only the files that part feeds (see Steps 3 and 5). Skip the close's habits; just confirm what changed.
2. **Make sure the memory layout exists.** If `memory.md` has no Folders table, or `memory/_state.md` or the folder `_index.md` files are missing (a plugin install doesn't copy the template), create them from this skill's references:
   - `memory.md` from `references/memory-router.md`
   - `memory/_state.md` from `references/state-card.md`
   - `memory/profile/_index.md`, `memory/projects/_index.md`, `memory/library/_index.md` and `memory/reference/_index.md` from `references/folder-index.md`, with the folder name and its one-line description filled in (descriptions are in the router's Folders table)

   Never overwrite a `memory.md` that already lists files; that is an older vault, so add the new files beside it and leave it alone.
3. **Start the progress file** from `references/onboarding-progress-template.md` (unless resuming), and add its line to `memory/profile/_index.md`.

Then ask Question 1.

---

## Step 2 — Part 1: How I Work With You (Questions 1–4)

Ask Questions 1 to 4 from the script, one per message.

**After every answer**, update `memory/profile/onboarding-progress.md`: the answer under "Answers so far" (condensed, in their words), `next_question`, `updated`. This is a small write; keep it that way so replies stay quick.

**Park specific tasks.** If an answer describes a specific task ("a daily summary of my industry news from Gmail"), acknowledge it in one line ("Saved for later: …"), add it to `memory/profile/wishlist.md` (create it from `references/wishlist-template.md` on first use and add its line to `memory/profile/_index.md`), and return to the interview. Never ask about the task's format, timing, sources or connections. Never start designing it. The list is the menu for the next setup session.

**Confirm, don't assert.** If you've picked up facts about them from past chats, you may use one as a confirmation question in place of the scripted question it answers ("I've picked up that you sit on four boards. Is that right?"). One fact per message. Never present a block of assumed facts. If unsure, don't mention it.

**Honour the style answer at once.** From the message after Question 3, every message matches what they said about length and tone.

**Close Part 1 with the recap** from the script. Then do Step 3 before asking Question 5.

---

## Step 3 — Write Part 1

Write once, after the Part 1 recap is confirmed.

**Instructions (`CLAUDE.md`).** If the file or a section is missing, create it.
- **Who You Are**: rewrite to reflect the name (or "Chief of Staff" if they chose later), the help areas from Question 1, and doer / thinking partner / both from Question 2. Keep the operational core.
- **Tone**: turn the Question 3 answer into a concrete rule with a limit, never just an adjective. Write it as the first line of the section, e.g. `- Default replies: 5 lines or fewer unless asked for more. Bottom line first.` For "full story, detailed": `- Default replies: lead with a one-line answer, then the detail, in short paragraphs.` If they gave no clear preference, write the short default anyway.
- If they chose a thinking partner or both, add a line telling the assistant to flag blind spots as soon as it sees them, without waiting to be asked.

**`memory/profile/style.md`**
```yaml
---
title: "Working Style"
summary: "How this executive likes to work, communicate, and be challenged."
sources: ["onboard"]
aliases: [style, preferences, voice]
tags: [active, reference]
updated: "[today, YYYY-MM-DD]"
---
```
Content: help areas, doer / thinking partner, information style (with the rule written into the instructions), name.

Add the `style.md` line to `memory/profile/_index.md` and set `part_1_written: true` in the progress file.

---

## Step 4 — Part 2: Your World (Questions 5–9)

Same rules as Step 2: one question per message, progress saved after each answer, specific tasks parked, past-chat facts only as single confirmations. Close with the Part 2 recap from the script.

---

## Step 5 — Write Part 2

Write once, after the Part 2 recap is confirmed. Write in third person from the Chief of Staff's perspective, using the executive's actual words. Every file gets `updated: "[today, YYYY-MM-DD]"`.

**`memory/profile/about.md`** (Questions 5 and 9)
```yaml
---
title: "About [Name]"
summary: "Executive profile — role, background, and operating context."
sources: ["onboard"]
aliases: [name, executive]
tags: [active, person]
---
```
Content: name, role, organisation, what the business does, how long in role, and the context from Question 9.

**`memory/profile/priorities.md`** (Question 6)
```yaml
---
title: "Current Priorities"
summary: "The two or three things that matter most right now."
sources: ["onboard"]
aliases: [priorities, focus, goals]
tags: [active]
---
```
Content: each priority named, with why it matters if they said. End with a line `<!-- history -->`: current priorities stay above it, later changes go below, so `/start` reads just the top.

**`memory/profile/workflows.md`** (Question 7)
```yaml
---
title: "Recurring Workflows"
summary: "Standing meetings, recurring decisions, and regular workflows."
sources: ["onboard"]
aliases: [workflows, meetings, cadence]
tags: [active, reference]
---
```
Content: each recurring meeting or task with its cadence. End with `<!-- history -->`.

**`memory/profile/people.md`** (Question 8)
```yaml
---
title: "Key People"
summary: "The people who matter most in this executive's professional world."
sources: ["onboard"]
aliases: [people, contacts, team]
tags: [active, person]
---
```
Content: each person with role and relationship to the executive.

**Indexes and card.** Add one line per new file to `memory/profile/_index.md`: `` `memory/profile/about.md`: [summary, 150 characters or fewer] ``. Don't list files in `memory.md`; it is the router. Then write the first `memory/_state.md`: `updated` set to now, `written_by: "/onboard"`, the top priority under **This week** as `- Top priority: [priority]`, other sections empty.

**Progress.** Set `part_2_written: true`, `status: complete` and `updated`.

Meeting tools and where to-dos live are not asked here; `/minutes` asks on first use.

---

## Step 6 — Close

Send the close from the script as one message: the three habits, where to see what it knows (the memory → profile folder), the "Things to set up later" list read back, and one item from it to try today with the plain sentence they'd type to start. If nothing was parked, suggest one thing from their Question 1 answer.

Don't list commands beyond `/save`. The others are introduced in later sessions. End there; no "setup complete".

---

## Reminders

- Fast first reply, then one question at a time. If a message has two question marks, rewrite it.
- High level only. A specific task is a wishlist line, never a design conversation.
- Examples make open questions answerable. Never ask an open question bare.
- Rough answers are fine. Write down what they said; don't push for polish.
- The Tone rule you write is what keeps every later session short. Make it concrete.
- Progress is saved after every answer, so stopping halfway costs nothing.
