# hosts/nuc-luna/hardware/filesystems.nix
#
# Additional filesystem configuration for nuc-luna
_: {
  # Set persist filesystem as needed for boot (required by impermanence)
  fileSystems."/".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/home".neededForBoot = true;
  fileSystems."/boot".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;

  # Common NFS mount for media
  fileSystems."/export/media" = {
    device = "10.32.40.10:/mnt/user/media";
    fsType = "nfs";
    options = [
      "noatime"
      "nofail"
      "soft"
    ];
  };

  # tmpfs mounts for volatile directories
  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "size=4G"
      "mode=1777"
      "noatime"
    ];
  };
}
