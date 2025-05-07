# hosts/nuc-juno/hardware/default.nix
#
# Hardware configuration for nuc-juno
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

  # Intel QuickSync for hardware acceleration - using hardware.graphics
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
    hostName = "nuc-juno";
    hostId = "cafef00e"; # Required for ZFS
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
