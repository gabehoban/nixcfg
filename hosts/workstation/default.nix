# hosts/workstation/default.nix
# Main configuration for workstation host using the new modular approach
{
  configLib,
  inputs,
  ...
}:
{
  networking.hostName = "workstation";

  imports = [
    # ───────────────────────────────────────────
    # External Module Integrations
    # ───────────────────────────────────────────
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko

    # ───────────────────────────────────────────
    # Hardware Configuration
    # ───────────────────────────────────────────
    (configLib.moduleImport "hardware/hw-cpu-amd.nix")
    (configLib.moduleImport "hardware/hw-gpu-amd.nix")
    (configLib.moduleImport "network/default.nix")

    # Host-specific hardware configuration
    ./hardware

    # ───────────────────────────────────────────
    # System Configuration
    # ───────────────────────────────────────────
    # Use the GNOME desktop profile instead of individual modules
    (configLib.profileImport "desktop/gnome.nix")

    # ───────────────────────────────────────────
    # Additional Services (only include what's needed)
    # ───────────────────────────────────────────
    (configLib.moduleImport "services/ssh.nix")
    (configLib.moduleImport "services/ai.nix")
    (configLib.moduleImport "services/yubikey.nix")
    (configLib.moduleImport "services/zram.nix")

    # ───────────────────────────────────────────
    # User Configuration
    # ───────────────────────────────────────────
    (configLib.moduleImport "users/gabehoban.nix")
  ];

  # ───────────────────────────────────────────
  # Home-manager configuration
  # ───────────────────────────────────────────
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit configLib;
    };
  };

  # Enable AMD-specific firmware and drivers
  hardware.enableRedistributableFirmware = true;
}
