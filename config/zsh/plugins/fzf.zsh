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

# gwq: Select a worktree via fzf and cd into it
function gwcd() {
  local dir
  dir=$(gwq list | fzf --layout=reverse --prompt="worktree> ")
  if [[ -n "$dir" ]]; then
    cd "$dir"
  fi
}
