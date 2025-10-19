{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # SQLite
    sqlite
    
    # PostgreSQL client tools
    postgresql
  ];
}
