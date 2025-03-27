# ───────────────────────────────────────────
# Storage Configuration for Workstation
# ───────────────────────────────────────────
_: {
  # ───────────────────────────────────────────
  # Disko Configuration (Declarative Partitioning)
  # ───────────────────────────────────────────
  disko.devices = {
    # Physical Disk Configuration
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1"; # Primary NVMe drive
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition
            ESP = {
              size = "512M";
              type = "EF00"; # EFI System Partition type
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            # ZFS Root Partition
            zroot = {
              size = "100%"; # Use remaining space
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };

    # ZFS Pool Configuration
    zpool = {
      zroot = {
        type = "zpool";
        # Global ZFS Options
        rootFsOptions = {
          canmount = "off"; # Don't mount the root dataset directly
          compression = "zstd"; # Use zstd compression
          "com.sun:auto-snapshot" = "false"; # Disable auto snapshots
        };
        # Create initial snapshots for rollback
        postCreateHook = "(zfs list -t snapshot -H -o name | grep -E '^zroot/encrypted/root@blank$' || zfs snapshot zroot/encrypted/root@blank) && (zfs list -t snapshot -H -o name | grep -E '^zroot/encrypted/home@blank$' || zfs snapshot zroot/encrypted/home@blank)";

        # ZFS Datasets
        datasets = {
          # Encrypted container dataset
          encrypted = {
            type = "zfs_fs";
            options.mountpoint = "none"; # Don't mount directly
            options.encryption = "aes-256-gcm"; # Encryption algorithm
            options.keyformat = "passphrase"; # Use passphrase
            postCreateHook = ''zfs set keylocation="prompt" "zroot/encrypted"'';
          };

          # Root filesystem
          "encrypted/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy"; # Let NixOS handle the mounting
            postCreateHook = "zfs snapshot zroot/encrypted/root@blank";
          };

          # Nix store
          "encrypted/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };

          # Persistent data
          "encrypted/persist" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/persist";
          };

          # Home directories
          "encrypted/home" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
          };
        };
      };
    };
  };

  # ───────────────────────────────────────────
  # Additional Filesystem Mounts
  # ───────────────────────────────────────────
  fileSystems = {
    # Essential filesystems needed during boot
    "/".neededForBoot = true;
    "/nix".neededForBoot = true;
    "/home".neededForBoot = true;
    "/boot".neededForBoot = true;
    "/persist".neededForBoot = true;

    # Secondary SSD for games storage
    "/games" = {
      device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_232758800485-part1";
      fsType = "xfs";
    };
  };
}
