{ ... }:

{
  # gwq: git worktree manager with ghq-like structured layout.
  # Worktrees live under ~/worktrees/<host>/<owner>/<repo>/<branch>, mirroring ghq.
  #
  # cd.launch_shell = false is required so that `gwq completion zsh` emits the
  # cd shim wrapper, letting `gwq cd` / `gwq add` change the current shell's
  # directory instead of spawning a subshell (see programs/zsh shell integration).
  xdg.configFile."gwq/config.toml".text = ''
    [worktree]
    basedir = "~/worktrees"

    [cd]
    launch_shell = false
  '';
}
