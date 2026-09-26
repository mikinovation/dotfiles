{
  stdenv,
  fetchurl,
  lib,
}:

let
  version = "2.1.283";

  mainTgz = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    sha512 = "/8Y1pe7M15qMOU7RwUEjpFcM8XGVXNzWrWRXXp/0HlGm1k8FcOCxYMA9VR237JUUzzx5DkcQaGvELAo4si7TwA==";
  };

  natives = {
    x86_64-linux = {
      target = "linux-x64";
      sha512 = "q9+Ke42t/I6oLb/bTmh6sI24jMw4KNwz3QbQLp9dVQ8ipQChfAW5L11SX8jcDzVCW/P2tId7ftI+lgBURvz9uQ==";
    };
    aarch64-darwin = {
      target = "darwin-arm64";
      sha512 = "GczpJ+FvnOYvxn6XPGHbdqJEZMves6Vc0WKS/g1N2eG39EKKAHxG77e+w4Rjtmf8xgCxNY36Jf/IOfbcyus4zA==";
    };
  };
  native =
    natives.${stdenv.hostPlatform.system}
      or (throw "claude-code: unsupported platform ${stdenv.hostPlatform.system}");

  nativeTgz = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code-${native.target}/-/claude-code-${native.target}-${version}.tgz";
    inherit (native) sha512;
  };
in
stdenv.mkDerivation {
  pname = "claude-code";
  inherit version;

  dontUnpack = true;
  # Node.js SEA binaries embed the JS application in a custom section of the
  # executable. strip and patchelf both corrupt this blob, so both must be
  # disabled. On NixOS, nix-ld handles the dynamic linking; on darwin the
  # binary is already self-contained.
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    # Extract main npm package
    mkdir -p main-pkg
    tar xzf ${mainTgz} -C main-pkg --strip-components=1

    # Extract the ${native.target} native binary and replace the placeholder
    mkdir -p native-pkg
    tar xzf ${nativeTgz} -C native-pkg --strip-components=1
    cp native-pkg/claude main-pkg/bin/claude.exe
    chmod +x main-pkg/bin/claude.exe

    # Install package files
    mkdir -p $out/lib/node_modules/@anthropic-ai/claude-code
    cp -r main-pkg/* $out/lib/node_modules/@anthropic-ai/claude-code/

    # Create .bin symlink structure matching node2nix layout
    mkdir -p $out/lib/node_modules/.bin
    ln -s ../@anthropic-ai/claude-code/bin/claude.exe $out/lib/node_modules/.bin/claude

    # bin -> lib/node_modules/.bin symlink (node2nix convention)
    ln -s lib/node_modules/.bin $out/bin
  '';

  meta = {
    description = "Use Claude, Anthropic's AI assistant, right from your terminal.";
    homepage = "https://github.com/anthropics/claude-code";
    license = lib.licenses.unfree;
    platforms = builtins.attrNames natives;
    mainProgram = "claude";
  };
}
