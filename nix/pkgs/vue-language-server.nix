{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/language-server/-/language-server-3.3.9.tgz";
    sha512 = "yFBAU07FaAGEtvmnSAzOf1C0GFafzgoh5TVn9FKZU81hTzNKslto2hROJljOPjvVu8Pyq1W3+nXz7TNjZH8waA==";
  };
in
buildNpmPackage {
  pname = "vue-language-server";
  version = "3.3.9";

  src = runCommand "vue-language-server-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-language-server-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-MNnzmCqQm//H6Ldh+RpvDWEzNgT2yHUzPNSMA7GWqNI=";

  dontNpmBuild = true;

  meta = {
    description = "Vue language server";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
    mainProgram = "vue-language-server";
  };
}
