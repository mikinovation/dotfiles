{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/typescript-plugin/-/typescript-plugin-3.3.11.tgz";
    sha512 = "sTfyjuZuAClToH59lcBxNMWF+Ede6IBUiYEZI1MgL3Bf9sWV15mtv9P2dfL+4moSQjRf+17O7HX+a8JQdXhLYA==";
  };
in
buildNpmPackage {
  pname = "vue-typescript-plugin";
  version = "3.3.11";

  src = runCommand "vue-typescript-plugin-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-typescript-plugin-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-YD+X6cNmZiZQj6p1zqTuy9z17MY1kjDl8unjJuOlPFk=";

  dontNpmBuild = true;

  meta = {
    description = "Vue TypeScript plugin";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
  };
}
