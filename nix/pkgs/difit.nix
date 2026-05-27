{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/difit/-/difit-5.0.1.tgz";
    sha512 = "0KNJBKbQP4fVPBFWrwBPJro1PELLQnuKoIZV1m+mfS7mDcYZnQKSyfcVwEuUGaGEMkb5dMqXuSiQaQG1csLPvQ==";
  };
in
buildNpmPackage {
  pname = "difit";
  version = "5.0.1";

  src = runCommand "difit-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./difit-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-e5E3lTUtiog6iFczC/FT7iFMxPv5yVyH/jl8eM/G8Xg=";

  dontNpmBuild = true;

  npmFlags = [ "--ignore-scripts" ];

  meta = {
    description = "Lightweight CLI that serves a GitHub-like web UI for Git diffs";
    homepage = "https://github.com/yoshiko-pg/difit";
    license = lib.licenses.mit;
    mainProgram = "difit";
  };
}
