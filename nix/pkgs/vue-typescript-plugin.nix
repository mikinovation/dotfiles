{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/typescript-plugin/-/typescript-plugin-3.2.6.tgz";
    sha512 = "D7DO3/MDrdRAxZSpZU8SFBgk4a3d1yk75eKbDqAg7eM/AgpL7ur+PEuwqnOQiwFGEdtrhuFhiqksUtnzJHiq+w==";
  };
in
buildNpmPackage {
  pname = "vue-typescript-plugin";
  version = "3.2.6";

  src = runCommand "vue-typescript-plugin-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-typescript-plugin-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-fT7M9eLZCqN4Ve0TZ94yW4Nbl9Q6W8sxLL7k+93rx6c=";

  dontNpmBuild = true;

  meta = {
    description = "Vue TypeScript plugin";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
  };
}
