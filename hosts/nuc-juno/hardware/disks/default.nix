# hosts/nuc-juno/hardware/disks/default.nix
#
# Storage configuration for nuc-juno
_:

{
  # Disko Configuration
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-512GB_SSD_CN47BBM0208294";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "nixos"
                  "-f"
                ];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "subvol=root"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "subvol=home"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "subvol=nix"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "subvol=persist"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "subvol=log"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "32G";
                  };
                };
              };
            };
          };
        };
      };
      minio = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WD_Blue_SA510_2.5_1000GB_24135Z800504";
        content = {
          type = "gpt";
          partitions = {
            xfs = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                # XFS optimization for Minio workloads
                extraArgs = [
                  "-b"
                  "size=4096"
                  "-s"
                  "size=4096"
                  "-d"
                  "su=64k,sw=1"
                ];
                mountpoint = "/minio/data";
                mountOptions = [
                  "noatime"
                  "nodiratime"
                  "logbufs=8"
                ];
              };
            };
          };
        };
      };
    };
  };

  # BTRFS optimizations
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # Add BTRFS support
  boot.kernelModules = [ "btrfs" ];

  # Add scheduler optimization for SSDs
  services.udev.extraRules = ''
    # Set scheduler for NVMe SSD
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
  '';
}
