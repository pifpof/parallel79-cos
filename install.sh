#!/usr/bin/env bash
# install.sh — Build distributable packages for AI Chief of Staff
#
# Produces two kinds of output in dist/:
#
#   1. dist/ai-chief-of-staff.zip
#      ONE package containing the whole plugin — .claude-plugin/plugin.json,
#      all skills/, the schema/ vault template, README.md, and LICENSE.
#      This is the one-step install: unzip it, or point a Claude Code plugin
#      install at the folder, and every skill is available at once. This is
#      the file to hand someone who just wants "the whole thing, installed
#      in one shot" — no picking through individual skills.
#
#   2. dist/<skill>.skill  (one per skill, kept for platforms/workflows that
#      only support installing a single skill at a time — e.g. dragging one
#      skill into Claude Cowork's Customize → Skills panel)
#      Each .skill file is a ZIP archive containing the skill folder as the
#      root: onboard.skill → onboard/SKILL.md (Cowork unzips and installs).
#
# Install options:
#   Whole plugin  → unzip dist/ai-chief-of-staff.zip and install the folder
#                   as a Claude Code plugin, or push it to GitHub and run
#                   /plugin marketplace add <owner/repo>, then
#                   /plugin install ai-chief-of-staff@parallel79
#   Single skill  → double-click a .skill file in Finder (Cowork installs
#                   it automatically), or rename .skill → .zip and use
#                   Customize → Skills → + → Upload a skill
#
# Usage:
#   ./install.sh           Build everything (combined package + per-skill)
#   ./install.sh --clean   Wipe dist/ first, then build

set -euo pipefail

# Avoid macOS resource-fork cruft (.DS_Store / ._* / __MACOSX) in any zip we build
export COPYFILE_DISABLE=1

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
DIST_DIR="$REPO_ROOT/dist"
TMP_DIR="$REPO_ROOT/.build-tmp"

PACK_NAME="AI Chief of Staff"
PACK_VERSION="1.8.0"

# ── Colours ───────────────────────────────────────────────────────────────────
GOLD='\033[38;5;214m'; GREEN='\033[0;32m'; DIM='\033[2m'; RED='\033[0;31m'; NC='\033[0m'
say() { echo -e "${GOLD}▸ $*${NC}"; }
ok()  { echo -e "  ${GREEN}✓${NC} $*"; }
err() { echo -e "  ${RED}✗${NC} $*"; }

# ── Clean ─────────────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--clean" ]]; then
  say "Cleaning dist/"
  rm -f "$DIST_DIR"/*.skill "$DIST_DIR"/*.zip
fi

mkdir -p "$DIST_DIR"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

say "Building ${PACK_NAME} v${PACK_VERSION}"
echo ""

# ── 1. The combined package — one zip, the whole plugin ────────────────────────
say "Combined package"

PLUGIN_STAGE="$TMP_DIR/ai-chief-of-staff"
mkdir -p "$PLUGIN_STAGE"

cp -R "$REPO_ROOT/.claude-plugin" "$PLUGIN_STAGE/"
cp -R "$REPO_ROOT/skills" "$PLUGIN_STAGE/"
cp -R "$REPO_ROOT/schema" "$PLUGIN_STAGE/"
cp "$REPO_ROOT/README.md" "$PLUGIN_STAGE/"
cp "$REPO_ROOT/LICENSE" "$PLUGIN_STAGE/"

# Strip anything that shouldn't ship (editor/OS cruft, if present)
find "$PLUGIN_STAGE" -name ".DS_Store" -delete

(cd "$TMP_DIR" && zip -qrX "$DIST_DIR/ai-chief-of-staff.zip" "ai-chief-of-staff/")
ok "ai-chief-of-staff.zip — full plugin, one-step install"

# ── 2. Per-skill packages — kept for single-skill install flows ────────────────
say "Per-skill packages"

for skill_dir in "$SKILLS_DIR"/*/; do
  [[ -d "$skill_dir" ]] || continue
  name="$(basename "$skill_dir")"
  md="$skill_dir/SKILL.md"

  if [[ ! -f "$md" ]]; then
    err "$name — SKILL.md not found, skipping"
    continue
  fi

  # Stage: tmp/<name>/ (folder becomes the zip root). Copy the whole skill
  # folder, not just SKILL.md, so references/ templates ship with the skill.
  cp -R "$skill_dir" "$TMP_DIR/$name"
  find "$TMP_DIR/$name" -name ".DS_Store" -delete

  # Zip from inside tmp/ so the archive root is <name>/SKILL.md, not a full path
  (cd "$TMP_DIR" && zip -qrX "$DIST_DIR/${name}.skill" "$name/")

  ok "${name}.skill"
done

rm -rf "$TMP_DIR"

SKILL_COUNT=$(find "$DIST_DIR" -maxdepth 1 -name "*.skill" | wc -l | tr -d ' ')
echo ""

# ── Summary ───────────────────────────────────────────────────────────────────
say "Done — ${SKILL_COUNT} skills, one combined package → dist/"
echo ""
echo -e "${DIM}  Want everything in one shot?"
echo -e "  Unzip dist/ai-chief-of-staff.zip and install the folder as a Claude"
echo -e "  Code plugin (or /plugin marketplace add pifpof/parallel79-cos)."
echo ""
echo -e "  Want just one skill?"
echo -e "  Double-click its .skill file in Finder — Cowork installs it"
echo -e "  automatically. If drag-and-drop fails (known Cowork bug in some"
echo -e "  versions): rename .skill → .zip, then Customize → Skills → +"
echo -e "  → Upload a skill.${NC}"
echo ""
