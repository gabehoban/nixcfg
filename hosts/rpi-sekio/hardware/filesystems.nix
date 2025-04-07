# hosts/rpi-sekio/hardware/filesystems.nix
#
# File system configuration for rpi-sekio
{ lib, ... }:

{
  # File systems configuration
  fileSystems = {
    # Root filesystem with SD card optimizations
    "/" = lib.mkForce {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [
        "defaults"
        "noatime"
      ];
    };
  };

  # Note: Other tmpfs mounts and optimizations are handled by the
  # hw-platform-rpi.nix module when hardware.raspberry-pi.optimizeForSD is true
}
