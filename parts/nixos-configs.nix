# parts/nixos-configs.nix
#
# NixOS configurations for all systems
{ inputs, self, ... }:
{
  flake = {
    # NixOS configurations
    nixosConfigurations = let 
      # System configuration
      defaultSystem = "x86_64-linux";
      
      # Library imports
      lib = inputs.nixpkgs.lib;
      configLib = import ../lib { inherit lib inputs; };
      
      # Common arguments for system configuration
      mkArgs = system: {
        inherit inputs configLib;
        outputs = self;
        nixpkgs = inputs.nixpkgs;
        system = system;
      };
    in {
      # Workstation configuration (x86_64-linux)
      workstation = inputs.nixpkgs.lib.nixosSystem {
        system = defaultSystem;
        specialArgs = mkArgs defaultSystem;
        modules = [
          (configLib.relativeToRoot "hosts/workstation")
          inputs.chaotic.nixosModules.default
        ];
      };
      
      # Sekio configuration (aarch64-linux)
      sekio = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = mkArgs "aarch64-linux";
        modules = [
          (configLib.relativeToRoot "hosts/sekio")
          { nixpkgs.overlays = [ (import ../overlays { inherit inputs; }).hardware ]; }
        ];
      };
    };
  };
}