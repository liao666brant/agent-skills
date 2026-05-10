#!/usr/bin/env bash
# auto-rename.sh — Stop hook: auto-generate session title after 3 valid user prompts.
# Input: stdin JSON {session_id, transcript_path, cwd}
# Guards against recursion via AGENT_TOOLS_INTERNAL env var.
set -uo pipefail

# G1: recursion guard
if [ "${AGENT_TOOLS_INTERNAL:-0}" = "1" ]; then
  exit 0
fi

# Parse stdin
INPUT="$(cat)"
SESSION_ID="$(echo "$INPUT" | node -e "process.stdout.write(JSON.parse(require('fs').readFileSync(0,'utf8')).session_id||'')" 2>/dev/null)"
TRANSCRIPT="$(echo "$INPUT" | node -e "process.stdout.write(JSON.parse(require('fs').readFileSync(0,'utf8')).transcript_path||'')" 2>/dev/null)"

if [ -z "$SESSION_ID" ] || [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

# State directory
STATE_DIR="${HOME}/.claude/agent-tools-state"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/${SESSION_ID}.json"

# Run logic in node for reliability on Windows
node -e "
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const sessionId = process.argv[1];
const transcript = process.argv[2];
const stateFile = process.argv[3];

// Load state
let state = { promptCount: 0, renamed: false };
try { state = JSON.parse(fs.readFileSync(stateFile, 'utf8')); } catch {}

// Already renamed — skip
if (state.renamed) process.exit(0);

// Count valid user prompts from transcript
const lines = fs.readFileSync(transcript, 'utf8').split('\n').filter(Boolean);
let validPrompts = 0;
for (const line of lines) {
  try {
    const obj = JSON.parse(line);
    if (obj.type !== 'user') continue;
    const content = obj.message?.content || '';
    // Extract text from content (string or array)
    let text = '';
    if (typeof content === 'string') {
      text = content;
    } else if (Array.isArray(content)) {
      text = content.map(c => c.text || c.content || '').join(' ');
    }
    // Skip slash commands and empty
    if (!text || text.trim().startsWith('/')) continue;
    // Skip system-reminder only messages
    if (text.trim().startsWith('<system-reminder>') && !text.includes('</system-reminder>\\n')) continue;
    // Skip very short confirmations (< 5 chars) like '确认', '是', 'y'
    const cleaned = text.replace(/<[^>]+>/g, '').trim();
    if (cleaned.length < 5) continue;
    validPrompts++;
  } catch {}
}

// Save count
state.promptCount = validPrompts;
fs.writeFileSync(stateFile, JSON.stringify(state));

// Not enough prompts yet
if (validPrompts < 3) process.exit(0);

// Collect user messages for title generation (last 5 valid ones)
const userMsgs = [];
for (const line of lines) {
  try {
    const obj = JSON.parse(line);
    if (obj.type !== 'user') continue;
    const content = obj.message?.content || '';
    let text = typeof content === 'string' ? content : (Array.isArray(content) ? content.map(c => c.text || '').join(' ') : '');
    const cleaned = text.replace(/<[^>]+>/g, '').trim();
    if (!cleaned || cleaned.startsWith('/') || cleaned.length < 5) continue;
    userMsgs.push(cleaned.slice(0, 200));
  } catch {}
}
const context = userMsgs.slice(-5).join('\n');

// Generate title via claude -p
const prompt = 'Based on these user messages from a coding session, generate a concise 3-8 word title. Match the language of the messages (Chinese messages = Chinese title). Output ONLY the title, no quotes, no punctuation at end.\n\nMessages:\n' + context;

try {
  const title = execSync(
    'echo ' + JSON.stringify(prompt) + ' | AGENT_TOOLS_INTERNAL=1 claude -p --model haiku',
    { timeout: 60000, encoding: 'utf8', env: { ...process.env, AGENT_TOOLS_INTERNAL: '1' } }
  ).trim().replace(/^[\"'\`]+|[\"'\`\.。]+$/g, '');

  if (!title || title.length > 60) process.exit(0);

  // Write to transcript
  const entries = [
    JSON.stringify({type: 'custom-title', customTitle: title, sessionId}),
    JSON.stringify({type: 'agent-name', agentName: title, sessionId})
  ];
  fs.appendFileSync(transcript, '\n' + entries.join('\n') + '\n');

  // Mark as renamed
  state.renamed = true;
  state.title = title;
  fs.writeFileSync(stateFile, JSON.stringify(state));

  console.log('Auto-renamed: ' + title);
} catch (e) {
  // Silent failure — don't block user
  process.exit(0);
}
" "$SESSION_ID" "$TRANSCRIPT" "$STATE_FILE"
