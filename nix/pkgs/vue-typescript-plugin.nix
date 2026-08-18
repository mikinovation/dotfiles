{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/typescript-plugin/-/typescript-plugin-3.3.10.tgz";
    sha512 = "1IzVHNgSrueIsQNETp9I+emLwuhnuw8iV1s9i6wKtfoYPEtg6ZXAgDQKPupedDZ+IQbkm9CSUc3NKODPpJByHg==";
  };
in
buildNpmPackage {
  pname = "vue-typescript-plugin";
  version = "3.3.10";

  src = runCommand "vue-typescript-plugin-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-typescript-plugin-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-MbaO7QEuDT7r8Oxt1Rc3Di2svt6UD5zyKt7Xmf/NuYM=";

  dontNpmBuild = true;

  meta = {
    description = "Vue TypeScript plugin";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
  };
}
