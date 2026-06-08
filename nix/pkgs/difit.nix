{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/difit/-/difit-5.0.2.tgz";
    sha512 = "ZcvfiNhsj3H6QQG1Bv9m5qAJhXorD65HqNZhNrChwHbKiCLFJQ2Alr4ImUDoZIbQy3CRM+PSSq7rFYGDE97Nrw==";
  };
in
buildNpmPackage {
  pname = "difit";
  version = "5.0.2";

  src = runCommand "difit-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./difit-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-/IONCb5/GaX6xTQnUkDYjoX1BvBUb80oNCvm7dGkgJw=";

  dontNpmBuild = true;

  npmFlags = [ "--ignore-scripts" ];

  meta = {
    description = "Lightweight CLI that serves a GitHub-like web UI for Git diffs";
    homepage = "https://github.com/yoshiko-pg/difit";
    license = lib.licenses.mit;
    mainProgram = "difit";
  };
}
