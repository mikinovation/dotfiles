# fzf integrations

# cmi: Select a command from history via fzf and execute it
function cmi() {
  local cmd
  cmd=$(fc -nrl 1 | awk '!seen[$0]++' | fzf --no-sort --layout=reverse --prompt="Select command: ")
  if [[ -n "$cmd" ]]; then
    print -s -- "$cmd"
    eval "$cmd"
  fi
}
