{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
  makeWrapper,
  nodejs,
}:

let
  tgz = fetchurl {
    url = "https://registry.npmjs.org/chrome-devtools-mcp/-/chrome-devtools-mcp-1.6.0.tgz";
    sha512 = "VZX6f/OjQSYhy2BGGRs+y3LsrsAQAz/HwZCWKBLVyST/4r/3zjVEjjVW7gMCVbRDuspnVdcp5hQDPrQ5UFrdZw==";
  };
in
buildNpmPackage {
  pname = "chrome-devtools-mcp";
  version = "1.6.0";

  # nodejs >=20.19 required by the package engines field.
  inherit nodejs;

  src = runCommand "chrome-devtools-mcp-src" { nativeBuildInputs = [ nodejs ]; } ''
    mkdir -p $out
    tar xzf ${tgz} -C $out --strip-components=1
    cp ${./chrome-devtools-mcp-lock.json} $out/package-lock.json
    # The tarball ships a prebuilt bundle; strip dev/build-only metadata so
    # `npm ci` has nothing to fetch and matches the empty lockfile.
    node -e '
      const fs = require("fs");
      const p = "'"$out"'/package.json";
      const j = JSON.parse(fs.readFileSync(p, "utf8"));
      delete j.devDependencies;
      delete j.dependencies;
      delete j.scripts;
      fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
    '
  '';

  # The published tarball ships a prebuilt bundle (build/) with all
  # dependencies inlined, so there is nothing to fetch, install, or build.
  forceEmptyCache = true;
  npmDepsHash = "sha256-4PR8CelDmanmUw7htH9cJLYb6ZjWfYf36UpwF0s7hEA=";

  dontNpmBuild = true;

  npmFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [ makeWrapper ];

  # The default npm install hook assumes a populated node_modules; this package
  # has none, so install the prebuilt bundle manually and wrap its bin.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/chrome-devtools-mcp
    cp -r build package.json LICENSE $out/lib/node_modules/chrome-devtools-mcp/

    makeWrapper ${nodejs}/bin/node $out/bin/chrome-devtools-mcp \
      --add-flags $out/lib/node_modules/chrome-devtools-mcp/build/src/bin/chrome-devtools-mcp.js

    runHook postInstall
  '';

  meta = {
    description = "Chrome DevTools MCP server for browser automation and debugging";
    homepage = "https://github.com/ChromeDevTools/chrome-devtools-mcp";
    license = lib.licenses.asl20;
    mainProgram = "chrome-devtools-mcp";
  };
}
