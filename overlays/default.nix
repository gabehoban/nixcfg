{ inputs }:

# ==================== OVERLAY DEFINITIONS ====================

{
  # Custom package additions
  additions = final: prev: import ./packages.nix { inherit inputs; } final prev;

  # External overlays (referenced from inputs)
  neovim-nightly = inputs.neovim-nightly-overlay.overlay;

  # Additional overlays can be added here
}
