{ lib, pkgs, ... }:

{
  programs.zsh.sessionVariables = lib.mkIf pkgs.stdenv.isLinux {
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock";
  };
}
