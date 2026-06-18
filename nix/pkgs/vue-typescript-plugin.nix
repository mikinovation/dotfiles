{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/typescript-plugin/-/typescript-plugin-3.3.5.tgz";
    sha512 = "LkelOXMKGh5RkVh1YVw8rIaeqTqBWrY25Ejas7FZSpJ4VZ/6f+7CJ/6XBMAHZFZIFrEHjSygwSd9lG4lWZ3QFg==";
  };
in
buildNpmPackage {
  pname = "vue-typescript-plugin";
  version = "3.3.5";

  src = runCommand "vue-typescript-plugin-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-typescript-plugin-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-4Pg1brSsFaHr+MZN9GIrH2eklKFBkWfke92/w6jos+U=";

  dontNpmBuild = true;

  meta = {
    description = "Vue TypeScript plugin";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
  };
}
