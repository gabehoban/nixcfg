# hosts/nuc-titan/hardware/filesystems.nix
#
# Additional filesystem configuration for nuc-titan
{
  # Set persist filesystem as needed for boot (required by impermanence)
  fileSystems."/".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/home".neededForBoot = true;
  fileSystems."/boot".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;

  # tmpfs mounts for volatile directories
  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "size=16G"
      "mode=1777"
      "noatime"
    ];
  };

  # Special cache directories for builds
  fileSystems."/var/lib/nix-build-cache" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "size=32G"
      "mode=1755"
      "noatime"
    ];
  };
}
