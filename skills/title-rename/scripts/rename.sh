#!/usr/bin/env bash
# title-rename: rename session by appending custom-title to transcript JSONL
# Usage: rename.sh "<title>"
set -u

TITLE="${1:-}"
if [ -z "$TITLE" ]; then
  echo "Usage: rename.sh <title>" >&2
  exit 1
fi

# Find the active session and its transcript
node -e "
const fs = require('fs');
const path = require('path');
const home = process.env.HOME || process.env.USERPROFILE;
const title = process.argv[1];
const sessDir = path.join(home, '.claude', 'sessions');
const projDir = path.join(home, '.claude', 'projects');

// Find active session
const sessFiles = fs.readdirSync(sessDir).filter(f => f.endsWith('.json'));
let sessionId = '';
for (const f of sessFiles) {
  try {
    const data = JSON.parse(fs.readFileSync(path.join(sessDir, f), 'utf8'));
    if (data.status === 'busy' && data.sessionId) {
      sessionId = data.sessionId;
      break;
    }
  } catch {}
}

if (!sessionId) {
  console.error('No active session found');
  process.exit(1);
}

// Find transcript JSONL
let transcriptPath = '';
const projects = fs.readdirSync(projDir);
for (const proj of projects) {
  const candidate = path.join(projDir, proj, sessionId + '.jsonl');
  if (fs.existsSync(candidate)) {
    transcriptPath = candidate;
    break;
  }
}

if (!transcriptPath) {
  console.error('Transcript not found for session: ' + sessionId);
  process.exit(1);
}

// Append custom-title and agent-name entries
const entries = [
  JSON.stringify({type: 'custom-title', customTitle: title, sessionId}),
  JSON.stringify({type: 'agent-name', agentName: title, sessionId})
];

fs.appendFileSync(transcriptPath, '\n' + entries.join('\n') + '\n');
console.log('Session renamed: ' + title);
" "$TITLE"
