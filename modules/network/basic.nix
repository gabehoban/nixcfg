# modules/network/basic.nix
#
# Basic network configuration
# Configures NetworkManager, firewall, and mDNS discovery
{ lib, ... }:
{
  # Network management settings
  networking = {
    # Use NetworkManager for handling network connections
    networkmanager.enable = true;

    # Default firewall setting (can be overridden by host configurations)
    firewall.enable = lib.mkDefault false;
  };

  # Service discovery configuration - mDNS for .local hostnames
  services.avahi = {
    # Enable mDNS/DNS-SD service discovery (Avahi)
    enable = true;

    # Enable multicast DNS NSS lookup for .local domains
    nssmdns4 = true;

    # Configure IP protocol support
    ipv4 = true;
    ipv6 = true;

    # Publish this host's information on the network
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };

    # Automatically open necessary ports in the firewall
    openFirewall = true;
  };
}
