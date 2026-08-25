{ pkgs, username, ... }:

{
  # System-level nix-darwin configuration (macOS counterpart of nixos/configuration.nix)

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Timezone
  time.timeZone = "Asia/Tokyo";

  # User account
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # system.defaults の user 単位の設定と launchd agent の所有者を決めるために必要
  system.primaryUser = username;

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  # Determinate Nix installer を使う場合は nix が /etc/nix を占有するため
  # `nix.enable = false;` を追加すること
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
  ];

  # System fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  # Used for backwards compatibility. Please read the nix-darwin changelog
  # before changing.
  system.stateVersion = 6;
}
