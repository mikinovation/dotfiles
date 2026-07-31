{ pkgs, ... }:

let
  clipboardHistory = pkgs.writeShellApplication {
    name = "clipboard-history";
    runtimeInputs = with pkgs; [
      wl-clipboard
      coreutils
      findutils
    ];
    text = builtins.readFile ./clipboard-history.sh;
  };
in
{
  home.packages = [ clipboardHistory ];

  # WSLg keeps the Wayland selection in sync with the Windows clipboard, so
  # polling it here captures both what was copied on the Windows side and what
  # neovim yanked (clipboard=unnamedplus pushes every yank out to "+").
  systemd.user.services.clipboard-history = {
    Unit = {
      Description = "Record clipboard history";
      After = [ "graphical-session.target" ];
    };

    Service = {
      # systemd --user does not inherit WAYLAND_DISPLAY from the login shell.
      Environment = [ "WAYLAND_DISPLAY=wayland-0" ];
      ExecStart = "${clipboardHistory}/bin/clipboard-history daemon";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
