{ config, pkgs, inputs, ... }:

{
  programs.agent-skills = {
    enable = true;

    sources = {
      anthropic = {
        path = inputs.anthropic-skills;
        subdir = "skills";
      };
      agent-browser = {
        path = inputs.agent-browser;
        subdir = "skills";
      };
      vercel-skills = {
        path = inputs.vercel-skills;
        subdir = "skills";
      };
      local = {
        path = ../../claude/skills;
      };
    };

    skills = {
      enable = [
        "find-skills"
        "skill-creator"
        "agent-browser"
        "git-commit"
        "git-organize-commits"
        "git-pick-changes"
        "git-pr"
      ];
    };

    targets = {
      claude = {
        enable = true;
      };
    };
  };
}
