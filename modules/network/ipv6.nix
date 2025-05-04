# modules/network/ipv6.nix
#
# IPv6 configuration for NixOS systems
# Ensures full IPv6 support with SLAAC, DHCPv6, and privacy extensions
{ lib, ... }:
{
  networking = {
    # Enable IPv6 globally
    enableIPv6 = true;

    # IPv6 configuration options
    dhcpcd = {
      # Enable DHCPv6 and SLAAC
      IPv6rs = lib.mkDefault true;

      # Wait for both IPv4 and IPv6 before considering network online
      wait = lib.mkDefault "both";
    };

    # Enable IPv6 privacy extensions (RFC 4941)
    # This creates temporary addresses for outbound connections
    tempAddresses = lib.mkDefault "enabled";

    # Enable IPv6 forwarding if needed for container/VM networking
    # This is disabled by default for security
    # enableIPv6Forwarding = false;
  };

  # IPv6 firewall configuration
  networking.firewall = {
    # Allow IPv6 neighbor discovery and router advertisements
    allowPing = true;

    # Enable stateful IPv6 firewall
    enableIPv6 = true;

    # Allow ICMPv6 neighbor discovery
    extraInputRules = ''
      ip6 nexthdr icmpv6 icmpv6 type { nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert } accept
    '';
  };

  # Ensure sysctl settings for IPv6 are properly configured
  boot.kernel.sysctl = {
    # Accept Router Advertisements
    "net.ipv6.conf.all.accept_ra" = 2; # Accept RA even when forwarding

    # Enable IPv6 privacy extensions
    "net.ipv6.conf.all.use_tempaddr" = 2;
    "net.ipv6.conf.default.use_tempaddr" = 2;

    # Allow IPv6 default route
    "net.ipv6.conf.all.accept_ra_defrtr" = 1;
    "net.ipv6.conf.default.accept_ra_defrtr" = 1;

    # Allow prefix information from RAs
    "net.ipv6.conf.all.accept_ra_pinfo" = 1;
    "net.ipv6.conf.default.accept_ra_pinfo" = 1;

    # Prefer IPv6 over IPv4 when both are available
    "net.ipv6.conf.all.autoconf" = 1;
    "net.ipv6.conf.default.autoconf" = 1;
  };
}
