# modules/network/dns.nix
#
# DNS configuration and resolvers
{ config, lib, ... }:

{
  #
  # System-wide DNS resolver configuration
  #
  networking = {
    # DNS hostname resolution settings
    resolvconf.enable = lib.mkDefault true;

    # DNSSec validation
    dnssec = {
      enable = lib.mkDefault true;
      # Use NixOS defaults for validation and negative trust anchors
    };
  };

  # If NetworkManager is enabled, configure its DNS settings as well
  networking.networkmanager.dns = lib.mkIf config.networking.networkmanager.enable "systemd-resolved";

  # Enable systemd-resolved for DNS resolution management
  services.resolved = {
    enable = true;

    # Configure DNS over TLS
    dnssec = "allow-downgrade";
    llmnr = "false";

    # Additional DNS resolver options
    extraConfig = ''
      # Cache TTL settings
      Cache=yes
      CacheFromLocalhost=no

      # DNS over TLS settings
      DNSOverTLS=opportunistic
    '';
  };
}
