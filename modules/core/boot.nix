# modules/core/boot.nix
#
# Boot and kernel configuration module
#
# Configures the boot loader, kernel parameters, and process scheduling
# optimizations using the CachyOS kernel and ananicy-cpp for process
# prioritization.
{
  pkgs,
  ...
}:
{
  # Boot configuration
  boot = {
    # Use systemd in initrd
    initrd.systemd.enable = true;

    # Kernel parameters for performance and quieter boot
    kernelParams = [
      # Fallback shell on boot failure
      "boot.shell_on_fail"
      # CPU specific optimizations
      "clearcpuid=514"
      # Reduce log verbosity for cleaner boot
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      # Kernel optimizations
      "nowatchdog"
      "quiet"
      "splash"
      "split_lock_detect=off"
    ];

    # Use CachyOS optimized kernel and ZFS
    kernelPackages = pkgs.linuxPackages_cachyos;
  };

  # Process scheduling services
  services = {
    # Ananicy for prioritizing processes
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
      extraRules = [
        {
          name = ".easyeffects-wr";
          type = "LowLatency_RT";
        }
      ];
    };
  };
}
