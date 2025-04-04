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

    # Remote deployment tools
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      colmena,
      # Hardware support
      hardware,
      # System management
      # Boot security
      # UI and customization
      ...
    }@inputs:
    let
      # --------- System Configuration ---------
      # Default system architecture
      defaultSystem = "x86_64-linux";

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
          ;
        system = defaultSystem;
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

      # --------- Colmena Configuration ---------
      colmena = {
        meta = {
          # Support both architectures for deployment
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          nixpkgs = import nixpkgs {
            system = defaultSystem;
          };
          # Enable distributed builds for all nodes
          nodeNixSettings = {
            substituters = [
              "https://cache.nixos.org/"
              "https://gabehoban.cachix.org"
              "https://chaotic-nyx.cachix.org"
              "https://nix-community.cachix.org"
            ];
            trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "gabehoban.cachix.org-1:8KJ3WRVyJGR7/Ghf1qol4pCqmmGuxNNpedDneyivky4="
              "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
          };
        };

        # Define the sekio node for Colmena
        sekio =
          { self, ... }:
          {
            deployment = {
              targetHost = "sekio.local";
              targetUser = "gabehoban"; # Use non-root user with sudo privileges
              sudo.enable = true; # Use sudo for privileged operations
              allowLocalDeployment = false;
              buildOnTarget = false;
              targetPlatform = "aarch64-linux";
              remoteBuild = false; # Build locally and push to target
            };

            imports = [
              self.nixosConfigurations.sekio.config
            ];
          };
      };

      # --------- SD Card Images ---------
      images = {
        sekio = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            (configLib.relativeToRoot "images/sekio.nix")
            {
              nixpkgs.overlays = [ self.overlays.hardware ];

              # Override SD image parameters
              # Use individual settings rather than a set
              sdImage.firmwareSize = 128; # Increase boot partition size (MB)
              sdImage.expandOnBoot = true; # Make sure SD card is expanded on first boot

              # Root partition size is controlled by the default rootfs size
              # We disable auto-resize since we'll be creating a state partition

              # For initial boot, use extlinux which is compatible with the SD card
              # The final system will switch to u-boot after installation
              boot.loader.generic-extlinux-compatible.enable = true;
            }
          ];
          specialArgs = {
            inherit inputs outputs configLib;
            system = "aarch64-linux";
          };
        };

        # Workstation installation ISO image
        workstation-iso = nixpkgs.lib.nixosSystem {
          system = defaultSystem;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
            (configLib.relativeToRoot "images/workstation.nix")
            {
              nixpkgs.overlays = [ self.overlays.default ];
            }
          ];
          specialArgs = {
            inherit inputs outputs configLib;
            system = defaultSystem;
          };
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
        inherit (self) nixosConfigurations;
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
          pkgs.colmena
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
