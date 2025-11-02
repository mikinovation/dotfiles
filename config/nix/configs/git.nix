{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    ignores = [
      # Custom tools
      ".serena/"

      # OS files
      ".DS_Store"
      "Thumbs.db"
      "Desktop.ini"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "ehthumbs.db"

      # Editor configurations
      ".vscode/"
      ".idea/"
      "*.swp"
      "*.swo"
      "*~"
      ".vim/"
      "*.sublime-workspace"

      # Development tools
      ".direnv/"
      ".envrc.local"

      # Python
      "__pycache__/"
      "*.pyc"
      "*.pyo"
      "*.pyd"
      ".pytest_cache/"
      "*.egg-info/"
      ".Python"
      "pip-log.txt"

      # Node.js
      "node_modules/"
      ".npm/"
      "npm-debug.log*"
      "yarn-debug.log*"
      "yarn-error.log*"

      # Logs
      "*.log"

      # Environment files
      ".env.local"
      ".env.*.local"
    ];

    settings = {
      fetch = {
        prune = true;
        pruneTags = true;
      };
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
}
