{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/language-server/-/language-server-3.2.9.tgz";
    sha512 = "zC99h1wn4jVNIRzNnn6waFRzHZitlLIIqSE8+YgAwIeut6zsWtyh9fO3yWbtPGfxLM4pIMEeIWOZ6c+MjPbciQ==";
  };
in
buildNpmPackage {
  pname = "vue-language-server";
  version = "3.2.9";

  src = runCommand "vue-language-server-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-language-server-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-JYS//m9Fg9E5VloZds5j188wvts+mmWLRRtARL1pwDc=";

  dontNpmBuild = true;

  meta = {
    description = "Vue language server";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
    mainProgram = "vue-language-server";
  };
}
