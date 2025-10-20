{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Rust toolchain (includes rustc, cargo, rust-analyzer, rustfmt, clippy)
    rustup

    # Build dependencies
    gcc
    gnumake
    pkg-config
    openssl
  ];

  # Environment variables for Rust
  home.sessionVariables = {
    # Cargo installation directory
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
    RUSTUP_HOME = "${config.home.homeDirectory}/.rustup";
  };

  # Add cargo bin to PATH
  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];

  # Create cargo config
  home.file.".cargo/config.toml".text = ''
    [build]
    jobs = 4

    [term]
    color = "auto"
  '';
}
