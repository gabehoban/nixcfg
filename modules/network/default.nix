# modules/network/default.nix
#
# Combined networking module - imports all networking configurations
# Using NetworkManager for improved flexibility and better desktop integration
{
  lib,
  config,
  pkgs,
  ...
}:

let
  # Import the network utility library
  networkLib = import ./network.lib.nix { inherit lib; };

  # Define our local network configuration
  localDomain = "labrats.cc";
  localHosts = {
    # IPv4 host entries
    "10.32.40.41" = [
      "nuc-luna"
      "nuc-luna.${localDomain}"
    ];
    "10.32.40.42" = [
      "nuc-titan"
      "nuc-titan.${localDomain}"
    ];
    "10.32.40.43" = [
      "nuc-juno"
      "nuc-juno.${localDomain}"
    ];
    "10.32.40.45" = [
      "minio-vip"
      "minio-vip.${localDomain}"
      "minio"
    ];

    # IPv6 ULA host entries
    "fd00:5500:ae00:40::41" = [
      "nuc-luna-v6"
      "nuc-luna-v6.${localDomain}"
    ];
    "fd00:5500:ae00:40::42" = [
      "nuc-titan-v6"
      "nuc-titan-v6.${localDomain}"
    ];
    "fd00:5500:ae00:40::43" = [
      "nuc-juno-v6"
      "nuc-juno-v6.${localDomain}"
    ];
  };

  # Define NTP servers to use
  chronyServers = [
    "0.nixos.pool.ntp.org"
    "1.nixos.pool.ntp.org"
    "2.nixos.pool.ntp.org"
    "3.nixos.pool.ntp.org"
    "time.cloudflare.com"
  ];
