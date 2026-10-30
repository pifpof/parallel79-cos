# Minutes template

Filename: `/outputs/meetings/YYYY-MM-DD-<slug>.md`. Omit any section with nothing in it.

```markdown
---
title: ""                     # e.g. "Discovery call — Acme (Jordan Lee)"
date: YYYY-MM-DD
type: meeting
attendees: []                 # names as they should appear in memory
source: granola               # granola | fireflies | otter | fathom | zoom | paste | file | debrief
source_link: ""               # URL back to the meeting tool's note, if any
source_id: ""                 # matches the ledger: granola:<id>, paste:<slug>, debrief:<slug>
languages: []                 # e.g. [en] or [fa, en]
tags: [meeting]
---

# [Title]

**Date:** YYYY-MM-DD · **Attendees:** … · **Source:** [link or "debrief"]

## Summary
3–5 sentences. What the meeting was for, what came out of it, what happens next.

## Topics
- **[Topic]** — what was said that matters, in a line or two.

## Decisions
- [Decision] — [who decided / agreed], [any condition].

## Action items: mine
| # | Task | Due | Source quote | Confidence |
|---|---|---|---|---|
| 1 | Send the pricing deck | 2026-03-14 | "I'll get you the deck by Friday" | High |

## Waiting on others
| # | Owner | Task | Due | Source quote | Confidence |
|---|---|---|---|---|---|

## Others' items (FYI)
| # | Owner | Task | Due | Confidence |
|---|---|---|---|---|

## Open questions
- Ideas raised that nobody took on; questions left unanswered.

## Risks
- Anything that could derail a decision, deal or deadline.

## People & context learned
- **[Name]** — role, company, what they care about, how they came to the meeting.

## Quality notes
- Working from summary, not transcript / speakers not separated / audio gaps / language mix — anything that lowers confidence.
- Due dates resolved from ranges: "(said: early-to-mid Dec)".
```

Rules: no raw transcript; quotes only on action items, kept short and in the original language; sensitive matters appear only as `[Sensitive matter discussed — not recorded]`.
