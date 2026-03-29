# fzf integrations

# cmi: Select a command from history via fzf and execute it
function cmi() {
  local cmd
  cmd=$(fc -ln 1 | tac | awk '!seen[$0]++' | fzf --no-sort --layout=reverse --prompt="Select command: ")
  if [[ -n "$cmd" ]]; then
    print -z "$cmd"
  fi
}
