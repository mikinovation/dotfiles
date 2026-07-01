{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/typescript-plugin/-/typescript-plugin-3.3.6.tgz";
    sha512 = "3jubnULC27+N2DYw2gLWMeQMdQuS5lUjeR6yzvDh76tx35zYO2c4z+LNLenJqncAOXdhqkCRLzuBgDSkTEJCqg==";
  };
in
buildNpmPackage {
  pname = "vue-typescript-plugin";
  version = "3.3.6";

  src = runCommand "vue-typescript-plugin-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-typescript-plugin-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-z5+BhrTFIGxvB40yadHnewWDpykO1syvCDRxJsdrCbo=";

  dontNpmBuild = true;

  meta = {
    description = "Vue TypeScript plugin";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
  };
}
