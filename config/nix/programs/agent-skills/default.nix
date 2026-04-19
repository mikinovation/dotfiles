{
  config,
  pkgs,
  inputs,
  ...
}:

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
      antfu-skills = {
        path = inputs.antfu-skills;
        subdir = "skills";
      };
      obra-superpowers = {
        path = inputs.obra-superpowers;
        subdir = "skills";
      };
    };

    skills = {
      enable = [
        "find-skills"
        "skill-creator"
        "agent-browser"
        "vue-best-practices"
        "nuxt"
        "test-driven-development"
      ];
    };

    targets = {
      claude = {
        enable = true;
      };
    };
  };
}
