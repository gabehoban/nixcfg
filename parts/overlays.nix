# parts/overlays.nix
#
# NixOS package overlays
{ inputs, ... }:
{
  flake = {
    # Package overlays
    overlays = import ../overlays { inherit inputs; };
  };
}