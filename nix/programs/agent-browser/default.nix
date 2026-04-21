{ config, pkgs, ... }:

{
  # Set environment variables so Playwright uses browsers from the Nix store
  home.sessionVariables = {
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
  };
}
