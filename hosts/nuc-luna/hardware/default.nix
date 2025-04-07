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
    useDHCP = false;

    # Static IP configuration
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "10.32.40.41";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = "10.32.40.254";
    nameservers = [
      "10.32.40.254"
      "1.1.1.1"
    ];

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
