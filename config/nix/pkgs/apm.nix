{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  openssl,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "apm";
  version = "0.8.12";

  src = fetchurl {
    url = "https://github.com/microsoft/apm/releases/download/v${version}/apm-linux-x86_64.tar.gz";
    hash = "sha256-WMiLwFHQ8JranYh1G4c8gm1Wt2KsL7+KvUAy3OOOazk=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ openssl ];

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
    mkdir -p $out/libexec/apm $out/bin
    cp -r apm-linux-x86_64/* $out/libexec/apm/
    chmod +x $out/libexec/apm/apm
    ln -s $out/libexec/apm/apm $out/bin/apm
  '';

  meta = {
    description = "Agent Package Manager - dependency manager for AI agents";
    homepage = "https://github.com/microsoft/apm";
    platforms = [ "x86_64-linux" ];
  };
}
