# hosts/rpi-sekio/hardware/default.nix
#
# Main hardware configuration for rpi-sekio
{
  lib,
  modulesPath,
  inputs,
  ...
}:
{
  imports = [
    # Basic hardware detection
    (modulesPath + "/installer/scan/not-detected.nix")

    # Raspberry Pi hardware support
    inputs.hardware.nixosModules.raspberry-pi-4

    # Modularized hardware configuration
    ./boot.nix
    ./filesystems.nix
    ./platform.nix
    ./rpi-config.nix
  ];

  # System architecture
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # Network configuration
  networking.useDHCP = lib.mkDefault true;
}
