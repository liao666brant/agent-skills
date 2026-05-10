#!/usr/bin/env bash
# title-rename: set session name by updating the session JSON file.
# Usage: title-rename.sh "<title>"
set -u

TITLE="${1:-}"
if [ -z "$TITLE" ]; then
  echo "Usage: title-rename.sh <title>" >&2
  exit 1
fi

SESSIONS_DIR="$HOME/.claude/sessions"
if [ ! -d "$SESSIONS_DIR" ]; then
  exit 1
fi

# Find the active (busy) session file and update its name
node -e "
const fs = require('fs');
const path = require('path');
const dir = path.join(process.env.HOME || process.env.USERPROFILE, '.claude', 'sessions');
const title = process.argv[1];
const files = fs.readdirSync(dir).filter(f => f.endsWith('.json'));
for (const f of files) {
  const fp = path.join(dir, f);
  try {
    const data = JSON.parse(fs.readFileSync(fp, 'utf8'));
    if (data.status === 'busy') {
      data.name = title;
      fs.writeFileSync(fp, JSON.stringify(data));
      console.log('Session renamed: ' + title);
      process.exit(0);
    }
  } catch {}
}
console.error('No active session found');
process.exit(1);
" "$TITLE"
