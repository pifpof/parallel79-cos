# Your AI Chief of Staff

You've just hired a Chief of Staff. Not a chatbot you open when you need an answer — a system that knows your business, remembers your context, and works alongside you every day.

This guide explains how it works and how to use it. It takes about five minutes to read. You won't need anything technical.

---

## The Idea in One Minute

Most people use AI like a search engine. Ask a question, get an answer, close the tab. Nothing accumulates. Every conversation starts from zero — the system never remembers last week's decision or last quarter's context.

Your Chief of Staff is different. It keeps a memory. Every time you work with it, it learns a little more about your business, your priorities, and how you operate. Over time it stops being a tool you use and becomes a colleague who already knows what's going on.

The whole system rests on one simple habit:

> **Your conversation is working memory. Your vault is long-term memory. "Save to memory" is the save button.**

When you're talking to your Chief of Staff, everything is live — but temporary. When you save to memory, what mattered gets written down permanently. Next time, it's still there. That's the entire trick. Master that one habit and everything else follows.

---

## How You'll Use It

Two commands bookend almost every session:

**Start with `/start`** — your Chief of Staff reads everything it knows and opens with a brief on where things stand. You never have to catch it up.

**End with `/save`** — before you close, it writes down what changed: decisions you made, priorities that shifted, anything new. This is what makes tomorrow's session pick up cleanly.

That's the core loop. Start the session, save at the end. Everything in between is the actual work.

`/start` is also where you go beyond the everyday. The standing rules that shape your Chief of Staff live in `CLAUDE.md` and load automatically, every session — deliberately lightweight, since they're read constantly. Some context is useful but too slow to fetch by default: pulling today's calendar, checking a project tracker, querying a CRM. `/start` is where you ask for that, just for this session — type something like `/start also check our project tracker for anything overdue` and your Chief of Staff will go get it before opening with the brief.

---

## The Nine Commands

You don't need to memorize these. You'll learn them by using them. But here's the full set so you know what's available.

### Every day

**`/start`** — Start a session. Your Chief of Staff restores context and tells you where things stand. If you keep weekly goals in `/outputs/goals/` (one `YYYY-MM-DD-weekly-goals.md` file per week), it also reads this week's goals and tells you where your #1 goal stands. Add extra instructions right on the command — `/start also check X` — for anything this particular session needs that's beyond the standing rules in `CLAUDE.md`.

**`/save`** — End a session. Writes what changed back to memory so nothing is lost.

### Every week

**`/review`** — A step back. What moved this week, what stalled, what patterns are showing up, and the one priority for the week ahead. This is where the system earns its keep — it sees things across weeks that you're too close to notice.

### Feeding the system

**`/capture`** — Hand it something to remember. A link, a report, a document. It reads it, pulls out what matters to you, and files it. Next time it's relevant, your Chief of Staff already knows it.

**`/sync`** — Dropped a stack of files in and want them all absorbed at once? This catches the system up on everything new.

**`/minutes`** — Turn a meeting into minutes and action items. If you record meetings with a tool like Granola, it pulls the transcript itself; otherwise paste one in, or just type `/minutes debrief` and tell it what happened. It strips the small talk, writes clean minutes into `outputs/meetings/`, and sorts the action items from your point of view: what *you* owe, what you're *waiting on* from others, and what others owe each other. Then it updates memory — new people, project progress, decisions — and, once you say yes, sends your to-dos to your task system. `/minutes today` does all of today's meetings in one go. The first run creates a settings file at `memory/reference/meetings.md` where you tell it where your to-dos live; until then they go to `outputs/follow-ups.md`.

### Asking the system

**`/query`** — Ask a question and get an answer drawn from your own accumulated knowledge — not the open internet. "What did we decide about the vendor contract?" "Pull together everything we know about this client." The longer you've used the system, the better these answers get.

### Keeping it healthy

**`/lint`** — A tune-up. Every so often, run this and your Chief of Staff checks its own memory for anything stale, missing, or contradictory, cleans up what it safely can, and flags anything that needs your call. Weekly or monthly is plenty.

