{ config, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    # Ctrl+T: File search
    # Ctrl+R: Command history search
    # Alt+C: Directory change
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";

    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };

  home.packages = with pkgs; [
    fd # Required by fzf commands above
  ];
}
