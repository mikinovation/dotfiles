{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/typescript-plugin/-/typescript-plugin-3.2.8.tgz";
    sha512 = "djn/lftbQ0ZXQFYk7HNVNG9lz6V/Lo/wv9t5MADPvQZoH2wC01Cdcs7kJuPVuk40KJXtOFBdpPPl4TcLMWmJww==";
  };
in
buildNpmPackage {
  pname = "vue-typescript-plugin";
  version = "3.2.8";

  src = runCommand "vue-typescript-plugin-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-typescript-plugin-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-T5Zo0HsaO3Mm25ChoeGPmKR1ghpTzhE6Qu122keIngg=";

  dontNpmBuild = true;

  meta = {
    description = "Vue TypeScript plugin";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
  };
}
