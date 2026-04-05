{
  config,
  pkgs,
  nodePkgs,
  ...
}:

{
  mcp-servers.programs = {
    playwright.enable = true;
    context7.enable = true;
    nixos.enable = true;
    notion.enable = true;
    terraform.enable = true;
  };

  programs.mcp = {
    enable = true;
    servers.deepwiki = {
      url = "https://mcp.deepwiki.com/mcp";
    };
  };

  programs.claude-code = {
    enable = true;
    package = nodePkgs."@anthropic-ai/claude-code";
    enableMcpIntegration = true;

    # settings.json
    settings = {
      includeCoAuthoredBy = false;
      teammateMode = "in-process";
      hooks = {
        Stop = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "$HOME/ghq/github.com/mikinovation/dotfiles/config/claude/hooks/notify-stop.sh";
              }
            ];
          }
        ];
        Notification = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "$HOME/ghq/github.com/mikinovation/dotfiles/config/claude/hooks/notify-input.sh";
              }
            ];
          }
        ];
      };
      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
      };
      permissions = {
        defaultMode = "bypassPermissions";
        allow = [
          "Bash(grep *)"
          "Bash(ls *)"
          "Bash(ls)"
          "Bash(find *)"
          "Bash(gh api *)"
          "Bash(git status *)"
          "Bash(git diff *)"
          "Bash(gh run view *)"
          "Bash(git log *)"
          "Bash(git fetch *)"
        ];
      };
    };

    # Agents, commands, CLAUDE.md
    agentsDir = ../../../claude/agents;
    commandsDir = ../../../claude/commands;
    memory.source = ../../../claude/CLAUDE.md;
  };
}
