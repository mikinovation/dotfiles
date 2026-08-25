#!/bin/bash
# PreCompact hook: record context compaction events.

LOG_DIR="$HOME/.claude/compact-logs"
mkdir -p "$LOG_DIR"

SESSION_ID="${CLAUDE_CODE_SESSION_ID:-unknown}"
# BSD date (macOS) は -Iseconds を解釈しないため明示フォーマットを使う
TIMESTAMP="$(date +%Y-%m-%dT%H:%M:%S%z)"

printf '[%s] compact session=%s cwd=%s\n' \
  "$TIMESTAMP" "$SESSION_ID" "$PWD" \
  >> "$LOG_DIR/compact.log"
