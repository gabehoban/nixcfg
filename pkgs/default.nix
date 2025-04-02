{
  pkgs ? (import ../nixpkgs.nix) { },
}:

# ==================== PACKAGE IMPORTS ====================
let
  # All packages in flat structure
  all = import ./all { inherit pkgs; };

  # Function to merge package sets
  mergePkgSets = sets: builtins.foldl' (acc: set: acc // set) { } sets;
in

# ==================== EXPORTED PACKAGES ====================
mergePkgSets [ all ]
