{ inputs }:

# ==================== OVERLAY DEFINITIONS ====================

{
  # Custom package additions
  additions = final: prev: import ./packages.nix { inherit inputs; } final prev;
}
