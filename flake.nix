{
  description = "Gabe's NixOS configuration";

  # ==================== INPUTS ====================
  inputs = {
    # Core dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware";

    # Framework & functionality modules
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";

    # Extended modules (with nixpkgs follows)
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Application integrations
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # External overlays
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  # ==================== OUTPUTS ====================
  outputs =
    {
      self,
      nixpkgs,
      chaotic,
      home-manager,
      ...
    }@inputs:
    let
      # --------- System Configuration ---------
      system = "x86_64-linux";

      # --------- Library Imports ---------
      inherit (self) outputs;
      inherit (nixpkgs) lib;
      configLib = import ./lib { inherit lib inputs; };

      # --------- Common Arguments ---------
      specialArgs = {
        inherit
          inputs
          outputs
          configLib
          nixpkgs
          system
          ;
      };
    in
    {
      # --------- NixOS Configurations ---------
      nixosConfigurations = {
        workstation = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            (configLib.relativeToRoot "hosts/workstation")
            chaotic.nixosModules.default
            home-manager.nixosModules.home-manager
          ];
        };
      };

      # --------- Package Overlays ---------
      overlays = import ./overlays { inherit inputs; };

      # --------- Custom Packages ---------
      packages = configLib.forAllSystems (
        pkgsSystem:
        let
          pkgs = nixpkgs.legacyPackages.${pkgsSystem};
        in
        import ./pkgs { inherit pkgs; }
      );

      # --------- Development Tools ---------
      formatter = configLib.forAllSystems (pkgsSystem: self.packages.${pkgsSystem}.nixfmt-plus);
    };
  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
      "https://cache.nixos.org/"
      "https://chaotic-nyx.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
