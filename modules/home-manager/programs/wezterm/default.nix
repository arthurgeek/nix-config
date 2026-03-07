{ lib, pkgs, ... }:

{
  xdg.configFile = {
    "wezterm/wezterm.lua".source = ./wezterm.lua;
    "wezterm/zen.lua".source = ./zen.lua;
    "wezterm/wezterm.terminfo".source = ./wezterm.terminfo;
  };

  home.activation.weztermTerminfo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.ncurses}/bin/tic -x -o "$HOME/.terminfo" "$HOME/.config/wezterm/wezterm.terminfo"
  '';
}
