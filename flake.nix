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
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      lix-module,
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
            lix-module.nixosModules.default
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
}
