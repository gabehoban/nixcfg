# hosts/nuc-luna/hardware/boot.nix
#
# Boot configuration for nuc-luna
{ pkgs, ... }:
{
  # Use systemd-boot for UEFI systems
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "auto";
        editor = false;
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
    };

    # Silent boot for server hardware
    kernelParams = [
      # For Intel Alder Lake-N100
      "intel_pstate=active"
      "quiet"
      "udev.log_level=3"
    ];

    # Load additional modules for hardware support
    kernelModules = [
      "kvm-intel" # For virtualization capabilities
    ];

    # Disable console blanking
    consoleLogLevel = 0;
    initrd.verbose = false;
  };
}
