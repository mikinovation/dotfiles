{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
  nodejs,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/difit/-/difit-5.0.12.tgz";
    sha512 = "web1qFG754iuYnXqh+cHmO7Ne1N5pZJUvl25Ei2QPAsq19WhelKQhQwDxmXHuk8bX20W0Cu0HLSLLRKYCTaCww==";
  };
in
buildNpmPackage {
  pname = "difit";
  version = "5.0.12";

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

  npmDepsHash = "sha256-N43Y1/dLljJxapt6/4604juhupKHkYdvnf7BEqXjZEw=";

  dontNpmBuild = true;

  npmFlags = [ "--ignore-scripts" ];

  meta = {
    description = "Lightweight CLI that serves a GitHub-like web UI for Git diffs";
    homepage = "https://github.com/yoshiko-pg/difit";
    license = lib.licenses.mit;
    mainProgram = "difit";
  };
}
