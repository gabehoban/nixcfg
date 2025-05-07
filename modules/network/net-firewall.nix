# modules/network/net-firewall.nix
#
# Enhanced NixOS firewall configuration module
# Using interface-agnostic approach for better flexibility
{
  config,
  lib,
  primaryInterface ? "enp1s0", # Use module argument with default
  ...
}:

let
  # Define trusted networks
  homeNetwork = "10.32.0.0/16"; # Home network range
  loopback = "127.0.0.1/8";

  # SSH rate limiting is enabled by default
  enableSSHRateLimit = true;
in
{
  networking.firewall = {
    # Use mkDefault to allow host-specific configurations to override
    enable = lib.mkDefault true;
    allowPing = lib.mkDefault true;

    # Trust interfaces dynamically based on the primary interface
    # This makes the config more portable across different hardware
    trustedInterfaces = [ primaryInterface "lo" ];

    # Configure ICMPv6 rules for proper IPv6 operation
    extraInputRules = ''
      # Allow all needed ICMPv4 types
      ip protocol icmp icmp type {
        echo-request, echo-reply,
        destination-unreachable, time-exceeded,
        parameter-problem
      } accept

      # Allow all ICMPv6 types required for proper IPv6 operation
      ip6 nexthdr icmpv6 icmpv6 type {
        destination-unreachable, packet-too-big, time-exceeded,
        parameter-problem, echo-request, echo-reply,
        nd-router-solicit, nd-router-advert, nd-neighbor-solicit,
        nd-neighbor-advert, ind-neighbor-solicit, ind-neighbor-advert,
        mld-listener-query, mld-listener-report, mld-listener-done,
        router-renumbering
      } accept

      # Allow all traffic from trusted networks (home network and loopback)
      ip saddr { ${homeNetwork}, ${loopback} } accept
      ip6 saddr ::1 accept

      ${lib.optionalString enableSSHRateLimit ''
      # Rate limit SSH connections to prevent brute force attacks
      tcp dport 22 ct state new limit rate 6/minute accept
      ''}
    '';

    # Common default ports that should be open
    allowedTCPPorts = lib.mkDefault [ 22 ]; # SSH

    # Connection tracking modules without autoload (removed in kernel 6.0+)
    connectionTrackingModules = [ "ftp" "tftp" "irc" "sane" "pptp" "snmp" ];
  };
}
