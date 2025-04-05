# modules/hardware/hw-platform-rpi.nix
#
# General optimizations for Raspberry Pi devices to improve reliability and performance
{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.hardware.raspberry-pi;
in
{
  options.hardware.raspberry-pi = {
    optimizeForSD = mkEnableOption "Enable SD card write reduction optimizations";

    enableZramSwap = mkEnableOption "Enable ZRAM for swap to reduce SD card wear";

    volatileLogs = mkEnableOption "Keep all logs in memory to reduce SD card writes";

    enablePowerSaving = mkEnableOption "Enable power-saving features";

    security = {
      enableFirewall = mkEnableOption "Enable basic firewall settings";
      enableSSHHardening = mkEnableOption "Enable SSH hardening measures";
    };
  };

  config = mkMerge [
    # SD card write reduction optimizations
    (mkIf cfg.optimizeForSD {
      # Mount temporary filesystems in RAM
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
      };

      # Setup automatic TRIM for flash storage if supported
      services.fstrim = {
        enable = true;
        interval = "weekly";
      };
    })

    # ZRAM swap configuration
    (mkIf cfg.enableZramSwap {
      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50; # Use 50% of RAM for compressed swap
      };
    })

    # Volatile logs configuration
    (mkIf cfg.volatileLogs {
      # Keep logs in RAM
      fileSystems."/var/log" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "defaults"
          "size=128M"
          "mode=755"
        ];
      };

      # Configure journald to store logs in RAM
      services.journald.extraConfig = ''
        Storage=volatile
        RuntimeMaxUse=32M
        SystemMaxUse=32M
      '';
    })

    # Power saving options
    (mkIf cfg.enablePowerSaving {
      # CPU frequency scaling
      powerManagement.cpuFreqGovernor = "ondemand";

      # USB power saving
      boot.kernelParams = [
        "usbcore.autosuspend=1"
      ];

      # Power off USB devices when not in use
      services.udev.extraRules = ''
        # Power off USB devices when not in use
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
      '';
    })

    # Security: Firewall
    (mkIf cfg.security.enableFirewall {
      networking.firewall = {
        enable = lib.mkForce true; # Override default setting from network module
        allowedTCPPorts = [
          22 # SSH
        ];
        # Allow ping
        allowPing = true;
        # Log all denied packets
        logRefusedConnections = true;
      };
    })

    # Security: SSH hardening
    (mkIf cfg.security.enableSSHHardening {
      services.openssh = {
        settings = {
          # Disable root login completely
          PermitRootLogin = "no";

          # Disable password authentication, use keys only
          PasswordAuthentication = false;

          # Additional security settings
          X11Forwarding = false;
          MaxAuthTries = 12;  # Increased to allow more authentication attempts
          LoginGraceTime = 20;
        };
      };
    })

    # Security: No fail2ban as per project requirements
  ];
}
