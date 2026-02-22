{ pkgs, nodePkgs, mcp-servers-nix, ... }:

{
  home.packages = with pkgs; [
    sheldon
    fnm
    uv
    zoxide
    ghq
    jq
    nodePkgs."@anthropic-ai/claude-code"
    nodePkgs."ccmanager"
    nodePkgs."@vue/language-server"
    nodePkgs."@vue/typescript-plugin"
  ];

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

  home.file = {
    ".config/nvim".source = pkgs.lib.cleanSourceWith {
      src = ../nvim;
      filter = path: type:
        let baseName = baseNameOf path;
        in baseName != "lazy-lock.json";
    };

    ".wezterm.lua".source = ../wezterm/.wezterm.lua;

    ".p10k.zsh".source = ../zsh/plugins/.p10k.zsh;

    ".config/sheldon/plugins.toml".source = ../sheldon/plugins.toml;

    "dotfiles/config/zsh/plugins/wsl.zsh".source = ../zsh/plugins/wsl.zsh;

    ".claude/settings.json".source = ../claude/settings.json;

    ".claude/skills".source = ../claude/skills;

    ".claude/agents".source = ../claude/agents;

    ".claude/commands".source = ../claude/commands;

    ".claude/CLAUDE.md".source = ../claude/CLAUDE.md;
  };
}
