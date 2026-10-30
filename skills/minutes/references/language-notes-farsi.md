# Language notes — Persian (Farsi)

Example language pack for `/minutes`. Load when `language_notes` in `memory/reference/meetings.md` includes `farsi`. Use it as a model for writing packs for other languages.

## Politeness (taarof)

- Ritual courtesy is not content. "Ghorbanet beram", "khaste nabashid", "befarmaid", repeated offers and refusals, elaborate thanks — drop them.
- Taarof refusals are not decisions. "No, no, you don't need to" followed by the work proceeding is not a cancellation. Judge commitments by what happens next in the conversation, not the first answer.
- Offers made out of taarof ("I'll do it, it's nothing") are commitments only if the conversation treats them as settled — confirmed, scheduled, or not politely declined. When unsure, record the item with Low confidence.

## Indirect requests are real instructions

- Requests from a senior person are often phrased softly: "agar zahmati nist…" (if it's no trouble…), "mishe ye negahi bendazid?" (could you take a look?), "behtare…" (it would be better if…). Treat these as action items owned by the person addressed, with Medium confidence unless the owner explicitly accepts.
- "Inshallah" attached to a commitment does not cancel it, but lowers confidence one step when no date is given.

## Dates

- Convert Jalali (Solar Hijri) dates to Gregorian; keep the original in brackets the first time: "2026-03-21 (1 Farvardin 1405)".
- Persian weeks start on Saturday; "akhar-e hafte" (end of the week) usually means Wednesday–Thursday. Resolve to a date, keep the phrase in Quality notes.
- Nowruz (around 20–21 March) and the following ~13 days are a common reason deadlines slip — flag any due date that lands in that window as a Risk.

## Script and names

- Speech often mixes Farsi with English terms, and is sometimes typed in Finglish (Farsi in Latin script). Treat all three as one language for detection.
- Keep names in their original form with a transliteration in brackets the first time: "مریم (Maryam)". Use the vault's existing spelling of a name if one exists — check aliases.
- Honorifics ("aghaye", "khanoom", "jan", "doktor") are not part of the name. Strip them when matching people; "Ali jan" is Ali.

## Sensitive content

- Family and health enquiries are a normal part of the opening of a Persian conversation. They are small talk — drop them entirely, with no placeholder line.
- A placeholder line is only for a sensitive matter that was material to the meeting (e.g. someone unavailable for health reasons → record the availability, not the reason).
