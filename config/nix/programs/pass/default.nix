{ pkgs, ... }:

{
  # password-store (pass) for managing secrets as GPG-encrypted files.
  #
  # The encrypted store itself (~/.password-store) is NOT tracked in this
  # public dotfiles repository; it is expected to be a separate PRIVATE
  # repository cloned at runtime. This module only provides the tooling
  # and shell integration.
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [
      exts.pass-otp
      exts.pass-import
    ]);
    settings = {
      PASSWORD_STORE_DIR = "$HOME/.password-store";
      PASSWORD_STORE_GENERATED_LENGTH = "32";
    };
  };

  # GPG is the encryption backend for pass.
  programs.gpg.enable = true;

  # gpg-agent caches passphrases so pass does not re-prompt on every call.
  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    pinentry.package = pkgs.pinentry-curses;
    defaultCacheTtl = 3600;
    maxCacheTtl = 28800;
  };
}
