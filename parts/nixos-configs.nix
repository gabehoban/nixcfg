# parts/nixos-configs.nix
#
# NixOS configurations for all systems
{ inputs, self, ... }:
{
  flake = {
    # NixOS configurations
    nixosConfigurations =
      let
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
        commonModules = [ ];
      in
      {
        # Workstation configuration (x86_64-linux)
        workstation = inputs.nixpkgs.lib.nixosSystem {
          system = defaultSystem;
          specialArgs = mkArgs defaultSystem;
          modules = [
            (configLib.relativeToRoot "hosts/workstation")
            inputs.chaotic.nixosModules.default
          ] ++ commonModules;
        };

        # Homelab hosts - all x86_64-linux

        # Luna configuration - Plex media server
        nuc-luna = inputs.nixpkgs.lib.nixosSystem {
          system = defaultSystem;
          specialArgs = mkArgs defaultSystem;
          modules = [
            (configLib.relativeToRoot "hosts/nuc-luna")
            inputs.chaotic.nixosModules.default
          ] ++ commonModules;
        };

        # Juno configuration - Download services
        nuc-juno = inputs.nixpkgs.lib.nixosSystem {
          system = defaultSystem;
          specialArgs = mkArgs defaultSystem;
          modules = [
            (configLib.relativeToRoot "hosts/nuc-juno")
            inputs.chaotic.nixosModules.default
          ] ++ commonModules;
        };

        # Titan configuration - Build host and binary cache
        nuc-titan = inputs.nixpkgs.lib.nixosSystem {
          system = defaultSystem;
          specialArgs = mkArgs defaultSystem;
          modules = [
            (configLib.relativeToRoot "hosts/nuc-titan")
            inputs.chaotic.nixosModules.default
          ] ++ commonModules;
        };
      };
  };
}
