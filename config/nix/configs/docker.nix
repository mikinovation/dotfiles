{ pkgs, ... }:

{
  programs.zsh.sessionVariables = {
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock";
  };
}
