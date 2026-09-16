{
  lib,
  pkgs,
  username,
  profile,
  ...
}:

let
  isFull = profile == "full";

  cjkFonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];
in
{
  # System-level NixOS configuration

  # WSL
  wsl.enable = true;
  wsl.defaultUser = username;

  # Timezone and locale
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  # User account
  users.users.${username} = {
    isNormalUser = true;
    # docker グループは virtualisation.docker が有効なときしか作られないため、
    # light では extraGroups からも外す（存在しないグループはユーザ作成に失敗する）
    extraGroups = [
      "networkmanager"
      "wheel"
    ]
    ++ lib.optionals isFull [ "docker" ];
    shell = pkgs.zsh;

    # WSL では logind のセッションが作られず XDG_RUNTIME_DIR (/run/user/$UID) が存在しないため、
    # linger を有効にして systemd の user インスタンス経由で作成させる（fnm の multishell が依存している）
    linger = true;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Enable nix-ld for dynamically linked executables (e.g. sass-embedded).
  # pkgs/claude-code.nix の Node.js SEA バイナリは patchelf できず nix-ld に
  # 依存しているため、light でも必ず有効にしておくこと
  programs.nix-ld.enable = true;

  # Docker
  virtualisation.docker.enable = isFull;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Nix settings
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
  # WSL には GUI が無く、ターミナル (WezTerm) は Windows ホスト側のフォントを
  # 使うため、light ではシステムフォントを一切入れない
  fonts.packages = lib.optionals isFull cjkFonts;

  # オフライン版 NixOS マニュアルの HTML は WSL では使わないので生成しない。
  # man は残す（--help より参照頻度が高いため）
  documentation.nixos.enable = false;
  documentation.doc.enable = false;

  # perl / rsync / strace の既定インストールを light では省く。
  # 必要になったら environment.systemPackages に個別に足す
  environment.defaultPackages = lib.mkIf (!isFull) [ ];

  # WSL の ext4.vhdx は一度太ると自動では縮まないため、世代とストアを
  # 定期的に掃除して肥大そのものを防ぐ
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "25.11";
}
