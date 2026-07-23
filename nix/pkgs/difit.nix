{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
  nodejs,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/difit/-/difit-5.0.8.tgz";
    sha512 = "4wraDkhacN6VFdFm57GP+0qtimu0vnxgZ3hyVjgVEoU6r4xkH2B/vZoLa0XePYzbIhyZ/xPHYFn6WmVk8OVPCw==";
  };
in
buildNpmPackage {
  pname = "difit";
  version = "5.0.8";

  # devDependencies (oxlint/oxlint-tsgolint) declare a broken peer range
  # upstream; they're unused at runtime since dontNpmBuild = true ships the
  # tarball's prebuilt dist, so drop them to keep npm ci conflict-free.
  src = runCommand "difit-src" { nativeBuildInputs = [ nodejs ]; } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./difit-lock.json} $out/package-lock.json
    node -e '
      const fs = require("fs");
      const p = "'"$out"'/package.json";
      const j = JSON.parse(fs.readFileSync(p, "utf8"));
      delete j.devDependencies;
      fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
    '
  '';

  npmDepsHash = "sha256-kpHSTPTqGHezE8UqP6F8O9HPhad90ikSDKbudPs/i8k=";

  dontNpmBuild = true;

  npmFlags = [ "--ignore-scripts" ];

  meta = {
    description = "Lightweight CLI that serves a GitHub-like web UI for Git diffs";
    homepage = "https://github.com/yoshiko-pg/difit";
    license = lib.licenses.mit;
    mainProgram = "difit";
  };
}
