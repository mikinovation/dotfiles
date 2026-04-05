{
  config,
  pkgs,
  nodePkgs,
  inputs,
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

    # Plugins (from anthropics/claude-code repository)
    plugins = [
      "${inputs.claude-code-plugins}/plugins/code-review"
      "${inputs.claude-code-plugins}/plugins/security-guidance"
      "${inputs.claude-code-plugins}/plugins/commit-commands"
      "${inputs.claude-code-plugins}/plugins/pr-review-toolkit"
    ];

    # LSP servers
    lspServers = {
      typescript = {
        command = "typescript-language-server";
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".ts" = "typescript";
          ".tsx" = "typescriptreact";
          ".js" = "javascript";
          ".jsx" = "javascriptreact";
        };
      };
      vue = {
        command = "vue-language-server";
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".vue" = "vue";
        };
      };
      nix = {
        command = "nil";
        extensionToLanguage = {
          ".nix" = "nix";
        };
      };
      lua = {
        command = "lua-language-server";
        extensionToLanguage = {
          ".lua" = "lua";
        };
      };
      ruby = {
        command = "solargraph";
        args = [ "stdio" ];
        extensionToLanguage = {
          ".rb" = "ruby";
          ".rake" = "ruby";
          ".gemspec" = "ruby";
        };
      };
      rust = {
        command = "rust-analyzer";
        extensionToLanguage = {
          ".rs" = "rust";
        };
      };
    };

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
        DISABLE_AUTOUPDATER = "1";
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

    # Agents, CLAUDE.md
    agentsDir = ../../../claude/agents;
    memory.source = ../../../claude/CLAUDE.md;
  };
}
