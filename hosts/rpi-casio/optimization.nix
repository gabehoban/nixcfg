# hosts/rpi-casio/optimization.nix
#
# Performance and longevity optimizations for Raspberry Pi
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Raspberry Pi optimizations are now directly applied via hw-platform-rpi.nix flattened module

  # ───────────────────── Memory Management Improvements ─────────────────────

  # Early OOM killer protects critical GPS/NTP services
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    extraArgs = [
      "--prefer=(gpsd|chronyd)"
      "--avoid=(prometheus|node_exporter)"
    ];
  };

  # Memory tuning optimized for NTP server operation
  boot.kernel.sysctl = {
    # VM settings
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
    "vm.dirty_expire_centisecs" = 1500;
    "vm.dirty_writeback_centisecs" = 1500;
    "vm.min_free_kbytes" = 16384;
    "kernel.panic_on_oom" = 0;

    # Network buffers for precise NTP traffic
    "net.core.rmem_max" = 4194304;
    "net.core.wmem_max" = 1048576;
    "net.core.netdev_max_backlog" = 5000;
    "net.core.somaxconn" = 1024;
    "net.ipv4.tcp_rmem" = "4096 87380 4194304";
    "net.ipv4.tcp_wmem" = "4096 65536 1048576";
    "net.ipv4.tcp_no_metrics_save" = 1;
    "net.ipv4.udp_mem" = "65536 131072 262144";

    "vm.laptop_mode" = 5;
  };

  # ───────────────────── I/O Optimizations ─────────────────────

  # Storage I/O optimized for SD card longevity
  services.udev.extraRules = ''
    # Use deadline for SD cards
    ACTION=="add|change", KERNEL=="mmcblk[0-9]", ATTR{queue/scheduler}="deadline"

    # Use mq-deadline for SSDs
    ACTION=="add|change", SUBSYSTEM=="block", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"

    # Improve sequential read performance
    ACTION=="add|change", SUBSYSTEM=="block", ATTR{queue/read_ahead_kb}="1024"

    # Avoid SD card issues with NCQ
    ACTION=="add|change", KERNEL=="mmcblk[0-9]", ATTR{device/queue_depth}="1"
  '';

  # Prioritize timing-critical processes
  security.pam.loginLimits = [
    {
      domain = "chrony";
      item = "nice";
      type = "-";
      value = "-10";
    }
    {
      domain = "chrony";
      item = "rtprio";
      type = "-";
      value = "20";
    }
    {
      domain = "gpsd";
      item = "nice";
      type = "-";
      value = "-5";
    }
  ];

  # ───────────────────── Process Scheduling ─────────────────────

  # Reserve CPU core 3 for real-time GPS/NTP services
  boot.kernelParams = [
    "isolcpus=3"
    "nohz_full=3"
    "rcu_nocbs=3"
  ];

  # Bind critical services to the isolated core
  systemd.services.chrony.serviceConfig.CPUAffinity = "3";
  systemd.services.gpsd.serviceConfig.CPUAffinity = "3";

  # ───────────────────── Storage Management ─────────────────────

  # TRIM helps maintain flash storage performance
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # Use the global Nix garbage collection settings from core/nix.nix

  # Prevent temporary files from filling storage
  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root 7d"
    "D /var/tmp 1777 root root 7d"
  ];

  # ───────────────────── Service Optimizations ─────────────────────

  # Systemd tuning for resource constrained environment
  systemd = {
    extraConfig = ''
      DefaultTimeoutStartSec=20s
      DefaultTimeoutStopSec=20s
      DefaultLimitNOFILE=65536
    '';

    # Will add proper journald configuration later

    # Time synchronization is mission-critical service
    services.chrony.serviceConfig = {
      MemoryLimit = "40M";
      CPUWeight = 90;
      IOWeight = 90;
      IOSchedulingClass = "realtime";
      IOSchedulingPriority = 4;
      OOMScoreAdjust = -900;
    };

    # GPS input is essential for stratum 1 operation
    services.gpsd.serviceConfig = {
      MemoryLimit = "30M";
      CPUWeight = 80;
      IOWeight = 80;
      OOMScoreAdjust = -800;
    };

    # Monitoring is less critical than timing
    services.prometheus.serviceConfig = lib.mkIf config.services.prometheus.enable {
      CPUWeight = 30;
      IOWeight = 30;
      OOMScoreAdjust = 300;
    };
  };

  # ───────────────────── Resource Monitoring ─────────────────────

  environment.systemPackages = with pkgs; [
    iotop
    htop
    lm_sensors
    smartmontools
    sysstat
    glances
    nmon
    procps
    iproute2
  ];

  # ───────────────────── Network Performance Tuning ─────────────────────

  networking = {
    nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
  };
}
