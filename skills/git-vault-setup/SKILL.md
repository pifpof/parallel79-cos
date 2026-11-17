---
name: git-vault-setup
description: "Optional: put the AI Chief of Staff's vault under Git version control. Use this skill whenever the executive says '/git-vault-setup', asks to 'version my vault', 'back up my memory to GitHub', 'keep a history of changes', 'use Git', 'sync across machines with Git', or asks whether to use iCloud or GitHub for the vault. Explains the trade-off in plain words, turns the vault folder into a private Git repo with a sensible .gitignore and a first commit, optionally connects a private GitHub repo, and records the setting so every /save makes one commit. Never pushes unless the executive says so, and never makes a repo public. Can be run at any time after onboarding."
version: 1.0.0
allowed-tools: [Read, Write, Edit, Bash]
---

# Chief of Staff — Git Vault Setup

## What This Skill Does

Turns the executive's vault into a Git repository, so every `/save` becomes a commit: a dated, reversible history of what the Chief of Staff knew and when. Optionally connects a private remote (GitHub) for backup and use on several machines.

It's optional, and it's for people who want it. Most executives are fine with a synced folder (iCloud Drive, OneDrive, Dropbox). Nothing else in the system depends on Git.

---

## Tone and Approach

Plain words. The executive may never have used Git. Explain each step in one line before doing it, ask before anything that leaves their machine, and stop at any point they want to.

---

## Step 1 — Explain the Choice

In three or four sentences:

- **Synced folder (what you have now):** simple, automatic, nothing to learn. No history: if something gets overwritten, it's gone.
- **Git:** every save is kept as a version you can look back on or undo. With a private GitHub repo, it's backed up and works across machines. It's a little more technical.
- **Not both on the same folder.** A Git repo inside iCloud Drive, OneDrive or Dropbox can get corrupted when the sync service and Git both write to it. If they choose Git and the vault is in a synced folder, recommend moving the vault out of it first (say where it is now and suggest `~/Documents/<vault name>` outside the synced area), and do the move only on a yes.

Ask whether they want to go ahead. If not, stop; nothing changes.

---

## Step 2 — Check the Ground

Run these checks quietly, and stop with a plain explanation if one fails:

1. **Git is installed:** `git --version`. If not, on a Mac suggest `xcode-select --install` (or `brew install git`), and stop until it's done.
2. **Where the vault is:** if its path contains `Mobile Documents` (iCloud Drive), `OneDrive`, `Dropbox` or `Google Drive`, it's in a synced folder. Go back to the last point of Step 1.
3. **Not already a repo:** `git -C "<vault>" rev-parse --show-toplevel`.
   - Prints the vault path → it's already set up. Skip to Step 4 (remote) or Step 5 if that's done too.
   - Prints a different, parent folder → the vault sits inside another repo. Don't nest a second one. Explain and stop; the executive (or whoever set up that repo) decides.
   - Fails → not a repo. Continue.
4. **Big or private files:** list anything in the vault over 50 MB and any file whose name suggests credentials (`.env`, `*.key`, `*credentials*`, `*secret*`). Name them and propose adding them to `.gitignore`. Git keeps every version forever; secrets must never be committed.

---

## Step 3 — Create the Repo

1. Write `.gitignore` at the vault root from `references/gitignore-template`, plus anything agreed in Step 2. Ask one question: keep removed files (`trash/`) in the history, or leave them out? Default: keep them, so nothing is ever truly lost.
2. `git init`, then `git add -A` and `git commit -m "setup: initial vault"`.
3. Confirm in one line: how many files are in the first version.

---

## Step 4 — Connect a Private Remote (optional)

Ask: "Want a private copy on GitHub, for backup and other machines?" If no, skip to Step 5.

If yes:

- **With the GitHub CLI** (`gh auth status` succeeds): propose `gh repo create <vault-name> --private --source "<vault>" --remote origin --push`. Say plainly that this uploads the vault, including everything in `/data`, to a **private** repo on their account. Run it only on an explicit yes.
- **Without it:** give the two or three steps to create a private repo on github.com, then `git remote add origin <url>` and `git push -u origin main`. Offer to run the commands once they paste the URL.
- **Never** create a public repo, and never push to a remote they didn't name.

---

## Step 5 — Record the Setting

Add this section to the end of the vault's `CLAUDE.md` (create the file if it doesn't exist):

```markdown
## Version History (Git)

This vault is a Git repo. `/save` ends with one commit (`save: <summary>`).
push after save: no
```

Ask whether `/save` should also push each time. Only if they say yes, set `push after save: yes` (and only when a remote exists). The default is no: commits stay on this machine until they push.

Then confirm in two lines: what's set up, and that every `/save` from now on is a version they can look back on.

---

## Undoing It

If they change their mind later: deleting the hidden `.git` folder at the vault root removes the history and leaves every file in place. Remove the "Version History (Git)" section from `CLAUDE.md` too. Never do this without an explicit request, and say first that the history is lost.

---

## Reminders

- Optional, plain-language, one step at a time. The executive can stop anywhere.
- Never put a Git repo inside a cloud-synced folder, and never nest it inside another repo.
- Nothing leaves the machine without an explicit yes. Remotes are private, always.
- Secrets and huge files go in `.gitignore` before the first commit, not after.
- `/save` commits; it pushes only when `CLAUDE.md` says `push after save: yes`.
