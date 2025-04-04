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

  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDmlr0LtfwsOHLCmI87VUS8YqGWa/dKKWtQFGuvoH89E";

  # Enable AMD-specific firmware and drivers
  hardware.enableRedistributableFirmware = true;

  # Enable cross-compilation support for Raspberry Pi (aarch64)
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # NixOS release version
  system.stateVersion = "24.11";
}
