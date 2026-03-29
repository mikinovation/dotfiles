{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-b";
    baseIndex = 1;
    escapeTime = 0;
    terminal = "tmux-256color";
    keyMode = "vi";
    newSession = true;

    extraConfig = ''
      # Session switching
      bind n switch-client -n
      bind p switch-client -p
      bind C new-session

      # Status bar (Tokyo Night)
      set -g status-style 'bg=#1a1b26 fg=#a9b1d6'
      set -g status-left '#[fg=#7aa2f7,bold] #S '
      set -g status-left-length 20
      set -g status-right ""

      # Create dev sessions on startup
      new -d -s dev1
      new -d -s dev2
      new -d -s dev3
      new -d -s dev4
      new -d -s dev5
    '';
  };
}
