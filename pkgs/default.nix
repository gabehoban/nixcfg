{
  pkgs ? (import ../nixpkgs.nix) { },
}:

# ==================== PACKAGE IMPORTS ====================
let
  # All packages in flat structure
  all = import ./all { inherit pkgs; };

  # Legacy imports for backward compatibility
  development = import ./development { inherit pkgs; };
  shells = import ./shells { inherit pkgs; };
  utils = import ./utils { inherit pkgs; };

  # Function to merge package sets
  mergePkgSets = sets: builtins.foldl' (acc: set: acc // set) { } sets;
in

# ==================== EXPORTED PACKAGES ====================
mergePkgSets [
  all
  # Legacy imports below - will be removed in future
  development
  shells
  utils
]