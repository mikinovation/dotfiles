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
    url = "https://registry.npmjs.org/chrome-devtools-mcp/-/chrome-devtools-mcp-1.7.0.tgz";
    sha512 = "6xFW7oiUxTxZuHcfyYBkKQtmttjCbfifKZMSEk5CV8H2FucvKweYiJr8CblddYHtYjA4C14K9VAs1r49906RBA==";
  };
in
buildNpmPackage {
  pname = "chrome-devtools-mcp";
  version = "1.7.0";

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
  npmDepsHash = "sha256-tow/ir6++u8kDSYp4wDYZ9fvK9Z0nw9/QzqVN6uPIfs=";

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
