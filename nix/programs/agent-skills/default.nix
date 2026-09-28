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
      vuejs-ai-skills = {
        path = inputs.vuejs-ai-skills;
        subdir = "skills";
      };
      # mattpocock/skills はカテゴリ別に配置されているため、公式プラグインと同じく
      # 安定版の engineering と productivity をカテゴリごとの source として取り込む
      # grill-me は Skill ツールで "grilling" を呼ぶため、idPrefix を付けず上流と同じ ID にする
      mattpocock-engineering = {
        path = inputs.mattpocock-skills;
        subdir = "skills/engineering";
        filter.maxDepth = 1;
      };
      mattpocock-productivity = {
        path = inputs.mattpocock-skills;
        subdir = "skills/productivity";
        filter.maxDepth = 1;
      };
    };

    skills = {
      enable = [
        "find-skills"
        "skill-creator"
        "vue-best-practices"
        "nuxt"
      ];
      enableAll = [
        "mattpocock-engineering"
        "mattpocock-productivity"
      ];
    };

    targets = {
      claude = {
        enable = true;
      };
    };
  };
}
