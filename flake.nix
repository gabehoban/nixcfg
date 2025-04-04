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
    flake-utils.url = "github:numtide/flake-utils";

    # Extended modules (with nixpkgs follows)
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
  };

  # ==================== OUTPUTS ====================
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      chaotic,
      agenix-rekey,
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
          ];
        };
        
        sekio = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "aarch64-linux";
          modules = [
            (configLib.relativeToRoot "hosts/sekio")
            { nixpkgs.overlays = [ self.overlays.hardware ]; }
          ];
        };
      };
      
      # --------- SD Card Images ---------
      images = {
        sekio = import "${nixpkgs}/nixos/lib/make-system.nix" {
          system = "aarch64-linux";
          modules = [
            (configLib.relativeToRoot "images/sekio.nix")
            { nixpkgs.overlays = [ self.overlays.hardware ]; }
          ];
          specialArgs = { inherit inputs outputs configLib; };
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

      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.nixosConfigurations;
      };

      # --------- Development Tools ---------
      formatter = configLib.forAllSystems (pkgsSystem: self.packages.${pkgsSystem}.nixfmt-plus);
    }
    // flake-utils.lib.eachDefaultSystem (system: rec {
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ agenix-rekey.overlays.default ];
      };
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.agenix-rekey
          pkgs.age-plugin-yubikey
          pkgs.rage
        ];
      };
    });

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org/"
      "https://gabehoban.cachix.org"
      "https://chaotic-nyx.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "gabehoban.cachix.org-1:8KJ3WRVyJGR7/Ghf1qol4pCqmmGuxNNpedDneyivky4="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
