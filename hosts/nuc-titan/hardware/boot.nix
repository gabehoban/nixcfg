# hosts/nuc-titan/hardware/boot.nix
#
# Boot configuration for nuc-titan
_: {
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

    # Optimization for AMD Ryzen 9 6900HX
    kernelParams = [
      "amd_pstate=active" # AMD P-state driver
      "iommu=pt" # IOMMU pass-through for better performance
      "quiet"
      "udev.log_level=3"
    ];

    # Load additional modules for hardware support
    kernelModules = [
      "kvm-amd" # AMD virtualization
      "amdgpu" # AMD GPU support
      "k10temp" # AMD CPU temperature monitoring
    ];

    # Disable console blanking
    consoleLogLevel = 0;
    initrd.verbose = false;
  };
}