in
{
  imports = [
    # Standard NixOS firewall
    ./net-firewall.nix

    # Use the shared networking for domain and host entries
    (networkLib.makeSharedNetworking {
      domainName = localDomain;
      localHosts = localHosts;
    })
  ];

  # Make module arguments available to all modules
  # Note: We no longer export networkLib as a module argument to avoid infinite recursion
  # Host configs now import the library directly instead
  #
  # primaryInterface is now set by makeNetworkInterface function for each host

  # Basic network settings that apply to all hosts
  networking = {
    # Enable NetworkManager for network configuration
    networkmanager = {
      enable = true;

      # Global NetworkManager settings
      settings = {
        connection = {
          # Use stable-privacy for IPv6 address generation
          "ipv6.addr-gen-mode" = "stable-privacy";
        };
      };

      # Use NetworkManager for DNS resolution
      dns = lib.mkForce "default";

      # NetworkManager profiles are now configured per-interface via makeNetworkInterface
      # No default fallback profile is needed as each host configures its specific interfaces
      ensureProfiles = {
        profiles = { };
      };
    };

    # Disable systemd-networkd as we're using NetworkManager
    useNetworkd = false;

    # Define interfaces to be ignored by NetworkManager
    # This helps avoid any automatically-created connections for specific interfaces
    networkmanager.unmanaged = [ ]; # Add any interfaces to be managed by other tools here

    # Disable dhcpcd as we're using NetworkManager
    dhcpcd.enable = false;

    # Enable global DHCP for interfaces not managed by NetworkManager
    # Use mkForce to override default settings from NetworkManager
    useDHCP = lib.mkForce true;

    # Don't set fallback nameservers - use only router-provided DNS
    nameservers = [ ];

    # Enable IPv6 globally
    enableIPv6 = lib.mkForce true;

    # IPv6 privacy extensions configured per-host via kernel parameters
  };

  # Configure all network-related services
  services = {
    # Local network service discovery (Avahi/mDNS)
    avahi = {
      enable = true;

      # Enable .local hostname resolution without editing /etc/hosts
      nssmdns4 = true;

      # Enable both IPv4 and IPv6 to ensure all local devices are discovered
      ipv4 = true;
      ipv6 = true;

      # Advertise this system on the local network for discovery
      publish = {
        enable = true;
        addresses = true; # Share IP addresses
        domain = true; # Share domain information
        workstation = true; # Identify as a workstation
      };

      # Allow connections through firewall for mDNS (UDP port 5353)
      openFirewall = true;
    };

    # Configure DNS resolution to work with NetworkManager
    resolved = {
      enable = true;
      dnssec = "allow-downgrade"; # Better security with fallback
      llmnr = "true"; # Enable Link-Local Multicast Name Resolution for local discovery
      fallbackDns = []; # Explicitly disable fallback DNS servers
    };

    # Standardized time synchronization with chrony
    chrony = {
      # Always enable chrony on all hosts
      enable = lib.mkForce true;

      # Use standard NTP servers from the NixOS pool
      servers = lib.mkForce chronyServers;

      # Disable RTC trimming to avoid conflicts with rtcsync
      enableRTCTrimming = lib.mkForce false;

      # Standard chrony configuration used across all hosts
      extraConfig = lib.mkForce ''
        # Allow NTP client access from localhost only
        allow 127.0.0.1
        allow ::1

        # Allow local network to use this server as an NTP source
        # Restricted to prevent time modification
        allow 10.32.40.0/24

        # Record the rate at which the system clock gains/losses time
        driftfile /var/lib/chrony/drift

        # Allow the system clock to be stepped during initial sync
        makestep 1.0 3

        # Enable kernel synchronization
        rtcsync

        # Enable hardware timestamping if the NIC supports it
        hwtimestamp *

        # Increase logging during initial synchronization
        logchange 0.5

        # Use a wider selection of NTP servers with appropriate weighting
        minsources 3

        # Lock the memory to prevent timing data from being paged
        lock_all
      '';
    };

    # Explicitly disable timesyncd when using chrony
    timesyncd.enable = lib.mkForce false;
  };

  # Direct IPv6 sysctl parameters for NetworkManager operation
  boot.kernel.sysctl = {
    # Router Advertisement settings - set to 2 for NetworkManager control
    # Value 2 means accept RAs even if forwarding is enabled
    "net.ipv6.conf.all.accept_ra" = lib.mkForce 2;
    "net.ipv6.conf.default.accept_ra" = lib.mkForce 2;

    # These settings ensure specific interfaces also accept RAs
    # Without these, the global settings might not propagate properly
    "net.ipv6.conf.*.accept_ra" = lib.mkForce 2;
    "net.ipv6.conf.lo.accept_ra" = lib.mkForce 0; # No need for RAs on loopback

    # Other RA settings
    "net.ipv6.conf.all.accept_ra_defrtr" = lib.mkForce 1;
    "net.ipv6.conf.default.accept_ra_defrtr" = lib.mkForce 1;
    "net.ipv6.conf.all.accept_ra_pinfo" = lib.mkForce 1;
    "net.ipv6.conf.default.accept_ra_pinfo" = lib.mkForce 1;

    # Address configuration settings
    "net.ipv6.conf.all.autoconf" = lib.mkForce 1;
    "net.ipv6.conf.default.autoconf" = lib.mkForce 1;
    "net.ipv6.conf.*.autoconf" = lib.mkForce 1;
    "net.ipv6.conf.lo.autoconf" = lib.mkForce 0; # Disable for loopback

    # Privacy extension settings - conditional based on machine role
    # 0 = disabled (for infrastructure hosts)
    # 2 = enabled + preferred (for workstations)
    # This default is conservative for infrastructure hosts
    "net.ipv6.conf.all.use_tempaddr" = lib.mkForce 0;
    "net.ipv6.conf.default.use_tempaddr" = lib.mkForce 0;

    # Routing settings - IPv6 forwarding disabled by default
    "net.ipv6.conf.all.forwarding" = lib.mkForce 0;
  };

  # Custom systemd service to remove auto-created NetworkManager connections
  # Modified to keep our interface-specific profiles and essential system connections
  systemd.services.nm-remove-auto-connections = {
    description = "Remove auto-created NetworkManager connections while preserving essential connections";
    wantedBy = [ "NetworkManager.service" ];
    # Run after NetworkManager but with a delay to ensure all profiles are created
    after = [ "NetworkManager.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Wait for NixOS profiles to be created first
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
      # Simple script that preserves only:
      # 1. Profiles that start with "NixOS" (old naming scheme)
      # 2. Profiles that start with "nm-" (new interface-based naming scheme)
      # 3. Loopback connections
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '
          # Store the UUIDs of connections to keep - NixOS profiles, nm-* profiles, and loopback
          KEEP_UUIDS=$(${pkgs.networkmanager}/bin/nmcli -t -f NAME,UUID connection show | ${pkgs.gnugrep}/bin/grep -E "^(NixOS|nm-|lo:)" | ${pkgs.coreutils}/bin/cut -d: -f2)

          # Get all connection UUIDs
          ALL_UUIDS=$(${pkgs.networkmanager}/bin/nmcli -t -f UUID connection show)

          # Loop through all connections and delete those not in the keep list
          for uuid in $ALL_UUIDS; do
            if ! echo "$KEEP_UUIDS" | ${pkgs.gnugrep}/bin/grep -q "$uuid"; then
              echo "Removing connection with UUID: $uuid"
              ${pkgs.networkmanager}/bin/nmcli connection delete "$uuid"
            fi
          done
        '
      '';
    };
  };

  # NOTE: For users to be able to manage network connections,
  # they should be added to the "networkmanager" group in the user configuration:
  #
  # users.users.<username>.extraGroups = [ "networkmanager" ];
  #
  # Per-host IPv6 privacy settings should be defined in the host-specific
  # configuration file. For workstation hosts:
  #
  # boot.kernel.sysctl = {
  #   "net.ipv6.conf.all.use_tempaddr" = lib.mkForce 2;
  #   "net.ipv6.conf.default.use_tempaddr" = lib.mkForce 2;
  # };
  #
  # Alternatively, you can set the ipv6Privacy parameter when using makeNetworkInterface:
  #
  # imports = [
  #   (networkLib.makeNetworkInterface {
  #     interfaceName = "eno1";
  #     ipv6Privacy = true;  # For workstations
  #   })
  # ];
}
