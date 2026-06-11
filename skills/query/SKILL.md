---
name: query
description: "Ask a question against the AI Chief of Staff's structured memory. Use this skill whenever the executive says '/query', asks a question about their own business, projects, decisions, or history, says 'what do we know about X', 'what did we decide on Y', 'pull together everything on Z', or wants a synthesized answer drawn from their accumulated memory rather than the open internet. Reads the clean wiki context and answers from it — more coherent and far cheaper than flat search because the knowledge is already compiled. Writes substantial answers to /outputs for the record."
version: 1.0.0
allowed-tools: [Read, Write]
---

# Chief of Staff — Query

## What This Skill Does

Answers a question using the executive's own compiled memory. Because the wiki is already structured and summarized, the answer is grounded, coherent, and traceable — drawn from what the system actually knows rather than reconstructed from scattered files or the open web.

This is the payoff skill. Every `/capture`, every `/save`, every `/sync` has been building toward this: the moment the executive asks a question and gets back an answer that reflects everything the system has accumulated.

---

## Tone and Approach

Answer the question directly and lead with the answer. The executive asked because they want to know — don't make them read through your process to get there.

Ground every claim in memory. When the answer draws on a specific source or decision, you can reference it — that traceability is what makes the answer trustworthy. If the memory doesn't contain enough to answer well, say so honestly rather than filling the gap with generic knowledge.

---

## Step 1 — Understand the Question

Read what the executive is asking. Identify:
- What they actually want to know
- Which parts of memory are likely relevant — projects, people, decisions, library topics
- Whether this is a factual lookup ("what did we decide about pricing") or a synthesis ("what are the risks across all our active vendor relationships")

---

## Step 2 — Gather from Memory

Read efficiently using the index first:

1. Read `memory.md` to find which files are relevant
2. Use `aliases` and `tags` in metadata blocks to locate the right files even if the executive's phrasing doesn't match filenames exactly
3. Load the relevant files fully
4. If the question touches raw sources, check `/data` for the original material

Read only what's relevant. The whole point of the compiled wiki is that you don't need to load everything to answer well — the index and summaries let you find the right files fast.

---

## Step 3 — Answer

Lead with the direct answer. Then support it.

**For a factual lookup:** give the answer in a sentence or two, with the source or decision it came from. Done.

**For a synthesis:** structure the answer so it's scannable. Open with the bottom line, then the supporting detail organized however the question demands — by project, by risk, by timeline, whatever fits. Draw connections across files that the executive might not have made themselves.

Throughout:
- Ground claims in what memory actually contains
- Reference sources or decisions where it strengthens the answer
- Distinguish clearly between what the system knows and what it's inferring
- If memory is thin on the topic, say so — "Here's what we have, but it's limited" — and offer to capture more

---

## Step 4 — Save Substantial Answers

For anything beyond a quick factual lookup, write the answer to `/outputs/`:

`/outputs/[YYYY-MM-DD]-[query-slug].md`

Include the question at the top and the full answer below. This gives every meaningful query a persistent, auditable record — and means a good synthesis can be reused rather than regenerated.

For quick lookups, skip the save — not every answer needs to be filed.

---

## Step 5 — Offer the Next Step

If the answer surfaced a gap, a decision to make, or a thread worth pulling, note it in one line. The executive may want to act on it — be ready to move into that work with full context.

---

## Reminders

- Lead with the answer. The executive's question is the priority, not your reasoning.
- Ground everything in memory. The advantage of this system over open search is that the answer comes from *their* compiled knowledge — honor that.
- Traceability builds trust. Reference where an answer came from when it matters.
- Honesty about gaps is better than confident filler. If memory can't support a good answer, say so and offer to capture more.
- Save substantial syntheses to `/outputs`. A good answer is an asset worth keeping.
