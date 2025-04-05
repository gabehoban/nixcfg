# modules/services/chrony.nix
#
# Chrony NTP server configuration with GPS/PPS integration
# Flattened module that directly applies configuration
{
  config,
  lib,
  pkgs,
  ...
}:

# Direct configuration with customization options
let
  # Access existing values if they exist, or use defaults
  enableGPS = config.services.chrony.enableGPS or false;
  
  # Default networks that are allowed to use this NTP server
  allowedNetworks = config.services.chrony.allowedNetworks or [
    "192.168.1.0/24" # DMZ
    "10.32.10.0/24" # VLAN10 - Trusted
    "10.32.20.0/24" # VLAN20 - Guest
    "10.32.30.0/24" # VLAN30 - IOT
    "10.32.40.0/24" # VLAN40 - Servers
    "10.32.50.0/24" # VLAN50 - Video
  ];
  
  # Default public NTP servers to use as initial time source
  publicServers = config.services.chrony.publicServers or [
    "time.apple.com"
    "time.nist.gov"
    "time.cloudflare.com"
  ];
in
{
  # Maintain the option interface for backward compatibility and host configuration
  options.services.chrony = with lib; {
    enableGPS = mkOption {
      type = types.bool;
      default = false;
      description = "Enable GPS/PPS integration with chrony";
    };

    allowedNetworks = mkOption {
      type = types.listOf types.str;
      default = [
        "192.168.1.0/24" # DMZ
        "10.32.10.0/24" # VLAN10 - Trusted
        "10.32.20.0/24" # VLAN20 - Guest
        "10.32.30.0/24" # VLAN30 - IOT
        "10.32.40.0/24" # VLAN40 - Servers
        "10.32.50.0/24" # VLAN50 - Video
      ];
      description = "Networks that are allowed to use this NTP server";
    };

    publicServers = mkOption {
      type = types.listOf types.str;
      default = [
        "time.apple.com"
        "time.nist.gov"
        "time.cloudflare.com"
      ];
      description = "Public NTP servers to use as initial time source";
    };
  };

  # Direct implementation
  config = {
    # Create directory structure for chrony
    systemd.tmpfiles.rules = [
      "d /etc/chrony 0750 chrony chrony -"
      "d /var/lib/chrony 0750 chrony chrony -"
      "d /var/log/chrony 0750 chrony chrony -"
    ];

    # Enable the chrony service
    services.chrony = {
      enable = true;

      # Custom configuration for chrony
      extraConfig = ''
        #[-] Define directory locations [-]#
        driftfile   /var/lib/chrony/chrony.drift
        keyfile     /etc/chrony/chrony.keys
        logdir      /var/log/chrony
        ntsdumpdir  /var/lib/chrony

        #[-] Collect statistics for calibration [-]#
        log tracking measurements statistics
        log rawmeasurements measurements statistics tracking refclocks tempcomp

        #[-] General Chrony Configuration [-]#
        # Note: lock_all was removed as it can cause stability issues on some hardware
        # Set maximum skew threshold for sources
        maxupdateskew 100.0
        # Set amount of ram allocated to logging client state 
        clientloglimit 10000000
        # Hardware clock sync handled by NixOS chrony module
        # rtcsync - removed to avoid conflicts with rtcfile/rtcautotrim
        # Adjust clock if time differs by +/- 0.1 seconds
        makestep 0.1 3
        # Rate limit clients to ensure low latency
        ratelimit interval 1 burst 16 leak 2

        #[-] Allow all client connections from internal nets [-]#
        ${lib.concatMapStrings (net: "allow ${net}\n") allowedNetworks}
        # Network QoS Code
        dscp 48

        ${lib.optionalString enableGPS ''
          #[-] Configure stratum 1 sources [-]#
          # GPS Serial data reference (NMEA data shared by GPSD via SHM)
          refclock SHM 0 refid NMEA offset 0.0339 precision 1e-3 poll 3 noselect
          # PPS reference with improved parameters for stability
          refclock PPS /dev/pps0 refid PPS lock NMEA maxlockage 2 poll 4 precision 1e-7 prefer
        ''}

        #[-] Public servers to set as initial time source [-]#
        ${lib.concatMapStrings (server: "server ${server} iburst\n") publicServers}
      '';
    };

    # Add chrony to the systemPackages
    environment.systemPackages = with pkgs; [
      chrony
    ];

    # Configure firewall to allow NTP traffic if the NFT-based firewall is enabled
    modules.network.firewall.rules = lib.mkIf (config.modules.network.firewall.enable or false) {
      ntp = {
        from = map (net: "ntp-${net}") allowedNetworks;
        to = [ "fw" ];
        allowedUDPPorts = [ 123 ]; # NTP uses UDP port 123
      };
    };

    # Define NTP zones for each allowed network
    modules.network.firewall.zones = lib.mkIf (config.modules.network.firewall.enable or false) 
      (lib.listToAttrs (map (net: {
        name = "ntp-${net}";
        value = {
          ipv4Addresses = [ net ];
        };
      }) allowedNetworks));

    # Configure persistence for chrony data
    impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
      "/var/lib/chrony" # For drift file and time measurements
      "/var/log/chrony" # For log files
      # Not persisting /etc/chrony since its config is managed by NixOS
    ];
  };
}