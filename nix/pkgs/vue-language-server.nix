{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/language-server/-/language-server-3.2.6.tgz";
    sha512 = "quU6+4aa7xEOorwYNoS7FT85K6jVfMiCHew2YtKtVWUxI/UjRePpvewrhXYykiwUZ498U5Lf5V4vJSQsAxI/5w==";
  };
in
buildNpmPackage {
  pname = "vue-language-server";
  version = "3.2.6";

  src = runCommand "vue-language-server-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-language-server-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-QxFGHIVMelG6I2YLKj9tlu9z1HjK86xL0pj6644sf4U=";

  dontNpmBuild = true;

  meta = {
    description = "Vue language server";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
    mainProgram = "vue-language-server";
  };
}
