{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
  nodejs,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/@vue/language-server/-/language-server-3.3.9.tgz";
    sha512 = "yFBAU07FaAGEtvmnSAzOf1C0GFafzgoh5TVn9FKZU81hTzNKslto2hROJljOPjvVu8Pyq1W3+nXz7TNjZH8waA==";
  };
in
buildNpmPackage {
  pname = "vue-language-server";
  version = "3.3.9";

  # index.js does `require('typescript')` and uses the classic JS API
  # (ts.server.protocol). Upstream declares typescript as `*` / `latest`, which
  # now resolves to TypeScript 7 — a package whose entrypoint is only
  # lib/version.cjs, so the server crashes on startup with
  # "Cannot read properties of undefined (reading 'protocol')".
  # Pin typescript to 5.x and drop devDependencies so package.json matches
  # the committed lockfile.
  src = runCommand "vue-language-server-src" { nativeBuildInputs = [ nodejs ]; } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./vue-language-server-lock.json} $out/package-lock.json
    node -e '
      const fs = require("fs");
      const path = process.argv[1] + "/package.json";
      const p = JSON.parse(fs.readFileSync(path, "utf8"));
      delete p.devDependencies;
      p.dependencies = Object.assign({}, p.dependencies, { typescript: "^5.9.3" });
      fs.writeFileSync(path, JSON.stringify(p, null, 2) + "\n");
    ' $out
  '';

  npmDepsHash = "sha256-0Ozzvbzdhv8nRhDJCtMHVIgm3dZuBdvC4ex8HjJ1El0=";

  dontNpmBuild = true;

  meta = {
    description = "Vue language server";
    homepage = "https://github.com/vuejs/language-tools";
    license = lib.licenses.mit;
    mainProgram = "vue-language-server";
  };
}
