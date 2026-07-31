# clipboard-history — keep a history of clipboard text and read it back.
#
# WSLg's compositor does not implement the wlr-data-control protocol, so
# `wl-paste --watch` fails and event-driven clipboard managers (cliphist and
# friends) cannot be used here. Polling is the only way to notice that something
# was copied on the Windows side, and it is cheap: wl-paste against WSLg takes
# about 25ms, versus ~734ms for the powershell.exe Get-Clipboard route.
#
# Entries live one per file under $STORE, named with a zero padded counter so
# that a plain reverse sort gives newest first.

STORE="${CLIPBOARD_HISTORY_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/clipboard-history}"
MAX_ENTRIES="${CLIPBOARD_HISTORY_MAX:-200}"
POLL_INTERVAL="${CLIPBOARD_HISTORY_INTERVAL:-2}"
PREVIEW_WIDTH=200

usage() {
	cat <<'EOF'
Usage: clipboard-history <command>

  daemon      Poll the clipboard and record every new text entry
  list        Print "<id>\t<preview>", newest first
  get <id>    Print the raw content of an entry
  clear       Remove every entry
EOF
}

# Newest first. Empty output when the store does not exist yet.
entry_ids() {
	[ -d "$STORE" ] || return 0
	find "$STORE" -maxdepth 1 -type f -name '[0-9]*' -printf '%f\n' 2>/dev/null | sort -r
}

newest_id() {
	entry_ids | head -n 1
}

# Read the clipboard as plain text. Non-text content (images) yields nothing.
read_clipboard() {
	wl-paste --no-newline --type text/plain 2>/dev/null || true
}

# Drop any existing entry with identical content so re-copying moves it to the
# top instead of piling up duplicates.
remove_duplicates() {
	local content="$1" id
	for id in $(entry_ids); do
		if [ "$(cat "$STORE/$id")" = "$content" ]; then
			rm -f "$STORE/$id"
		fi
	done
}

prune() {
	local id count=0
	for id in $(entry_ids); do
		count=$((count + 1))
		if [ "$count" -gt "$MAX_ENTRIES" ]; then
			rm -f "$STORE/$id"
		fi
	done
}

store() {
	local content="$1" latest next

	[ -n "$content" ] || return 0

	latest="$(newest_id)"
	if [ -n "$latest" ] && [ "$(cat "$STORE/$latest")" = "$content" ]; then
		return 0
	fi

	remove_duplicates "$content"

	latest="$(newest_id)"
	if [ -n "$latest" ]; then
		next=$((10#$latest + 1))
	else
		next=1
	fi

	printf '%s' "$content" >"$STORE/$(printf '%012d' "$next")"
	prune
}

cmd_daemon() {
	local previous="" content
	while true; do
		content="$(read_clipboard)"
		if [ "$content" != "$previous" ]; then
			store "$content"
			previous="$content"
		fi
		sleep "$POLL_INTERVAL"
	done
}

cmd_list() {
	local id preview
	for id in $(entry_ids); do
		preview="$(tr '\n\t' '  ' <"$STORE/$id" | cut -c "1-$PREVIEW_WIDTH")"
		printf '%s\t%s\n' "$id" "$preview"
	done
}

cmd_get() {
	local id="${1:-}"
	if [ -z "$id" ]; then
		echo "clipboard-history: get requires an entry id" >&2
		return 1
	fi
	if [ ! -f "$STORE/$id" ]; then
		echo "clipboard-history: no such entry: $id" >&2
		return 1
	fi
	cat "$STORE/$id"
}

mkdir -p "$STORE"

case "${1:-}" in
daemon) cmd_daemon ;;
list) cmd_list ;;
get)
	shift
	cmd_get "$@"
	;;
clear) rm -f "$STORE"/[0-9]* ;;
"" | -h | --help) usage ;;
*)
	echo "clipboard-history: unknown command: $1" >&2
	usage >&2
	exit 1
	;;
esac
