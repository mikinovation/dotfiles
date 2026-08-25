{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  openssl,
  lib,
}:

let
  sources = {
    x86_64-linux = {
      target = "apm-linux-x86_64";
      hash = "sha256-WMiLwFHQ8JranYh1G4c8gm1Wt2KsL7+KvUAy3OOOazk=";
    };
    aarch64-darwin = {
      target = "apm-darwin-arm64";
      hash = "sha256-76h3AQba6HHir3LjwDOqv3qE0Vxjd+LVqVuST8bHi98=";
    };
  };
  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "apm: unsupported platform ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation rec {
  pname = "apm";
  version = "0.8.12";

  src = fetchurl {
    url = "https://github.com/microsoft/apm/releases/download/v${version}/${source.target}.tar.gz";
    inherit (source) hash;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ openssl ];

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
    mkdir -p $out/libexec/apm $out/bin
    cp -r ${source.target}/* $out/libexec/apm/
    chmod +x $out/libexec/apm/apm
    ln -s $out/libexec/apm/apm $out/bin/apm
  '';

  meta = {
    description = "Agent Package Manager - dependency manager for AI agents";
    homepage = "https://github.com/microsoft/apm";
    platforms = builtins.attrNames sources;
  };
}
