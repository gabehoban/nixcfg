# hosts/nuc-luna/hardware/default.nix
#
# Hardware configuration for nuc-luna
{ configLib, pkgs, ... }:

{
  imports = [
    # Hardware-specific configurations
    ./boot.nix
    ./disks
    ./filesystems.nix

    # Hardware modules
    (configLib.moduleImport "hardware/hw-cpu-intel.nix")
  ];

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

  # Network configuration
  networking = {
    hostName = "nuc-luna";
    hostId = "cafef00d"; # Required for ZFS
    useDHCP = true; # Enable DHCP for global configuration

    # Enable both IPv4 and IPv6
    enableIPv6 = true;

    # Enable DHCP specifically for eth0 interface
    interfaces.eth0 = {
      useDHCP = true;
    };

    # Remove static IP configuration as it's now handled by DHCP with router static assignment
    # The router has static DHCP entries for this host

    # Add host entries for the homelab
    hosts = {
      "10.32.40.41" = [ "nuc-luna" ];
      "10.32.40.42" = [ "nuc-titan" ];
      "10.32.40.43" = [ "nuc-juno" ];
      "10.32.40.45" = [ "minio-vip" ];
    };
  };

  # Time synchronization
  services.chrony.enable = true;

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
