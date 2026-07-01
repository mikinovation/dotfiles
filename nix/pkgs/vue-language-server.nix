{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/language-server/-/language-server-3.3.6.tgz";
    sha512 = "86t6vpJP85TBMqInkuBJP+bzZ+tkCqp6JWSFAQw6wI7Tatoah0XNP/7DQE5cCC+u+byXJ51Fzt+sjv4L9vFbBg==";
  };
in
buildNpmPackage {
  pname = "vue-language-server";
  version = "3.3.6";

  src = runCommand "vue-language-server-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-language-server-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-OwMdpbvhtH6c23TCoZn6SzDELu0bn4KnwM8ynNWJdvE=";

  dontNpmBuild = true;

  meta = {
    description = "Vue language server";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
    mainProgram = "vue-language-server";
  };
}
