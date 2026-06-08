{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/language-server/-/language-server-3.3.4.tgz";
    sha512 = "yNlIAbYFLipUgMsHcH2q0EfUc3qKEBEeD5bErFc1ecgJiFHvbnBROlqY+yK7AhGWCq4R/4s3dhfEf6lFTMjIJw==";
  };
in
buildNpmPackage {
  pname = "vue-language-server";
  version = "3.3.4";

  src = runCommand "vue-language-server-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-language-server-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-ZpK6uK8ABi6fgJnKndu/RG/Muzviu9WwdvVoeYWyZRw=";

  dontNpmBuild = true;

  meta = {
    description = "Vue language server";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
    mainProgram = "vue-language-server";
  };
}
