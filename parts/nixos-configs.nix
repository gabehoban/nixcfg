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
      inherit (inputs.nixpkgs) lib;
      configLib = import ../lib { inherit lib inputs; };
      
      # Common arguments for system configuration
      mkArgs = system: {
        inherit inputs configLib;
        outputs = self;
        inherit (inputs) nixpkgs;
        inherit system;
      };
      
      # Common modules for all systems
      commonModules = [
        inputs.nixos-nftables-firewall.nixosModules.default
      ];
    in {
      # Workstation configuration (x86_64-linux)
      workstation = inputs.nixpkgs.lib.nixosSystem {
        system = defaultSystem;
        specialArgs = mkArgs defaultSystem;
        modules = [
          (configLib.relativeToRoot "hosts/workstation")
          inputs.chaotic.nixosModules.default
        ] ++ commonModules;
      };
      
      # Sekio configuration (aarch64-linux)
      sekio = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = mkArgs "aarch64-linux";
        modules = [
          (configLib.relativeToRoot "hosts/sekio")
          { nixpkgs.overlays = [ (import ../overlays { inherit inputs; }).hardware ]; }
        ] ++ commonModules;
      };
      
      # Casio configuration (aarch64-linux)
      casio = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = mkArgs "aarch64-linux";
        modules = [
          (configLib.relativeToRoot "hosts/casio")
          { nixpkgs.overlays = [ (import ../overlays { inherit inputs; }).hardware ]; }
        ] ++ commonModules;
      };
    };
  };
}