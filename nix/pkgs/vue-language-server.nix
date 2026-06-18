{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/language-server/-/language-server-3.3.5.tgz";
    sha512 = "SY9HoCQFAc+izSv4OpoCyQtEb3APZzmq9zV8TXgUxprcyPwmbrv3mtJKRY9HhrbiBhtO+/0l2W3bqr+GZOw3EA==";
  };
in
buildNpmPackage {
  pname = "vue-language-server";
  version = "3.3.5";

  src = runCommand "vue-language-server-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-language-server-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-LdmtdpcMQZ55fnBsW8qn0bIyr8z1WFZMc4Q7sNlIsT8=";

  dontNpmBuild = true;

  meta = {
    description = "Vue language server";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
    mainProgram = "vue-language-server";
  };
}
