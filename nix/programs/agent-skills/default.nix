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
      # grill-me は Skill ツールで "grilling" を呼ぶため、idPrefix を付けず上流と同じ ID で取り込む
      # 他ソースとの ID 衝突を避けるため、使うスキルだけに絞って discover する
      mattpocock-skills = {
        path = inputs.mattpocock-skills;
        subdir = "skills/productivity";
        filter = {
          maxDepth = 1;
          nameRegex = "grilling|grill-me";
        };
      };
    };

    skills = {
      enable = [
        "find-skills"
        "skill-creator"
        "vue-best-practices"
        "nuxt"
        "test-driven-development"
        "grilling"
        "grill-me"
      ];
    };

    targets = {
      claude = {
        enable = true;
      };
    };
  };
}
