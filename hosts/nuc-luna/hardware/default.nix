# hosts/nuc-luna/hardware/default.nix
#
# Hardware configuration for nuc-luna
{ configLib, pkgs, lib, ... }:

{
  imports = [
    # Hardware-specific configurations
    ./boot.nix
    ./disks
    ./filesystems.nix
    ./network.nix

    # Hardware modules
    (configLib.moduleImport "hardware/hw-cpu-intel.nix")
  ];

  # Set the primary interface name as a module argument with high priority
  _module.args = {
    primaryInterface = lib.mkForce "enp1s0";
  };

  # Intel QuickSync for Plex - using hardware.graphics (renamed from hardware.opengl)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Basic host network configuration
  networking = {
    hostName = "nuc-luna";
    hostId = "cafef00d"; # Required for ZFS
  };

  # System hardware tweaks
  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };

  # Kernel modules
  boot.kernelModules = [
    "coretemp" # CPU temperature monitoring
  ];
}
