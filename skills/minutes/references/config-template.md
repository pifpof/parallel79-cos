---
title: "Meeting settings"
summary: "How /minutes finds meetings, writes minutes and routes action items."
sources: []
aliases: ["meeting config", "minutes settings"]
tags: [reference, system]
---

# Meeting settings

Read by `/minutes` on every run, and by `/start`, `/review` and `/lint`. Edit freely — plain language is fine where a value needs explaining.

## Source
meeting_tool: detect          # detect | granola | fireflies | otter | fathom | zoom | none

## Language
working_language: English     # language the minutes are written in
language_notes: []            # e.g. [farsi] — loads the matching pack from the skill's references/

## Review
review: external-only         # always | external-only | never

## Action item destination
destination: markdown         # airtable | asana | todoist | linear | trello | notion | markdown
mapping: |
  (destination-specific: base/table/project IDs, field names, select values.
   See the skill's references/destinations.md for what each destination needs.)
route_waiting_on: true        # send "waiting on" items to the destination too
route_others: false           # send other people's items (normally minutes-only)

## CRM
crm_convention: none          # path to a conventions file in this vault, or none

## Sanitization (added to the built-in defaults)
never_record: []              # e.g. ["pricing discussed with Client X", "board compensation"]

## People hints
aliases: []                   # e.g. ["Ali jan = Ali Rezaei", "AR = Ali Rezaei"]

## Skip / webinar patterns
webinar_title_patterns: ["webinar", "masterclass", "keynote", "tactics to"]
skip_title_patterns: []       # e.g. ["focus time", "lunch"]

## Hourly clients (optional)
hourly_rule: none
# Example:
# hourly_rule: |
#   Meetings with [contact] → time entry in [destination/table] against [project],
#   rate [rate]. Ask for duration if the meeting tool doesn't give one.

## Other rules (optional)
# Free-text rules specific to this executive, e.g. referral tracking,
# meetings never to surface in /start.
