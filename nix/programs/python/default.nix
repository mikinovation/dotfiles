{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    python3
    uv
  ];

  home.sessionVariables = {
    UV_PYTHON_PREFERENCE = "only-system";
    UV_PYTHON = "3.13";
  };
}
