# modules/hardware/hw-platform-rpi.nix
#
# General optimizations for Raspberry Pi devices to improve reliability and performance
# This is a flattened module that applies all optimizations directly when imported
_:

# Fully flattened direct configuration with all optimizations enabled by default
{
  # Define a flag that can be checked by other modules to detect Raspberry Pi platform
  # (Using an empty attrset that can be checked with `hasAttrByPath` or `?` operator)
  hardware.raspberry-pi = { };

  # SD card write reduction optimizations
  boot.tmp.useTmpfs = true;

  # Reduce writes to the SD card by keeping temporary files in RAM
  fileSystems = {
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=512M"
        "mode=1777"
      ];
    };

    # Volatile logs in RAM
    "/var/log" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=128M"
        "mode=755"
      ];
    };
  };

  # Setup automatic TRIM for flash storage if supported
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # ZRAM swap configuration
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50; # Use 50% of RAM for compressed swap
  };

  # Configure journald to store logs in RAM
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=32M
    SystemMaxUse=32M
  '';

  # Power saving options
  powerManagement.cpuFreqGovernor = "ondemand";

  # USB power saving
  boot.kernelParams = [ "usbcore.autosuspend=1" ];

  # Power off USB devices when not in use
  services.udev.extraRules = ''
    # Power off USB devices when not in use
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
  '';

  # Security: Firewall
  modules.network.firewall = {
    enable = true; # Use new NFT-based firewall
    # SSH is enabled by default, no need to specify port 22
    # Allow ping
    allowPing = true;
    # Log all denied packets
    logRefusedConnections = true;
  };

  # Security: SSH hardening
  services.openssh = {
    settings = {
      # Disable root login completely
      PermitRootLogin = "no";

      # Disable password authentication, use keys only
      PasswordAuthentication = false;

      # Additional security settings
      X11Forwarding = false;
      MaxAuthTries = 12; # Increased to allow more authentication attempts
      LoginGraceTime = 20;
    };
  };
}
