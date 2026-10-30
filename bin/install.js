#!/usr/bin/env node
/**
 * AI Chief of Staff Skills — cross-platform installer
 * Usage:
 *   npx ai-chief-of-staff-skills                        # auto-detect platform
 *   npx ai-chief-of-staff-skills --platform claude      # Claude Code / Cowork (global)
 *   npx ai-chief-of-staff-skills --platform claude-project  # Claude Code (project-local)
 *   npx ai-chief-of-staff-skills --platform antigravity
 *   npx ai-chief-of-staff-skills --platform gemini
 *   npx ai-chief-of-staff-skills --platform codex
 *   npx ai-chief-of-staff-skills --platform copilot     # GitHub Copilot (workspace)
 *   npx ai-chief-of-staff-skills --vault                # also copy vault template (Claude/Cowork only)
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

const args = process.argv.slice(2);
const platformFlag = args.find(a => a.startsWith('--platform='))?.split('=')[1]
  || (args.indexOf('--platform') !== -1 ? args[args.indexOf('--platform') + 1] : null);
const copyVault = args.includes('--vault');

const PLATFORM_DIRS = {
  'claude':          path.join(os.homedir(), '.claude', 'skills'),
  'claude-project':  path.join(process.cwd(), '.claude', 'skills'),
  'cowork':          path.join(os.homedir(), '.claude', 'skills'),
  'antigravity':     path.join(os.homedir(), '.agents', 'skills'),
  'gemini':          path.join(os.homedir(), '.gemini', 'skills'),
  'codex':           path.join(os.homedir(), '.codex', 'skills'),
  'copilot':         path.join(process.cwd(), '.github', 'skills'),
};

const VAULT_SUPPORTED = ['claude', 'claude-project', 'cowork', 'antigravity', 'gemini'];

function detectPlatform() {
  if (process.env.CLAUDE_CODE || fs.existsSync(path.join(os.homedir(), '.claude'))) return 'claude';
  if (process.env.ANTIGRAVITY || fs.existsSync(path.join(os.homedir(), '.agents'))) return 'antigravity';
  if (process.env.GEMINI_CLI || fs.existsSync(path.join(os.homedir(), '.gemini'))) return 'gemini';
  if (process.env.OPENAI_CODEX || fs.existsSync(path.join(os.homedir(), '.codex'))) return 'codex';
  return 'claude';
}

function copyDir(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDir(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

function main() {
  const platform = platformFlag || detectPlatform();

  if (!PLATFORM_DIRS[platform]) {
    console.error(`Unknown platform: "${platform}"`);
    console.error(`Supported: ${Object.keys(PLATFORM_DIRS).join(', ')}`);
    process.exit(1);
  }

  const targetBase = PLATFORM_DIRS[platform];
  const skillsDir = path.join(__dirname, '..', 'skills');
  const installed = [];

  for (const skillName of fs.readdirSync(skillsDir)) {
    const skillSrc = path.join(skillsDir, skillName, 'SKILL.md');
    if (!fs.existsSync(skillSrc)) continue;

    // Copy the whole skill folder so references/ templates ship with it
    const skillDest = path.join(targetBase, skillName);
    copyDir(path.join(skillsDir, skillName), skillDest);
    installed.push(skillName);
  }

  console.log(`\nAI Chief of Staff skills installed for ${platform}:`);
  for (const s of installed) console.log(`  ✓ /${s}  →  ${path.join(targetBase, s, 'SKILL.md')}`);

  if (copyVault || (!platformFlag && VAULT_SUPPORTED.includes(platform))) {
    const schemaDir = path.join(__dirname, '..', 'schema');
    const vaultDest = path.join(process.cwd(), 'chief-of-staff-vault');
    if (!fs.existsSync(vaultDest)) {
      copyDir(schemaDir, vaultDest);
      console.log(`\nVault template copied to: ${vaultDest}`);
      console.log('  Open Claude Code inside that folder and run /onboard to get started.');
    } else {
      console.log(`\nVault already exists at ${vaultDest} — skipped.`);
    }
  }

  console.log(`\nDone. Open your agentic tool and type /start to get started.\n`);
}

main();
