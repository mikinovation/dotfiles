{
  stdenv,
  fetchurl,
  lib,
}:

let
  mainTgz = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-2.1.175.tgz";
    sha512 = "x37KEw7T1vz/CLkpLYqa8d6eyS/R1777+HMYJRqYf4e5+OhZwF/+d1LoTs5vFXTrFCWFjZTbWGZksW/gKpvCTQ==";
  };
  nativeTgz = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/-/claude-code-linux-x64-2.1.175.tgz";
    sha512 = "RegEK8Cdj5tM2ZiePk887o+OwwfibR5jxI2yh3z0aKtelFH63kM2TZEGvroj5iCsKP33LMK3kFKwBD4gJ3d1LQ==";
  };
in
stdenv.mkDerivation {
  pname = "claude-code";
  version = "2.1.175";

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
