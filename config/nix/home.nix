{ config, pkgs, nodePkgs, mcp-servers-nix, ... }:

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
    nodePkgs."@anthropic-ai/claude-code"
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
    ./configs/mcp-servers.nix
    ./configs/textlint.nix
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
    "dotfiles/config/zsh/plugins/wsl.zsh".source = ../zsh/plugins/wsl.zsh;

    # Claude Code Settings
    ".claude/settings.json".source = ../claude/settings.json;

    # Claude Code skills
    ".claude/skills".source = ../claude/skills;

    # Claude Code agents (subagents)
    ".claude/agents".source = ../claude/agents;

    # Claude Code commands (slash commands)
    ".claude/commands".source = ../claude/commands;
  };

  xdg.configFile."nix/nix.conf".force = true;

  # Set zsh as default shell using activation script
  # This is necessary for standalone home-manager (non-NixOS)
  home.activation.make-zsh-default-shell = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    PATH="/usr/bin:/bin:$PATH"
    ZSH_PATH="${config.home.homeDirectory}/.nix-profile/bin/zsh"

    if [[ $(getent passwd ${config.home.username}) != *"$ZSH_PATH" ]]; then
      echo "Setting zsh as default shell (using chsh). Password might be necessary."

      if ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "Adding zsh to /etc/shells"
        $DRY_RUN_CMD echo "$ZSH_PATH" | sudo tee -a /etc/shells
      fi

      echo "Running chsh to make zsh the default shell"
      $DRY_RUN_CMD chsh -s "$ZSH_PATH" ${config.home.username}
      echo "Zsh is now set as default shell!"
    else
      echo "Zsh is already the default shell"
    fi
  '';

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
