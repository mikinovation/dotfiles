{
  lib,
  pkgs,
  ...
}:

{
  # Set environment variables so Playwright uses the browsers from the Nix store.
  # aarch64-darwin では playwright-driver.browsers が壊れやすいため Linux 限定にし、
  # macOS では Playwright 自身のダウンロードに任せる
  home.sessionVariables = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
  };
}
