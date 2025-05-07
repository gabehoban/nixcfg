# hosts/nuc-titan/hardware/default.nix
#
# Hardware configuration for nuc-titan
{ configLib, pkgs, lib, ... }:

{
  imports = [
    # Hardware-specific configurations
    ./boot.nix
    ./disks
    ./filesystems.nix
    ./network.nix

    # Hardware modules
    (configLib.moduleImport "hardware/hw-cpu-amd.nix")
  ];

  # Set the primary interface name as a module argument with high priority
  _module.args = {
    primaryInterface = lib.mkForce "enp2s0";
  };

  # AMD GPU acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      amdvlk
      rocmPackages.rocm-runtime
    ];
  };

  # Basic host network configuration
  networking = {
    hostName = "nuc-titan";
    hostId = "cafef00f"; # Required for ZFS
  };

  # System hardware tweaks
  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };

  # Enable CPU performance optimization
  powerManagement.cpuFreqGovernor = "performance";

  # AMD-specific optimization
  hardware.cpu.amd.updateMicrocode = true;

  # Kernel modules specifically for Ryzen 9 6900HX
  boot.kernelModules = [
    "k10temp" # AMD CPU temperature monitoring
    "amd_pstate" # AMD P-state driver
    "amd_gpu" # AMD GPU support
  ];
}
