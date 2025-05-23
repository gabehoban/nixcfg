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
    (configLib.moduleImport "services/sys-ssh.nix")
    (configLib.moduleImport "services/sec-yubikey.nix")
    (configLib.moduleImport "services/sys-zram.nix")

    # ───────────────────────────────────────────
    # User Configuration
    # ───────────────────────────────────────────
    (configLib.moduleImport "users/gabehoban.nix")
  ];

  # Enable impermanence for ephemeral system state
  impermanence.enable = true;

  # ───────────────────────────────────────────
  # Network and Security Configuration
  # ───────────────────────────────────────────
  # Enable the standard NixOS firewall
  networking.firewall.enable = true;

  # ───────────────────────────────────────────
  # Home-manager configuration
  # ───────────────────────────────────────────
  home-manager = {
    useGlobalPkgs = true; # Uses the system's nixpkgs, so don't set nixpkgs options in home-manager
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit configLib;
    };
    # Note: When using useGlobalPkgs, don't set any nixpkgs options in home-manager modules
  };

  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDmlr0LtfwsOHLCmI87VUS8YqGWa/dKKWtQFGuvoH89E";

  # Enable AMD-specific firmware and drivers
  hardware.enableRedistributableFirmware = true;

  # Enable cross-compilation support for Raspberry Pi (aarch64)
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # NixOS release version
  system.stateVersion = "24.11";
}
