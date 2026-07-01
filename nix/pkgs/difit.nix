{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/difit/-/difit-5.0.4.tgz";
    sha512 = "0kZd6zFbju9uBtS0YFUnGaJFhlmKZP4w9OBe7+EtrKGNd7X6j+mYtMb3BFWjFvMXp3dyVUfyd82jf7s2djcgkg==";
  };
in
buildNpmPackage {
  pname = "difit";
  version = "5.0.4";

  src = runCommand "difit-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./difit-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-ZI2ijJn5XALt7mrA2DvHg31B5/7YTFypDz2JE21jr08=";

  dontNpmBuild = true;

  npmFlags = [ "--ignore-scripts" ];

  meta = {
    description = "Lightweight CLI that serves a GitHub-like web UI for Git diffs";
    homepage = "https://github.com/yoshiko-pg/difit";
    license = lib.licenses.mit;
    mainProgram = "difit";
  };
}
