# ==================== IMAGE CONFIGURATION UTILITIES ====================

{
  description = "Common NixOS installation configuration";

  # --------- Image Creation Function ---------
  # Creates a NixOS installation image with common configuration
  mkInstallationImage =
    {
      # System architecture
      system ? "x86_64-linux",

      # Installation media type
      cdType ? "graphical-calamares-gnome",

      # Target host configuration

      # Additional modules to include
      extraModules ? [ ],
    }:

    # --------- Image Builder Function ---------
    { nixpkgs }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        # Base installation media
        {
          imports = [
            "${nixpkgs.outPath}/nixos/modules/installer/cd-dvd/installation-cd-${cdType}.nix"
          ] ++ extraModules;
        }
      ];
    };

  # --------- Helper Functions ---------
  # (Add additional helper functions here)
}
