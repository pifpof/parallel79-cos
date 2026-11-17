---
name: git-vault-setup
description: "Optional: put the AI Chief of Staff's vault under Git version control. Use this skill whenever the executive says '/git-vault-setup', asks to 'version my vault', 'back up my memory to GitHub', 'keep a history of changes', 'use Git', 'sync across machines with Git', or asks whether to use iCloud or GitHub for the vault. Explains the trade-off in plain words, turns the vault folder into a private Git repo with a sensible .gitignore and a first commit, optionally connects a private GitHub repo, and records the setting so every /save makes one commit. Never pushes unless the executive says so, and never makes a repo public. Can be run at any time after onboarding."
version: 1.1.0
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
- **It works wherever the vault is,** including a synced folder. If the vault is in iCloud Drive, OneDrive, Dropbox or Google Drive, Git's history is kept in a local folder outside it, so the sync service never touches it (syncing Git's internal files can corrupt them). Their files stay exactly where they are.
- **The one hard rule:** if it goes to GitHub, the repo is private. That's checked before anything is uploaded.

Ask whether they want to go ahead. If not, stop; nothing changes.

---

## Step 2 — Check the Ground

Run these checks quietly. Only a missing Git or a public remote stops the skill; everything else adjusts how the repo is set up:

1. **Git is installed:** `git --version`. If not, on a Mac suggest `xcode-select --install` (or `brew install git`), and stop until it's done.
2. **Is the vault in a synced folder?** Yes if its real path (`pwd -P`) contains `Mobile Documents` (iCloud Drive), `Library/CloudStorage`, `OneDrive`, `Dropbox` or `Google Drive`. Don't assume from a folder's name; check the path. If yes, Step 3 keeps the history outside it. Never move the vault.
3. **Not already a repo:** check for a `.git` at the vault root, then `git -C "<vault>" rev-parse --show-toplevel`.
   - `.git` exists and it prints the vault path → it's already set up. If it already has a remote (`git remote -v`), run the private check in Step 4 on it now, before anything else; a public remote stops the skill there. Then skip to Step 4 (remote) or Step 5 if that's done too.
   - Prints a different, parent folder → the vault sits inside another repo. That's allowed: the vault gets its own repo, and the parent will see it as a nested one. Say so in one line, and suggest adding the vault's path to the parent repo's `.gitignore` so the two histories stay separate. Continue on a yes.
   - Fails → not a repo. Continue.
4. **Repos inside the vault:** `find "<vault>" -mindepth 2 -name .git -prune` lists any folder that's already its own Git repo (a code project kept in `/data`, say). Add each one's path to `.gitignore`: it keeps its own history, and committing it here would only record a pointer to it.
5. **Size:** if the vault is over 1 GB (`du -sh`), say so. GitHub refuses single files over 100 MB and gets slow on very large repos; propose leaving bulky folders (exports, media, archives in `/data`) out via `.gitignore`.
6. **Big or private files:** list anything in the vault over 50 MB and any file whose name suggests credentials (`.env`, `*.key`, `*credentials*`, `*secret*`). Name them and propose adding them to `.gitignore`. Git keeps every version forever; secrets must never be committed.

---

## Step 3 — Create the Repo

1. Write `.gitignore` at the vault root from `references/gitignore-template`, plus anything agreed in Step 2. Ask one question: keep removed files (`trash/`) in the history, or leave them out? Default: keep them, so nothing is ever truly lost.
2. Create the repo:
   - **Ordinary local folder:** `git init`.
   - **Synced folder:** `git init --separate-git-dir "$HOME/.vault-git/<vault-name>.git"`. Git's history lives in that local folder; the vault holds only a one-line `.git` file pointing to it. Tell the executive where the history is, in one line.

   Then `git add -A` and `git commit -m "setup: initial vault"`.
3. Confirm in one line: how many files are in the first version.

---

## Step 4 — Connect a Private Remote (optional)

Ask: "Want a private copy on GitHub, for backup and other machines?" If no, skip to Step 5.

If yes:

- **With the GitHub CLI** (`gh auth status` succeeds): propose `gh repo create <vault-name> --private --source "<vault>" --remote origin` (no `--push`). Say plainly that the next step uploads the vault, including everything in `/data`, to a **private** repo on their account. Run it only on an explicit yes.
- **Without it:** give the two or three steps to create a repo on github.com with **Private** selected, then `git remote add origin <url>` once they paste the URL.
- **Then the private check, then the first push.** Run the check below. Only if it passes: `git push -u origin main`.
- **Never** create a public repo, and never push to a remote they didn't name.

**Private check (run before every push, and before connecting any remote).** A vault holds the executive's private business. Never push it anywhere that isn't verified private:

1. Read the remote: `git -C "<vault>" remote get-url origin`. It must be a GitHub URL (`github.com/<owner>/<repo>`). Any other host can't be verified here: refuse.
2. Check visibility:
   - With the GitHub CLI: `gh repo view <owner>/<repo> --json visibility -q .visibility` must print `PRIVATE`.
   - Without it: `curl -s -o /dev/null -w '%{http_code}' https://api.github.com/repos/<owner>/<repo>`. `200` means anyone can see it: it's public. `404` means it isn't publicly visible, which is what's needed. Anything else (rate limit, no network) means it couldn't be verified.
3. **Public, internal, or not verified → stop.** Don't push, don't record the remote as safe. Tell the executive in plain words: the repo is public (or couldn't be checked), so nothing was uploaded; make it private on GitHub (the repo's Settings → General → Danger Zone → Change visibility) or remove the remote with `git remote remove origin`, then run this again.

---

## Step 5 — Record the Setting

Add this section to the end of the vault's `CLAUDE.md` (create the file if it doesn't exist):

```markdown
## Version History (Git)

This vault is a Git repo. `/save` ends with one commit (`save: <summary>`).
push after save: no
```

Ask whether `/save` should also push each time. Only if they say yes, set `push after save: yes` (and only when a remote exists and has passed the private check). `/save` repeats the check before every push, in case the repo's visibility changes later. The default is no: commits stay on this machine until they push.

Then confirm in two lines: what's set up, and that every `/save` from now on is a version they can look back on.

---

## Undoing It

If they change their mind later: deleting the hidden `.git` at the vault root (and, for a synced vault, the history folder under `~/.vault-git/`) removes the history and leaves every file in place. Remove the "Version History (Git)" section from `CLAUDE.md` too. Never do this without an explicit request, and say first that the history is lost.

---

## Reminders

- Optional, plain-language, one step at a time. The executive can stop anywhere.
- The vault can live anywhere. In a synced folder, Git's history lives outside it; repos already inside the vault go in `.gitignore`.
- Nothing leaves the machine without an explicit yes. Remotes are private, always: verified before the first push, and by `/save` before every push after. Public or unverifiable means stop.
- Secrets and huge files go in `.gitignore` before the first commit, not after.
- `/save` commits; it pushes only when `CLAUDE.md` says `push after save: yes`.
