# parts/images.nix
#
# Image building configurations
{ inputs, self, ... }:
{
  flake = {
    # Image configurations
    images = let
      # Library imports
      lib = inputs.nixpkgs.lib;
      configLib = import ../lib { inherit lib inputs; };
      
      # Common arguments for image configuration
      mkArgs = system: {
        inherit inputs configLib;
        outputs = self;
        nixpkgs = inputs.nixpkgs;
        system = system;
      };
    in {
      # Sekio SD card image
      sekio = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = mkArgs "aarch64-linux";
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          (configLib.relativeToRoot "images/sekio.nix")
          {
            nixpkgs.overlays = [ (import ../overlays { inherit inputs; }).hardware ];
            sdImage.firmwareSize = 128;
            sdImage.expandOnBoot = true;
            boot.loader.generic-extlinux-compatible.enable = true;
          }
        ];
      };
      
      # Workstation ISO image
      workstation-iso = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = mkArgs "x86_64-linux";
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
          (configLib.relativeToRoot "images/workstation.nix")
          {
            nixpkgs.overlays = [ self.overlays.default ];
          }
        ];
      };
    };
  };
}