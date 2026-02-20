{ config, pkgs, nodePkgs, ... }:

{
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Shell and development tools
    sheldon  # Zsh plugin manager
    fnm      # Fast Node Manager
    uv       # Python package manager
    zoxide   # Smart cd replacement
    ghq      # Git repository organizer
    jq       # JSON processor
    nodePkgs."agent-browser"
    nodePkgs."ccmanager"
    nodePkgs."@vue/language-server"
    nodePkgs."@vue/typescript-plugin"
  ];

  # Import program configurations
  imports = [
    ./configs/git.nix
    ./configs/zsh.nix
    ./configs/neovim.nix
    ./configs/nodejs.nix
    ./configs/ruby.nix
    ./configs/rust.nix
    ./configs/database.nix
    ./configs/agent-browser.nix
    ./configs/claude-code.nix
    ./configs/textlint.nix
    ./configs/agent-skills.nix
  ];

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/<username>/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # Note: EDITOR and VISUAL are set in neovim.nix
  };

  # Manage dotfiles using home.file
  home.file = {
    # Neovim configuration (exclude lazy-lock.json as it will be managed in data directory)
    ".config/nvim".source = pkgs.lib.cleanSourceWith {
      src = ../nvim;
      filter = path: type:
        let baseName = baseNameOf path;
        in baseName != "lazy-lock.json";
    };

    # Wezterm configuration
    ".wezterm.lua".source = ../wezterm/.wezterm.lua;

    # Powerlevel10k configuration
    ".p10k.zsh".source = ../zsh/plugins/.p10k.zsh;

    # Sheldon configuration
    ".config/sheldon/plugins.toml".source = ../sheldon/plugins.toml;

    # WSL-specific configuration
    "ghq/github.com/mikinovation/dotfiles/config/zsh/plugins/wsl.zsh".source = ../zsh/plugins/wsl.zsh;

  };
}
