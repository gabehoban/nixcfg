# hosts/nuc-titan/hardware/default.nix
#
# Hardware configuration for nuc-titan
{ configLib, pkgs, ... }:

{
  imports = [
    # Hardware-specific configurations
    ./boot.nix
    ./disks
    ./filesystems.nix

    # Hardware modules
    (configLib.moduleImport "hardware/hw-cpu-amd.nix")
  ];

  # AMD GPU acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      amdvlk
      rocmPackages.rocm-runtime
    ];
  };

  # Network configuration
  networking = {
    hostName = "nuc-titan";
    hostId = "cafef00f"; # Required for ZFS
    useDHCP = false;

    # Static IP configuration
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "10.32.40.42";
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
