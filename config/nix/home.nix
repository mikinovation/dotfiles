{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mikinovation";
  home.homeDirectory = "/home/mikinovation";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Shell and development tools
    sheldon  # Zsh plugin manager
    fnm      # Fast Node Manager
    uv       # Python package manager
    zoxide   # Smart cd replacement

    # Add more packages here as needed
  ];

  # Import program configurations
  imports = [
    ./configs/git.nix
    ./configs/zsh.nix
    ./configs/nodejs.nix
    ./configs/ruby.nix
    ./configs/rust.nix
    ./configs/database.nix
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
  #  /etc/profiles/per-user/mikinovation/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
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
    "dotfiles/config/zsh/plugins/wsl.zsh".source = ../zsh/plugins/wsl.zsh;
  };

  xdg.configFile."nix/nix.conf".force = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Nix settings
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
}
