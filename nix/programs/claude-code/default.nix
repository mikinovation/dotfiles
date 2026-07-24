{
  lib,
  pkgs,
  inputs,
  claudeCode,
  chromeDevtoolsMcp,
  ...
}:

{
  mcp-servers.programs = {
    context7.enable = true;
    terraform.enable = true;
  };

  programs.mcp = {
    enable = true;
    servers.deepwiki = {
      url = "https://mcp.deepwiki.com/mcp";
    };
    servers.chrome-devtools = {
      command = "${chromeDevtoolsMcp}/bin/chrome-devtools-mcp";
      args = [
        "--executablePath"
        (lib.getExe pkgs.chromium)
        "--headless"
        "--isolated"
      ];
    };
  };

  programs.claude-code = {
    enable = true;
    package = claudeCode;
    enableMcpIntegration = true;

    # skills-dir personal plugins do not expose their commands in Claude Code
    # 2.1.218, so deploy the commit-commands plugin as user commands instead
    commandsDir = "${inputs.claude-code-plugins}/plugins/commit-commands/commands";

    # LSP servers
    lspServers = {
      typescript = {
        command = "typescript-language-server";
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".ts" = "typescript";
          ".tsx" = "typescriptreact";
          ".mts" = "typescript";
          ".cts" = "typescript";
          ".js" = "javascript";
          ".jsx" = "javascriptreact";
          ".mjs" = "javascript";
          ".cjs" = "javascript";
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
      model = "opusplan";
      effortLevel = "xhigh";
      includeCoAuthoredBy = false;
      teammateMode = "in-process";
      hooks = {
        Stop = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "$HOME/ghq/github.com/mikinovation/dotfiles/nix/programs/claude-code/hooks/notify-stop.sh";
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
                command = "$HOME/ghq/github.com/mikinovation/dotfiles/nix/programs/claude-code/hooks/notify-input.sh";
              }
            ];
          }
        ];
        PreCompact = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "$HOME/ghq/github.com/mikinovation/dotfiles/nix/programs/claude-code/hooks/pre-compact.sh";
              }
            ];
          }
        ];
      };
      statusLine = {
        type = "command";
        command = "sh $HOME/ghq/github.com/mikinovation/dotfiles/nix/programs/claude-code/statusline.sh";
      };
      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
        CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR = "1";
        DISABLE_UPDATES = "1";
        CLAUDE_CODE_STOP_HOOK_BLOCK_CAP = "5";
        ANTHROPIC_DEFAULT_OPUS_MODEL = "claude-opus-4-8";
        ANTHROPIC_DEFAULT_SONNET_MODEL = "claude-sonnet-5";
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
      autoMode.hard_deny = [
        "Bash(rm -rf /*)"
        "Bash(rm -rf ~*)"
        "Bash(rm -rf $HOME*)"
        "Bash(rm -rf .*)"
        "Bash(git push --force*)"
        "Bash(git push -f*)"
        "Bash(git reset --hard*)"
        "Bash(dd if=*)"
        "Bash(mkfs*)"
        "Bash(chmod -R 777*)"
      ];
    };

    skills = {
      "commit-commands:create-branch" = ./skills/commit-commands/create-branch;
      "nix-npm-update" = ./skills/nix-npm-update;
      "grill-me" = ./skills/grill-me;
      "grilling" = ./skills/grilling;
    };

    context = ./CLAUDE.md;
  };
}
