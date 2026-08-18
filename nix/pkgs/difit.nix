{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
  nodejs,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/difit/-/difit-5.0.11.tgz";
    sha512 = "UD83DQ9nHeFtzrXP0mgV/cPHyUawpQh+GLGq2QlUYyAzQtytimfJfW3zzNfF1CGhogF1KxBGmXyzxw+B9bOkYg==";
  };
in
buildNpmPackage {
  pname = "difit";
  version = "5.0.11";

  # devDependencies (oxlint/oxlint-tsgolint) declare a broken peer range
  # upstream; they're unused at runtime since dontNpmBuild = true ships the
  # tarball's prebuilt dist, so drop them to keep npm ci conflict-free.
  # packageManager pins pnpm upstream, which makes npm refuse to run at all.
  src = runCommand "difit-src" { nativeBuildInputs = [ nodejs ]; } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./difit-lock.json} $out/package-lock.json
    node -e '
      const fs = require("fs");
      const p = "'"$out"'/package.json";
      const j = JSON.parse(fs.readFileSync(p, "utf8"));
      delete j.devDependencies;
      delete j.packageManager;
      fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
    '
  '';

  npmDepsHash = "sha256-rd+4EThXKsDaBXtGyz9I4ur5B3kaUtYWXxW8tDqUUtU=";

  dontNpmBuild = true;

  npmFlags = [ "--ignore-scripts" ];

  meta = {
    description = "Lightweight CLI that serves a GitHub-like web UI for Git diffs";
    homepage = "https://github.com/yoshiko-pg/difit";
    license = lib.licenses.mit;
    mainProgram = "difit";
  };
}
