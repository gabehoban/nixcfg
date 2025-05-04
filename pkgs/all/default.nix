# pkgs/all/default.nix
#
# Package collection module
# Aggregates all custom packages for import into the system
{
  pkgs ? (import ../../nixpkgs.nix) { },
}:
{
  # Development tools
  nixfmt-plus = pkgs.callPackage ./nixfmt-plus.nix { };

  # Shell enhancements
  zsh-histdb-skim = pkgs.callPackage ./zsh-histdb-skim.nix { };
}
