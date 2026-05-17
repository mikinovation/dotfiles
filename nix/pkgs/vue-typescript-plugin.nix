{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/typescript-plugin/-/typescript-plugin-3.2.9.tgz";
    sha512 = "I3IQ+jbLlvSMyViV0yxbJgMG4em6UlSgfIVLk4KNMWddSyo4CFjrjm3BLm76vV/8snRb3dKmeYfQPm7axYlMuw==";
  };
in
buildNpmPackage {
  pname = "vue-typescript-plugin";
  version = "3.2.9";

  src = runCommand "vue-typescript-plugin-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-typescript-plugin-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-ibM3l2/mtaScga/NZBsUxqv9puwzCc4Nb1KapmEilew=";

  dontNpmBuild = true;

  meta = {
    description = "Vue TypeScript plugin";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
  };
}
