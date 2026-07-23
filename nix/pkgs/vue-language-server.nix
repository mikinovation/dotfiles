{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/language-server/-/language-server-3.3.8.tgz";
    sha512 = "9Gl/Bf/Jpo7NYAe67F9zCFAb8t9pDH+6qqWzHxfntddflK6615zLkd8dBhBqQzGktZV7VFIiEbb6N4EMUI26oQ==";
  };
in
buildNpmPackage {
  pname = "vue-language-server";
  version = "3.3.8";

  src = runCommand "vue-language-server-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-language-server-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-WU+OMvkMXTXXQtZp17unQyyPiaKDKJXsE1nZ984LzHg=";

  dontNpmBuild = true;

  meta = {
    description = "Vue language server";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
    mainProgram = "vue-language-server";
  };
}
