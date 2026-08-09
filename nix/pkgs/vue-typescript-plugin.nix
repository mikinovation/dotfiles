{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/typescript-plugin/-/typescript-plugin-3.3.9.tgz";
    sha512 = "lU5YLNiuaClZX1U9XwRaGZMeIFFvCin8SrESm5/azzfw/RvYvYj42sspy5/+XfSIZHHPn8Kdc2nm5qZ9C4OFfw==";
  };
in
buildNpmPackage {
  pname = "vue-typescript-plugin";
  version = "3.3.9";

  src = runCommand "vue-typescript-plugin-src" { } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-typescript-plugin-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-7Dv7Uc1R8nOFL2vJODTgjYQY+eMgnc9yVFdEUSLzo7s=";

  dontNpmBuild = true;

  meta = {
    description = "Vue TypeScript plugin";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
  };
}
