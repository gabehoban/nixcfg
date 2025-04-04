# hosts/sekio/hardware/filesystems.nix
#
# File system configuration for Sekio
{ lib, ... }:

{
  # File systems configuration
  fileSystems = {
    # Boot partition configuration - standard across all configurations
    "/boot" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };
    
    # Root filesystem with SD card optimizations
    "/" = lib.mkForce {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "defaults" "noatime" ];
    };
  };
  
  # Note: Other tmpfs mounts and optimizations are handled by the
  # hw-platform-rpi.nix module when hardware.raspberry-pi.optimizeForSD is true
}