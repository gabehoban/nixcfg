# modules/core/boot.nix
#
# Boot and kernel configuration module
{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  # Import secure boot module
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

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

    # Secure boot with lanzaboote
    lanzaboote = {
      enable = true;
      pkiBundle = lib.mkDefault "/var/lib/sbctl";
    };

    # Boot loader settings
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkForce false; # Disabled in favor of lanzaboote
      timeout = 3;
    };

    # Quiet boot settings
    consoleLogLevel = 0;
    initrd.verbose = false;

    # Graphical boot splash
    plymouth = {
      enable = true;
    };

    # Use CachyOS optimized kernel and ZFS
    zfs.package = pkgs.zfs_cachyos;
    kernelPackages = pkgs.linuxPackages_cachyos;
  };

  # Process scheduling services
  services = {
    # SCX scheduler for improved responsiveness
    scx = {
      enable = true;
      scheduler = "scx_bpfland";
      package = pkgs.scx.full;
    };

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

  # Boot-related utility packages
  environment.systemPackages = with pkgs; [
    sbctl # Secure boot key management
    efibootmgr # EFI boot entry management
  ];
}