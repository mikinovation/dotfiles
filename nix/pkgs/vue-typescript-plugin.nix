{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/typescript-plugin/-/typescript-plugin-3.3.4.tgz";
    sha512 = "/JD46EO1/nUZuTsoC2x1SD6ELrp3PW4sknjrvBJWX1uggEQAjJ7NR3IK3V7kfS6oky6Np9w1kYi4oFpdLA0zbQ==";
  };
in
buildNpmPackage {
  pname = "vue-typescript-plugin";
  version = "3.3.4";

  src = runCommand "vue-typescript-plugin-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-typescript-plugin-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-FOOxXNrS866bHqh1f2Nc+R2lqo8YasxQPeOr+ZeOhZU=";

  dontNpmBuild = true;

  meta = {
    description = "Vue TypeScript plugin";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
  };
}
