{ config, lib, pkgs, ... }:

let
  # Prisma 6.12.0 engine commit hash
  prismaEngineCommit = "8047c96bbd92db98a2abc7c9323ce77c02c89dbc";

  prismaQueryEngineLib = pkgs.stdenv.mkDerivation {
    pname = "prisma-query-engine-library";
    version = "6.12.0";
    src = pkgs.fetchurl {
      url = "https://binaries.prisma.sh/all_commits/${prismaEngineCommit}/debian-openssl-3.0.x/libquery_engine.so.node.gz";
      hash = "sha256-VU0rcE7bUE1yuRgPWclhjWAGAxRpclmchSnbqJR3M4s=";
    };
    dontUnpack = true;
    nativeBuildInputs = with pkgs; [ gzip autoPatchelfHook ];
    buildInputs = with pkgs; [ openssl stdenv.cc.cc.lib ];
    installPhase = ''
      mkdir -p $out/lib
      gzip -dc $src > $out/lib/libquery_engine.so.node
      chmod +x $out/lib/libquery_engine.so.node
    '';
  };

  prismaSchemaEngine = pkgs.stdenv.mkDerivation {
    pname = "prisma-schema-engine";
    version = "6.12.0";
    src = pkgs.fetchurl {
      url = "https://binaries.prisma.sh/all_commits/${prismaEngineCommit}/debian-openssl-3.0.x/schema-engine.gz";
      hash = "sha256-G/uKzCUTwjUe2NNsMIceBVaYThBS1KSnGhTAKDU3JxI=";
    };
    dontUnpack = true;
    nativeBuildInputs = with pkgs; [ gzip autoPatchelfHook ];
    buildInputs = with pkgs; [ openssl stdenv.cc.cc.lib ];
    installPhase = ''
      mkdir -p $out/bin
      gzip -dc $src > $out/bin/schema-engine
      chmod +x $out/bin/schema-engine
    '';
  };
in
{
  home.packages = with pkgs; [
    # SQLite
    sqlite

    # PostgreSQL client tools
    postgresql
  ];

  # Prisma engine environment variables for NixOS
  home.sessionVariables = {
    PRISMA_QUERY_ENGINE_LIBRARY = "${prismaQueryEngineLib}/lib/libquery_engine.so.node";
    PRISMA_SCHEMA_ENGINE_BINARY = "${prismaSchemaEngine}/bin/schema-engine";
    # Required when using externally-provided engines; Prisma's checksum validation
    # expects binaries from its own download mechanism
    PRISMA_ENGINES_CHECKSUM_IGNORE_MISSING = "1";
  };
}
