{
  stdenv,
  fetchurl,
  lib,
}:

let
  mainTgz = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-2.1.218.tgz";
    sha512 = "BHV951ruIa6QXaZFDF1wRhwxAOkAiafB2AOWG6wGRUJ4apaJ9mlzp1BFLAhGfG0SknwAyqBenqeT6nit6at4uQ==";
  };
  nativeTgz = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/-/claude-code-linux-x64-2.1.218.tgz";
    sha512 = "e132kA4dVipkVIWK66jpCncbJvLqvug2nD3zXEAdmaivuXNWvfQbMaXl6C0T2SusEimAoDirZz57MqKIGVVVcA==";
  };
in
stdenv.mkDerivation {
  pname = "claude-code";
  version = "2.1.218";

  dontUnpack = true;
  # Node.js SEA binaries embed the JS application in a custom ELF section.
  # strip and patchelf both corrupt this blob, so both must be disabled.
  # nix-ld handles dynamic linking on this NixOS system.
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    # Extract main npm package
    mkdir -p main-pkg
    tar xzf ${mainTgz} -C main-pkg --strip-components=1

    # Extract linux-x64 native binary and replace the placeholder
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
    platforms = [ "x86_64-linux" ];
    mainProgram = "claude";
  };
}