---

## Where Everything Lives

Your system is just a folder of files on your computer. Nothing is locked away in an app you can't see. You can open any of it, any time. Most people never need to — your Chief of Staff does all the writing — but it's yours, and it's readable.

The folder has a few parts:

- **`data`** — Raw material you've fed in. Reports, articles, documents. Never changed once it's there. This is the record of everything the system has ever read.
- **`memory`** — What your Chief of Staff actually knows. Your profile, your projects, and a library of everything worth retaining. This is the part that compounds.
- **`outputs`** — Things it produces for you. Briefs, answers, weekly reviews, meeting minutes.
- **`trash`** — Things you've removed from the picture but don't want gone forever.

If you want to *see* your system rather than just talk to it, open the folder in **Obsidian**. It turns your memory into a visual map you can browse and click through. You don't need it to use the system — but it's a satisfying way to watch your knowledge base grow.

---

## Getting the Most Out of It

**Save often.** The single biggest difference between people who get value from this and people who don't is the save habit. If something useful happened in a conversation, save it before you leave. A system you don't save to is just a chatbot.

**Feed it.** The more you capture, the smarter it gets. When you read something that matters to your business, hand it over. Every source makes every future answer better.

**Talk to it like a colleague, not a search box.** It has context. Use it. "What should I be worried about going into the board meeting?" is a better question than anything you'd type into Google — because it knows your board, your business, and your last three months.

**Debrief your meetings.** Most of your decisions and commitments happen in meetings. Run `/minutes` after the important ones — or `/minutes today` at the end of the day — and none of it depends on you remembering to retell it.

**Let it push back.** A good Chief of Staff doesn't just take orders — it notices patterns, flags what's being avoided, and tells you what you might not want to hear. That's the point. The weekly review especially is built to be honest with you.

---

## The Long Game

This system is worth almost nothing on day one. It barely knows you.

Give it a month of consistent use — starting sessions, saving out, capturing what matters — and it becomes something you'd struggle to work without. The value compounds. Every session adds to it. Every decision you log becomes history you can draw on. Every source you capture makes the next answer sharper.

You're not setting up a tool. You're training a second brain. Show up, save your work, and let it grow.

---

## Installation

**Claude Code / Claude Cowork — via plugin marketplace:**
```
/plugin marketplace add pifpof/parallel79-cos
/plugin install ai-chief-of-staff@parallel79
```
To update later: `/plugin marketplace update parallel79`, then reinstall.

**One package, installed in one shot:** `dist/ai-chief-of-staff.zip` bundles the whole plugin — every skill, the plugin manifest, the vault template, the license — as a single archive. Unzip it and install the folder as a Claude Code plugin, no picking through individual skills.

**Any platform — via npx (auto-detects your tool):**
```bash
npx github:pifpof/parallel79-cos
```

**Specific platform:**
```bash
npx github:pifpof/parallel79-cos --platform antigravity
npx github:pifpof/parallel79-cos --platform gemini
npx github:pifpof/parallel79-cos --platform codex
npx github:pifpof/parallel79-cos --platform copilot
```

**Manual — copy each folder in `skills/` (the `SKILL.md` plus any `references/` folder alongside it) to your platform's skill directory:**

| Platform | Directory |
|---|---|
| Claude Code / Cowork (global) | `~/.claude/skills/` |
| Claude Code (project) | `.claude/skills/` |
| Google Antigravity | `~/.agents/skills/` |
| Gemini CLI | `~/.gemini/skills/` |
| OpenAI Codex CLI | `~/.codex/skills/` |
| GitHub Copilot | `.github/skills/` |

**Claude Marketplace:** search for "AI Chief of Staff" in the in-app marketplace.

The skills work on any platform. The vault (the memory system) works on platforms with local filesystem access: Claude Code, Cowork, Antigravity, Gemini CLI.

---

*To begin, type `/onboard` and your Chief of Staff will introduce itself.*
