#!/bin/bash
# PreCompact hook: record context compaction events.

LOG_DIR="$HOME/.claude/compact-logs"
mkdir -p "$LOG_DIR"

SESSION_ID="${CLAUDE_CODE_SESSION_ID:-unknown}"
TIMESTAMP="$(date -Iseconds)"

printf '[%s] compact session=%s cwd=%s\n' \
  "$TIMESTAMP" "$SESSION_ID" "$PWD" \
  >> "$LOG_DIR/compact.log"
