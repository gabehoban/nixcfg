# modules/network/firewall.nix
#
# NFT-based firewall implementation with zone-based architecture
# This is a flattened module that configures a comprehensive firewall solution
# using nftables as a more modern replacement for iptables.
#
# Configuration can be customized in the host configuration:
#   modules.network.firewall = {
#     openPorts = [ 80 443 ];
#     rules.my-rule = { ... };
#   };
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Access existing values if they exist, or use defaults
  cfg = config.modules.network.firewall or {
    enable = true;
    openPorts = [];
    openTcpPorts = [];
    openUdpPorts = [];
    allowPing = true;
    limitPingRate = true;
    pingRateLimit = "5/second";
    logRefusedConnections = false;
    defaultPolicy = "drop";
    enableAntiSpoofing = true;
    extraCommands = "";
    rules = {};
    zones = {};
  };
in
{
  # Define the options interface for host-level customization
  options.modules.network.firewall = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the NFT-based firewall.";
    };

    openPorts = mkOption {
      type = types.listOf types.port;
      default = [ ];
      description = "List of TCP/UDP ports to open.";
    };

    openTcpPorts = mkOption {
      type = types.listOf types.port;
      default = [ ];
      description = "List of TCP ports to open.";
    };

    openUdpPorts = mkOption {
      type = types.listOf types.port;
      default = [ ];
      description = "List of UDP ports to open.";
    };

    allowPing = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to allow ICMP echo requests (ping).";
    };

    limitPingRate = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to rate limit ICMP echo requests to prevent ping flood attacks.";
    };

    pingRateLimit = mkOption {
      type = types.str;
      default = "5/second";
      description = "Rate limit for ICMP echo requests if limitPingRate is enabled.";
    };

    logRefusedConnections = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to log refused connections.";
    };
    
    defaultPolicy = mkOption {
      type = types.enum [ "accept" "drop" "reject" ];
      default = "drop";
      description = "Default policy for traffic not matching any rules.";
    };
    
    enableAntiSpoofing = mkOption {
      type = types.bool;
      default = true;
      description = "Enable anti-spoofing protection.";
    };
    
    extraCommands = mkOption {
      type = types.lines;
      default = "";
      description = "Extra commands to run when setting up the firewall.";
    };

    rules = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            from = mkOption {
              type = with types; either (enum [ "all" ]) (listOf str);
              default = "all";
              description = "Source zone(s) for this rule.";
            };

            to = mkOption {
              type = with types; either (enum [ "all" ]) (listOf str);
              default = [ "fw" ];
              description = "Destination zone(s) for this rule.";
            };

            allowedTCPPorts = mkOption {
              type = types.listOf types.port;
              default = [ ];
              description = "Allowed TCP ports for this rule.";
            };

            allowedUDPPorts = mkOption {
              type = types.listOf types.port;
              default = [ ];
              description = "Allowed UDP ports for this rule.";
            };

            verdict = mkOption {
              type =
                with types;
                nullOr (enum [
                  "accept"
                  "drop"
                  "reject"
                ]);
              default = null;
              description = "Verdict for matched traffic (if not using port rules).";
            };

            extraLines = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Extra nftables rules to add.";
            };
          };
        }
      );
      default = { };
      description = "Custom firewall rules.";
    };

    zones = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            interfaces = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Network interfaces belonging to this zone.";
            };

            ipv4Addresses = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "IPv4 addresses/subnets belonging to this zone.";
            };

            ipv6Addresses = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "IPv6 addresses/subnets belonging to this zone.";
            };

            parent = mkOption {
              type = with types; nullOr str;
              default = null;
              description = "Parent zone name, if this is a subzone.";
            };
          };
        }
      );
      default = { };
      description = "Network zones definition.";
    };
  };

  # Direct implementation
  config = {
    # Disable NixOS default firewall in favor of nixos-nftables-firewall
    networking.firewall.enable = lib.mkForce false;
    
    # Enable anti-spoofing protection if configured
    networking.firewall.checkReversePath = cfg.enableAntiSpoofing;

    # Ensure nftables modules are loaded early
    boot.kernelModules = [
      "nf_tables"
      "nft_counter"
      "nft_log"
      "nft_limit"
      "nft_nat"
      "nft_reject"
    ];

    # Add boot parameters to prevent loading of iptables
    boot.kernelParams = [ "iptables.modprobe=0" ];

    # Configure nftables firewall
    networking.nftables.firewall = {
      enable = cfg.enable;

      # Create merged rules: default rules plus user-defined rules
      rules = {
        # Default ports rule - open ports specified via our module options
        default-ports = {
          from = "all";
          to = [ "fw" ];
          allowedTCPPorts =
            cfg.openTcpPorts ++ (if builtins.isList cfg.openPorts then cfg.openPorts else [ ]);
          allowedUDPPorts =
            cfg.openUdpPorts ++ (if builtins.isList cfg.openPorts then cfg.openPorts else [ ]);
          ignoreEmptyRule = true; # Allow this rule to be empty if no ports are specified
        };

        # Default SSH rule - always allow SSH access
        ssh = {
          from = "all";
          to = [ "fw" ];
          allowedTCPPorts = [ 22 ];
        };

        # ICMP ping rule (controlled by allowPing option)
        ping = lib.mkIf cfg.allowPing {
          from = "all";
          to = [ "fw" ];
          extraLines = if cfg.limitPingRate then [
            "ip6 nexthdr icmpv6 icmpv6 type { echo-request } limit rate ${cfg.pingRateLimit} accept"
            "ip protocol icmp icmp type { echo-request } limit rate ${cfg.pingRateLimit} accept"
          ] else [
            "ip6 nexthdr icmpv6 icmpv6 type { echo-request } accept"
            "ip protocol icmp icmp type { echo-request } accept"
          ];
        };

        # Log dropped packets rule (controlled by logRefusedConnections option)
        log-dropped = lib.mkIf cfg.logRefusedConnections {
          from = "all";
          to = "all";
          ruleType = "policy";
          extraLines = [
            "counter log prefix \"dropped: \" drop"
          ];
        };
      } // cfg.rules; # Merge with user-defined rules

      # Add all user-defined zones
      zones = cfg.zones;

      # Enable common snippets for basic functionality but
      # disable the ICMP and drop snippets as we handle them ourselves
      snippets = {
        nnf-common.enable = true;
        nnf-icmp.enable = false; # We handle ICMP separately based on our allowPing option
        nnf-drop.enable = false; # We handle dropping with logging based on our logRefusedConnections option
      };
    };

    # Ensure nftables package is installed
    environment.systemPackages = [ pkgs.nftables ];
  };
}