{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/language-server/-/language-server-3.2.8.tgz";
    sha512 = "gQ63+CjdXKzpT6XWJhLPflO7TFBlHI8N+my2ltk8x0l4mfNIggymrj6n7S4Sm6wslI1ae8WSHkDg0dzXbxH/zg==";
  };
in
buildNpmPackage {
  pname = "vue-language-server";
  version = "3.2.8";

  src = runCommand "vue-language-server-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-language-server-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-2BMCvBbizjWQXbfPfQ31onNL1Q2p5CGdvSCMTzkRrEI=";

  dontNpmBuild = true;

  meta = {
    description = "Vue language server";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
    mainProgram = "vue-language-server";
  };
}
