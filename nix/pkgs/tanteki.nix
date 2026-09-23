{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
}:

buildNpmPackage rec {
  pname = "tanteki";
  version = "0-unstable-2026-09-22";

  src = fetchFromGitHub {
    owner = "iwasa-kosui";
    repo = "tanteki";
    rev = "cf51a7bab450253a4e1fc75cdf35692111b4bddb";
    hash = "sha256-dvEY+sUGi6TLbnvlIYphkx9IdpdQSdwpiJLRPLSlspI=";
  };

  sourceRoot = "${src.name}/skills/tanteki";

  npmDepsHash = "sha256-cU7TjuV+rrwCt03JjPh0saSMdeyNSeMnIJGo3dJstRY=";

  nodejs = nodejs_22;

  dontNpmBuild = true;

  npmFlags = [ "--ignore-scripts" ];

  postPatch = ''
    substituteInPlace scripts/lint.mjs \
      --replace-fail '#!/usr/bin/env node' '#!${lib.getExe nodejs_22}'

    substituteInPlace SKILL.md \
      --replace-fail '初回はそのディレクトリで `npm ci` を実行し、検査に必要なパッケージをインストールする。' '検査に必要なパッケージはインストール済みのため、`npm ci` は実行しない。' \
      --replace-fail 'node <スキルルート>/scripts/lint.mjs' '<スキルルート>/scripts/lint.mjs'

    substituteInPlace references/lint.md \
      --replace-fail '初回はスキルルートで `npm ci` を実行し、必要なパッケージをインストールしてください。その後、`scripts/lint.mjs` を実行します。' '必要なパッケージはインストール済みのため、`npm ci` は実行しません。`scripts/lint.mjs` を直接実行します。' \
      --replace-fail 'node /absolute/path/to/tanteki/scripts/lint.mjs' '/absolute/path/to/tanteki/scripts/lint.mjs'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r \
      SKILL.md \
      LICENSE \
      .textlintrc.json \
      package.json \
      package-lock.json \
      agents \
      references \
      rules \
      scripts \
      node_modules \
      $out/
    chmod +x $out/scripts/lint.mjs

    runHook postInstall
  '';

  meta = {
    description = "Agent skill for writing concise Japanese business and technical documents";
    homepage = "https://github.com/iwasa-kosui/tanteki";
    license = lib.licenses.mit;
  };
}
