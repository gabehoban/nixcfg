{
  pkgs ? (import ../nixpkgs.nix) { },
}:

# ==================== PACKAGE CATEGORY IMPORTS ====================
let
  # Development tools and utilities
  development = import ./development { inherit pkgs; };

  # Shell enhancements and tools
  shells = import ./shells { inherit pkgs; };

  # General utilities
  utils = import ./utils { inherit pkgs; };

  # Function to merge package sets
  mergePkgSets = sets: builtins.foldl' (acc: set: acc // set) { } sets;
in

# ==================== EXPORTED PACKAGES ====================
mergePkgSets [
  development
  shells
  utils
  # Add additional package categories here
]
