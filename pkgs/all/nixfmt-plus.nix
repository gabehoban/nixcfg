# pkgs/all/nixfmt-plus.nix
#
# Enhanced Nix formatter wrapper
# Combines deadnix, statix, and nixfmt for comprehensive code formatting
{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "nixfmt-plus";
  runtimeInputs = with pkgs; [
    deadnix
    nixfmt-rfc-style
    statix
  ];
  text = ''
    set -x
    deadnix --edit
    statix fix
    nixfmt .
  '';
}
