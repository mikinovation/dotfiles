# Clipboard history integration
#
# The history itself is recorded by the clipboard-history systemd user service
# (see nix/programs/clipboard). It contains both what was copied on the Windows
# side and what neovim yanked, because clipboard=unnamedplus pushes every yank
# out to the system clipboard.

if command -v clipboard-history >/dev/null 2>&1; then
  # cpi: Select an entry from the clipboard history and insert it at the cursor
  function cpi() {
    local id
    id=$(clipboard-history list | fzf --no-sort --layout=reverse \
      --prompt="Clipboard: " --preview 'clipboard-history get {1}' | cut -f1)

    if [[ -n "$id" ]]; then
      LBUFFER+="$(clipboard-history get "$id")"
    fi

    zle reset-prompt
  }
  zle -N cpi

  # Overrides zsh's builtin yank (paste from the kill ring), which this replaces
  # with something that actually reaches outside the shell.
  bindkey '^Y' cpi
fi
