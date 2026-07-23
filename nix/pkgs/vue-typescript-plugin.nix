{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/typescript-plugin/-/typescript-plugin-3.3.8.tgz";
    sha512 = "0GOhAdbMAt5KjGDsPXgcXkLWYBFwoEowPn1AYOUAYuxNup7CVbFJzup8yFGa9KZBtz/juk4FXS/Zirx3WWjLJw==";
  };
in
buildNpmPackage {
  pname = "vue-typescript-plugin";
  version = "3.3.8";

  src = runCommand "vue-typescript-plugin-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-typescript-plugin-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-rtCThMOPtiugVMGdkUAgD7hAGEWESULOD4EmnOUDa3E=";

  dontNpmBuild = true;

  meta = {
    description = "Vue TypeScript plugin";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
  };
}
