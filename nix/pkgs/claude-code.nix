{
  stdenv,
  fetchurl,
  lib,
}:

let
  mainTgz = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-2.1.140.tgz";
    sha512 = "R7cEIvTww28I4m7MKTGsS7yvb6BR85ub+ev2uCVZvZF8veKBz4VLRqda7H9hoFGXBt1t5cN1LC3f/c3PBfjFKA==";
  };
  nativeTgz = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/-/claude-code-linux-x64-2.1.140.tgz";
    sha512 = "6fIEtDVmYcuBxnhPhHNDQ7dK9i3HuB/Fl286mmLL6qlQ8egd6NL7zZLDEYQiJP3MDf+mU8aA2Cu84bwBi/KSHA==";
  };
in
stdenv.mkDerivation {
  pname = "claude-code";
  version = "2.1.140";

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
