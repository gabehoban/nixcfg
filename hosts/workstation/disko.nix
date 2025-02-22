{
  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = "/dev/nvme0n1";

        content = {
          type = "gpt";

          partitions = {
            ESP = {
              content = {
                format = "vfat";

                mountOptions = [
                  "defaults"
                  "umask=0077"
                ];

                mountpoint = "/boot";
                type = "filesystem";
              };

              size = "1024M";
              type = "EF00";
            };

            luks = {
              size = "100%";

              content = {
                type = "luks";
                name = "crypted";

                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];

                  subvolumes = {
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd" "noatime"];
                    };

                    "/home/.snapshots" = {
                      mountOptions = ["compress=zstd" "noatime"];
                      mountpoint = "/home/.snapshots";
                    };

                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };

                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime"];
                    };

                    "persist" = {
                      mountpoint = "/persist";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
