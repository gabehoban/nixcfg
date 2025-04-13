# parts/images.nix
#
# Image building configurations
{ inputs, self, ... }:
{
  flake = {
    # Image configurations
    images =
      let
        # Library imports
        inherit (inputs.nixpkgs) lib;
        configLib = import ../lib { inherit lib inputs; };

        # Common arguments for image configuration
        mkArgs = system: {
          inherit inputs configLib;
          outputs = self;
          inherit (inputs) nixpkgs;
          inherit system;
        };
      in
      {
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
