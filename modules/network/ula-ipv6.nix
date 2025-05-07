# modules/network/ula-ipv6.nix
#
# Module to add ULA IPv6 addresses to interfaces while maintaining SLAAC
# This uses the official NetworkManager dispatcher script mechanism in NixOS
{ config, lib, pkgs, ... }:

with lib;

{
  options = {
    networking.ula = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable ULA IPv6 addresses alongside SLAAC.";
      };

      address = mkOption {
        type = types.str;
        default = "";
        example = "fd00:5500:ae00:40::41";
        description = "The ULA IPv6 address to assign to the interface.";
      };

      interface = mkOption {
        type = types.str;
        default = "";
        example = "enp1s0";
        description = "The network interface to assign the ULA address to.";
      };

      prefixLength = mkOption {
        type = types.int;
        default = 64;
        description = "The prefix length for the ULA address.";
      };
    };
  };

  config = mkIf config.networking.ula.enable {
    # Add NetworkManager dispatcher script to add ULA IPv6 address when interface comes up
    networking.networkmanager.dispatcherScripts = [
      {
        source = pkgs.writeText "10-add-ula-ipv6" ''
          #!/bin/sh

          INTERFACE="$1"
          ACTION="$2"

          # Only run for our specified interface when it comes up
          if [ "$INTERFACE" = "${config.networking.ula.interface}" ] && [ "$ACTION" = "up" ]; then
            # Add the ULA IPv6 address
            ip -6 addr add ${config.networking.ula.address}/${toString config.networking.ula.prefixLength} dev $INTERFACE
            echo "Added ULA IPv6 address ${config.networking.ula.address}/${toString config.networking.ula.prefixLength} to $INTERFACE"
          fi
        '';
        type = "basic";
      }
    ];
  };
}
