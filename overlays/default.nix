{ inputs }:

# ==================== OVERLAY DEFINITIONS ====================

{
  # Custom package additions
  additions = final: prev: import ./packages.nix { inherit inputs; } final prev;
  
  # Hardware-specific modifications
  hardware = final: prev: 
    import ./rpi-uboot.nix { pkgs = prev; } final prev;
    
  # Combined overlays
  default = final: prev: let self = { inherit (self) additions hardware; }; in
    (self.additions final prev)
    // (self.hardware final prev);
}